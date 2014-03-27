nnl-builder
===========

NNL Builder, for building NoNameLinux

**What is 'NoNameLinux'?**

NoNameLinux *will be* a yet another small Linux distribution, with following features.

1. *It does not express any brands.* You can set original operating system name during the installation.
2. *It is based on musl, but aims general distribution.* Musl is an emerging libc for Linux, and is used mainly for embedded systems. But, unlike other Linux distribution using musl, it does not aim embedded use. However, it uses some softwares in embedded world as well.
3. *Is prefers to support abondoned machines.* Currently binaries are optimized for i486 CPUs. On systems with i686 CPUs or over, you can use general distribution like fedora or ubuntu. It aims older machines that cannot run current general distributions.
4. *It is an independent Linux distribution.* It does not resemble a specified single distribution. Currently version of softwares resembles ubuntu LTS, package manager is opkg, packaging scheme resembles rpm-like distribution, build system resembles rpm-fasioned slackware, and the installer is based on shell script like slackware.
5. *It has active security updates.* Like general distribution, in other words, unlike distributions for old machines, it provides security updates.


**What is 'NNL Builder'?**

NNL Builder *will be* a couple of scripts to build NoNameLinux installation image itself.


**Why NoNameLinux is developed?**

I was a Linux distribution developer for 15 years, but, recently I had not gotten any Linux distribution development jobs. All jobs are gone to foreign engineers. But anyway I need to continue it because I like it. NNL is a little piece of something for my peaceful mind.
