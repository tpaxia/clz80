@echo off
setlocal

if "%1" == "dist" goto :dist

::
:: Build [<platform> [<config> [<romsize> [<romname>]]]]
::

set TOOLS=../../Tools

set PATH=%TOOLS%\tasm32;%TOOLS%\zx;%PATH%

set TASMTABS=%TOOLS%\tasm32

set ZXBINDIR=%TOOLS%/cpm/bin/
set ZXLIBDIR=%TOOLS%/cpm/lib/
set ZXINCDIR=%TOOLS%/cpm/include/

::
:: This PowerShell script validates the build variables passed in.  If
:: necessary, the user is prmopted to pick the variables.  It then creates
:: an include file that is imbedded in the HBIOS assembly (build.inc).
:: It also creates a batch command file that sets environment variables
:: for use by the remainder of this batch file (build_env.cmd).
::

:: PowerShell -ExecutionPolicy Unrestricted .\Build.ps1 %* || exit /b

::
:: Below, we process the command file created by the PowerShell script.
:: This sets the environment variables: Platform, Config, ROMName,
:: ROMSize, & CPUType.
::

call build_env.cmd

::
:: Start of the actual build process for a given ROM.
::

echo Building %ROMSize%K ROM %ROMName% for Z%CPUType% CPU...


::
:: Build ROM Components
::

call :asm clz80basic || exit /b
 
::
:: Create final images (.rom, .upd, & .com)
:: The previously created bank images are concatenated as needed.
::
:: The .rom image is made up of 4 banks followed by the ROM Disk.  This
:: is for programming onto a ROM.
::
:: The .upd image is the same as above, but without the the ROM Disk.
:: This is so you can update just the code portion of your ROM without
:: updating the ROM Disk contents.
::
:: The .com image is a scaled down version of the ROM that you can run
:: as a standard application under an OS and it will replace your
:: HBIOS on the fly for testing purposes.
::

:: copy /b hbios_rom.bin + osimg.bin + osimg1.bin + osimg2.bin + ..\RomDsk\rom%ROMSize%_wbw.dat %ROMName%.rom || exit /b
:: copy /b hbios_rom.bin + osimg.bin + osimg1.bin + osimg2.bin %ROMName%.upd || exit /b
:: copy /b hbios_app.bin + osimg_small.bin %ROMName%.com || exit /b

::
:: Copy results to output directory
::

:: copy %ROMName%.rom ..\..\Binary || exit /b
:: copy %ROMName%.upd ..\..\Binary || exit /b
:: copy %ROMName%.com ..\..\Binary || exit /b

goto :eof

::
:: Simple procedure to assemble a specified component via TASM.
::

:asm

echo.
echo Building %1...
tasm -t80 -g3 -c -fFF %1.asm %1.bin %1.lst || exit /b

goto :eof

::
:: Build all of the official distribution ROMs
::

:dist

 

goto :eof
