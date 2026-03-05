# 특허청 XML 양식 가이드

특허로 전자출원용 XML 양식 작성 가이드입니다.

---

## XML 기본 구조

```xml
<?xml version="1.0" encoding="UTF-8"?>
<kr-patent-document lang="ko" country="KR" doc-type="application">
  <bibliographic-data>
    <!-- 서지사항 -->
  </bibliographic-data>
  <description>
    <!-- 명세서 -->
  </description>
  <claims>
    <!-- 청구범위 -->
  </claims>
  <abstract>
    <!-- 요약서 -->
  </abstract>
</kr-patent-document>
```

---

## 명세서 XML 템플릿

```xml
<?xml version="1.0" encoding="UTF-8"?>
<description>
  <invention-title lang="ko">
    {{발명의_명칭_한글}}
  </invention-title>
  <invention-title lang="en">
    {{발명의_명칭_영문}}
  </invention-title>

  <technical-field>
    <p num="0001">{{기술분야_내용}}</p>
  </technical-field>

  <background-art>
    <p num="0002">{{배경기술_내용_1}}</p>
    <p num="0003">{{배경기술_내용_2}}</p>
  </background-art>

  <citation-list>
    <patent-literature>
      <citation num="1">
        <patcit>
          <document-id>
            <country>KR</country>
            <doc-number>{{특허문헌_번호}}</doc-number>
          </document-id>
        </patcit>
      </citation>
    </patent-literature>
    <non-patent-literature>
      <citation num="1">
        <nplcit>{{비특허문헌_내용}}</nplcit>
      </citation>
    </non-patent-literature>
  </citation-list>

  <disclosure>
    <tech-problem>
      <p num="0004">{{해결하려는_과제}}</p>
    </tech-problem>

    <tech-solution>
      <p num="0005">{{과제_해결_수단}}</p>
    </tech-solution>

    <advantageous-effects>
      <p num="0006">{{발명의_효과}}</p>
    </advantageous-effects>
  </disclosure>

  <description-of-drawings>
    <p num="0007">도 1은 {{도면1_설명}}</p>
    <p num="0008">도 2는 {{도면2_설명}}</p>
  </description-of-drawings>

  <mode-for-invention>
    <p num="0009">{{실시예_내용}}</p>
  </mode-for-invention>

  <reference-signs-list>
    <p num="0010">{{부호의_설명}}</p>
  </reference-signs-list>
</description>
```

---

## 청구범위 XML 템플릿

```xml
<?xml version="1.0" encoding="UTF-8"?>
<claims>
  <!-- 독립항 -->
  <claim num="1" claim-type="independent">
    <claim-text>
      {{독립항_내용}}
    </claim-text>
  </claim>

  <!-- 종속항 -->
  <claim num="2" claim-type="dependent">
    <claim-ref idref="1">제1항</claim-ref>
    <claim-text>
      에 있어서, {{종속항_내용}}
    </claim-text>
  </claim>

  <!-- 방법 독립항 -->
  <claim num="3" claim-type="independent">
    <claim-text>
      {{방법_청구항_내용}}
    </claim-text>
  </claim>
</claims>
```

---

## 요약서 XML 템플릿

```xml
<?xml version="1.0" encoding="UTF-8"?>
<abstract>
  <p>{{요약_내용}}</p>
  <representative-figure>1</representative-figure>
</abstract>
```

---

## 전체 출원서 XML 템플릿

```xml
<?xml version="1.0" encoding="UTF-8"?>
<kr-patent-application>
  <application-body>
    <!-- 출원인 정보 -->
    <applicants>
      <applicant sequence="1">
        <addressbook>
          <name>{{출원인_이름}}</name>
          <address>
            <city>{{도시}}</city>
            <street>{{상세주소}}</street>
            <postcode>{{우편번호}}</postcode>
            <country>KR</country>
          </address>
        </addressbook>
      </applicant>
    </applicants>

    <!-- 발명자 정보 -->
    <inventors>
      <inventor sequence="1">
        <addressbook>
          <name>{{발명자_이름}}</name>
          <address>
            <country>KR</country>
          </address>
        </addressbook>
      </inventor>
    </inventors>

    <!-- IPC 분류 -->
    <classifications-ipc>
      <main-classification>{{주분류_IPC}}</main-classification>
      <further-classification>{{부분류_IPC}}</further-classification>
    </classifications-ipc>

    <!-- 발명의 명칭 -->
    <invention-title lang="ko">{{발명의_명칭}}</invention-title>
  </application-body>
</kr-patent-application>
```

---

## 마크다운 → XML 변환 스크립트

### Python 변환기

```python
import re

def md_to_patent_xml(md_content):
    """마크다운 명세서를 XML로 변환"""

    xml_parts = []
    xml_parts.append('<?xml version="1.0" encoding="UTF-8"?>')
    xml_parts.append('<description>')

    # 발명의 명칭 추출
    title_match = re.search(r'## 【발명의 명칭】\s*\n(.+)', md_content)
    if title_match:
        title = title_match.group(1).strip()
        xml_parts.append(f'  <invention-title lang="ko">{title}</invention-title>')

    # 기술분야 추출
    tech_match = re.search(r'## 【기술분야】\s*\n(.+?)(?=##|$)', md_content, re.DOTALL)
    if tech_match:
        tech = clean_text(tech_match.group(1))
        xml_parts.append(f'  <technical-field>')
        xml_parts.append(f'    <p num="0001">{tech}</p>')
        xml_parts.append(f'  </technical-field>')

    # 배경기술 추출
    bg_match = re.search(r'## 【발명의 배경이 되는 기술】\s*\n(.+?)(?=##|$)', md_content, re.DOTALL)
    if bg_match:
        bg = clean_text(bg_match.group(1))
        xml_parts.append(f'  <background-art>')
        xml_parts.append(f'    <p num="0002">{bg}</p>')
        xml_parts.append(f'  </background-art>')

    # ... (다른 섹션들도 유사하게 처리)

    xml_parts.append('</description>')

    return '\n'.join(xml_parts)


def clean_text(text):
    """텍스트 정리"""
    text = re.sub(r'\n+', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')
    return text.strip()


# 사용 예시
with open('명세서.md', 'r', encoding='utf-8') as f:
    md_content = f.read()

xml_output = md_to_patent_xml(md_content)

with open('명세서.xml', 'w', encoding='utf-8') as f:
    f.write(xml_output)
```

---

## 특허로 제출 형식

### 파일 구성
```
출원서류.zip
├── application.xml      # 출원서
├── description.xml      # 명세서
├── claims.xml           # 청구범위
├── abstract.xml         # 요약서
└── drawings/
    ├── drawing-1.tif    # 도면 1
    ├── drawing-2.tif    # 도면 2
    └── ...
```

### 도면 규격
- 형식: TIFF, PNG, JPEG
- 해상도: 300 DPI 이상
- 색상: 흑백 권장
- 크기: A4 이내

---

## 검증 도구

### 특허로 XML 검증기
1. 특허로 접속 (www.patent.go.kr)
2. 전자출원 SW 실행
3. XML 파일 불러오기
4. 자동 검증 실행

### 오류 유형
| 오류 | 원인 | 해결 |
|------|------|------|
| 인코딩 오류 | UTF-8 아닌 인코딩 | UTF-8로 저장 |
| 태그 오류 | 닫는 태그 누락 | 태그 쌍 확인 |
| 필수항목 누락 | 필수 태그 없음 | 누락 항목 추가 |
