# DevOps Web Console

一个基于 **Python + Flask + WebSocket** 构建的轻量级服务器管理面板，通过浏览器提供交互式终端、文件浏览、日志查看、系统监控和进程管理等功能。专为内网运维场景设计，无需安装任何客户端，开箱即用。

---

## ✨ 功能特性

| 模块 | 说明 |
|------|------|
| **🖥️ 交互式 Shell** | 基于 WebSocket + xterm.js，提供完整的远程终端体验，支持 `vim`、`top`、`cd` 等所有交互式命令。 |
| **📁 文件浏览器** | 以树形结构浏览服务器文件系统，点击目录可进入子目录，快速查看文件列表。 |
| **📜 日志查看器** | 手动输入日志文件路径，一键加载文件内容，方便快速排查问题。 |
| **📊 系统仪表盘** | 实时显示 CPU、内存、磁盘使用率及系统运行时间。 |
| **⚙️ 进程列表** | 展示当前运行的所有进程及其 PID、名称和 CPU 占用率。 |

---

## 🚀 快速开始

### 前置条件

- 操作系统：Linux（推荐 Arch Linux / Ubuntu / Debian / CentOS）
- Python 3.8 或更高版本
- 网络连通（浏览器访问）

### 一键部署（推荐）

复制以下命令到服务器终端执行：

```bash
curl -fsSL https://raw.githubusercontent.com/your-repo/devconsole/main/start.sh | bash
```

或手动保存 `start.sh` 并运行：

```bash
chmod +x start.sh
./start.sh
```

脚本将自动完成：
1. 安装 `uv`（若未安装）
2. 生成所有项目文件
3. 安装 Python 依赖（Flask、Flask‑SocketIO、Eventlet、psutil）
4. 后台启动服务
5. 显示访问地址

### 手动部署

若需自定义配置，可按以下步骤操作：

```bash
git clone https://github.com/your-repo/devconsole.git
cd devconsole
uv sync
uv run python app.py
```

服务默认监听 `0.0.0.0:5000`，访问 `http://<服务器IP>:5000` 即可。

---

## 📁 文件结构

```
devconsole/
├── start.sh                 # 一键启动脚本
├── pyproject.toml           # uv 项目配置（依赖声明）
├── app.py                   # Flask 应用入口
├── routes/
│   ├── __init__.py
│   ├── terminal.py          # WebSocket 终端处理
│   ├── system.py            # /api/system 接口
│   ├── processes.py         # /api/process 接口
│   ├── files.py             # /api/files  接口
│   └── logs.py              # /api/tail   接口
└── templates/
    ├── base.html            # 基础布局（导航栏、全局样式）
    ├── index.html           # 主页面（集成各卡片）
    ├── terminal.html        # 终端卡片
    ├── files.html           # 文件浏览卡片
    ├── logs.html            # 日志查看卡片
    ├── system.html          # 系统仪表盘卡片
    └── processes.html       # 进程列表卡片
```

---

## 🔧 技术栈

- **后端框架**：Flask 3.0+（Web 框架）
- **实时通信**：Flask‑SocketIO + Eventlet（WebSocket 支持）
- **系统监控**：psutil（获取 CPU/内存/磁盘/进程信息）
- **前端界面**：Bootstrap 5（布局）、FontAwesome（图标）、xterm.js（终端模拟）
- **包管理**：uv（高性能 Python 包管理器）

---

## 🌐 使用指南

1. **启动服务**：运行 `./start.sh` 或 `uv run python app.py`。
2. **访问控制台**：在浏览器中打开 `http://<IP>:5000`。
3. **切换功能**：点击左侧导航栏的图标切换不同模块。
   - **Shell**：在终端中输入命令，如 `ls`、`cd /tmp`、`vim` 等。
   - **Files**：点击目录名称进入子目录，查看文件列表。
   - **Logs**：在输入框中指定日志文件路径（如 `/var/log/syslog`），点击“Load”查看内容。
   - **System**：点击“Refresh”按钮更新系统状态数据。
   - **Processes**：进入该页面自动刷新进程列表。
4. **停止服务**：使用 `pkill -f "python app.py"` 或脚本提示的 PID 执行 `kill`。

---

## ⚠️ 安全提示

- 该工具**无身份认证**，请勿直接暴露在公网。
- 建议仅在**可信内网**中使用，或通过 **SSH 隧道** 转发端口访问。
- 若需增强安全性，可自行添加 Basic Auth 或使用 Nginx 反向代理。

---

## 📦 依赖列表

| 依赖 | 版本 | 用途 |
|------|------|------|
| Flask | ≥3.0.0 | Web 框架 |
| Flask‑SocketIO | ≥5.3.4 | WebSocket 支持 |
| Eventlet | ≥0.33.3 | 异步 I/O 协程库 |
| psutil | ≥5.9.6 | 系统资源监控 |

所有依赖由 `uv sync` 自动安装。

---

## 🤝 贡献与反馈

欢迎提交 Issue 或 Pull Request。若有功能需求或改进建议，请随时联系。

---

## 📄 许可证

MIT License © 2026

---

## 📞 联系方式

- 项目地址：[https://github.com/Tinmc189623/WebShell-Python](https://github.com/Tinmc189623/WebShell-Python/)

---

**祝您使用愉快！** 🎉
