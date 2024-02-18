---
layout: post
title:  "Learning 'vcpkg' - an introductiin"
date:   2024-02-19 20:20:48 +0100
categories: cpp package-manager
---

# VCPKG

When developing anything, I use package managers to fetch whatever 3.party when I need some new package in my project. I do this for ease of integrating it into my project, but also for tracking dependencies and version (recursively if the package has own dependencies), and for developer ergonomics - new developers run a command to restore the dependencies of the project after a clone.

Learning C++, however, there isn't a clear one-shoe-fits-all package-manager, and the learning curve is steep. So I'll just note down (hopefully in a meaningful manner) what I've learned to use in my Windows environment with `msvc`.

### What is it, though?
[vcpkg](https://vcpkg.io/en/) is a Microsoft developed package manager for c++, with [decent documentation](https://learn.microsoft.com/en-us/vcpkg/). It can build binaries from sources on the fly to enable better cross-compiler features.
It integrates easily with build-tools such as MSBuild and CMake, and CLI environments such as PS and bash, as well as built pipeline automation tools such as GitHub.

It runs in two modes; classic and manifest - where classic is more like a machine environment package manager, and manifest a dependency package manager for projects.

It works in much the same ways as nugets, as it fetches from the vcpkg package repository, and allows you to publish your own packages into the feed.

It supports cross-compiling; e.g. one can develop on Windows and build binaries that run on arduino or unix systems.

### Concepts
- ##### Ports
Defines metadata about a package, and how to aquire, build (if necessary) and install the package.
- ##### Triplets
Triplet is a standard term used in cross-compiling as a way to completely capture the target environment (CPU, OS, compiler, runtime, etc.) in a single, convenient name. E.g. `x86_64-unknown-linux-gnu` and `x86_64-w64-mingw32`.

We differentiate on host-triplets and target-triplets, when cross-compiling.
- ##### Host
The system on which vcpkg is being used to manage packages and build libraries. 


## Manifest Style
Initializing vcpkg in a project using vcpkg manifests, we can use the CLI:
> vcpkg new (--application | --name <port-name> --version <port-version>)
If you are only consuming packages, and not packing your application to push on a vcpkg repository, we can use the --application flag.

Adding a new port to your project manifest is as easy as:
> vcpkg add port amqpcpp
This adds the port to the dependency in vcpkg.json
> cat .\vcpkg.json
{
  "dependencies": [
    "amqpcpp"
  ]
}

Now depending on your build toolchain, you need to integrate the vcpkg with it.
I use msbuild, and therefore ran the following to integrate vcpkg user-wide with the msbuild system:
>vcpkg integrate install

However, the project is by default set to disable vcpkg, so we need to add that csproj porperty settings also (or pass the flag in the msbuild )
> msbuild /p:VcpkgEnableManifest=true

After the setup is done, and i run MSBuild for the first time, it will aquire, build and install the new amqpcpp package.

>msbuild
... 
VcpkgTripletSelection:
  Using triplet "x64-windows" from "C:\dev\.cpp\WindowsDesktopTutorial\vcpkg_installed\x64-windows\x64-windows\"
  Using normalized configuration "Debug"
VcpkgInstallManifestDependencies:
  Installing vcpkg dependencies to C:\dev\.cpp\WindowsDesktopTutorial\vcpkg_installed\x64-windows\
  Creating directory "C:\dev\.cpp\WindowsDesktopTutorial\vcpkg_installed\x64-windows\".
  "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\vcpkg\vcpkg.exe" install  --x-wait-for-lock --triplet "x64-windows"
   --vcpkg-root "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\vcpkg\\" "--x-manifest-root=C:\dev\.cpp\WindowsDeskto
  pTutorial\\" "--x-install-root=C:\dev\.cpp\WindowsDesktopTutorial\vcpkg_installed\x64-windows\\"
  "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\vcpkg\vcpkg.exe" install  --x-wait-for-lock --triplet "x64-windows"
   --vcpkg-root "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\vcpkg\\" "--x-manifest-root=C:\dev\.cpp\WindowsDeskto
  pTutorial\\" "--x-install-root=C:\dev\.cpp\WindowsDesktopTutorial\vcpkg_installed\x64-windows\\"
  Fetching registry information from https://github.com/microsoft/vcpkg (HEAD)...
...