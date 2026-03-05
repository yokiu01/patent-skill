# Patent Skill 설치 스크립트 (Windows PowerShell)

$CLAUDE_DIR = "$env:USERPROFILE\.claude"

Write-Host "Patent Skill 설치 중..."

# 디렉토리 생성
New-Item -ItemType Directory -Force -Path "$CLAUDE_DIR\skills" | Out-Null
New-Item -ItemType Directory -Force -Path "$CLAUDE_DIR\commands" | Out-Null

# 파일 복사
Copy-Item -Recurse -Force "patent" "$CLAUDE_DIR\skills\"
Copy-Item -Force "patent.md" "$CLAUDE_DIR\commands\"

Write-Host "설치 완료!"
Write-Host ""
Write-Host "사용 방법: /patent"
