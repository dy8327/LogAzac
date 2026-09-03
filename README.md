# LogAzac

> **로그 파일을 업로드하면 Python으로 데이터를 분석하고, 규칙에 따라 이상 로그를 탐지하여 결과를 저장·조회할 수 있는 로그 분석 웹 서비스**

🌐 **Service:** https://logazac.duckdns.org

## 📌 프로젝트 소개

**LogAzac**은 장비에서 발생하는 로그 파일을 사람이 직접 확인하던 업무를 자동화하기 위해 시작한 개인 프로젝트입니다.

과거 자판기 약 350대를 운영하며 장애 발생 시 로그를 직접 확인하고, 문제 원인을 분석한 뒤 개발사에 로그와 분석 내용을 전달했던 실무 경험을 바탕으로 기획했습니다.

단순히 로그를 화면에 출력하는 것이 아니라 다음 과정을 하나의 웹 서비스로 구현했습니다.

```text
로그 업로드 → Python 분석 → 이상 로그 탐지 → DB 저장 → 결과 조회 → 검사 이력 관리
````

운영·QA·기술지원 업무에서 반복적으로 수행하는 **로그 확인, 이상 유형 분류, 장애 원인 파악** 과정을 보다 빠르고 일관되게 처리하는 것이 프로젝트의 핵심 목표입니다.

---

## 🎯 개발 목적

기존 로그 분석 업무에서는 장애가 발생하면 로그 파일을 직접 열어 필요한 데이터를 찾고 정상 로그와 비교해야 했습니다.

* 많은 로그를 사람이 직접 확인해야 하는 문제
* 비슷한 장애를 반복해서 분석해야 하는 문제
* 이상 유형을 일관된 기준으로 관리하기 어려운 문제
* 과거 검사 결과를 다시 확인하기 어려운 문제

LogAzac에서는 이를 **규칙 기반 탐지 + 검사 결과 저장 + 이력 관리** 방식으로 자동화했습니다.

---

## 🔍 주요 탐지 유형

### 자판기 로그

* `MISSING_PRODUCT_NAME` - 상품명 누락
* `CORRUPTED_DATA` - 데이터 구조 이상
* `MISSING_SLOT` - 슬롯 정보 누락
* `PRICE_CHANGED` - 상품 가격 변경
* `PRODUCT_NAME_CHANGED` - 상품명 변경

### 공통 로그

* `DUPLICATE_ERROR` - 중복 데이터 오류
* `NULL_ERROR` - NULL 제약조건 오류
* `CLOSED_BUSINESS_ERROR` - 폐업 사업자 관련 오류

로그 형식에 따라 분석기를 분리하고, 탐지 결과에는 **규칙 유형, 탐지 값, 원본 로그, 설명**을 함께 저장합니다.

---

## ✨ 주요 기능

### 사용자 기능

* 회원가입 / 로그인 / 로그아웃
* `.txt`, `.log` 파일 업로드 및 Drag & Drop
* 로그 파일 분석 실행
* 분석 결과 및 이상 로그 상세 조회
* 이상 유형별 필터링
* 탐지 값 검색 및 결과 초기화
* 사용자별 검사 이력 조회
* 검사 결과 및 파일 삭제
* 마이페이지

### 관리자 기능

* 관리자 대시보드
* 회원 관리
* 업로드 파일 관리
* 이상 판단 규칙 조회
* 이상 판단 규칙 등록 및 관리
* 분석 현황 및 통계 확인

### UI / UX

* Light Mint 기반 반응형 UI
* PC / Mobile 대응
* 테이블 가로 스크롤 처리
* 로그인 상태 및 권한에 따른 Header 메뉴 변경
* 분석 결과 가독성을 위한 이상 값 Highlight 처리

---

## 🛠 Tech Stack

### Backend

* Java 21
* Spring Boot 4.1.1
* Spring MVC
* MyBatis
* Maven
* Python 3

### Frontend

* JSP
* HTML5
* CSS3
* JavaScript

### Database

* Oracle Database XE 21c

### Infrastructure / Deployment

* Google Cloud Platform Compute Engine
* Ubuntu Linux
* Docker
* Nginx Reverse Proxy
* HTTPS / Let's Encrypt
* DuckDNS
* systemd
* GitHub Actions

### Development

* Visual Studio Code
* Git / GitHub

---

## 🗄 Database

현재 서비스는 다음 5개 핵심 테이블을 중심으로 구성되어 있습니다.

| Table               | Description         |
| ------------------- | ------------------- |
| `USERS`             | 회원 및 권한 정보          |
| `LOG_FILES`         | 업로드된 로그 파일 정보       |
| `INSPECTIONS`       | 로그 검사 실행 정보 및 결과 요약 |
| `DETECTION_RULES`   | 이상 판단 규칙            |
| `DETECTION_RESULTS` | 탐지된 이상 로그 상세 결과     |

### 주요 관계

```text
USERS
  ↓
LOG_FILES
  ↓
INSPECTIONS
  ↓
DETECTION_RESULTS
  ↑
DETECTION_RULES
```

사용자별 업로드 파일과 검사 이력을 분리하고, 하나의 검사에서 발생한 여러 이상 탐지 결과를 저장하도록 구성했습니다.

---

## 🧩 분석 처리 흐름

```text
사용자 로그 업로드
        ↓
Spring Boot 파일 저장
        ↓
Python Analyzer 실행
        ↓
로그 형식 판별 및 Parsing
        ↓
이상 탐지 규칙 적용
        ↓
Spring Boot 결과 수신
        ↓
Oracle DB 저장
        ↓
검사 결과 / 이력 화면 제공
```

Java 웹 애플리케이션과 Python 분석 모듈을 분리하여 **웹 처리와 로그 분석 역할을 나누는 구조**로 구현했습니다.

---

## 📂 Project Structure

```text
LogAzac
├── src/main/java/com/logazac
│   ├── controller
│   ├── service
│   ├── mapper
│   └── dto
├── src/main/resources
│   ├── mapper
│   └── application.properties
├── src/main/webapp/WEB-INF/views
├── python
│   ├── analyzer.py
│   ├── parser.py
│   ├── detector.py
│   └── common_detector.py
├── db
├── .github/workflows
│   └── deploy.yml
└── pom.xml
```

### Web Layer

```text
JSP
 ↓
Controller
 ↓
Service
 ↓
Mapper
 ↓
MyBatis XML
 ↓
Oracle DB
```

---

## 🚀 Deployment Architecture

```text
GitHub master Push
        ↓
GitHub Actions
        ↓ SSH
GCP Compute Engine
        ↓
git pull + Maven Build
        ↓
systemd Service Restart
        ↓
Spring Boot :8080
        ↑
Nginx :80 / :443
        ↑
https://logazac.duckdns.org

Oracle XE 21c
└── Docker Container
```

배포 서버에서는 Spring Boot 애플리케이션을 `systemd` 서비스로 실행하고, Oracle XE는 Docker Container로 운영합니다.

Nginx를 Reverse Proxy로 사용하며 Let's Encrypt 인증서를 적용해 HTTPS로 서비스합니다.

---

## 🔄 Git Branch / CI·CD

현재 브랜치는 다음 용도로 운영합니다.

```text
develop → 기능 개발 및 수정
   ↓
master  → 배포 기준 브랜치
   ↓
GitHub Actions 자동배포
```

`master` 브랜치에 Push되면 GitHub Actions가 GCP VM에 SSH로 접속하여 다음 작업을 자동으로 수행합니다.

```text
git pull origin master
        ↓
Maven Build
        ↓
systemd Restart
        ↓
서비스 반영
```

---

## 🧩 구현 과정에서 해결한 문제

### 사용자별 검사 이력 분리

초기 개발 과정에서 특정 사용자 번호를 기준으로 검사 이력이 조회되는 문제가 있었습니다.

로그인 Session의 사용자 번호를 기준으로 조회하도록 수정하여 **사용자별 검사 기록을 분리**했습니다.

### MyBatis Parameter Binding

Mapper XML에서 사용하는 파라미터명과 Java Mapper에서 전달하는 파라미터가 일치하지 않아 다음 오류가 발생했습니다.

```text
Parameter 'fileNo' not found
```

Mapper Method와 XML Parameter를 동일하게 맞춰 해결했습니다.

### Python 분석기 실행 경로

개발 환경에서는 Windows 절대 경로로 Python 실행 파일과 분석기 경로가 지정되어 있어 Linux 서버에서 실행할 수 없었습니다.

`application.properties`의 환경변수 기반 설정으로 변경하여 **Windows 개발 환경과 Ubuntu 운영 환경을 분리**했습니다.

### 서버 재부팅 후 DB 접속 실패

GCP VM 재부팅 후 Spring Boot는 자동 실행됐지만 Oracle Docker Container가 중지되어 DB 연결이 실패했습니다.

Oracle Container에 Restart Policy를 적용하고 Spring Boot는 systemd 서비스로 관리하도록 구성했습니다.

### GitHub Actions 자동배포

초기에는 서버에서 직접 다음 작업을 수행했습니다.

```text
git pull → build → restart
```

이후 SSH Key 기반 GitHub Actions Workflow를 구성하고, 서비스 재시작에 필요한 최소 `sudo` 권한을 설정하여 `master` Push 시 자동으로 배포되도록 개선했습니다.

---

## ✅ 구현 현황

* [x] 회원가입 / 로그인 / 로그아웃
* [x] 사용자 권한 관리
* [x] 로그 파일 업로드 / Drag & Drop
* [x] Python 기반 로그 분석
* [x] 이상 로그 탐지
* [x] 분석 결과 Oracle DB 저장
* [x] 사용자별 검사 이력
* [x] 분석 결과 상세 조회
* [x] 이상 유형 Filter / 탐지 값 검색
* [x] 사용자 파일 삭제
* [x] 관리자 회원 관리
* [x] 관리자 파일 관리
* [x] 이상 판단 규칙 관리
* [x] 관리자 통계 Dashboard
* [x] 반응형 UI
* [x] GCP 배포
* [x] Oracle Docker 운영
* [x] Nginx Reverse Proxy
* [x] HTTPS 적용
* [x] systemd 서비스 운영
* [x] GitHub Actions 자동배포

---

## 💡 프로젝트에서 중점적으로 다룬 부분

이 프로젝트는 단순 CRUD보다 **실제 운영 업무에서 경험한 장애 분석 과정을 시스템으로 전환하는 것**에 중점을 두었습니다.

```text
비정형 로그
   ↓
구조 분석 / Parsing
   ↓
이상 패턴 탐지
   ↓
데이터 구조화
   ↓
DB 저장
   ↓
이력 / 결과 조회
   ↓
운영자가 원인을 빠르게 파악
```

웹 개발뿐 아니라 로그 분석, SQL, 데이터 구조 설계, Linux 서버 운영, Docker, HTTPS, 자동배포까지 직접 구성하면서 **개발 이후 실제 서비스 운영 과정**도 함께 경험하는 것을 목표로 했습니다.

---

## 🔮 향후 개선 방향

* 다양한 장비 로그 형식 추가
* 이상 판단 규칙 확장
* 통계 기준 및 Dashboard 고도화
* 분석 결과 Export 기능
* 예외 처리 및 테스트 보강
* 배포 안정성 및 모니터링 강화

---

## 👤 Developer

**개인 프로젝트**

관심 직무 및 분야

* 시스템 운영
* 서비스 운영
* 기술지원
* QA
* 로그 분석
* 데이터 기반 장애 분석
* Troubleshooting

---

## 📄 Project Status

> **핵심 기능 구현 및 GCP 배포 완료 / 기능 개선 및 안정화 진행 중**

실제 운영 경험에서 출발한 문제를 직접 정의하고, 로그 분석 로직부터 웹 서비스, 데이터베이스, Linux 배포 및 CI/CD까지 하나의 서비스 흐름으로 구현한 개인 프로젝트입니다.

```

이 버전이면 **“학생 프로젝트 소개문” 느낌보다 실제 운영형 포트폴리오 느낌**이 훨씬 강해져.

특히 지금 추가된 **GCP + Docker + Nginx + HTTPS + systemd + GitHub Actions 자동배포**는 꼭 README에 보여주는 게 맞아. 이건 LogAzac에서 꽤 좋은 강점이야.
```
