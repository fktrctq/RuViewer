
REM Stop Sevices
sc stop RuViewerSrvService

REM Wait
TIMEOUT /T 10 /NOBREAK

REM Find process
TASKLIST /FI "IMAGENAME eq RuViewerServerSrvc.exe"

REM Kil process
TASKKILL /F /IM RuViewerServerSrvc.exe

REM Wait
TIMEOUT /T 5 /NOBREAK

REM Run Services
sc start RuViewerSrvService