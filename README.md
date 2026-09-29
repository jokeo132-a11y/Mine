# XMRig 6.26.0 — GitHub SSH build

이 폴더의 ZIP은 실행 파일만 들어 있던 Windows 배포본을 **공식 XMRig 소스의 GitHub SSH 체크아웃과 재현 가능한 빌드**가 가능하도록 정리한 부트스트랩 패키지입니다. 소스 코드는 ZIP에 복제하지 않고, 빌드할 때 `git@github.com:xmrig/xmrig.git`의 `v6.26.0` 태그를 받습니다.

## 1. GitHub SSH를 터미널에 한 번 설정

```bash
./setup-github-ssh.sh
# 출력된 공개키(~/.ssh/id_ed25519.pub)를 GitHub Settings > SSH and GPG keys에 등록
```

각 터미널에서 별도 설정할 필요 없이 같은 사용자 계정의 `~/.ssh` 설정을 사용합니다. GitHub CLI가 아니라 일반 OpenSSH + Git을 사용합니다.

## 2. 빌드

Linux, macOS, WSL:

```bash
./build.sh
# 소스/빌드 디렉터리를 지우고 새로 구성하려면
./build.sh --clean
```

Windows PowerShell:

```powershell
.\build.ps1
# 또는
.\build.cmd
```

필수 도구는 `git`, `cmake`, C++ 컴파일러입니다. Ubuntu/WSL에서는 `sudo apt install git cmake build-essential libuv1-dev libssl-dev`, macOS에서는 `xcode-select --install` 후 CMake를 설치하세요. Windows에서는 Visual Studio Build Tools와 CMake를 설치하세요.

## 3. 설정 파일

기존 ZIP의 `config.json`은 개인 지갑 주소가 포함된 로컬 설정으로 보존했습니다. GitHub에 올릴 때는 커밋하지 말고 `config.example.json`을 복사해 `config.local.json`으로 만든 뒤 지갑과 풀 정보를 입력하세요.

```bash
cp config.example.json config.local.json
```

빌드 자체는 채굴을 시작하지 않습니다. 실행/채굴은 해당 풀의 약관과 적용 법규를 확인한 뒤 직접 수행하세요.

## 환경 변수

- `XMRIG_REPO`: 기본값 `git@github.com:xmrig/xmrig.git`
- `XMRIG_REF`: 기본값 `v6.26.0`
- `XMRIG_SOURCE_DIR`, `XMRIG_BUILD_DIR`: 체크아웃/빌드 위치 변경
- `XMRIG_JOBS`: 병렬 빌드 작업 수(Linux/macOS)

예: `XMRIG_REF=master ./build.sh` 또는 `./build.sh --repo git@github.com:YOUR_USER/YOUR_REPO.git --ref main`

## 빌드 후 자동 실행

지갑 주소는 `config.local.json`의 첫 번째 풀 사용자 값으로 설정되어 있습니다.

```bash
# Linux / macOS / WSL
./run.sh

# 추가 XMRig 옵션 전달 예시
./run.sh --print-time=30
```

PowerShell:

```powershell
.\run.ps1
.\run.ps1 --print-time=30
```

Windows CMD:

```bat
run.cmd
run.cmd --print-time=30
```

`build/xmrig`(Linux/macOS/WSL) 또는 `build/Release/xmrig.exe`(Windows)가 없으면 먼저 `build.sh`/`build.ps1`을 실행하고, 이미 빌드되어 있으면 곧바로 `config.local.json`으로 실행합니다. 기본 SSH 저장소나 버전을 바꾸려면 기존의 `XMRIG_REPO`, `XMRIG_REF` 환경 변수를 사용하세요.
