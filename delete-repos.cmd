:: delete-repos.cmd
::
:: This batch file delete repository given by the user
:: from github account repository.
::----------------------------------------------

@ECHO OFF

@SETLOCAL EnableDelayedExpansion

:: Parameters
@SET "PERSONAL_ACCESS_TOKEN=<your-github-personal-access-token>"
@SET "GITHUB_ACCOUNT=<your-organisation-account-name>"

:: Start batch
@GOTO userInput

:: Get Git repository URL
:userInput
@SET /p pathUrl="Veuillez inserer l'URL du depot Git a supprimer (HTTPS ou SSH): "

:: Get repository project name
@SET projectName=
@CALL :getProjectName %pathUrl%

:: Delete Git repository
"%~dp0\bin\cURL\curl.exe" -i -X DELETE -H "Authorization: token %PERSONAL_ACCESS_TOKEN%" https://api.github.com/repos/%GITHUB_ACCOUNT%/%projectName:~0,-4%
@IF %ERRORLEVEL% GEQ 1 (
    @CLS
    @ECHO Une erreur est survenue lors de la suppression du depot Git
    @PAUSE
    @GOTO eof
)

:: Success message
@CLS
@ECHO Votre depot Git a ete supprime avec succes.
@PAUSE
@GOTO eof

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