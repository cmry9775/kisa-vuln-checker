# kisa-vuln-checker — KISA 기준 서버 취약점 자동 점검

> 🚧 진행 중 (20개 항목 구현 — 계정관리·파일권한·서비스관리·패치관리 완료, 전 항목 검증 완료)

## 개요
- 목적: 2026 KISA 「주요정보통신기반시설 기술적 취약점 분석·평가」 Unix/Windows 항목 자동 점검

## 아키텍처
```mermaid
flowchart LR
    subgraph ENV["Docker 격리 환경 (docker/)"]
        direction TB
        TARGET["점검 대상 서버<br/>Linux / Windows"]
        subgraph CHK["점검 스크립트 (checks/)"]
            direction TB
            LNX["linux/<br/>Unix 점검 항목"]
            WIN["windows/<br/>Windows 점검 항목"]
        end
        LIB["공통 모듈 (lib/)<br/>실행 · 파싱 · 판정"]
        CHK --> LIB
        LIB -- "점검 명령 실행" --> TARGET
        TARGET -- "설정값 · 결과" --> LIB
    end

    RULE[("항목 목록 · 판단 기준<br/>KISA 가이드 기반")] --> CHK
    LIB --> RES["원시 결과 (results/)<br/>양호 / 취약 / 수동확인"]
    RES --> REP["보고서 생성 (report/)"]
    REP --> OUT(["점검 결과 보고서"])
```

| 구성 요소 | 경로 | 역할 |
|---|---|---|
| 점검 스크립트 | `checks/linux`, `checks/windows` | KISA 항목별 점검 로직 |
| 공통 모듈 | `lib/` | 명령 실행, 출력 파싱, 양호/취약 판정 |
| 실행 환경 | `docker/` | 격리된 환경에서 재현 가능한 실행 |
| 결과 | `results/` | 항목별 판정 결과 저장 |
| 보고서 | `report/` | 결과를 취합해 보고서로 출력 |

## 핵심 결과
- 점검 항목 20개 (계정관리 5개: U-01~U-05, 파일권한 5개: U-14~U-18, 서비스관리 5개: U-19~U-23, 패치관리 5개: U-24~U-28) / 자동화율 100%
- **양호 컨테이너(docker/Dockerfile.ok) 20/20 "양호" 판정 → 오탐 0건**
- **취약 컨테이너(docker/Dockerfile.vuln) 20/20 "취약" 판정 → 미탐 0건** (U-03은 2단계 디버깅 끝에 최종 해결, U-04는 Dockerfile.vuln에 별도 조치가 없어 양호가 기대값, 상세: docs/검증결과.md)

## 실행 방법
```bash
# 취약 컨테이너 (20개 항목 모두 '취약' 판정이어야 함, U-04 제외)
docker build -f docker/Dockerfile.vuln -t checker:vuln .
docker run --rm checker:vuln > results/vuln.json

# 양호 컨테이너 (20개 항목 모두 '양호' 판정이어야 함 — 오탐 확인용)
docker build -f docker/Dockerfile.ok -t checker:ok .
docker run --rm checker:ok > results/ok.json
```

## 상세 문서
- docs/항목목록.md, docs/항목별_판단기준.md, docs/검증결과.md (취약/양호 컨테이너 실행 결과)
- report/kisa-vuln-checker_1차_보고서.docx (프로젝트 의의, Docker 설계, 공통 모듈 설계, U-01~U-05, U-14~U-18 설계 과정)

## 법적 고지
본 도구는 격리된 로컬 환경에서만 사용했습니다.
