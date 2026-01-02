# Claude Code Notification Hook Installer
# Usage: irm https://raw.githubusercontent.com/USERNAME/claude-notification-hook/main/install.ps1 | iex

$claudeDir = "$env:USERPROFILE\.claude"
$repoBase = "https://raw.githubusercontent.com/jia-lio/claude-notification-hook/main"

Write-Host "Installing Claude Code Notification Hook..." -ForegroundColor Cyan

# .claude 폴더 생성
if (!(Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    Write-Host "Created $claudeDir" -ForegroundColor Green
}

# show-popup.ps1 다운로드 (UTF-8 인코딩)
Write-Host "Downloading show-popup.ps1..." -ForegroundColor Yellow
$scriptContent = (Invoke-WebRequest -Uri "$repoBase/show-popup.ps1" -UseBasicParsing).Content
[System.IO.File]::WriteAllText("$claudeDir\show-popup.ps1", $scriptContent, [System.Text.Encoding]::UTF8)

# 기본 이미지 다운로드
Write-Host "Downloading default image..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "$repoBase/claudeImage.png" -OutFile "$claudeDir\claudeImage.png" -UseBasicParsing

# settings.json 머지 (기존 파일이 있으면 기존 설정 유지하면서 hooks 추가)
$settingsPath = "$claudeDir\settings.json"

# 추가할 hooks 정의
$newHooks = @{
    Stop = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "powershell -ExecutionPolicy Bypass -File `"$claudeDir\show-popup.ps1`""
                }
            )
        }
    )
    Notification = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "powershell -ExecutionPolicy Bypass -File `"$claudeDir\show-popup.ps1`""
                }
            )
        }
    )
    SubagentStop = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "powershell -ExecutionPolicy Bypass -File `"$claudeDir\show-popup.ps1`""
                }
            )
        }
    )
}

if (Test-Path $settingsPath) {
    # 기존 settings.json 읽기
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    # hooks 객체가 없으면 생성
    if (-not $settings.hooks) {
        $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue @{}
    }

    # 각 hook 추가 (기존 hook이 없는 경우에만)
    foreach ($hookName in $newHooks.Keys) {
        if (-not $settings.hooks.$hookName) {
            $settings.hooks | Add-Member -NotePropertyName $hookName -NotePropertyValue $newHooks[$hookName]
            Write-Host "Added $hookName hook" -ForegroundColor Green
        } else {
            Write-Host "$hookName hook already exists, skipping" -ForegroundColor Yellow
        }
    }

    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
    Write-Host "Merged hooks into existing settings.json" -ForegroundColor Green
} else {
    # 새 settings.json 생성
    $settings = @{
        hooks = $newHooks
    }
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
    Write-Host "Created settings.json" -ForegroundColor Green
}

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "Restart Claude Code to apply changes." -ForegroundColor Cyan
