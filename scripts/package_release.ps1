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

$linuxExecutable = Join-Path $linuxBuild "The_House_of_the_Dead_25D.x86_64"
if (-not (Test-Path -LiteralPath $linuxExecutable)) {
	throw "Linux export is missing. Run the Godot Linux export first."
}
Compress-Archive -Path (Join-Path $linuxBuild "*") -DestinationPath $linuxArchive -CompressionLevel Optimal

$webEntryPoint = Join-Path $webBuild "index.html"
if (-not (Test-Path -LiteralPath $webEntryPoint)) {
	throw "Web export is missing. Run the Godot Web export first."
}
Compress-Archive -Path (Join-Path $webBuild "*") -DestinationPath $webArchive -CompressionLevel Optimal

$archivePaths = @($sourceArchive, $windowsArchive, $linuxArchive, $webArchive)
$unexpectedArchives = @(Get-ChildItem -LiteralPath $releaseRoot -File -Filter "*.zip" | Where-Object { $_.FullName -notin $archivePaths })
if ($unexpectedArchives.Count -gt 0) {
	throw "Unexpected ZIP archive(s) in release directory: $($unexpectedArchives.Name -join ', ')"
}
$archives = @($archivePaths | ForEach-Object { Get-Item -LiteralPath $_ } | Sort-Object Name)
$checksumLines = foreach ($archive in $archives) {
	$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive.FullName).Hash.ToLowerInvariant()
	"$hash  $($archive.Name)"
}
[System.IO.File]::WriteAllLines($checksumFile, [string[]]$checksumLines, [System.Text.UTF8Encoding]::new($false))

Write-Output "Release artifacts created in $releaseRoot"
Get-Content -LiteralPath $checksumFile
