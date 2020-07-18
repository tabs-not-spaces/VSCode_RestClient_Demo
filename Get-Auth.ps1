if (!(Test-Path $PSScriptRoot\.vscode\settings.json -ErrorAction SilentlyContinue)) {
    @'
{
    "rest-client.environmentVariables": {
        "$shared": {
        "Auth": null,
        "ExpiresOn": null,
        "ContentType": "Application/Json"
        }
    }
}
'@ | Out-File -FilePath $PSScriptRoot\.vscode\settings.json -Force -Encoding ascii -NoNewline
}
$app = get-content .\.localenv -raw | ConvertFrom-Json
$settings = Get-Content .\.vscode\settings.json -raw | ConvertFrom-Json
$auth = Get-MsalToken -ClientId $app.clientId -TenantId $app.tenantId -DeviceCode
if ($auth) {
    $settings.'rest-client.environmentVariables'.'$shared'.Auth = $auth.CreateAuthorizationHeader()
    $settings.'rest-client.environmentVariables'.'$shared'.ExpiresOn = $auth.ExpiresOn
    $settings | ConvertTo-Json | Out-File .\.vscode\settings.json -Force -NoNewline -Encoding ascii
    Write-Host "$(($auth.CreateAuthorizationHeader()).Substring(0,20))`.."
    Write-Host "Auth token updated.."
}
else {
    throw "nah bruh.."
}