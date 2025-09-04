# RTGen 配置系統升級說明

## 概述

我已經成功重構了 RTGen 的配置系統，實現了基於範本的變數替換機制，並將設定分離到 `settings.yml` 和各個 config 檔案中。

## 主要改進

### 1. 配置架構

- **settings.yml**: 包含專案級別的設定
  - `docker.image_name`: Docker 映像名稱
  - `docker.image_tag`: Docker 映像標籤  
  - `docker.registry_username`: Docker Registry 使用者名稱
  - `github.username`: GitHub 使用者名稱
  - `github.branches`: 觸發 workflow 的分支列表

- **config/docker.yml**: Docker 相關的詳細配置
  - 基礎映像設定
  - 容器配置
  - GPU 支援
  - 進階功能 (GUI 支援、設備存取、工作區掛載)

- **config/github.yml**: GitHub Actions 相關配置
  - Workflow 設定
  - Docker workflow 矩陣 (CPU/GPU)
  - 觸發條件

### 2. 範本系統

新增了 Python 基於的範本處理系統 (`scripts/process_template.py`):

- **變數替換**: `{{ variable.name }}`
- **條件判斷**: `{% if condition %}...{% endif %}`
- **迴圈處理**: `{% for item in list %}...{% endfor %}`
- **過濾器**: `{{ list | add_prefix('- ') }}`

### 3. 範本檔案

重新設計了所有範本檔案使用變數替換:

- `templates/docker/dockerfile.cpu`: CPU 版本 Dockerfile
- `templates/docker/dockerfile.gpu`: GPU 版本 Dockerfile  
- `templates/docker/compose.cpu.yml`: CPU 版本 docker-compose
- `templates/docker/compose.gpu.yml`: GPU 版本 docker-compose
- `templates/github/docker.cpu.yml`: CPU Docker workflow
- `templates/github/docker.gpu.yml`: GPU Docker workflow

### 4. 範例配置

新增了範例配置檔案:

- `examples/settings-robotics.yml`: 機器人專案範例設定
- `examples/docker-robotics.yml`: 機器人專案 Docker 配置範例

## 使用方式

### 基本設定

1. 編輯 `settings.yml` 設定專案基本資訊:
```yaml
project_name: my-project
docker:
  image_name: my-app
  image_tag: latest
  registry_username: username
github:
  username: username
  branches:
    - main
    - develop
```

2. 根據需要調整 `config/` 中的詳細配置

3. 執行生成:
```bash
./gen.sh                 # 生成到預設目錄
./gen.sh -test          # 測試模式
./gen.sh --output dir   # 指定輸出目錄
```

### 進階配置

對於複雜專案 (如機器人專案)，可以在 `config/docker.yml` 中啟用進階功能:

```yaml
advanced:
  gui_support:
    enabled: true        # GUI 支援
  device_access:
    enabled: true        # 硬體設備存取
  network:
    mode: host          # 網路模式
  privileged: true      # 特權模式
  workspace_volumes:    # 工作區掛載
    - "../src:/workspace/src"
```

## 技術細節

### 依賴需求

- Python 3
- PyYAML (`pip3 install PyYAML`)

### 範本處理流程

1. 載入 `settings.yml` 主要設定
2. 載入 `config/` 中的功能特定配置
3. 合併配置 (settings.yml 優先級較高)
4. 使用 Python 腳本處理範本變數替換
5. 生成最終檔案

### 檔案結構

```
rtgen/
├── settings.yml              # 主要設定檔
├── config/                   # 功能特定配置
│   ├── docker.yml
│   ├── github.yml
│   ├── license.yml
│   └── readme.yml
├── templates/                # 範本檔案
│   ├── docker/
│   │   ├── dockerfile.cpu
│   │   ├── dockerfile.gpu
│   │   ├── compose.cpu.yml
│   │   └── compose.gpu.yml
│   └── github/
│       ├── docker.cpu.yml
│       └── docker.gpu.yml
├── scripts/                  # 腳本工具
│   ├── process_template.py   # 範本處理
│   └── template_utils.sh     # Shell 輔助函數
└── examples/                 # 範例配置
    ├── settings-robotics.yml
    └── docker-robotics.yml
```

這個新的系統提供了更好的靈活性和可維護性，允許您輕鬆自訂專案配置而不需要修改範本檔案。
