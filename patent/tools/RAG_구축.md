# 특허 RAG 시스템 구축 가이드

등록 특허 데이터를 활용한 RAG(Retrieval-Augmented Generation) 시스템 구축 가이드입니다.

---

## 시스템 개요

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  특허 DB    │ --> │  Embedding   │ --> │  Vector DB  │
│  (KIPRIS)   │     │  (OpenAI)    │     │  (Pinecone) │
└─────────────┘     └──────────────┘     └─────────────┘
                           │
                           v
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  사용자     │ --> │  RAG Query   │ --> │  LLM 응답   │
│  질의       │     │  Engine      │     │  (Claude)   │
└─────────────┘     └──────────────┘     └─────────────┘
```

---

## 1단계: 특허 데이터 수집

### KIPRIS에서 데이터 수집

```python
import requests
import json
import time

class PatentCollector:
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = "https://plus.kipris.or.kr/openapi/rest"

    def collect_patents_by_ipc(self, ipc_code, max_count=1000):
        """IPC 코드별 특허 수집"""
        patents = []
        page = 1

        while len(patents) < max_count:
            url = f"{self.base_url}/patUtiModInfoSearchSevice/ipcSearchInfo"
            params = {
                "accessKey": self.api_key,
                "ipc": ipc_code,
                "numOfRows": 100,
                "pageNo": page
            }

            response = requests.get(url, params=params)
            items = self._parse_items(response.text)

            if not items:
                break

            patents.extend(items)
            page += 1
            time.sleep(0.1)  # Rate limiting

        return patents[:max_count]

    def get_full_text(self, application_number):
        """특허 전문 조회"""
        # 명세서, 청구항 등 상세 정보 조회
        pass

    def save_to_json(self, patents, filename):
        """JSON으로 저장"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(patents, f, ensure_ascii=False, indent=2)


# 사용 예시
collector = PatentCollector("YOUR_API_KEY")

# AI 관련 특허 수집
ai_patents = collector.collect_patents_by_ipc("G06N", max_count=500)
collector.save_to_json(ai_patents, "ai_patents.json")
```

### 데이터 구조

```json
{
  "patents": [
    {
      "application_number": "10-2024-0001234",
      "title": "인공지능 기반 동작 분석 시스템",
      "abstract": "본 발명은...",
      "claims": [
        {
          "number": 1,
          "type": "independent",
          "text": "사용자의 영상 데이터를..."
        }
      ],
      "description": {
        "technical_field": "...",
        "background_art": "...",
        "disclosure": "..."
      },
      "ipc": ["G06N 3/04", "G06V 40/20"],
      "applicant": "주식회사 ABC",
      "filing_date": "2024-01-15"
    }
  ]
}
```

---

## 2단계: 임베딩 생성

### OpenAI Embedding

```python
from openai import OpenAI
import numpy as np

class PatentEmbedder:
    def __init__(self, api_key):
        self.client = OpenAI(api_key=api_key)
        self.model = "text-embedding-3-small"

    def embed_patent(self, patent):
        """특허 문서 임베딩"""
        # 청구항 + 요약 + 제목 결합
        text = self._prepare_text(patent)

        response = self.client.embeddings.create(
            model=self.model,
            input=text
        )

        return response.data[0].embedding

    def _prepare_text(self, patent):
        """임베딩용 텍스트 준비"""
        parts = []

        # 제목 (가중치 높음)
        parts.append(f"제목: {patent['title']}")

        # 독립항 (가장 중요)
        for claim in patent.get('claims', []):
            if claim['type'] == 'independent':
                parts.append(f"청구항: {claim['text']}")

        # 요약
        if patent.get('abstract'):
            parts.append(f"요약: {patent['abstract']}")

        return "\n".join(parts)

    def batch_embed(self, patents, batch_size=100):
        """배치 임베딩"""
        embeddings = []

        for i in range(0, len(patents), batch_size):
            batch = patents[i:i+batch_size]
            texts = [self._prepare_text(p) for p in batch]

            response = self.client.embeddings.create(
                model=self.model,
                input=texts
            )

            batch_embeddings = [d.embedding for d in response.data]
            embeddings.extend(batch_embeddings)

        return embeddings
```

### 로컬 임베딩 (비용 절감)

```python
from sentence_transformers import SentenceTransformer

class LocalEmbedder:
    def __init__(self):
        # 한국어 지원 모델
        self.model = SentenceTransformer('jhgan/ko-sroberta-multitask')

    def embed(self, text):
        return self.model.encode(text).tolist()

    def batch_embed(self, texts):
        return self.model.encode(texts).tolist()
```

---

## 3단계: 벡터 DB 구축

### Pinecone 사용

```python
from pinecone import Pinecone, ServerlessSpec

class PatentVectorDB:
    def __init__(self, api_key):
        self.pc = Pinecone(api_key=api_key)
        self.index_name = "patent-db"

    def create_index(self, dimension=1536):
        """인덱스 생성"""
        if self.index_name not in self.pc.list_indexes().names():
            self.pc.create_index(
                name=self.index_name,
                dimension=dimension,
                metric="cosine",
                spec=ServerlessSpec(
                    cloud="aws",
                    region="us-east-1"
                )
            )

        self.index = self.pc.Index(self.index_name)

    def upsert_patents(self, patents, embeddings):
        """특허 벡터 저장"""
        vectors = []

        for i, (patent, embedding) in enumerate(zip(patents, embeddings)):
            vectors.append({
                "id": patent['application_number'],
                "values": embedding,
                "metadata": {
                    "title": patent['title'],
                    "abstract": patent.get('abstract', ''),
                    "ipc": patent.get('ipc', []),
                    "claims_count": len(patent.get('claims', []))
                }
            })

        # 배치 업서트
        self.index.upsert(vectors=vectors, batch_size=100)

    def search(self, query_embedding, top_k=10, filter=None):
        """유사 특허 검색"""
        results = self.index.query(
            vector=query_embedding,
            top_k=top_k,
            include_metadata=True,
            filter=filter
        )

        return results['matches']
```

### 로컬 벡터 DB (ChromaDB)

```python
import chromadb
from chromadb.config import Settings

class LocalPatentDB:
    def __init__(self, persist_dir="./patent_db"):
        self.client = chromadb.PersistentClient(path=persist_dir)
        self.collection = self.client.get_or_create_collection(
            name="patents",
            metadata={"hnsw:space": "cosine"}
        )

    def add_patents(self, patents, embeddings):
        """특허 추가"""
        ids = [p['application_number'] for p in patents]
        documents = [p['title'] + " " + p.get('abstract', '') for p in patents]
        metadatas = [{"title": p['title'], "ipc": str(p.get('ipc', []))} for p in patents]

        self.collection.add(
            ids=ids,
            embeddings=embeddings,
            documents=documents,
            metadatas=metadatas
        )

    def search(self, query_embedding, n_results=10):
        """검색"""
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=n_results
        )

        return results
```

---

## 4단계: RAG 쿼리 엔진

### Claude 연동 RAG

```python
import anthropic

class PatentRAG:
    def __init__(self, anthropic_key, vector_db, embedder):
        self.client = anthropic.Anthropic(api_key=anthropic_key)
        self.vector_db = vector_db
        self.embedder = embedder

    def query(self, user_query, top_k=5):
        """RAG 쿼리 실행"""
        # 1. 쿼리 임베딩
        query_embedding = self.embedder.embed(user_query)

        # 2. 유사 특허 검색
        similar_patents = self.vector_db.search(query_embedding, top_k=top_k)

        # 3. 컨텍스트 구성
        context = self._build_context(similar_patents)

        # 4. Claude에 질의
        response = self._ask_claude(user_query, context)

        return {
            "answer": response,
            "sources": similar_patents
        }

    def _build_context(self, patents):
        """검색된 특허로 컨텍스트 구성"""
        context_parts = []

        for i, patent in enumerate(patents, 1):
            metadata = patent.get('metadata', {})
            context_parts.append(f"""
=== 참고 특허 {i} ===
제목: {metadata.get('title', 'N/A')}
출원번호: {patent['id']}
IPC: {metadata.get('ipc', 'N/A')}
요약: {metadata.get('abstract', 'N/A')[:500]}
""")

        return "\n".join(context_parts)

    def _ask_claude(self, query, context):
        """Claude에 질의"""
        system_prompt = """당신은 특허 전문가입니다.
제공된 참고 특허를 바탕으로 사용자의 질문에 답변하세요.
선행기술과의 차별점, 청구항 작성 방향 등을 조언해주세요."""

        message = self.client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=2000,
            system=system_prompt,
            messages=[
                {
                    "role": "user",
                    "content": f"""참고 특허:
{context}

질문: {query}"""
                }
            ]
        )

        return message.content[0].text


# 사용 예시
rag = PatentRAG(
    anthropic_key="YOUR_KEY",
    vector_db=vector_db,
    embedder=embedder
)

result = rag.query("Bi-LSTM 기반 동작 분석 특허의 청구항은 어떻게 작성해야 하나요?")
print(result["answer"])
```

---

## 5단계: 전체 파이프라인

```python
class PatentRAGPipeline:
    def __init__(self, config):
        self.collector = PatentCollector(config['kipris_key'])
        self.embedder = PatentEmbedder(config['openai_key'])
        self.vector_db = PatentVectorDB(config['pinecone_key'])
        self.rag = PatentRAG(config['anthropic_key'], self.vector_db, self.embedder)

    def build_index(self, ipc_codes, max_per_ipc=500):
        """인덱스 구축"""
        all_patents = []

        for ipc in ipc_codes:
            patents = self.collector.collect_patents_by_ipc(ipc, max_per_ipc)
            all_patents.extend(patents)

        embeddings = self.embedder.batch_embed(all_patents)
        self.vector_db.create_index()
        self.vector_db.upsert_patents(all_patents, embeddings)

        return len(all_patents)

    def search_prior_art(self, invention_description):
        """선행기술 검색"""
        return self.rag.query(f"다음 발명의 선행기술을 찾아주세요: {invention_description}")

    def suggest_claims(self, invention_description):
        """청구항 제안"""
        return self.rag.query(f"다음 발명의 청구항을 제안해주세요: {invention_description}")


# 파이프라인 실행
config = {
    "kipris_key": "...",
    "openai_key": "...",
    "pinecone_key": "...",
    "anthropic_key": "..."
}

pipeline = PatentRAGPipeline(config)

# AI 관련 특허 인덱스 구축
pipeline.build_index(["G06N", "G06V", "G06F"], max_per_ipc=300)

# 선행기술 검색
result = pipeline.search_prior_art("Bi-LSTM 기반 한국무용 동작 분석 시스템")
```

---

## 비용 추정

| 구성요소 | 서비스 | 예상 비용 |
|----------|--------|-----------|
| 임베딩 | OpenAI | ~$0.02 / 1M tokens |
| 벡터 DB | Pinecone | Free tier: 1M vectors |
| LLM | Claude | ~$3 / 1M tokens |

**1,000개 특허 인덱스 구축**: 약 $5~10
