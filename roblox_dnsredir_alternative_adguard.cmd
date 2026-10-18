@ECHO OFF
PUSHD "%~dp0"
set _arch=x86
IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set _arch=x86_64)
IF DEFINED PROCESSOR_ARCHITEW6432 (set _arch=x86_64)
PUSHD "%_arch%"

start "" goodbyedpi.exe -5 --set-ttl 5 --dns-addr 94.140.14.14 --dns-port 53 --dnsv6-addr 2a10:50c0::ad1:ff --dnsv6-port 53

POPD
POPD