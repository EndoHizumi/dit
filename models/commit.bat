@echo off

SET time2=%time: =0%
SET TimeStamp=%date:~0,4%%date:~5,2%%date:~8,2%-%time2:~0,2%%time2:~3,2%%time2:~6,2%
SET localRepo="%~1"
SET remoteRepo="%~2"
SET logPath="%~3"
SET backupDir="%localRepo:"=%\.repository\bk\%TimeStamp%\"
SET ignoreFilePath="%localRepo:"=%\.ignoreFile"
SET ignoreDirPath="%localRepo:"=%\.ignoreDir"

if exist %ignoreFilePath% (
    for /f "delims= usebackq" %%a in (%ignoreFilePath%) do (
    SET ignoreFile="%%a"
    )
) else (
    echo ignoreFile doesn't exist:%ignoreFilePath% 
    exit /b -1
)

if exist %ignoreDirPath% (
    for /f "delims= usebackq" %%b in (%ignoreDirPath%) do (
    SET ignoreDir="%%b"
    )
) else (
    echo ignoreDir doesn't exist:%ignoreDirPath% 
    exit /b -1
)

cd %localRepo% > nul
echo "�����[�g�f�B���N�g���̃o�b�N�A�b�v���쐬���Ă��܂�... %remoteRepo% -> %backupDir% "
pushd %remoteRepo%
xcopy  /e %remoteRepo%\* %backupDir% 
popd
if not %errorlevel% == 0 (
 echo �G���[�F�o�b�N�A�b�v�̍쐬�Ɏ��s���܂����B
 exit /b -1
)

echo "���[�J���̓��e�Ń����[�g�Ɠ������܂��B %localRepo% -> %remoteRepo%"
robocopy /MIR /R:10 /W:1 /Z /E %localRepo% %remoteRepo% /XF %ignoreFile%  /XD %ignoreDir%
echo %errorlevel%
if not %errorlevel% == 0 (
 echo �G���[�F�����Ɏ��s���܂����B
 exit /b -1
)
exit /b 0
