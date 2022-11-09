Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$(Invoke-WebRequest https://raw.githubusercontent.com/barnuri/powershell-utils/master/installProfileTools.ps1 -Headers @{"Cache-Control"="no-cache"}).Content | iex
