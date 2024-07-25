## ユーザー権限で実行しているかチェック
if (([Security.Principal.WindowsPrincipal]`
			[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
			[Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Write-Error "This script need to be run in a regular (non-admin) console." -ErrorAction Stop
}


## ==================================================
## scoop
## ==================================================

Write-Host "Installing Apps via scoop..." -ForegroundColor Magenta

# scoop 本体のインストール
if (!(Get-Command -Name "scoop" -ErrorAction SilentlyContinue)) {
	Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# scoop の動作に必要な git をインストール
if (!(scoop export | Select-String "\bgit\b")) {
	scoop install git
}

$buckets = scoop bucket list

# 公式 bucket を追加
if (!$buckets.Contains('extras')) {
	scoop bucket add extras
}

# 個人 bucket を追加
if (!$buckets.Contains('my')) {
	scoop bucket add my https://github.com/amano41/scoop-bucket
}

# scoop 本体を更新
scoop update 6>&1 | Out-Null

## インストール済みのパッケージ
$installed = @()
foreach ($pkg in (scoop export)) {
	$installed += ($pkg -split " ")[0]
}

# main
$packages = @(
	"bat",
	"dark",
	"delta",
	"fd",
	"fzf",
	"gh",
	"gow",
	"grex",
	"gsudo",
	"imagemagick",
	"innounp",
	"lessmsi",
	"lsd",
	"pandoc",
	"pipx",
	"poetry",
	"python",
	"r",
	"ripgrep",
	"sd",
	"starship",
	"uutils-coreutils",
	"zoxide"
)

foreach ($pkg in $packages) {
	if (!($installed -contains $pkg)) {
		Write-Host $pkg
		scoop install $pkg 6>&1 | Out-Null
		$installed += ($pkg)
	}
}

# extras
$packages = @(
	"bitwarden",
	"ccleaner",
	"eartrumpet",
	"everything",
	"fastcopy",
	"greenshot",
	"jamovi",
	"keypirinha",
	"mpc-be",
	"obs-studio",
	"obsidian",
	"posh-git",
	"quicklook",
	"rstudio",
	"sumatrapdf",
	"winscp"
)

foreach ($pkg in $packages) {
	if (!($installed -contains $pkg)) {
		Write-Host $pkg
		scoop install $pkg 6>&1 | Out-Null
		$installed += ($pkg)
	}
}

# my
$packages = @(
	"allrename",
	"cassava",
	"clipboard-history",
	"keyhac",
	"massigra",
	"mery",
	"rapture",
	"registry-finder",
	"sizer",
	"sylphyhorn-plus",
	"trayvolume",
	"tresgrep",
	"win32yank",
	"winmerge-jp",
	"xdoc2txt"
)

foreach ($pkg in $packages) {
	if (!($installed -contains $pkg)) {
		Write-Host $pkg
		scoop install $pkg 6>&1 | Out-Null
		$installed += ($pkg)
	}
}


## ==================================================
## pipx
## ==================================================

Write-Host "Installing Apps via pipx..." -ForegroundColor Magenta

pipx ensurepath

pipx install exrex
pipx install git+https://github.com/amano41/dynalist.git
pipx install git+https://github.com/amano41/qrc.git
