# KIPRIS Open API 연동 가이드

KIPRIS Open API를 활용한 선행기술 조사 자동화 가이드입니다.

---

## API 개요

| 항목 | 내용 |
|------|------|
| **제공** | 특허청 + 한국특허정보원 |
| **URL** | https://plus.kipris.or.kr/openapi/ |
| **인증** | API Key (회원가입 후 발급) |
| **형식** | REST API (XML/JSON) |
| **비용** | 무료 (일일 호출 제한 있음) |

---

## API Key 발급 방법

1. **KIPRIS PLUS 접속**: https://plus.kipris.or.kr
2. **회원가입** (개인/기업)
3. **마이페이지 → Open API → 키 발급 신청**
4. **승인 후 API Key 확인**

---

## 주요 API 목록

### 1. 특허 검색 API

```
GET /openapi/rest/patUtiModInfoSearchSevice/freeSearchInfo
```

**파라미터**:
| 파라미터 | 필수 | 설명 |
|----------|:----:|------|
| `accessKey` | O | API Key |
| `word` | O | 검색어 |
| `patent` | - | 특허 포함 여부 (Y/N) |
| `utility` | - | 실용신안 포함 여부 |
| `numOfRows` | - | 결과 개수 (기본 10) |
| `pageNo` | - | 페이지 번호 |

**요청 예시**:
```
https://plus.kipris.or.kr/openapi/rest/patUtiModInfoSearchSevice/freeSearchInfo
?accessKey=YOUR_API_KEY
&word=딥러닝+동작+분석
&patent=Y
&numOfRows=20
```

### 2. 특허 상세 정보 API

```
GET /openapi/rest/patUtiModInfoSearchSevice/biblioSearchInfo
```

**파라미터**:
| 파라미터 | 필수 | 설명 |
|----------|:----:|------|
| `accessKey` | O | API Key |
| `applicationNumber` | O | 출원번호 |

### 3. 청구항 정보 API

```
GET /openapi/rest/patUtiModInfoSearchSevice/claimSearchInfo
```

---

## Python 연동 코드

### 기본 검색

```python
import requests
import xml.etree.ElementTree as ET

class KiprisAPI:
    BASE_URL = "https://plus.kipris.or.kr/openapi/rest"

    def __init__(self, api_key):
        self.api_key = api_key

    def search_patent(self, keyword, num_results=20):
        """특허 키워드 검색"""
        url = f"{self.BASE_URL}/patUtiModInfoSearchSevice/freeSearchInfo"
        params = {
            "accessKey": self.api_key,
            "word": keyword,
            "patent": "Y",
            "numOfRows": num_results
        }

        response = requests.get(url, params=params)
        return self._parse_response(response.text)

    def get_patent_detail(self, application_number):
        """특허 상세 정보 조회"""
        url = f"{self.BASE_URL}/patUtiModInfoSearchSevice/biblioSearchInfo"
        params = {
            "accessKey": self.api_key,
            "applicationNumber": application_number
        }

        response = requests.get(url, params=params)
        return self._parse_response(response.text)

    def _parse_response(self, xml_text):
        """XML 응답 파싱"""
        root = ET.fromstring(xml_text)
        items = []

        for item in root.findall('.//item'):
            patent = {
                'title': self._get_text(item, 'inventionTitle'),
                'application_number': self._get_text(item, 'applicationNumber'),
                'application_date': self._get_text(item, 'applicationDate'),
                'applicant': self._get_text(item, 'applicantName'),
                'ipc': self._get_text(item, 'ipcNumber'),
                'abstract': self._get_text(item, 'astrtCont')
            }
            items.append(patent)

        return items

    def _get_text(self, element, tag):
        """XML 요소 텍스트 추출"""
        el = element.find(tag)
        return el.text if el is not None else ""


# 사용 예시
if __name__ == "__main__":
    api = KiprisAPI("YOUR_API_KEY")

    # 선행기술 검색
    results = api.search_patent("딥러닝 동작 분석")

    for patent in results:
        print(f"제목: {patent['title']}")
        print(f"출원번호: {patent['application_number']}")
        print(f"IPC: {patent['ipc']}")
        print("-" * 50)
```

### 선행기술 분석 자동화

```python
class PriorArtAnalyzer:
    def __init__(self, api_key):
        self.kipris = KiprisAPI(api_key)

    def analyze_prior_art(self, invention_keywords):
        """선행기술 자동 분석"""
        all_results = []

        # 키워드 조합 검색
        for keyword in invention_keywords:
            results = self.kipris.search_patent(keyword)
            all_results.extend(results)

        # 중복 제거
        unique_results = self._remove_duplicates(all_results)

        # 관련도 분석
        analyzed = self._analyze_relevance(unique_results, invention_keywords)

        return analyzed

    def _remove_duplicates(self, results):
        """출원번호 기준 중복 제거"""
        seen = set()
        unique = []
        for r in results:
            if r['application_number'] not in seen:
                seen.add(r['application_number'])
                unique.append(r)
        return unique

    def _analyze_relevance(self, results, keywords):
        """관련도 점수 계산"""
        for r in results:
            score = 0
            title = r.get('title', '').lower()
            abstract = r.get('abstract', '').lower()

            for kw in keywords:
                if kw.lower() in title:
                    score += 2
                if kw.lower() in abstract:
                    score += 1

            r['relevance_score'] = score

        # 점수순 정렬
        return sorted(results, key=lambda x: x['relevance_score'], reverse=True)


# 사용 예시
analyzer = PriorArtAnalyzer("YOUR_API_KEY")

keywords = ["Bi-LSTM", "동작 분석", "한국무용", "개인화 학습"]
prior_arts = analyzer.analyze_prior_art(keywords)

print("=== 선행기술 분석 결과 ===")
for i, pa in enumerate(prior_arts[:10], 1):
    print(f"{i}. [{pa['relevance_score']}점] {pa['title']}")
    print(f"   출원번호: {pa['application_number']}")
```

---

## Node.js 연동 코드

```javascript
const axios = require('axios');
const xml2js = require('xml2js');

class KiprisAPI {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://plus.kipris.or.kr/openapi/rest';
    }

    async searchPatent(keyword, numResults = 20) {
        const url = `${this.baseUrl}/patUtiModInfoSearchSevice/freeSearchInfo`;
        const params = {
            accessKey: this.apiKey,
            word: keyword,
            patent: 'Y',
            numOfRows: numResults
        };

        const response = await axios.get(url, { params });
        return this.parseXML(response.data);
    }

    async parseXML(xmlData) {
        const parser = new xml2js.Parser();
        const result = await parser.parseStringPromise(xmlData);

        const items = result?.response?.body?.[0]?.items?.[0]?.item || [];

        return items.map(item => ({
            title: item.inventionTitle?.[0] || '',
            applicationNumber: item.applicationNumber?.[0] || '',
            applicant: item.applicantName?.[0] || '',
            ipc: item.ipcNumber?.[0] || ''
        }));
    }
}

// 사용 예시
const api = new KiprisAPI('YOUR_API_KEY');
api.searchPatent('딥러닝 동작 분석').then(results => {
    results.forEach(p => console.log(p.title));
});
```

---

## Claude Code 연동 방법

### 환경변수 설정
```bash
export KIPRIS_API_KEY="your_api_key_here"
```

### 스킬에서 활용
```
선행기술 조사 시:
1. WebSearch로 1차 검색
2. KIPRIS API로 정확한 특허 정보 확인
3. 상세 청구항 분석
```

---

## API 호출 제한

| 구분 | 제한 |
|------|------|
| 일일 호출 | 10,000건 |
| 초당 호출 | 10건 |
| 결과 개수 | 최대 100건/요청 |

---

## 참고 링크

- KIPRIS PLUS: https://plus.kipris.or.kr
- API 문서: https://plus.kipris.or.kr/openapi/
- 특허정보 포털: https://www.kipris.or.kr
