param (
    [string]$CategoryName,
    [string]$ProjectName
)
$windowTitle = "$ProjectName/Angular"
$rawUI = $host.ui.rawui
Start-ThreadJob -ScriptBlock {
    param($rawUI, $windowTitle)
    while ($true) {
        if ($rawUI.WindowTitle -ne $windowTitle) {
            $rawUI.WindowTitle = $windowTitle
        }
        Start-Sleep -Milliseconds 250
    }
} -ArgumentList $rawUI, $windowTitle

cls

echo "  [spawn-angular-window/INFO] Running Angular client for $CategoryName $ProjectName..."

fetch-bff-env $CategoryName $ProjectName

Set-Location "./client"

# echo "Installing dependencies"
# npm i
# echo "-> OK"

echo "  [spawn-angular-window/INFO] Serving client"

npm run start # en-US
# ng serve --configuration production # es-MX

echo "  [spawn-angular-window/INFO] OK"
return
