# Patent Skill for Claude Code

변리사 없이 특허 출원을 도와주는 Claude Code 스킬입니다.

## 기능

- 선행기술 자동 검색 (KIPRIS, Google Patents)
- 특허청 공식 양식에 맞는 명세서 생성
- 청구항 구조화 가이드
- 요약서 템플릿

## 설치 방법

### Windows
```powershell
# 1. 저장소 클론
git clone https://github.com/YOUR_USERNAME/patent-skill.git

# 2. 파일 복사
xcopy /E /I patent-skill\patent %USERPROFILE%\.claude\skills\patent
copy patent-skill\patent.md %USERPROFILE%\.claude\commands\
```

### macOS / Linux
```bash
# 1. 저장소 클론
git clone https://github.com/YOUR_USERNAME/patent-skill.git

# 2. 파일 복사
cp -r patent-skill/patent ~/.claude/skills/
cp patent-skill/patent.md ~/.claude/commands/
```

## 사용 방법

```
/patent
```

또는 자연어로:
```
"특허 출원하고 싶어. 내 발명은 [발명 설명]"
```

## 파일 구조

```
~/.claude/
├── commands/
│   └── patent.md              # /patent 명령어
└── skills/
    └── patent/
        ├── patent.md          # 메인 스킬
        └── templates/
            ├── 명세서.md
            ├── 청구항.md
            └── 요약서.md
```

## 참고 자료

- [특허로](https://www.patent.go.kr) - 전자출원
- [KIPRIS](https://www.kipris.or.kr) - 선행기술 검색
- [특허청](https://www.kipo.go.kr) - 법령/서식
