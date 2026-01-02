# Claude Code Notification Hook

Claude Code 작업 완료 및 권한 요청 시 커스텀 팝업 알림을 표시합니다.

## 지원 환경

- VSCode (Claude Code 확장)

## 설치

PowerShell에서 실행하거나, Claude Code에 아래 명령어를 입력하면 자동으로 설치됩니다:

```powershell
irm https://raw.githubusercontent.com/jia-lio/claude-notification-hook/main/install.ps1 | iex
```

> **참고:** 설치 후 Claude Code를 재시작해야 적용됩니다.

## 기능

- 작업 완료 시 팝업 알림
- 권한 요청 시 팝업 알림
- 커스텀 이미지 지원
- 슬라이드 애니메이션

> **참고:** 이 알림은 이미지만 표시되며, 텍스트 메시지는 포함되지 않습니다.

## 커스터마이징

### 이미지 변경

`~/.claude/claudeImage.png` 파일을 원하는 이미지로 교체하세요. 팝업 크기가 이미지에 맞게 자동 조정됩니다.

### 표시 시간 변경

`~/.claude/show-popup.ps1` 파일에서 타이머 간격 수정:

```powershell
$timer.Interval = [TimeSpan]::FromSeconds(3)  # 3초 -> 원하는 시간
```

## 파일 구조

```
~/.claude/
├── settings.json      # 훅 설정
├── show-popup.ps1     # 팝업 스크립트
└── claudeImage.png    # 알림 이미지
```

## 제거

`~/.claude/settings.json`에서 hooks 섹션을 삭제하세요.
