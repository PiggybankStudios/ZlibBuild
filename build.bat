@echo off

rem set Target=Windows
set Target=WASM

set ConvertToWat=1

set RootDir=..
set PigWasmDir=%RootDir%\..\PigWasmStdLib

if "%Target%"=="Windows" (
	goto WINDOWS_BUILD
) else if "%Target%"=="WASM" (
	goto WASM_BUILD
) else (
	echo ERROR: Unsupported value for Target: "%Target%"
	goto END
)

rem +==============================+
rem |        WINDOWS_BUILD         |
rem +==============================+
:WINDOWS_BUILD

call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64

echo [Compiling Windows DLL]

set CompilerFlags=/GS- /W3 /Zc:wchar_t /WX- /Zc:forScope /Zi /Gm- /Od /Gd /MDd /FC /Zc:inline /fp:precise /nologo /diagnostics:column /errorReport:prompt
set CompilerFlags=%CompilerFlags% /D "WIN32" /D "_CRT_NONSTDC_NO_DEPRECATE" /D "_CRT_SECURE_NO_DEPRECATE" /D "_CRT_NONSTDC_NO_WARNINGS" /D "ZLIB_WINAPI" /D "WIN64" /D "_WINDLL"
set CompilerFlags=%CompilerFlags% /I"..\..\.."
rem set CompilerFlags=%CompilerFlags% /ifcOutput "Temp\" /Fa"Temp\" /Fo"Temp\" /Fp"Temp\zlibvc.pch"
set LinkerFlags=/MACHINE:X64 /NOLOGO /OUT:"zlib.lib"

set ObjectFiles=
cl %CompilerFlags% /c /Fo"adler32.obj" "%RootDir%\adler32.c" & set ObjectFiles=%ObjectFiles% "adler32.obj"
cl %CompilerFlags% /c /Fo"compress.obj" "%RootDir%\compress.c" & set ObjectFiles=%ObjectFiles% "compress.obj"
cl %CompilerFlags% /c /Fo"crc32.obj" "%RootDir%\crc32.c" & set ObjectFiles=%ObjectFiles% "crc32.obj"
cl %CompilerFlags% /c /Fo"deflate.obj" "%RootDir%\deflate.c" & set ObjectFiles=%ObjectFiles% "deflate.obj"
rem cl %CompilerFlags% /c /Fo"gzclose.obj" "%RootDir%\gzclose.c" & set ObjectFiles=%ObjectFiles% "gzclose.obj"
rem cl %CompilerFlags% /c /Fo"gzlib.obj" "%RootDir%\gzlib.c" & set ObjectFiles=%ObjectFiles% "gzlib.obj"
rem cl %CompilerFlags% /c /Fo"gzread.obj" "%RootDir%\gzread.c" & set ObjectFiles=%ObjectFiles% "gzread.obj"
rem cl %CompilerFlags% /c /Fo"gzwrite.obj" "%RootDir%\gzwrite.c" & set ObjectFiles=%ObjectFiles% "gzwrite.obj"
cl %CompilerFlags% /c /Fo"infback.obj" "%RootDir%\infback.c" & set ObjectFiles=%ObjectFiles% "infback.obj"
cl %CompilerFlags% /c /Fo"inffast.obj" "%RootDir%\inffast.c" & set ObjectFiles=%ObjectFiles% "inffast.obj"
cl %CompilerFlags% /c /Fo"inflate.obj" "%RootDir%\inflate.c" & set ObjectFiles=%ObjectFiles% "inflate.obj"
cl %CompilerFlags% /c /Fo"inftrees.obj" "%RootDir%\inftrees.c" & set ObjectFiles=%ObjectFiles% "inftrees.obj"
cl %CompilerFlags% /c /Fo"trees.obj" "%RootDir%\trees.c" & set ObjectFiles=%ObjectFiles% "trees.obj"
cl %CompilerFlags% /c /Fo"uncompr.obj" "%RootDir%\uncompr.c" & set ObjectFiles=%ObjectFiles% "uncompr.obj"
cl %CompilerFlags% /c /Fo"zutil.obj" "%RootDir%\zutil.c" & set ObjectFiles=%ObjectFiles% "zutil.obj"
rem cl %CompilerFlags% /c /Fo"ioapi.obj" "%RootDir%\contrib\minizip\ioapi.c" & set ObjectFiles=%ObjectFiles% "ioapi.obj"
rem cl %CompilerFlags% /c /Fo"iowin32.obj" "%RootDir%\contrib\minizip\iowin32.c" & set ObjectFiles=%ObjectFiles% "iowin32.obj"
rem cl %CompilerFlags% /c /Fo"unzip.obj" "%RootDir%\contrib\minizip\unzip.c" & set ObjectFiles=%ObjectFiles% "unzip.obj"
rem cl %CompilerFlags% /c /Fo"zip.obj" "%RootDir%\contrib\minizip\zip.c" & set ObjectFiles=%ObjectFiles% "zip.obj"
LINK /lib %LinkerFlags% %ObjectFiles%

goto END

rem +==============================+
rem |          WASM_BUILD          |
rem +==============================+
:WASM_BUILD

echo [Compiling WASM .wasm]

rem -DNO_STRERROR -DNO_ERRNO_H
set CompilerFlags=-DSTD_ASSERTIONS_ENABLED
rem --no-standard-libraries = ?
rem --no-standard-includes = ?
rem --target=wasm32 = ?
rem -mbulk-memory = Prevent conversion of simple loops into memset or memcpy?
rem -fno-builtin = (Optional) makes some calls like sqrtf actually go to our own sqrtf function rather than linking to the builtin clang implementation
set CompilerFlags=%CompilerFlags% --no-standard-libraries --no-standard-includes --target=wasm32 -mbulk-memory
set IncludeDirectories=-I"%RootDir%" -I"%PigWasmDir%\include"
rem --no-entry        = ?
rem --allow-undefined = ?
rem --import-memory   = ?
rem --lto-O2          = ?
set LinkerFlags=--no-entry --allow-undefined --import-memory --lto-O2 --relocatable

set ObjectFiles=
clang %CompilerFlags% %IncludeDirectories% -c -o "adler32.o" "%RootDir%\adler32.c" & set ObjectFiles=%ObjectFiles% "adler32.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "compress.o" "%RootDir%\compress.c" & set ObjectFiles=%ObjectFiles% "compress.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "crc32.o" "%RootDir%\crc32.c" & set ObjectFiles=%ObjectFiles% "crc32.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "deflate.o" "%RootDir%\deflate.c" & set ObjectFiles=%ObjectFiles% "deflate.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "gzclose.o" "%RootDir%\gzclose.c" & set ObjectFiles=%ObjectFiles% "gzclose.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "gzlib.o" "%RootDir%\gzlib.c" & set ObjectFiles=%ObjectFiles% "gzlib.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "gzread.o" "%RootDir%\gzread.c" & set ObjectFiles=%ObjectFiles% "gzread.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "gzwrite.o" "%RootDir%\gzwrite.c" & set ObjectFiles=%ObjectFiles% "gzwrite.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "infback.o" "%RootDir%\infback.c" & set ObjectFiles=%ObjectFiles% "infback.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "inffast.o" "%RootDir%\inffast.c" & set ObjectFiles=%ObjectFiles% "inffast.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "inflate.o" "%RootDir%\inflate.c" & set ObjectFiles=%ObjectFiles% "inflate.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "inftrees.o" "%RootDir%\inftrees.c" & set ObjectFiles=%ObjectFiles% "inftrees.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "trees.o" "%RootDir%\trees.c" & set ObjectFiles=%ObjectFiles% "trees.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "uncompr.o" "%RootDir%\uncompr.c" & set ObjectFiles=%ObjectFiles% "uncompr.o"
clang %CompilerFlags% %IncludeDirectories% -c -o "zutil.o" "%RootDir%\zutil.c" & set ObjectFiles=%ObjectFiles% "zutil.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "ioapi.o" "%RootDir%\contrib\minizip\ioapi.c" & set ObjectFiles=%ObjectFiles% "ioapi.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "iowin32.o" "%RootDir%\contrib\minizip\iowin32.c" & set ObjectFiles=%ObjectFiles% "iowin32.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "unzip.o" "%RootDir%\contrib\minizip\unzip.c" & set ObjectFiles=%ObjectFiles% "unzip.o"
rem clang %CompilerFlags% %IncludeDirectories% -c -o "zip.o" "%RootDir%\contrib\minizip\zip.c" & set ObjectFiles=%ObjectFiles% "zip.o"
wasm-ld %ObjectFiles% %LinkerFlags% -o zlib.wasm

if "%ConvertToWat%"=="1" (
	wasm2wat zlib.wasm > zlib.wat
)

rem clang "%RootDir%\adler32.c" -c %CompilerFlags% %IncludeDirectories% -o "engine.o"

goto END

rem +==============================+
rem |             END              |
rem +==============================+
:END

echo [Finished!]
