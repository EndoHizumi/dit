@echo off

SET targetDirectory=%~1
SET remoteDirectory=%~2
SET beforePath=%CD%

cd %targetDirectory% > nul
mkdir .repository\logs

echo remoteRepo="%remoteDirectory%"> .repository\config
echo localRepo="%targetDirectory%">> .repository\config

echo ".*"> .ignoreDir
echo "*.log *.ignoreDir *.ignoreFile ~*"> .ignoreFile

cd %beforePath%

echo initialize function Complete. %targetDirectory%