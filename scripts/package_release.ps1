[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$releaseRoot = Join-Path $projectRoot "artifacts\release"
$windowsBuild = Join-Path $projectRoot "build\windows"
$linuxBuild = Join-Path $projectRoot "build\linux"
$webBuild = Join-Path $projectRoot "build\web"

New-Item -ItemType Directory -Force -Path $releaseRoot | Out-Null

$sourceArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Source.zip"
$windowsArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Windows_x64.zip"
$linuxArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Linux_x64.zip"
$webArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Web.zip"
$checksumFile = Join-Path $releaseRoot "SHA256SUMS.txt"

foreach ($target in @($sourceArchive, $windowsArchive, $linuxArchive, $webArchive, $checksumFile)) {
	if (Test-Path -LiteralPath $target) {
		Remove-Item -LiteralPath $target -Force
	}
}

git -C $projectRoot archive --format=zip --output=$sourceArchive HEAD -- . ":(exclude)build" ":(exclude).vercel"
if ($LASTEXITCODE -ne 0) {
	throw "git archive failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath (Join-Path $windowsBuild "The_House_of_the_Dead_25D.exe"))) {
	throw "Windows export is missing. Run the Godot Windows Desktop export first."
}
Compress-Archive -Path (Join-Path $windowsBuild "*") -DestinationPath $windowsArchive -CompressionLevel Optimal

if (Test-Path -LiteralPath (Join-Path $linuxBuild "The_House_of_the_Dead_25D.x86_64")) {
	Compress-Archive -Path (Join-Path $linuxBuild "*") -DestinationPath $linuxArchive -CompressionLevel Optimal
}

if (Test-Path -LiteralPath (Join-Path $webBuild "index.html")) {
	Compress-Archive -Path (Join-Path $webBuild "*") -DestinationPath $webArchive -CompressionLevel Optimal
}

$archives = Get-ChildItem -LiteralPath $releaseRoot -File -Filter "*.zip" | Sort-Object Name
$checksumLines = foreach ($archive in $archives) {
	$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive.FullName).Hash.ToLowerInvariant()
	"$hash  $($archive.Name)"
}
Set-Content -LiteralPath $checksumFile -Value $checksumLines -Encoding utf8NoBOM

Write-Output "Release artifacts created in $releaseRoot"
Get-Content -LiteralPath $checksumFile
