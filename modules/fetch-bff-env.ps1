param (
	[string]$CategoryName,
	[string]$ProjectName
)

echo "   [fetch-bff-env/INFO] Setting up environment"
Set-Location "C:/ROOT_DEV_TODO/Vanguard/$CategoryName/$ProjectName/$ProjectName"
if (Test-Path -Path "./.env") {
	Get-Content -Path "./.env" | ForEach-Object {
		if ($_ -match "^\s*([^#][^=]*)=(.*)") {
			[System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
		}
	}
	echo "   [fetch-bff-env/INFO] .env found and environment variables set"
} else {
	echo "   [fetch-bff-env/FATAL] .env not found"
}