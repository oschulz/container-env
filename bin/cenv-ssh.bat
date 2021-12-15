@ECHO OFF

Rem get last argument and keep all others
:lastarg
  set "All_BUT_LAST_ARG=%All_BUT_LAST_ARG% %SEC_LAST_ARG%" 
  set "SEC_LAST_ARG=%LAST_ARG%"
  set "LAST_ARG=%~1"
  shift
  if not "%~1"=="" goto lastarg

IF "%LAST_ARG%"=="bash" (
    set "LAST_ARG=%SEC_LAST_ARG%"
) ELSE (
    set "All_BUT_LAST_ARG=%All_BUT_LAST_ARG% %SEC_LAST_ARG%" 
)

Rem Remove leading whitespace
for /f "tokens=* delims= " %%a in ("%All_BUT_LAST_ARG%") do (
    set All_BUT_LAST_ARG=%%a
)

Rem split at tilde (~)
for /f "tokens=1,2 delims=~" %%a in ("%LAST_ARG%") do (
  set Server=%%a
  set Cenv=%%b
)

Rem Check if there are arguments and if container is used
IF NOT "%Server%"=="" (
    IF NOT "%Cenv%"=="" (
        IF NOT "%All_BUT_LAST_ARG%"=="" (
            ssh -t %All_BUT_LAST_ARG% "%Server%" cenv  "%Cenv%"
        ) ELSE (
            ssh -t %Server% cenv  "%Cenv%"
        )

    ) ELSE (
        IF NOT "%All_BUT_LAST_ARG%"=="" (
            ssh %All_BUT_LAST_ARG% "%Server%"
        ) ELSE (
            ssh "%Server%"
        )
    )
)


Rem Debug section
Rem :endoftests
Rem IF NOT "%Server%"=="-V" (
Rem    ECHO SEC_LAST_ARG = %SEC_LAST_ARG%
Rem    ECHO Args = %All_BUT_LAST_ARG%
Rem    ECHO Server = %Server%
Rem    ECHO Env = %Cenv%
Rem )
