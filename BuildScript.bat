@echo off
SET "SDKLocation=G:\SteamLibrary\steamapps\common\XCOM 2 War of the Chosen SDK"
SET "GameLocation=G:\SteamLibrary\steamapps\common\XCOM 2\XCom2-WarOfTheChosen"
SET "SRCLocation=D:\Github\ExtendedPersonnelInfo"
SET "DependencyLocation=D:\Github"

REM SET "LWOTCLocation=D:\Github\lwotc"
powershell.exe -NonInteractive -ExecutionPolicy Unrestricted  -file "D:\Github\ExtendedPersonnelInfo\.scripts\build.ps1" -srcDirectory "%SRCLocation%" -sdkPath "%SDKLocation%" -gamePath "%GameLocation%" -dependencyPath "%DependencyLocation%" -config "debug"
