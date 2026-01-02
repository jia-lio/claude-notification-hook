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

# settings.json 생성 (기존 파일이 있으면 백업)
$settingsPath = "$claudeDir\settings.json"
if (Test-Path $settingsPath) {
    $backup = "$claudeDir\settings.backup.json"
    Copy-Item $settingsPath $backup
    Write-Host "Backed up existing settings to settings.backup.json" -ForegroundColor Yellow
}

$settings = @{
    hooks = @{
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
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8
Write-Host "Created settings.json" -ForegroundColor Green

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "Restart Claude Code to apply changes." -ForegroundColor Cyan
