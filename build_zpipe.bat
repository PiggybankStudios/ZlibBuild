@echo off

call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64

set RootDir=".."

echo test

echo [Compiling zpipe.c]

set CompilerFlags=/nologo /I"%RootDir%"
set LinkerFlags=/NOLOGO /OUT:"zpipe.exe"

cl %CompilerFlags% /c /Fo"zpipe.obj" "zpipe.c"
LINK /lib %LinkerFlags% "zlib.lib" "zpipe.obj"

echo [Finished!]
