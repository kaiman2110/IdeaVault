<#
.SYNOPSIS
    IdeaVault にメモをクイック投入する。
.DESCRIPTION
    inbox/ にfrontmatter付きのメモファイルを作成する。
.PARAMETER Title
    メモのタイトル。省略時は対話モードで入力。
.PARAMETER Tags
    カンマ区切りのタグ。例: "godot,save-system"
.PARAMETER Type
    メモの種別。idea (デフォルト), task, reference, exploration
.EXAMPLE
    .\quick-add.ps1 "セーブ機能を改善したい"
    .\quick-add.ps1 "シェーダー記事" -Tags "godot,shader" -Type reference
#>
param(
    [Parameter(Position = 0)]
    [string]$Title,
    [string]$Tags = "",
    [ValidateSet("idea", "task", "reference", "exploration")]
    [string]$Type = "idea"
)

$ErrorActionPreference = "Stop"
$VaultRoot = Split-Path -Parent $PSScriptRoot

if (-not $Title) {
    $Title = Read-Host "メモのタイトル"
    if (-not $Title) { Write-Error "タイトルは必須です。"; exit 1 }
    if (-not $Tags) {
        $t = Read-Host "タグ（カンマ区切り、省略可）"
        if ($t) { $Tags = $t }
    }
}

$now = Get-Date
$id = $now.ToString("yyyyMMddHHmmss")
$dateStr = $now.ToString("yyyy-MM-dd")
$fileTs = $now.ToString("yyyyMMdd-HHmmss")

$needs = "brainstorm"
if ($Type -eq "task") { $needs = "execution" }
if ($Type -eq "reference") { $needs = "research" }

$tagList = @()
if ($Tags) {
    $tagList = @($Tags -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
if ($tagList.Count -eq 0) {
    $tagsYaml = "[]"
} else {
    $lines = $tagList | ForEach-Object { "  - $_" }
    $tagsYaml = "`r`n" + ($lines -join "`r`n")
}

$safeTitle = $Title -replace '[\\/:*?"<>|]', ''
$fileName = "${fileTs}_${safeTitle}.md"
$filePath = Join-Path (Join-Path $VaultRoot "inbox") $fileName

$L = "`r`n"
$fm = "---" + $L
$fm += "id: `"$id`"" + $L
$fm += "title: `"$Title`"" + $L
$fm += "created: $dateStr" + $L
$fm += "updated: $dateStr" + $L
$fm += "needs: $needs" + $L
$fm += "tags: $tagsYaml" + $L
$fm += "type: $Type" + $L

if ($Type -eq "task") {
    $fm += "priority: medium" + $L
}
if ($Type -eq "reference") {
    $fm += "source: `"`"" + $L
}

$fm += "related: []" + $L
$fm += "---" + $L

$body = ""
if ($Type -eq "task") {
    $body = $L + "## やること" + $L + $L + "## TODO" + $L + $L + "- [ ]" + $L + $L + "## 備考" + $L
} elseif ($Type -eq "reference") {
    $body = $L + "## 概要" + $L + $L + "## 試したいこと" + $L + $L + "## メモ" + $L
} else {
    $body = $L + "## 何を思いついたか" + $L + $L + "## なぜやりたいか" + $L + $L + "## 気になること・未解決の疑問" + $L
}

$content = $fm + $body
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)

Write-Host ""
Write-Host "Created: inbox/$fileName" -ForegroundColor Green
$tagDisplay = $tagList -join ", "
Write-Host "  type: $Type | needs: $needs | tags: $tagDisplay"
