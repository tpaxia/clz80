@echo off
setlocal

pushd Basic && call Build %* || exit /b & popd
