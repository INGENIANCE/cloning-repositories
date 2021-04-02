:: cloning-repos.cmd
::
:: This batch file clones the url repository given by the user
:: and saves the output to github account repository.
::----------------------------------------------

@ECHO OFF

@SETLOCAL EnableDelayedExpansion

:: Parameters
@SET "PERSONAL_ACCESS_TOKEN=<your-github-personal-access-token>"
@SET "GITHUB_ACCOUNT=<your-organisation-account-name>"
@SET "USER_NAME=<your-anonymize-username>"
@SET "AUTHOR=somebody <your-name@your-domain.com>"

:: Check WMIC is available
@SET currentDate=
WMIC.EXE Alias /? >NUL 2>&1 || GOTO wmicErrorManager

:: Use WMIC to retrieve date and time
@FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
    @IF "%%~L"=="" goto dateDone
    @SET _yyyy=%%L
    @SET _mm=00%%J
    @SET _dd=00%%G
    @SET _hour=00%%H
    @SET _minute=00%%I
    @SET _second=00%%K
)
:dateDone

:: Pad digits with leading zeros
@SET _mm=%_mm:~-2%
@SET _dd=%_dd:~-2%
@SET _hour=%_hour:~-2%
@SET _minute=%_minute:~-2%
@SET _second=%_second:~-2%

@SET currentDate=%_yyyy%%_mm%%_dd%

:: Start batch
@GOTO userInput

:: Get Git repository URL
:userInput
@SET /p pathUrl="Veuillez inserer l'URL du depot Git a cloner (HTTPS ou SSH): "

:: Clone repository in local drive
"%~dp0\bin\PortableGit\cmd\git.exe" clone %pathUrl% source
@IF %ERRORLEVEL% GEQ 1 (
    @CLS
    @ECHO Impossible de cloner le depot. Verifier l'URL.
    @PAUSE
    @GOTO eof
)

:: Go to cloned repository
@CD source

:: Delete Git referential folder
@RD /S /Q .git

:: Generate project random value
@SET accountRandomValue=
@SET stringValues="abcdefghijklmnopqrstuvwxyz01234567890"
@FOR /L %%i in (1,1,7) do CALL :addRandomValue

:: Get repository project name
@SET projectName=
@CALL :getProjectName %pathUrl%

:: Create new repository in github
"%~dp0\bin\cURL\curl.exe" -i -X POST -H "Authorization: token %PERSONAL_ACCESS_TOKEN%" -d "{\"name\":\"%currentDate%-%accountRandomValue%-%projectName:~0,-4%\"}" https://api.github.com/orgs/%GITHUB_ACCOUNT%/repos
@IF %ERRORLEVEL% GEQ 1 (
    :: Delete all previous treatment
    CALL :deleteClone

    @CLS
    @ECHO Impossible d'acceder a GitHub. Veuillez reessayer.
    @PAUSE
    @GOTO eof
)

:: Init git repository
"%~dp0\bin\PortableGit\cmd\git.exe" init
"%~dp0\bin\PortableGit\cmd\git.exe" add .
"%~dp0\bin\PortableGit\cmd\git.exe" -c user.name="%USER_NAME%" commit --author="%AUTHOR%" -m "Initial commit"

:: Push cloned repository to github account
"%~dp0\bin\PortableGit\cmd\git.exe" remote add origin git@github.com:%GITHUB_ACCOUNT%/%currentDate%-%accountRandomValue%-%projectName%
"%~dp0\bin\PortableGit\cmd\git.exe" -c core.sshCommand="ssh -i ../ssh/id_rsa" push -u --force origin master
@IF %ERRORLEVEL% GEQ 1 (
    :: Delete all previous treatment
    CALL :deleteClone
    "%~dp0\bin\cURL\curl.exe" -i -X DELETE -H "Authorization: token %PERSONAL_ACCESS_TOKEN%" https://api.github.com/repos/%GITHUB_ACCOUNT%/%currentDate%-%accountRandomValue%-%projectName:~0,-4%

    @CLS
    @ECHO Une erreur est survenue lors de l'uplaod du depot vers GitHub
    @PAUSE
    @GOTO eof
)

:: Delete local cloned repository
CALL :deleteClone

:: Display new URL repository
@CLS
@ECHO URL a fournir au client : https://github.com/%GITHUB_ACCOUNT%/%currentDate%-%accountRandomValue%-%projectName:~0,-4%
@PAUSE
@GOTO eof

:: Generate random account value
:addRandomValue
@SET /a x=%random% %% 37
@SET accountRandomValue=%accountRandomValue%!stringValues:~%x%,1!
@GOTO eof

:: Delete local cloned repository
:deleteClone
@CD ..
@RD /S /Q source
@GOTO eof

:: Apply local date parsing
:wmicErrorManager
@ECHO WMIC is not available, using default date value
@SET currentDate=%date:~6,4%%date:~3,2%%date:~0,2%
@GOTO userInput

:: Parse path url to get project name
:getProjectName
@SET "stringToCheck=%~1"
:loop
@IF DEFINED stringToCheck (
    @FOR /f "delims=/ tokens=1*" %%x in ("%stringToCheck%") do (
        @SET "projectName=%%x"
        @SET "stringToCheck=%%y"
    )
    @GOTO loop
) else @EXIT /b

@ENDLOCAL
@EXIT /b

:eof