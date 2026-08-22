param (
	[string]$CategoryName,
	[string]$ProjectName,
	[string]$Here
)

$host.UI.RawUI.WindowTitle = $ProjectName


if (!$Here) {
	cls
}

echo "  [spawn-api/INFO] Running API server for $CategoryName $ProjectName..."

fetch-api-env $CategoryName $ProjectName

echo "  [spawn-api/INFO] Building"
dotnet build --configuration Debug

echo "  [spawn-api/INFO] Running"
Set-Location "./$ProjectName"
dotnet "./bin/Debug/net8.0/$ProjectName.dll"

echo "  [spawn-api/INFO] Exiting"
exit