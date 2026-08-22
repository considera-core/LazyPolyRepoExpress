param (
	[string]$CategoryName,
	[string]$ProjectName,
	[string]$Here
)

$host.UI.RawUI.WindowTitle = $ProjectName

if (!$Here) {
	cls
	echo "  [spawn-bff/INFO] Running BFF server & Angular client for $CategoryName $ProjectName..."
	spawn-angular-window $CategoryName $ProjectName
} else {
	echo "  [spawn-bff/INFO] Running only BFF server for $CategoryName $ProjectName..."
}

fetch-bff-env $CategoryName $ProjectName

echo "  [spawn-bff/INFO] Building"
Set-Location ".."
dotnet build --configuration Debug

echo "  [spawn-bff/INFO] Running"
Set-Location "$ProjectName"
dotnet "./bin/Debug/net8.0/$ProjectName.dll"

echo "  [spawn-bff/INFO] Exiting"
exit