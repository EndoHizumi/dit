@echo off 
SET time2=%time: =0%
SET TimeStamp=%date:~0,4%%date:~5,2%%date:~8,2%-%time2:~0,2%%time2:~3,2%%time2:~6,2%
SET localRepo=%2
SET remoteRepo=%1

echo "Cloning Remote Repository... %remoteRepo% -> %localRepo% "
pushd %remoteRepo%
echo åªç›à íu:%cd%
xcopy  /e %remoteRepo% %localRepo%
popd
if errorlevel 1 exit /b -1
exit /b 0