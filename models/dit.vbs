Set Shell1 = CreateObject( "WScript.Shell" )

'WScript.echo "----------- Dit -Directory Syncer Tools- ----------------"

set fs = Wscript.CreateObject("Scripting.FileSystemObject")
dim args:args=argsManager(Wscript.Arguments)
dim cd:cd = Shell1.CurrentDirectory
dim currentPath:currentPath =  Chr(34) & cd &Chr(34)
dim repositoryPath:repositoryPath = cd & "\.repository" 
dim configPath:configPath =  cd  & "\.repository\config" 
dim ignoreFilePath:ignoreFilePath = cd &  "\ignoreFile" 
dim ignoreDirPath:ignoreDirPath =  cd &  "\ignoreDir"
dim config:SET config =  CreateObject("Scripting.Dictionary")
dim mePosition:mePosition = fs.getParentFolderName(WScript.ScriptFullName)
dim timeStamp : timeStamp = year(now) & month(now) & day(now) & "-" &  hour(now) & minute(now) & Second(now)
dim logPath:logPath = cd & "\.repository\logs" 
dim logName:logName = "\ditLog-" & timeStamp & ".log"
dim logText

if args(0) = "" then 
    WScript.echo "Command is Empty."
    Wscript.Quit(0)
End if

Select Case LCase(args(0))

Case "init"
    call init(args(1),args(2))
Case "clone"
    call clone(args(1),args(2))
Case "commit"
    commit
Case "reset"
    Wscript.echo("reset command")
End Select

Sub init(local,remote)
    remoteRepoPath = ""

    if Len(local) <> 0 then
        cd = local
    End If

    if Len(remote) <> 0 then
        remoteRepoPath = remote
    End If
    
    dim cmdargs(1)
    cmdargs(0)=Chr(34) & cd & Chr(34) 
    cmdargs(1)=Chr(34) & remoteRepoPath &  Chr(34) 
    call ShellExec ("init.bat",cmdargs)
End Sub

Sub clone(remote,local)
    if len(local) <> 0 then  cd = local
    '設定ファイルの読み込みに失敗した場合は、指定ディレクトリをリポジトリに設定
    if loadConfig = False then 
        if len(local) <> 0 then
            call init(local,"")
        Else
            call init(cd,"")
        End if
        loadConfig
    End if

    if len(remote) <> 0 then
        remoteRepoPath =Chr(34) &  remote & Chr(34)
        config.remove "remoteRepo"
        config.add "remoteRepo",Chr(34) &  remote & Chr(34)
        if writeConfig = false then Exit Sub
    elseIF len(remote) = 0 then
        remoteRepoPath = config.Item("remoteRepo")
    End if
    
    dim cmdargs(1)
    cmdargs(0)=remoteRepoPath
    cmdargs(1)=config.Item("localRepo")
    call ShellExec ("clone.bat",cmdargs)
End Sub

Sub commit()
    dim cmdargs(2)
    if loadConfig = False then Exit Sub
    '引数無しで起動した場合
    if args(1) = "" then
        cmdargs(0)=config.Item("localRepo")
        cmdargs(1)=config.Item("remoteRepo")
    elseIF len(args(2)) <> 0 then
        cmdargs(0) = args(1)
        cmdargs(1) = args(2)
        cmdargs(2) = logName
    End If
    call ShellExec ("commit.bat",cmdargs)
End sub

Function loadConfig()
    dim textStream
    IF fs.FileExists(configPath) then
        SET textStream =  fs.OpenTextFile(configPath) 
        Do Until textStream.AtEndOfLine
            text = textStream.readLine()
            splited = split(text,"=")
            if UBound(splited) = 0 then 
                config.add splited(0),""
            Else
                config.add splited(0),splited(1)
            End If
        Loop
        loadConfig = True
    Else
        WScript.echo("Load Failure:Config File doesn't exist.(" & configPath & ")")
        loadConfig = False
    End IF
End Function

Function writeConfig()
    dim textStream
    if fs.FileExists(configPath) then
       SET textStream = fs.GetFile(configPath).OpenAsTextStream(2)
    Else
        WScript.echo("Write Failure:Config File doesn't exist.(" & configPath & ")")
        writeConfig = False
    End if
    
    For Each key In config
        textStream.writeLine(key & "=" & config.Item(key))
    Next
    writeConfig = True
End Function

Function writeData(path,text)
    dim textStream
    if fs.FileExists(path) = false then
       fs.CreateTextFile(path)
    End if
   SET textStream = fs.GetFile(path).OpenAsTextStream(8)
   textStream.writeLine(text)
   writeData = True
End Function

Function writeLog(text)
	 text2 = (Date & Space(1) & time) & ":" & text
     logText = logText  & vbcrlf &  text2
End Function 

Function outLog()
	logPath = cd & "\.repository\logs" & logName 
	call writeData(logPath,logText) 
End Function

Sub writeArrayLog(array,title)
	arrayText = title
    dim i : i = 0
    For Each item IN array
        arrayText = arrayText & vbcrlf & i & ":" & item
        i = i + 1
    Next
    writeLog(arrayText)
End Sub


Sub ShellExec(command,args)
    call writeLog("実行コマンド:" & command)
    call writeArrayLog(args,"引数")
    IF fs.FileExists(mePosition & "/" & command ) then
        'call Shell1.Run(Chr(34) & mePosition & "/" & command & Chr(34) & Space(1) & args(0) & Space(1)  & args(1),1)
        SET result = Shell1.Exec(Chr(34) & mePosition & "/" & command & Chr(34) & Space(1) & args(0) & Space(1)  & args(1))
        do while result.status = 0
            WScript.Sleep 1000
            printStdoe result
        Loop
    Else
        WScript.echo(command & " doesn't exist.")
    End IF
    IF result.ExitCode = 0 then
	    printScreen "処理が終了しました。"
	else 
		printScreen "処理に失敗しました。 "
	End If
	outLog
End Sub


Sub printStdoe(return)
        stdOutStr = return.StdOut.readAll()
        stdErrStr = return.StdErr.readAll()
        if Len(stdErrStr) <> 0 Then 
            WScript.echo(stdErrStr)
        End if
        if Len(stdOutStr) <> 0 Then 
            WScript.echo(stdOutStr)
        End if
        writeLog "実行結果"
        writeLog(stdOutStr & vbcrlf & stdErrStr)
End Sub

Sub printScreen(message)
    WScript.echo(message)
End Sub

Sub printArray(array)
    dim i : i = 0
    For Each item IN array
        printScreen i & ":" & item
        i = i + 1
    Next
End Sub

function argsManager(input)
    dim args(2)
    IF input.count = 1 then 
        args(0) = input(0)
        args(1) = ""
        args(2) = ""
    ElseIf input.count = 2 then
        args(0) = input(0)
        args(1) = input(1)
        args(2) = ""
    ElseIf input.count = 3 then
        args(0) = input(0)
        args(1) = input(1)
        args(2) = input(2)
    End if
    argsManager = args
End function