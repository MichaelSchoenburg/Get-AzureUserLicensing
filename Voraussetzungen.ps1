# PowerShell 7 installieren

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Install-Module PowerShellGet -Scope AllUsers

# Install-Module -Name Az -Scope AllUsers -Repository PSGallery -Force
Install-Module -Name Microsoft.Graph -Scope AllUsers -Repository PSGallery -Force
