@echo off
setlocal

call BuildROM %* || exit /b

if "%1" == "dist" (
  call Clean || exit /b
)