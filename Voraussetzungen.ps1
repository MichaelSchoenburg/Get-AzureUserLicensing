# PowerShell 7 installieren

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Install-Module PowerShellGet -Scope AllUsers

Install-Module -Name Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force
