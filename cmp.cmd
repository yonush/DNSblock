@echo off
cd /D %~dp0
nim c --cpu:amd64 --verbosity:0 -d:release -d:ssl -d:strip --opt:size DNSblock.nim %1 %2 %3
::nim c --cc:tcc --cpu:amd64 --verbosity:0 -d:release -d:ssl -d:strip --opt:size --tlsEmulation:on %1
