param(
	[string]$OutputPath
)

$ErrorActionPreference = "Stop"

$addonName = "SpellInfo"
$tocPath = Join-Path $PSScriptRoot "$addonName.TOC"
if (-not (Test-Path -LiteralPath $tocPath -PathType Leaf)) {
	throw "Addon TOC not found: $tocPath"
}

$tocContents = Get-Content -LiteralPath $tocPath
$versionLine = $tocContents | Where-Object { $_ -match '^##\s*Version:\s*(.+?)\s*$' } | Select-Object -First 1
if (-not $versionLine -or $versionLine -notmatch '^##\s*Version:\s*(.+?)\s*$') {
	throw "Version entry not found in addon TOC: $tocPath"
}
$version = $Matches[1].Trim()
$safeVersion = $version -replace '[^A-Za-z0-9._-]', '_'
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
	$OutputPath = Join-Path $PSScriptRoot "FlameSpellInfo-$safeVersion.zip"
}

$tocEntries = $tocContents | ForEach-Object {
	$entry = $_.Trim()
	if ($entry -and -not $entry.StartsWith("#")) {
		$entry
	}
}
$packageFiles = @("$addonName.TOC") + @($tocEntries)

$stagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
$stagedAddon = Join-Path $stagingRoot $addonName
try {
	New-Item -ItemType Directory -Path $stagedAddon -Force | Out-Null

	foreach ($relativePath in $packageFiles) {
		$sourcePath = Join-Path $PSScriptRoot $relativePath
		if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
			throw "TOC-listed package file not found: $relativePath"
		}

		$destinationPath = Join-Path $stagedAddon $relativePath
		$destinationDirectory = Split-Path -Parent $destinationPath
		New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
		Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
	}

	$resolvedOutputPath = [System.IO.Path]::GetFullPath($OutputPath)
	$outputDirectory = Split-Path -Parent $resolvedOutputPath
	if ($outputDirectory) {
		New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
	}
	Add-Type -AssemblyName System.IO.Compression
	Add-Type -AssemblyName System.IO.Compression.FileSystem
	$archive = [System.IO.Compression.ZipFile]::Open(
		$resolvedOutputPath,
		[System.IO.Compression.ZipArchiveMode]::Create
	)
	try {
		Get-ChildItem -LiteralPath $stagedAddon -File -Recurse | ForEach-Object {
			$relativePath = $_.FullName.Substring($stagedAddon.Length).TrimStart([char[]]@('\', '/'))
			$entryName = "$addonName/$relativePath" -replace '\\', '/'
			[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
				$archive,
				$_.FullName,
				$entryName,
				[System.IO.Compression.CompressionLevel]::Optimal
			) | Out-Null
		}
	}
	finally {
		$archive.Dispose()
	}
	Write-Output "Created addon archive: $resolvedOutputPath"
}
finally {
	if (Test-Path -LiteralPath $stagingRoot) {
		Remove-Item -LiteralPath $stagingRoot -Recurse -Force
	}
}