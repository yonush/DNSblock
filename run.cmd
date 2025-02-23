@echo off
cd /D %~dp0
nim r --cc:tcc --cpu:amd64 --verbosity:0 -d:release -d:ssl -d:strip --opt:size DNSblock.nim