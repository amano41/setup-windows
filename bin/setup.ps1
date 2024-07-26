
Push-Location $PSScriptRoot


## ==================================================
## 管理者権限のチェック
## ==================================================

if (!([Security.Principal.WindowsPrincipal]`
		[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
		[Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Write-Error "This script need to be run with elevated privileges." -ErrorAction Stop
}


## ==================================================
## レジストリに書き込むヘルパー関数
## ==================================================

function Set-Registry($path, $key, $value) {
	if (!(Test-Path $path)) {
		New-Item -Path $path -Force | Out-Null
	}
	Set-ItemProperty -Path $path -Name $key -Value $value | Out-Null
}


## ==================================================
## キーボードの設定
## ==================================================

Write-Host "Setting up Keyboard..." -ForegroundColor Magenta

## US 配列に変更
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" "LayerDriver JPN" "kbd101.dll"
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" "OverrideKeyboardIdentifier" "PCAT_101KEY"
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" "OverrideKeyboardType" 7
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters" "OverrideKeyboardSubtype" 0

## CapsLock (0x3a) ⇒ RCtrl (0x1de0)
## RCtrl (0x1de0) ⇒ LCtrl (0x1d)
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" `
	-Name "Scancode Map" `
	-Type Binary `
	-Value (`
		0x00,0x00,0x00,0x00,`
		0x00,0x00,0x00,0x00,`
		0x03,0x00,0x00,0x00,`
		0x1d,0xe0,0x3a,0x00,`
		0x1d,0x00,0x1d,0xe0,`
		0x00,0x00,0x00,0x00 `
	)

# キーリピートを高速化
Set-Registry "HKCU:\Control Panel\Accessibility\Keyboard Response" "AutoRepeatDelay" "500"
Set-Registry "HKCU:\Control Panel\Accessibility\Keyboard Response" "AutoRepeatRate" "50"
Set-Registry "HKCU:\Control Panel\Accessibility\Keyboard Response" "BounceTime" "0"
Set-Registry "HKCU:\Control Panel\Accessibility\Keyboard Response" "DelayBeforeAcceptance" "0"
Set-Registry "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "3"


## ==================================================
## マウスの設定
## ==================================================

Write-Host "Setting up Mouse..." -ForegroundColor Magenta

# ポインターのサイズ： 16 * (size + 1)
Set-Registry "HKCU:\Control Panel\Cursors" "CursorBaseSize" 80

# ポインターの色
Set-Registry "HKCU:\Control Panel\Cursors" "(Default)" "Windows Inverted"

# カーソル速度
Set-Registry "HKCU:\Control Panel\Mouse" "MouseSensitivity" "20"

# 一度にスクロールする行数
Set-Registry "HKCU:\Control Panel\Desktop" "WheelScrollLines" "9"


## ==================================================
## マシンレベルの設定
## ==================================================

Write-Host "Setting up Group Policies Options..." -ForegroundColor Magenta

# ロック画面を無効にする
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreen" 1

# コルタナを無効にする
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0
Get-AppxPackage -Name Microsoft.549981C3F5F10 -AllUsers | Remove-AppxPackage

# Web 検索を無効にする
Set-Registry "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1

# アクティビティ履歴を無効にする
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableActivityFeed" 0
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "PublishUserActivities" 0
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "UploadUserActivities" 0

# クリップボード履歴を無効にする
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowClipboardHistory" 0
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowCrossDeviceClipboard" 0

# 診断＆フィードバックを無効にする
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1

# 3D オブジェクトを非表示にする
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" "ThisPCPolicy" "Hide"

# ナビゲーションウィンドウの HDD を非表示にする
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}") {
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\DelegateFolders\{F5FB2C77-0E2F-4A16-A381-3E560C68BC83}"
}

# 設定画面上部のヘッダーを非表示にする
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" "EnabledState" 1
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Control\FeatureManagement\Overrides\4\4095660171" "EnabledStateOptions" 1
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" "EnabledState" 1
Set-Registry "HKLM:\SYSTEM\CurrentControlSet\Control\FeatureManagement\Overrides\4\2674077835" "EnabledStateOptions" 1


## ==================================================
## エクスプローラーの設定
## ==================================================

Write-Host "Setting up Explorer Options..." -ForegroundColor Magenta

# 拡張子を表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# 隠しファイル・隠しフォルダ・隠しドライブを表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

# チェックボックスを使用しない
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "AutoCheckSelect" 0

# タイトルバーにフルパスを表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

# クイックアクセスを無効化して PC を開く
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1

# 最近使ったファイルをクイックアクセスに表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowRecent" 0

# よく使うフォルダをクイックアクセスに表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowFrequent" 0


## ==================================================
## デスクトップアイコンの設定
## ==================================================

Write-Host "Setting up Desktop Icons..." -ForegroundColor Magenta

# PC を非表示にする
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 1

# ユーザーフォルダを非表示にする
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" 1

# ネットワークを非表示にする
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" 1

# ごみ箱を非表示にする
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{645FF040-5081-101B-9F08-00AA002F954E}" 1

# コントロールパネルを非表示にする
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" 1

# ライブラリを非表示にする
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{031E4825-7B94-4dc3-B131-E946B44C8DD5}" 1

# OneDrive を非表示にする
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" "{018D5C66-4533-4307-9B53-224DE2ED1FE6}" 1


## ==================================================
## タスクバーボタンの設定
## ==================================================

Write-Host "Setting up Taskbar Buttons..." -ForegroundColor Magenta

# 検索ボックスを非表示にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0

# ニュースと関心事を非表示にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" "ShellFeedsTaskbarViewMode" 2
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" "EnableFeeds" 0

# ウィジェットを非表示にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" 0

# タスクビューボタンを非表示にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0

# People を非表示にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" "PeopleBand" 0
Set-Registry "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "HidePeopleBar" 1

# 今すぐ会議を開始するを無効にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAMeetNow" 1

# Windows Ink ワークスペースボタンを非表示にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" "PenWorkspaceButtonDesiredVisibility" 0
Set-Registry "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" "AllowWindowsInkWorkspace" 0

# タッチキーボードボタンを非表示にする
Set-Registry "HKCU:\SOFTWARE\Microsoft\TabletTip\1.7" "TipbandDesiredVisibility" 0

# Copilot を非表示にする
Set-Registry "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 1


## ==================================================
## タスクバーからピン留めを削除
## ==================================================

Write-Host "Removing Pinned Items from Taskbar..." -ForegroundColor Magenta

# ショートカットを削除
Remove-Item "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*.lnk"

# レジストリを初期化
$path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
Set-ItemProperty -Path "$path" -Name "Favorites" -Type Binary -Value ([byte[]](255))
Remove-ItemProperty -Path "$path" -Name "FavoritesResolve"

# エクスプローラーの再起動で反映
Write-Host "Restarting Explorer..." -ForegroundColor Yellow
Stop-Process -Name Explorer -Force


## ==================================================
## 設定 → 個人用設定
## ==================================================

Write-Host "Setting up Personalization..." -ForegroundColor Magenta

# ロック画面：ロック画面にトリビアやヒントなどの情報を表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "RotatingLockScreenOverlayEnabled" 0

# スタート：よく使うアプリを表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" 0

# スタート：ときどきスタートメニューにおすすめのアプリを表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0

# スタート：スタートメニューまたはタスクバーのジャンプリストに最近開いた項目を表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackDocs" 0

# タスクバー：タスクバーをロックする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSizeMove" 0

# タスクバー：デスクトップをプレビューする
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "DisablePreviewDesktop" 1

# タスクバー：画面上のタスクバーの位置　⇒　左
$path = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
$name = "Settings"
$value = (Get-ItemProperty -Path $path -Name $name).Settings
$value[12] = 0
Set-ItemProperty -Path $path -Name $name -Value $value

# エクスプローラーの再起動で反映
Write-Host "Restarting Explorer..." -ForegroundColor Yellow
Stop-Process -Name Explorer -Force

## タスクバー：タスクバーボタンを結合する
Set-Registry "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarGlomLevel" 0

## タスクバー：タスクバーをすべてのディスプレイに表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "MMTaskbarEnabled" 0


## ==================================================
## 設定 → システム → 通知とアクション
## ==================================================

Write-Host "Setting up Notifications..." -ForegroundColor Magenta

# ロック画面に通知を表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" 0

# ロック画面にリマインダーと VolP の着信を表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" 0

# Windows へようこその情報を表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-310093Enabled" 0

# Windows を使用するためのヒントやおすすめの方法を取得
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SoftLandingEnabled" 0


## ==================================================
## 設定 → プライバシー → Windows のアクセス許可
## ==================================================

Write-Host "Setting up Privacy..." -ForegroundColor Magenta

# 広告識別子の使用をアプリに許可する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0

# Windows 追跡アプリの起動を許可する　※個人用設定 → スタート → よく使うアプリ　と同じレジストリエントリ
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start_TrackProgs" 0

# 設定アプリでおすすめのコンテンツを表示する
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353694Enabled" 0
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-353696Enabled" 0

# 音声認識
Set-Registry "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" 0

# 手描き入力
Set-Registry "HKCU:\Software\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0

# フィードバックの間隔
Set-Registry "HKCU:\Software\Microsoft\Siuf\Rules" "PeriodInNanoSeconds" 0
Set-Registry "HKCU:\Software\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0

## ==================================================
## 設定 → プライバシー → アプリのアクセス許可
## ==================================================

Write-Host "Setting up Permissions..." -ForegroundColor Magenta

# 位置情報
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny"

# カメラ
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" "Value" "Deny"

# マイク
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" "Value" "Deny"

# 音声によるアクティブ化
Set-Registry "HKCU:\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" "AgentActivationEnabled" 0

# 通知
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" "Value" "Deny"

# アカウント情報
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" "Value" "Deny"

# 連絡先
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" "Value" "Deny"

# カレンダー
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointment" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointment" "Value" "Deny"

# 電話をかける
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" "Value" "Deny"

# 通話履歴
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" "Value" "Deny"

# メール
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" "Value" "Deny"

# タスク
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" "Value" "Deny"

# メッセージング
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" "Value" "Deny"

# 無線
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" "Value" "Deny"

# 他のデバイス（ペアリングされていないデバイスとの通信）
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" "Value" "Deny"

# バックグラウンドアプリ（アプリのバックグランド実行）
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1

# アプリの診断
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" "Value" "Deny"

# ドキュメント
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" "Value" "Deny"

# ピクチャ
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" "Value" "Deny"

# ビデオ
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" "Value" "Deny"

# ファイルシステム
Set-Registry "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" "Value" "Deny"
Set-Registry "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" "Value" "Deny"


## ==================================================
## 環境変数の設定
## ==================================================

Write-Host "Setting up Environment Variables..." -ForegroundColor Magenta

## HOME
[Environment]::SetEnvironmentVariable("HOME", $env:USERPROFILE, "User")

## PATH
$path = @()
$path += "$env:USERPROFILE\.local\bin"
$path += "$env:USERPROFILE\bin"
$path += "$env:USERPROFILE\dotfiles\bin\windows"
$path += "$env:USERPROFILE\dotfiles\bin"
$path += "$env:USERPROFILE\OneDrive\bin"

$path_user = [Environment]::GetEnvironmentVariable("PATH", "User")
$path_user -split ';' | ForEach-Object {
	$p = $_.trim()
	if (!($path -contains $p)) {
		$path += $p
	}
}

$path = $path -join ";"
[Environment]::SetEnvironmentVariable("PATH", $path, "User")

## TEMP
$temp_user = "R:\Temp\User"
if (Test-Path $temp_user) {
	[Environment]::SetEnvironmentVariable("TEMP", $temp_user, "User")
	[Environment]::SetEnvironmentVariable("TMP", $temp_user, "User")
}

$temp_system = "R:\Temp\System"
if (Test-Path $temp_system) {
	[Environment]::SetEnvironmentVariable("TEMP", $temp_system, "Machine")
	[Environment]::SetEnvironmentVariable("TMP", $temp_system, "Machine")
}

## LANG
[Environment]::SetEnvironmentVariable("LANG", "ja_JP.UTF-8", "User")

## WSLENV
[Environment]::SetEnvironmentVariable("WSLENV", "TMP/p", "User")

## Python
[Environment]::SetEnvironmentVariable("PYTHONUTF8", "1", "User")
[Environment]::SetEnvironmentVariable("PYTHONDONTWRITEBYTECODE", "1", "User")
[Environment]::SetEnvironmentVariable("PIPENV_VENV_IN_PROJECT", "1", "User")


## ==================================================
## PowerShell モジュールのインストール
## ==================================================

Write-Host "Installing Powershell Modules..." -ForegroundColor Magenta

# PowerShellGet で NuGet ベースのリポジトリを操作するために必要
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# PSGallery を信頼するリポジトリに追加
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Install-Module PSFzf

# PSGallery を信頼するリポジトリから削除
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted


## ==================================================
## ストアアプリの削除
## ==================================================

Write-Host "Removing Default Store Apps..." -ForegroundColor Magenta

if ($PSVersionTable.PSVersion.Major -ge 7) {
	Import-Module -Name Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
}

$OldProgressPreference = $ProgressPreference
$ProgressPreference = "SilentlyContinue"

@(
	"Microsoft.3DBuilder",
	"Microsoft.BingFinance",
	"Microsoft.BingNews"
	"Microsoft.BingSports",
	"Microsoft.BingTranslator",
	"Microsoft.BingWeather",
	"Microsoft.CommsPhone",
	"Microsoft.FreshPaint",
	"Microsoft.GetHelp",
	"Microsoft.Getstarted",
	"Microsoft.Messaging",
	"Microsoft.Microsoft3DViewer",
	"Microsoft.MicrosoftOfficeHub",
	"Microsoft.MicrosoftSolitaireCollection",
	"Microsoft.MicrosoftStickyNotes",
	"Microsoft.MinecraftUWP",
	"Microsoft.MixedReality.Portal",
	"Microsoft.NetworkSpeedTest",
	"Microsoft.Office.OneNote",
	"Microsoft.Office.Sway",
	"Microsoft.OneConnect",
	"Microsoft.People",
	"Microsoft.Print3D",
	"Microsoft.ScreenSketch",
	"Microsoft.SkypeApp",
	"Microsoft.Wallet",
	"Microsoft.Windows.Photos",
	"Microsoft.WindowsAlarms",
	"Microsoft.WindowsCalculator",
	"Microsoft.WindowsCamera",
	"microsoft.windowscommunicationsapps",
	"Microsoft.WindowsFeedbackHub",
	"Microsoft.WindowsMaps",
	"Microsoft.WindowsPhone",
	"Microsoft.WindowsSoundRecorder",
	"Microsoft.Xbox.TCUI",
	"Microsoft.XboxApp",
	"Microsoft.XboxGameOverlay",
	"Microsoft.XboxGamingOverlay",
	"Microsoft.XboxIdentityProvider",
	"Microsoft.XboxSpeechToTextOverlay",
	"Microsoft.YourPhone",
	"Microsoft.ZuneMusic",
	"Microsoft.ZuneVideo",
	"Microsoft.5220175982889",
	"king.com.BubbleWitch3Saga",
	"king.com.CandyCrushSodaSaga",
	"king.com.*",
	"*bing*",
	"*Autodesk*",
	"*Dell*",
	"*Facebook*",
	"*Keeper*",
	"*MarchofEmpires*",
	"*Netflix*",
	"*Plex*",
	"*Twitter*",
	"ActiproSoftwareLLC.562882FEEB491",
	"46928bounde.EclipseManager",
	"PandoraMediaInc.29680B314EFC2",
	"D5EA27B7.Duolingo-LearnLanguagesforFree",
	"828B5831.HiddenCityMysteryofShadows",
	"NAVER.LINE*",
	"DolbyLaboratories.DolbyAccess",
	"7EE7776C.LinkedInforWindows",
	"flaregamesGmbH.RoyalRevolt2",
	"SpotifyAB.SpotifyMusic"
) | ForEach-Object {
	Get-AppxPackage -Name $_ -AllUsers | Remove-AppxPackage | Out-Null
}

Clear-Host
$ProgressPreference = $OldProgressPreference


## ==================================================
## Files のインストール
## ==================================================

Write-Host "Installing Files App..." -ForegroundColor Magenta

Add-AppxPackage -AppInstallerFile "https://cdn.files.community/files/stable/Files.Package.appinstaller"


## ==================================================
## WinGet
## ==================================================

if (!(Get-Command -Name "winget" -ErrorAction SilentlyContinue)) {
	Write-Host "Warning: `"winget`" not found !!" -ForegroundColor Red
	Read-Host "Update `"App Installer`" and press any key to continue:" -ForegroundColor Yellow
}

Write-Host "Installing Apps via WinGet..." -ForegroundColor Magenta

winget install -h -e --id Git.Git
winget install -h -e --id 7zip.7zip
winget install -h -e --id Google.Chrome
winget install -h -e --id Mozilla.Firefox
winget install -h -e --id VivaldiTechnologies.Vivaldi
winget install -h -e --id Microsoft.PowerShell
winget install -h -e --id Microsoft.PowerToys
winget install -h -e --id Microsoft.VisualStudioCode
winget install -h -e --id Microsoft.WindowsTerminal
winget install -h -e --id Zoom.Zoom
winget install -h -e --id Biscuit.Biscuit
winget install -h -e --id CubeSoft.CubePDF
winget install -h -e --id CubeSoft.CubePDFUtility
winget install -h -e --id HermannSchinagl.LinkShellExtension


## ==================================================
## WSL
## ==================================================

Write-Host "Setting up WSL..." -ForegroundColor Magenta

wsl --install


## ==================================================
## 終了
## ==================================================

Pop-Location
Write-Host "Setup Completed." -ForegroundColor Magenta
