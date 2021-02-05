# Netmon clean up script
$path = "C:\Windows\Utilities\NetworkTracing\Logs"
If (Test-Path -Path $path) {
    Get-ChildItem -Path $path -Filter *.cap | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-3)} | Remove-Item -Force
}