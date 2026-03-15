---
layout: post
title:  "Designing protocols over USB with bulk transfers"
date:   2026-03-14 18:00:00 +0100
categories: usb rust
---

A device that exposes a vendor-defined interface — no standard class like CDC or HID, just raw bulk transfer endpoints, gives you a lot of flexibility, but it also means you start with a blank slate: no framing, no sequencing, no error codes. You have to design all of that yourself.

This post is about protocol design and host-side Rust implementation using [`rusb`](https://crates.io/crates/rusb).

## A bit of USB background

USB has several transfer types: control, isochronous, interrupt, and bulk. For a device that needs to move chunks of data reliably without real-time constraints, bulk is usually the right choice:

- **Reliable** — the host/device hardware retries on errors, you won't silently lose bytes
- **No size limit** — a single transfer can be split across as many packets as needed
- **No reserved bandwidth** — unlike isochronous and interrupts, bulk transfers are scheduled opportunistically in whatever bandwith is available.
<!-- 
interrupt endpoints declare a polling interval (`bInterval`) that reserves a slot in every USB frame on a fixed schedule, whether or not the device has data to send. Bulk transfers are scheduled opportunistically in whatever bandwidth remains; no bus time is reserved upfront. The host still submits read requests to receive data, but there is no guaranteed periodic slot consuming bus bandwidth
-->

If you've worked with TCP sockets, bulk transfers will feel familiar in a way: the transport guarantees delivery and ordering, so that will not be a concern if you wonder if you wonder if you should implement retries or reordering at the application level.
<!-- Perhaps elaborate on this, and the remaining similarities with TCP/IP model (or OSI model) in a separate post? -->

### Byte stream message framing

A difference is that TCP, despite segmenting data internally, exposes a continuous byte stream to the application. <!-- — a `read()` call might return bytes from half a segment, a full one, or several merged together-->
The segment boundaries are invisible. Bulk transfers are discrete at the hardware level, which might seem like an advantage, but it doesn't help as much as you'd hope: the firmware might batch two logical messages into one transfer, or split a large response across several. The transfer boundaries don't correspond to your application messages either. Because neither TCP segments nor USB transfer boundaries map reliably to application messages, you end up treating both as a bidirectional byte pipe — and framing is still your problem.

A vendor interface with bulk IN and bulk OUT endpoints is exactly that: a bidirectional byte pipe. The device firmware and the host driver agree on nothing beyond "bytes go here, bytes come back there." The IN and OUT endpoints are completely independent. Nothing stops the host from writing to OUT and reading from IN at the same time — the hardware supports full duplex.

#### Suggestion for the application protocol

Since `rusb`'s `read_bulk` and `write_bulk` behave much like TCP's `read`/`write` — returning however many bytes happened to arrive — it can be worth wrapping the raw endpoints in a socket-like struct that buffers incoming bytes and exposes a `read_exact`-style interface. That way the framing logic lives in one place and the rest of your code works with complete messages rather than raw byte slices.

### Concurrency for unsolicited events

If you need the device to send unsolicited events while the host is also issuing commands, you'd need concurrency on the host side — a dedicated reader thread (or async task) continuously draining the IN endpoint, and a separate writer for outgoing commands. You'd also need a way to distinguish a response to a command you just sent from an unsolicited event the device pushed on its own. That usually means adding a message type field or a correlation ID to your protocol. Doable, but a significant step up in complexity.

## What even is a protocol?

A protocol is just a set of rules that two parties agree on for exchanging information — what to send, in what order, and what it means. HTTP is a protocol. Modbus is a protocol. The handshake you do when answering the phone ("hello?" / "hi, it's me") is a protocol.

A **message** is the basic unit of that exchange: a self-contained chunk of data with enough structure that the receiver can interpret it without additional context. A message usually has a defined beginning and end, some indication of what kind of information it carries, and the information itself.

HTTP is a good example because most developers have seen it up close. A request has a clearly defined structure: a start line with the method and path (`GET /index.html HTTP/1.1`), a set of headers, a blank line as separator, and an optional body. A response mirrors this: a status line, headers, blank line, body. Both parties know exactly what to expect and in what order. That shared knowledge *is* the protocol.

HTTP also solves the framing problem explicitly. The `Content-Length` header tells the receiver exactly how many bytes the body contains, so it knows when the message ends. Chunked transfer encoding is another approach — each chunk is prefixed with its size, and a zero-length chunk signals the end. Either way, the receiver never has to guess. This is the same problem you face with a raw byte stream over USB, and the same class of solution (a length field in the header) is what works there too.

With USB you get none of that out of the box. The hardware gives you endpoints and bytes. The protocol is entirely what you build on top — which is both the appeal and the challenge.

## Protocol design

### Framing

The first problem with a raw byte stream is knowing where one message ends and the next begins. Even though USB bulk transfers are discrete, nothing stops you from sending two logical messages in one transfer, or splitting a message across transfers.

I went with a **fixed-size header followed by a variable-length payload**. The header contains a length field, so the receiver always knows how many bytes to expect after it. Simple and predictable.

### Message structure

The wire format I settled on looks like this:

```text
[ magic (2 bytes) | version (1 byte) | command (1 byte) | length (2 bytes) | payload (N bytes) | checksum (2 bytes) ]
```

A few notes on each field:

**Magic** — a fixed two-byte constant (e.g. `0xAB 0xCD`) at the start of every message. If you ever receive bytes that don't start with the magic, you know you're out of sync. This saved me more than once during early firmware development when I had off-by-one bugs in the firmware's send path.

**Version** — add this from day one. You will change the protocol. When you do, you'll want the host and device to be able to negotiate or at least detect a mismatch gracefully rather than silently misbehaving.

**Command** — an opaque byte identifying the operation. I used a simple enum.

**Length** — number of bytes in the payload. Zero is valid for commands that carry no data.

**Checksum** — a CRC-16 over the header (excluding the checksum itself) and the payload. Not strictly necessary on USB since the transport already catches bit errors, but it catches bugs in your own serialization code.

### Request/response model

I kept it simple: every command sent to the device gets exactly one response back. The host sends, then blocks waiting for a reply. Fire-and-forget commands still get an acknowledgement response (a short "OK" or an error code). This makes the host-side code much easier to reason about — you never have to worry about matching responses to in-flight requests.

If you need higher throughput you can pipeline requests, but that adds complexity fast. I didn't need it.

### Error handling

USB has NAK at the transport level (the device telling the host "not ready, try again"), but that's handled transparently by the hardware. At the protocol level I defined a small set of error codes returned in the response:

- `OK` — success
- `UNKNOWN_COMMAND` — unrecognised command byte
- `INVALID_LENGTH` — payload length is out of range for this command
- `CHECKSUM_MISMATCH` — device computed a different checksum
- `BUSY` — device can't process the request right now

Having explicit error codes makes integration testing much easier.

## Host-side Rust with `rusb`

There are two main options for USB on the Rust host side: [`rusb`](https://crates.io/crates/rusb) (mature, synchronous, wraps libusb) and [`nusb`](https://crates.io/crates/nusb) (newer, async-native, pure Rust). I used `rusb` here because it's more established and the synchronous model maps naturally to the request/response protocol above.

```toml
[dependencies]
rusb = "0.9"
```

### Opening the device

```rust
use rusb::{Context, UsbContext};
use std::time::Duration;

const VID: u16 = 0x1234;
const PID: u16 = 0x5678;
const INTERFACE: u8 = 0;
const ENDPOINT_OUT: u8 = 0x01;
const ENDPOINT_IN: u8 = 0x81;
const TIMEOUT: Duration = Duration::from_millis(1000);

fn open_device() -> rusb::Result<rusb::DeviceHandle<rusb::Context>> {
    let context = Context::new()?;

    let handle = context
        .open_device_with_vid_pid(VID, PID)
        .ok_or(rusb::Error::NoDevice)?;

    // On Linux, the kernel may have claimed the interface
    handle.set_auto_detach_kernel_driver(true)?;
    handle.claim_interface(INTERFACE)?;

    Ok(handle)
}
```

`set_auto_detach_kernel_driver(true)` is a small quality-of-life thing — it detaches any kernel driver that has claimed the interface and re-attaches it on drop. Saves you the manual `detach_kernel_driver` call.

### Sending a command

I represent commands as plain structs and serialize them manually to a `Vec<u8>`. You can use [`zerocopy`](https://crates.io/crates/zerocopy) or [`bytemuck`](https://crates.io/crates/bytemuck) to make this less tedious, but for a small protocol I found explicit serialization easier to audit.

```rust
const MAGIC: [u8; 2] = [0xAB, 0xCD];
const PROTOCOL_VERSION: u8 = 1;

struct Message {
    command: u8,
    payload: Vec<u8>,
}

impl Message {
    fn serialize(&self) -> Vec<u8> {
        let mut buf = Vec::new();

        buf.extend_from_slice(&MAGIC);
        buf.push(PROTOCOL_VERSION);
        buf.push(self.command);
        buf.extend_from_slice(&(self.payload.len() as u16).to_le_bytes());
        buf.extend_from_slice(&self.payload);

        let checksum = crc16(&buf);
        buf.extend_from_slice(&checksum.to_le_bytes());

        buf
    }
}

fn send_command(
    handle: &rusb::DeviceHandle<rusb::Context>,
    command: u8,
    payload: &[u8],
) -> rusb::Result<Vec<u8>> {
    let msg = Message { command, payload: payload.to_vec() };
    let bytes = msg.serialize();

    handle.write_bulk(ENDPOINT_OUT, &bytes, TIMEOUT)?;

    let mut response = vec![0u8; 256];
    let n = handle.read_bulk(ENDPOINT_IN, &mut response, TIMEOUT)?;
    response.truncate(n);

    Ok(response)
}
```

The `write_bulk` / `read_bulk` pair is the core of the whole thing. The timeout argument is important — without it, a device that never responds will block the host forever.

## Lessons learned

**Always add a magic number.** I initially skipped it thinking I wouldn't need it. The second time the firmware sent garbage and the host tried to interpret it as a valid message I added the magic number and never looked back.

**Set a timeout and handle it.** A `TIMEOUT` error is normal — the device might be busy or resetting. Decide upfront whether you want to retry, return an error to the caller, or do something else. Having no policy means you'll handle it inconsistently across callsites.

**Test with malformed packets early.** Send messages with wrong magic, mismatched lengths, and bad checksums and verify the device rejects them cleanly. It's much easier to fix the firmware's parser before the protocol is baked in than after.

**Version the protocol from day one.** I added the version field as an afterthought on the second iteration. The firmware and host were briefly out of sync during the transition and it was annoying to debug. If the version field had been there from the start, the host would have detected the mismatch immediately.

**`nusb` is worth considering if you need async.** I chose `rusb` for simplicity, but if your application is already async (e.g. a Tokio service), `nusb` integrates more naturally and avoids blocking a thread on every transfer.

---

All in all, designing a protocol over USB bulk transfers is not that different from designing one over a serial port or a TCP socket. The USB layer handles reliability; you just need to handle framing, versioning, and errors at the application layer. Starting simple — magic, version, length, checksum — and only adding complexity when you actually need it worked well for me.
