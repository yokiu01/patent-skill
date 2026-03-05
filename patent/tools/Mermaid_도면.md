# Mermaid 기반 특허 도면 자동화

Mermaid 문법으로 특허 도면을 자동 생성하는 가이드입니다.

---

## Mermaid 기본 문법

### 1. 플로우차트 (가장 많이 사용)

```mermaid
flowchart TD
    A[시작] --> B{조건}
    B -->|Yes| C[처리1]
    B -->|No| D[처리2]
    C --> E[끝]
    D --> E
```

### 2. 시퀀스 다이어그램

```mermaid
sequenceDiagram
    사용자->>시스템: 요청
    시스템->>DB: 조회
    DB-->>시스템: 결과
    시스템-->>사용자: 응답
```

### 3. 블록 다이어그램 (시스템 구성도)

```mermaid
block-beta
    columns 3
    A["모듈A"] B["모듈B"] C["모듈C"]
    D["처리부"]:3
```

---

## 특허 도면 템플릿

### 도 1. 전체 시스템 구성도

```mermaid
flowchart TB
    subgraph INPUT["입력부 (10)"]
        A1["영상 데이터"]
        A2["센서 데이터"]
    end

    subgraph SYSTEM["시스템 (100)"]
        B1["전처리 모듈 (110)"]
        B2["분석 모듈 (120)"]
        B3["최적화 모듈 (130)"]
        B4["피드백 모듈 (140)"]

        B1 --> B2
        B2 --> B3
        B3 --> B4
    end

    subgraph OUTPUT["출력부 (20)"]
        C1["피드백 UI"]
    end

    INPUT --> SYSTEM
    SYSTEM --> OUTPUT
```

### 도 2. 처리 플로우

```mermaid
flowchart TD
    START((시작)) --> A["데이터 입력 (S210)"]
    A --> B["전처리 (S220)"]
    B --> C["특징 추출 (S230)"]
    C --> D{"분석 완료?"}
    D -->|No| C
    D -->|Yes| E["결과 생성 (S240)"]
    E --> F["피드백 출력 (S250)"]
    F --> END((종료))
```

### 도 3. 신경망 구조

```mermaid
flowchart LR
    subgraph INPUT["입력층"]
        I1["x1"]
        I2["x2"]
        I3["xn"]
    end

    subgraph HIDDEN["은닉층 (Bi-LSTM)"]
        direction TB
        H1["Forward LSTM"]
        H2["Backward LSTM"]
        H3["Fusion Layer"]
        H1 --> H3
        H2 --> H3
    end

    subgraph OUTPUT["출력층"]
        O1["정확도"]
        O2["리듬"]
        O3["연속성"]
    end

    INPUT --> HIDDEN
    HIDDEN --> OUTPUT
```

### 도 4. 데이터 흐름

```mermaid
flowchart TB
    subgraph COLLECT["데이터 수집"]
        D1["사용자A 데이터"]
        D2["사용자B 데이터"]
        D3["사용자N 데이터"]
    end

    AGG["데이터 통합 (420)"]
    CLUSTER["군집 분석 (430)"]
    META["메타분석 (440)"]

    subgraph RESULT["분석 결과"]
        R1["난이도 프로파일"]
        R2["오류 패턴"]
        R3["개선 우선순위"]
    end

    COLLECT --> AGG
    AGG --> CLUSTER
    CLUSTER --> META
    META --> RESULT
```

---

## 사용 방법

### 1. GitHub/GitLab에서 렌더링

GitHub README.md에 Mermaid 코드 블록을 추가하면 자동 렌더링됩니다.

````markdown
```mermaid
flowchart TD
    A --> B
```
````

### 2. Mermaid Live Editor

온라인에서 즉시 미리보기 및 이미지 다운로드:
- https://mermaid.live

### 3. VS Code 확장

- **Markdown Preview Mermaid Support** 설치
- Markdown 파일에서 미리보기

### 4. CLI 도구로 이미지 변환

```bash
# 설치
npm install -g @mermaid-js/mermaid-cli

# PNG 변환
mmdc -i diagram.mmd -o diagram.png -b white

# PDF 변환
mmdc -i diagram.mmd -o diagram.pdf

# SVG 변환
mmdc -i diagram.mmd -o diagram.svg
```

---

## 특허 도면 자동 생성 프롬프트

Claude에게 다음과 같이 요청하세요:

```
발명의 구성요소:
- 입력부: 영상 데이터 수신
- 처리부: AI 분석
- 출력부: 피드백 제공

위 구성요소로 특허 도면용 Mermaid 다이어그램을 생성해줘.
도면 부호(100, 110, 120...)를 포함해서.
```

---

## 특허청 제출용 변환

### Mermaid → 이미지 → 특허 도면

1. **Mermaid 코드 작성**
2. **PNG/SVG로 내보내기**
3. **이미지 편집** (필요시)
   - 흑백 변환
   - 부호 추가/수정
   - 해상도 조정 (300 DPI)
4. **TIFF로 변환** (특허청 권장)

### 이미지 변환 명령어

```bash
# ImageMagick 사용
convert diagram.png -colorspace Gray -density 300 diagram.tif
```

---

## 템플릿 모음

### 시스템 구성도 템플릿

```mermaid
flowchart TB
    subgraph 입력부["입력부 (10)"]
        IN1["구성요소1"]
        IN2["구성요소2"]
    end

    subgraph 처리부["처리부 (100)"]
        P1["모듈1 (110)"]
        P2["모듈2 (120)"]
        P3["모듈3 (130)"]
        P1 --> P2 --> P3
    end

    subgraph 출력부["출력부 (20)"]
        OUT1["결과물"]
    end

    입력부 --> 처리부 --> 출력부
```

### 방법 플로우 템플릿

```mermaid
flowchart TD
    S1["단계1 (S110)"] --> S2["단계2 (S120)"]
    S2 --> S3{"판단 (S130)"}
    S3 -->|조건A| S4["처리A (S140)"]
    S3 -->|조건B| S5["처리B (S150)"]
    S4 --> S6["단계3 (S160)"]
    S5 --> S6
```

### 계층 구조 템플릿

```mermaid
flowchart TB
    TOP["상위 시스템"]

    subgraph LAYER1["계층1"]
        L1A["모듈A"]
        L1B["모듈B"]
    end

    subgraph LAYER2["계층2"]
        L2A["서브모듈1"]
        L2B["서브모듈2"]
        L2C["서브모듈3"]
    end

    TOP --> LAYER1
    LAYER1 --> LAYER2
```

---

## 부호 규칙

| 부호 범위 | 용도 |
|-----------|------|
| 10~19 | 입력부 |
| 20~29 | 출력부 |
| 100~199 | 메인 시스템/장치 |
| 110~119 | 제1 모듈 |
| 120~129 | 제2 모듈 |
| S100~S199 | 방법 단계 |
