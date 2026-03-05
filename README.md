# Patent Skill for Claude Code

변리사 없이 특허 출원을 도와주는 Claude Code 스킬입니다.

## 주요 기능

### 기본 기능
- 선행기술 자동 검색 (KIPRIS, Google Patents)
- 특허청 공식 양식에 맞는 명세서 생성
- 청구항 구조화 가이드
- 요약서 템플릿

### 고급 기능 (v2.0)
- **IPC 코드 자동 추천** - 키워드 기반 분류 코드 매핑
- **거절이유 대응 가이드** - 진보성/신규성/기재불비 대응 전략
- **KIPRIS API 연동** - Python/Node.js 코드 제공
- **Mermaid 도면 자동화** - 시스템 구성도/플로우차트 자동 생성
- **XML 양식 변환** - 특허로 전자출원용 XML 템플릿
- **청구항 자동 생성** - AI 프롬프트로 청구항 초안 작성
- **심사관 거절 패턴 분석** - 거절 유형별 대응 템플릿
- **RAG 시스템 구축 가이드** - 특허 DB 기반 검색 증강 생성

---

## 설치 방법

### Windows (PowerShell)
```powershell
# 1. 저장소 클론
git clone https://github.com/yokiu01/patent-skill.git
cd patent-skill

# 2. 설치 스크립트 실행
.\install.ps1
```

### macOS / Linux
```bash
# 1. 저장소 클론
git clone https://github.com/yokiu01/patent-skill.git
cd patent-skill

# 2. 설치 스크립트 실행
chmod +x install.sh
./install.sh
```

### 수동 설치
```bash
# Windows
xcopy /E /I patent %USERPROFILE%\.claude\skills\patent
copy patent.md %USERPROFILE%\.claude\commands\

# macOS/Linux
cp -r patent ~/.claude/skills/
cp patent.md ~/.claude/commands/
```

---

## 사용 방법

### 명령어
```
/patent
```

### 자연어
```
"특허 출원하고 싶어. 내 발명은 [발명 설명]"
```

### 작업 흐름
1. **발명 분석** - 핵심 기술 파악, IPC 코드 추정
2. **선행기술 조사** - KIPRIS/Google Patents 검색
3. **차별점 분석** - 신규성/진보성 확인
4. **명세서 작성** - 공식 양식에 맞게 작성
5. **청구항 작성** - 독립항/종속항 구성
6. **요약서 작성** - 400자 이내 요약
7. **파일 출력** - 마크다운/XML 파일 생성

---

## 파일 구조

```
~/.claude/
├── commands/
│   └── patent.md                    # /patent 명령어
└── skills/
    └── patent/
        ├── patent.md                # 메인 스킬
        ├── templates/
        │   ├── 명세서.md            # 명세서 양식
        │   ├── 청구항.md            # 청구항 가이드
        │   ├── 요약서.md            # 요약서 양식
        │   ├── 거절이유_대응.md     # 거절 대응 가이드
        │   └── XML_양식.md          # 전자출원 XML
        ├── tools/
        │   ├── IPC_분류.md          # IPC 코드 추천
        │   ├── KIPRIS_API.md        # API 연동 코드
        │   ├── Mermaid_도면.md      # 도면 자동화
        │   ├── 청구항_프롬프트.md   # 청구항 생성 AI
        │   ├── 거절패턴_분석.md     # 거절 패턴 분석
        │   └── RAG_구축.md          # RAG 시스템 가이드
        └── examples/
            └── 샘플_AI서비스_특허.md # 등록 특허 예시
```

---

## 출원 비용 (2024년 기준)

| 항목 | 비용 |
|------|------|
| 출원료 | 46,000원 |
| 심사청구료 (기본) | 143,000원 + 44,000원×청구항수 |
| 등록료 (1~3년차) | 매년 15,000원 + 13,000원×청구항수 |

---

## 참고 자료

| 사이트 | URL | 용도 |
|--------|-----|------|
| **특허로** | https://www.patent.go.kr | 전자출원 |
| **KIPRIS** | https://www.kipris.or.kr | 선행기술 검색 |
| **KIPRIS+** | https://plus.kipris.or.kr | Open API |
| **특허청** | https://www.kipo.go.kr | 법령/서식 |
| **WIPO IPC** | https://www.wipo.int/classifications/ipc | IPC 검색 |

---

## 주의사항

1. **법적 조언 아님** - 이 도구는 작성 보조 도구이며, 법적 조언을 제공하지 않습니다
2. **선행기술 조사 필수** - 출원 전 반드시 유사 특허 확인
3. **비밀 유지** - 출원 전 발명 내용 공개 금지 (신규성 상실)
4. **복잡한 특허** - 권리범위가 중요한 경우 전문가 검토 권장

---

## 라이선스

MIT License

---

## 기여

이슈 및 PR 환영합니다!
