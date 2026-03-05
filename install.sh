#!/bin/bash
# Patent Skill 설치 스크립트

CLAUDE_DIR="$HOME/.claude"

echo "Patent Skill 설치 중..."

# 디렉토리 생성
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/commands"

# 파일 복사
cp -r patent "$CLAUDE_DIR/skills/"
cp patent.md "$CLAUDE_DIR/commands/"

echo "설치 완료!"
echo ""
echo "사용 방법: /patent"
