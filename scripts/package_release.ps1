[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$releaseRoot = Join-Path $projectRoot "artifacts\release"
$windowsBuild = Join-Path $projectRoot "build\windows"
$linuxBuild = Join-Path $projectRoot "build\linux"
$webBuild = Join-Path $projectRoot "build\web"

$sourceArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Source.zip"
$windowsArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Windows_x64.zip"
$linuxArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Linux_x64.zip"
$webArchive = Join-Path $releaseRoot "The_House_of_the_Dead_25D_Web.zip"
$checksumFile = Join-Path $releaseRoot "SHA256SUMS.txt"
$archivePaths = @($sourceArchive, $windowsArchive, $linuxArchive, $webArchive)

function Assert-NonEmptyFile {
	param(
		[Parameter(Mandatory = $true)]
		[string]$LiteralPath,
		[Parameter(Mandatory = $true)]
		[string]$Description
	)

	if (-not (Test-Path -LiteralPath $LiteralPath -PathType Leaf)) {
		throw "$Description is missing: $LiteralPath"
	}
	if ((Get-Item -LiteralPath $LiteralPath).Length -le 0) {
		throw "$Description is empty: $LiteralPath"
	}
}

$windowsExecutable = Join-Path $windowsBuild "The_House_of_the_Dead_25D.exe"
$linuxExecutable = Join-Path $linuxBuild "The_House_of_the_Dead_25D.x86_64"
$requiredWebFiles = @(
	(Join-Path $webBuild "index.html"),
	(Join-Path $webBuild "index.js"),
	(Join-Path $webBuild "index.pck"),
	(Join-Path $webBuild "index.wasm")
)

Assert-NonEmptyFile -LiteralPath $windowsExecutable -Description "Windows export"
Assert-NonEmptyFile -LiteralPath $linuxExecutable -Description "Linux export"
foreach ($requiredWebFile in $requiredWebFiles) {
	Assert-NonEmptyFile -LiteralPath $requiredWebFile -Description "Web export file"
}

$workingTreeStatus = @(& git -C $projectRoot status --porcelain=v1 --untracked-files=all)
if ($LASTEXITCODE -ne 0) {
	throw "git status failed with exit code $LASTEXITCODE"
}
if ($workingTreeStatus.Count -gt 0) {
	throw "The Git worktree must be clean before packaging because the source archive is created from HEAD. Commit the verified release tree first."
}

New-Item -ItemType Directory -Force -Path $releaseRoot | Out-Null

foreach ($target in @($archivePaths + $checksumFile)) {
	if (Test-Path -LiteralPath $target) {
		Remove-Item -LiteralPath $target -Force
	}
}

git -C $projectRoot archive --format=zip --output=$sourceArchive HEAD -- . ":(exclude)build" ":(exclude).vercel"
if ($LASTEXITCODE -ne 0) {
	throw "git archive failed with exit code $LASTEXITCODE"
}
Assert-NonEmptyFile -LiteralPath $sourceArchive -Description "Source archive"

Compress-Archive -Path (Join-Path $windowsBuild "*") -DestinationPath $windowsArchive -CompressionLevel Optimal
Assert-NonEmptyFile -LiteralPath $windowsArchive -Description "Windows archive"

Compress-Archive -Path (Join-Path $linuxBuild "*") -DestinationPath $linuxArchive -CompressionLevel Optimal
Assert-NonEmptyFile -LiteralPath $linuxArchive -Description "Linux archive"

Compress-Archive -Path (Join-Path $webBuild "*") -DestinationPath $webArchive -CompressionLevel Optimal
Assert-NonEmptyFile -LiteralPath $webArchive -Description "Web archive"

$unexpectedArchives = @(Get-ChildItem -LiteralPath $releaseRoot -File -Filter "*.zip" | Where-Object { $_.FullName -notin $archivePaths })
if ($unexpectedArchives.Count -gt 0) {
	throw "Unexpected ZIP archive(s) in release directory: $($unexpectedArchives.Name -join ', ')"
}

$archives = @($archivePaths | ForEach-Object {
	Assert-NonEmptyFile -LiteralPath $_ -Description "Required release archive"
	Get-Item -LiteralPath $_
} | Sort-Object Name)
$checksumLines = @(foreach ($archive in $archives) {
	$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archive.FullName).Hash.ToLowerInvariant()
	"$hash  $($archive.Name)"
})
if ($checksumLines.Count -ne $archivePaths.Count) {
	throw "Checksum manifest must contain exactly $($archivePaths.Count) archive entries."
}
[System.IO.File]::WriteAllLines($checksumFile, [string[]]$checksumLines, [System.Text.UTF8Encoding]::new($false))
Assert-NonEmptyFile -LiteralPath $checksumFile -Description "Checksum manifest"

Write-Output "Release artifacts created in $releaseRoot"
Get-Content -LiteralPath $checksumFile
