---
layout: post
title: Preparing migration from ASP.NET Framework 4.8 to modern .NET 
---


## Building Configurations
Framework uses XML-based Web.config (project scoped) & Machine.config (environment scoped) files to configure the web-server & application it is hosting.

The Web.config will specify the settings for it's containing directory and all the children below it ([QUESTION:] unless setting is overriden in a child web.config?)



#### *References*
- [.NET Framework Configuration Documentation](https://learn.microsoft.com/en-us/previous-versions/dotnet/netframework-1.1/kza1yk3a(v=vs.71))

- [IIS: Build an ASP.NET Website on IIS](https://learn.microsoft.com/en-us/iis/application-frameworks/scenario-build-an-aspnet-website-on-iis/overview-build-an-asp-net-website-on-iis)

- [Windows Server 2012: Web Server (IIS) Overview](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/hh831725(v=ws.11))
    - [Configuration Editor](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh831362(v=ws.11)?redirectedfrom=MSDN)

- [Configuration Builders](https://learn.microsoft.com/en-us/aspnet/config-builder)

## Logging?