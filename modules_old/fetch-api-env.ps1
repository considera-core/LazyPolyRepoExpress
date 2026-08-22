param (
	[string]$CategoryName,
	[string]$ProjectName
)

# todo, once this process is done, the variables should be saved to the spawn-api-window process

echo "   [fetch-api-env/INFO] Setting up environment"
Set-Location "C:/ROOT_DEV_TODO/Vanguard/$CategoryName/$ProjectName"
if (Test-Path -Path "./.env") {
	Get-Content -Path "./.env" | ForEach-Object {
		if ($_ -match "^\s*([^#][^=]*)=(.*)") {
			[System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
		}
	}
	echo "   [fetch-api-env/INFO] .env found and environment variables set"
} else {
	echo "   [fetch-api-env/ERROR] .env not found. One more try..."
	echo "   [fetch-api-env/INFO] Setting up environment"
	Set-Location "C:/ROOT_DEV_TODO/Vanguard/$CategoryName/$ProjectName/$ProjectName"
	if (Test-Path -Path "./.env") {
		Get-Content -Path "./.env" | ForEach-Object {
			if ($_ -match "^\s*([^#][^=]*)=(.*)") {
				[System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
			}
		}
		echo "   [fetch-api-env/INFO] .env found and environment variables set"
	} else {
		echo "   [fetch-api-env/FATAL] .env not found. Exiting..."
	}
	Set-Location ..
}