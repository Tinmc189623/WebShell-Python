#!/usr/bin/env bash
set -e

# ===================== VERSION =====================
SCRIPT_VERSION="0.2.0"
REPO_OWNER="Tinmc189623"
REPO_NAME="WebShell-Python"
REPO_BRANCH="main"
GITHUB_RAW="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_BRANCH}"

# ===================== LANGUAGE DETECTION =====================
detect_lang() {
    local lang="${LANG:-en_US.UTF-8}"
    case "$lang" in
        zh_CN*|zh_SG*|zh_HK*|zh_TW*|zh_* )
            echo "zh"
            ;;
        *)
            echo "en"
            ;;
    esac
}

LANG_CODE=$(detect_lang)

# ===================== MESSAGES =====================
if [ "$LANG_CODE" = "zh" ]; then
    MSG_PROJECT_DIR="📁 项目根目录"
    MSG_CHECK_UV="🔧 检查 uv..."
    MSG_INSTALL_UV="📦 正在安装 uv..."
    MSG_GENERATING="📁 生成项目文件..."
    MSG_INSTALL_DEPS="📦 正在安装依赖 (uv sync)..."
    MSG_STARTING="🚀 启动服务..."
    MSG_SUCCESS="✅ 服务启动成功！"
    MSG_ACCESS="🌐 访问地址"
    MSG_LOG="📄 日志文件"
    MSG_STOP="🛑 停止服务"
    MSG_FAIL="❌ 启动失败，请查看"
    MSG_NO_UV="uv 未安装，正在尝试安装..."
    MSG_CHECK_UPDATE="🔍 检查更新..."
    MSG_UPDATE_AVAIL="🆕 发现新版本"
    MSG_CURRENT_VER="当前版本"
    MSG_LATEST_VER="最新版本"
    MSG_UPDATE_ASK="是否立即更新？(y/N)"
    MSG_UPDATING="⏳ 正在更新..."
    MSG_UPDATE_OK="✅ 更新成功！正在重新启动..."
    MSG_UPDATE_FAIL="❌ 更新失败"
    MSG_NO_UPDATE="✅ 已是最新版本"
    MSG_SKIP_UPDATE="⏭️  跳过更新"
else
    MSG_PROJECT_DIR="📁 Project root"
    MSG_CHECK_UV="🔧 Checking uv..."
    MSG_INSTALL_UV="📦 Installing uv..."
    MSG_GENERATING="📁 Generating project files..."
    MSG_INSTALL_DEPS="📦 Installing dependencies (uv sync)..."
    MSG_STARTING="🚀 Starting service..."
    MSG_SUCCESS="✅ Service started successfully!"
    MSG_ACCESS="🌐 Access URL"
    MSG_LOG="📄 Log file"
    MSG_STOP="🛑 To stop"
    MSG_FAIL="❌ Failed to start, check"
    MSG_NO_UV="uv not found, attempting to install..."
    MSG_CHECK_UPDATE="🔍 Checking for updates..."
    MSG_UPDATE_AVAIL="🆕 New version available"
    MSG_CURRENT_VER="Current version"
    MSG_LATEST_VER="Latest version"
    MSG_UPDATE_ASK="Update now? (y/N)"
    MSG_UPDATING="⏳ Updating..."
    MSG_UPDATE_OK="✅ Update successful! Restarting..."
    MSG_UPDATE_FAIL="❌ Update failed"
    MSG_NO_UPDATE="✅ Already up to date"
    MSG_SKIP_UPDATE="⏭️  Update skipped"
fi

# ===================== UPDATE FUNCTIONS =====================
fetch_url() {
    local url="$1"
    if command -v curl &>/dev/null; then
        curl -fsSL "$url" 2>/dev/null
    elif command -v wget &>/dev/null; then
        wget -qO- "$url" 2>/dev/null
    elif command -v python3 &>/dev/null; then
        python3 -c "import urllib.request, sys; sys.stdout.write(urllib.request.urlopen('$url').read().decode())" 2>/dev/null
    else
        echo ""
    fi
}

check_for_updates() {
    echo "$MSG_CHECK_UPDATE"
    local remote_version
    remote_version=$(fetch_url "${GITHUB_RAW}/version.txt" | tr -d '\n\r')
    if [ -z "$remote_version" ]; then
        # Fallback: extract version from remote start.sh
        remote_version=$(fetch_url "${GITHUB_RAW}/start.sh" | grep -m1 '^SCRIPT_VERSION=' | sed 's/^SCRIPT_VERSION="//;s/".*//')
    fi
    if [ -z "$remote_version" ]; then
        echo "⚠️  ${MSG_UPDATE_FAIL}: cannot fetch remote version, skipping update check"
        return 0   # 返回 0，避免触发 set -e 退出脚本
    fi
    if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
        echo "$MSG_UPDATE_AVAIL"
        echo "  $MSG_CURRENT_VER: $SCRIPT_VERSION"
        echo "  $MSG_LATEST_VER: $remote_version"
        read -p "$MSG_UPDATE_ASK " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            perform_update "$remote_version"
        else
            echo "$MSG_SKIP_UPDATE"
        fi
    else
        echo "$MSG_NO_UPDATE"
    fi
    return 0  # 确保总是返回 0，不中断脚本
}

perform_update() {
    local new_version="$1"
    echo "$MSG_UPDATING"
    local tmp_script
    tmp_script=$(mktemp /tmp/update_webshell.XXXXXX)
    chmod +x "$tmp_script"

    # Write the updater script
    cat > "$tmp_script" <<'EOFUPD'
#!/bin/bash
# This script updates the original start.sh and then re-executes it
NEW_SCRIPT="$1"
TARGET_SCRIPT="$2"
if [ -z "$NEW_SCRIPT" ] || [ -z "$TARGET_SCRIPT" ]; then
    echo "Usage: $0 <new_script_path> <target_script_path>"
    exit 1
fi
sleep 1
cp -f "$NEW_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
rm -f "$NEW_SCRIPT"
exec "$TARGET_SCRIPT"
EOFUPD

    # Download the new script to a temporary file
    local new_script_file
    new_script_file=$(mktemp /tmp/new_start.XXXXXX)
    if ! fetch_url "${GITHUB_RAW}/start.sh" > "$new_script_file"; then
        echo "❌ ${MSG_UPDATE_FAIL}: cannot download new script"
        rm -f "$tmp_script" "$new_script_file"
        return 1
    fi
    chmod +x "$new_script_file"

    # Execute the updater, which will replace this script and restart
    exec "$tmp_script" "$new_script_file" "$0"
    # exec replaces the current process, so the lines below are never reached
}

# ===================== MAIN SCRIPT =====================

# Check for updates (skip if --no-update is passed)
if [[ "$1" != "--no-update" ]]; then
    check_for_updates
fi

# ---------- Continue with normal execution ----------
PROJECT_DIR="$(pwd)"
echo "$MSG_PROJECT_DIR: $PROJECT_DIR"

echo "$MSG_CHECK_UV"
if ! command -v uv &> /dev/null; then
    echo "$MSG_NO_UV"
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm uv || pip install uv --user
    else
        pip install uv --user
    fi
fi

echo "$MSG_GENERATING"

# ---------- Write pyproject.toml ----------
cat > pyproject.toml <<'EOF'
[project]
name = "webshell"
version = "0.1.0"
dependencies = [
    "flask>=3.0.0",
    "flask-socketio>=5.3.4",
    "eventlet>=0.33.3",
    "psutil>=5.9.6",
]
requires-python = ">=3.8"
EOF

# ---------- Write app.py ----------
cat > app.py <<'EOF'
import os
from flask import Flask, render_template
from flask_socketio import SocketIO
from routes import system, processes, files, logs
from routes.terminal import register_socketio_handlers

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, async_mode='eventlet')

app.register_blueprint(system.bp)
app.register_blueprint(processes.bp)
app.register_blueprint(files.bp)
app.register_blueprint(logs.bp)

register_socketio_handlers(socketio)

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)
EOF

# ---------- routes/ directory ----------
mkdir -p routes

cat > routes/__init__.py <<'EOF'
# Empty file to mark package
EOF

cat > routes/terminal.py <<'EOF'
import os, pty, subprocess, threading, time
from flask import request
from flask_socketio import emit

shell_processes = {}

def register_socketio_handlers(socketio):
    def read_shell_output(sid, fd):
        while True:
            try:
                output = os.read(fd, 1024).decode('utf-8', errors='ignore')
                if output:
                    socketio.emit('shell_output', {'data': output}, room=sid)
            except OSError:
                break
            time.sleep(0.01)

    @socketio.on('connect')
    def handle_connect():
        sid = request.sid
        master_fd, slave_fd = pty.openpty()
        process = subprocess.Popen(['/bin/bash'], stdin=slave_fd, stdout=slave_fd, stderr=slave_fd, preexec_fn=os.setsid, shell=False)
        shell_processes[sid] = {'process': process, 'master_fd': master_fd, 'slave_fd': slave_fd}
        thread = threading.Thread(target=read_shell_output, args=(sid, master_fd))
        thread.daemon = True
        thread.start()
        emit('shell_ready', {'status': 'Connected to shell'})

    @socketio.on('shell_input')
    def handle_shell_input(data):
        sid = request.sid
        if sid in shell_processes:
            os.write(shell_processes[sid]['master_fd'], data['data'].encode())

    @socketio.on('disconnect')
    def handle_disconnect():
        sid = request.sid
        if sid in shell_processes:
            p = shell_processes[sid]['process']
            p.terminate()
            p.wait()
            os.close(shell_processes[sid]['master_fd'])
            os.close(shell_processes[sid]['slave_fd'])
            del shell_processes[sid]
EOF

cat > routes/system.py <<'EOF'
from flask import Blueprint, jsonify
import psutil
bp = Blueprint('system', __name__, url_prefix='/api')

@bp.route('/system')
def system():
    mem = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    data = {
        'cpu': psutil.cpu_percent(interval=0.1),
        'memory': {'total': mem.total, 'used': mem.used, 'free': mem.free},
        'disk': {'total': disk.total, 'used': disk.used, 'free': disk.free},
        'uptime': int(psutil.boot_time())
    }
    return jsonify(data)
EOF

cat > routes/processes.py <<'EOF'
from flask import Blueprint, jsonify
import psutil
bp = Blueprint('processes', __name__, url_prefix='/api')

@bp.route('/process')
def process():
    procs = []
    for p in psutil.process_iter(['pid', 'name', 'cpu_percent']):
        try:
            info = p.info
            procs.append({'pid': info['pid'], 'name': info['name'], 'cpu': info['cpu_percent']})
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return jsonify(procs)
EOF

cat > routes/files.py <<'EOF'
from flask import Blueprint, jsonify, request
import os
bp = Blueprint('files', __name__, url_prefix='/api')

@bp.route('/files')
def files():
    path = request.args.get('path', '.')
    if not os.path.isdir(path):
        return jsonify({'error': 'Invalid path'}), 400
    items = []
    for item in os.listdir(path):
        full = os.path.join(path, item)
        typ = 'dir' if os.path.isdir(full) else 'file'
        items.append({'name': item, 'type': typ})
    return jsonify({'path': path, 'files': items})
EOF

cat > routes/logs.py <<'EOF'
from flask import Blueprint, jsonify, request
import os
bp = Blueprint('logs', __name__, url_prefix='/api')

@bp.route('/tail')
def tail():
    file = request.args.get('file', '/var/log/syslog')
    if not os.path.exists(file):
        return jsonify({'error': 'File not found'}), 404
    try:
        with open(file, 'r') as f:
            content = f.read()
        return jsonify({'content': content})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
EOF

# ---------- templates/ directory ----------
mkdir -p templates

cat > templates/base.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{% block title %}DevOps Console{% endblock %}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/xterm/css/xterm.css" />
  <style>
    body { background: #0d1117; color: #e6edf3; height: 100vh; overflow: hidden; }
    .sidebar { background: #161b22; border-right: 1px solid #30363d; height: 100vh; padding-top: 1rem; }
    .sidebar .nav-link { color: #8b949e; border-radius: 6px; padding: 0.5rem 1rem; margin: 0.2rem 0.5rem; }
    .sidebar .nav-link:hover, .sidebar .nav-link.active { background: #1f2937; color: #f0f6fc; }
    .sidebar .nav-link i { margin-right: 10px; }
    .main-content { padding: 1.5rem; height: 100vh; overflow-y: auto; }
    .card { background: #161b22; border: 1px solid #30363d; border-radius: 12px; margin-bottom: 1.5rem; }
    .card-header { background: transparent; border-bottom: 1px solid #30363d; font-weight: 600; }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px,1fr)); gap: 1rem; }
    .stat-item { background: #0d1117; padding: 1rem; border-radius: 8px; text-align: center; }
    .stat-item .value { font-size: 1.8rem; font-weight: 700; color: #58a6ff; }
    .stat-item .label { color: #8b949e; font-size: 0.9rem; }
    #terminal-container { height: 70vh; background: #0d1117; border-radius: 8px; }
    #terminal { height: 100%; width: 100%; }
    .file-list { list-style: none; padding: 0; }
    .file-list li { padding: 0.5rem; border-bottom: 1px solid #21262d; cursor: pointer; }
    .file-list li:hover { background: #1f2937; }
    .file-list .dir { color: #58a6ff; }
    .file-list .file { color: #e6edf3; }
    .log-view { background: #0d1117; padding: 1rem; border-radius: 8px; max-height: 400px; overflow-y: auto; font-family: monospace; white-space: pre-wrap; }
    .badge-tail { background: #238636; }
  </style>
</head>
<body>
<div class="container-fluid h-100">
  <div class="row h-100">
    <nav class="col-md-2 col-lg-2 d-md-block sidebar p-0">
      <div class="d-flex flex-column">
        <h5 class="text-center p-3 border-bottom border-secondary"><i class="bi bi-terminal-fill me-2"></i>DevOps</h5>
        <ul class="nav flex-column">
          <li class="nav-item"><a class="nav-link active" data-section="terminal"><i class="bi bi-console"></i> Shell</a></li>
          <li class="nav-item"><a class="nav-link" data-section="files"><i class="bi bi-folder2-open"></i> Files</a></li>
          <li class="nav-item"><a class="nav-link" data-section="logs"><i class="bi bi-file-text"></i> Logs</a></li>
          <li class="nav-item"><a class="nav-link" data-section="system"><i class="bi bi-speedometer2"></i> System</a></li>
          <li class="nav-item"><a class="nav-link" data-section="processes"><i class="bi bi-hdd-stack"></i> Processes</a></li>
        </ul>
      </div>
    </nav>
    <main class="col-md-10 col-lg-10 main-content">
      {% block content %}{% endblock %}
    </main>
  </div>
</div>

<script src="https://cdn.socket.io/4.6.0/socket.io.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/xterm/lib/xterm.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    const socket = io();
    const term = new Terminal({ cursorBlink: true, theme: { background: '#0d1117', foreground: '#e6edf3' } });
    term.open(document.getElementById('terminal'));
    term.focus();

    socket.on('shell_ready', (msg) => term.writeln('\x1b[32m' + msg.status + '\x1b[0m'));
    socket.on('shell_output', (data) => term.write(data.data));
    term.onData((data) => socket.emit('shell_input', { data: data }));
    socket.on('disconnect', () => term.writeln('\x1b[31mDisconnected\x1b[0m'));

    document.querySelectorAll('.sidebar .nav-link').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            document.querySelectorAll('.sidebar .nav-link').forEach(l => l.classList.remove('active'));
            this.classList.add('active');
            const section = this.dataset.section;
            document.querySelectorAll('.section').forEach(s => s.style.display = 'none');
            const target = document.getElementById('section-' + section);
            if (target) target.style.display = 'block';
            if (section === 'terminal') setTimeout(() => term.resize(term.cols, term.rows), 100);
            if (section === 'system') refreshStats();
            if (section === 'processes') refreshProcesses();
            if (section === 'files') loadFiles();
        });
    });

    function loadFiles(path = '.') {
        fetch(`/api/files?path=${encodeURIComponent(path)}`)
            .then(r => r.json())
            .then(data => {
                const ul = document.getElementById('file-list');
                if (data.error) { ul.innerHTML = `<li class="text-danger">${data.error}</li>`; return; }
                document.getElementById('current-path').textContent = data.path;
                ul.innerHTML = '';
                data.files.forEach(f => {
                    const li = document.createElement('li');
                    li.className = f.type === 'dir' ? 'dir' : 'file';
                    li.innerHTML = `<i class="bi ${f.type === 'dir' ? 'bi-folder-fill' : 'bi-file-earmark'} me-2"></i>${f.name}`;
                    if (f.type === 'dir') li.addEventListener('click', () => loadFiles(data.path + '/' + f.name));
                    ul.appendChild(li);
                });
            });
    }
    document.querySelector('[data-section="files"]').addEventListener('click', function(e) {
        if (!document.getElementById('file-list').children.length) loadFiles();
    });

    document.getElementById('load-log').addEventListener('click', function() {
        const path = document.getElementById('log-path').value;
        fetch(`/api/tail?file=${encodeURIComponent(path)}`)
            .then(r => r.json())
            .then(data => {
                const el = document.getElementById('log-content');
                el.textContent = data.error ? 'Error: ' + data.error : data.content;
            });
    });

    function refreshStats() {
        fetch('/api/system')
            .then(r => r.json())
            .then(data => {
                document.getElementById('cpu').textContent = data.cpu + '%';
                document.getElementById('mem').textContent = Math.round((data.memory.used / data.memory.total) * 100) + '%';
                document.getElementById('disk').textContent = Math.round((data.disk.used / data.disk.total) * 100) + '%';
                document.getElementById('uptime').textContent = Math.floor(data.uptime / 3600) + 'h';
            });
    }
    document.getElementById('refresh-stats').addEventListener('click', refreshStats);

    function refreshProcesses() {
        fetch('/api/process')
            .then(r => r.json())
            .then(data => {
                const tbody = document.getElementById('process-table');
                tbody.innerHTML = data.map(p => `<tr><td>${p.pid}</td><td>${p.name}</td><td>${p.cpu}</td></tr>`).join('');
            });
    }

    window.addEventListener('resize', () => term.resize(term.cols, term.rows));
});
</script>
</body>
</html>
EOF

cat > templates/index.html <<'EOF'
{% extends "base.html" %}
{% block content %}
<div id="section-terminal" class="section">{% include "terminal.html" %}</div>
<div id="section-files" class="section" style="display:none;">{% include "files.html" %}</div>
<div id="section-logs" class="section" style="display:none;">{% include "logs.html" %}</div>
<div id="section-system" class="section" style="display:none;">{% include "system.html" %}</div>
<div id="section-processes" class="section" style="display:none;">{% include "processes.html" %}</div>
{% endblock %}
EOF

cat > templates/terminal.html <<'EOF'
<div class="card">
  <div class="card-header"><i class="bi bi-console me-2"></i>Interactive Shell</div>
  <div class="card-body p-0"><div id="terminal-container"><div id="terminal"></div></div></div>
</div>
EOF

cat > templates/files.html <<'EOF'
<div class="card">
  <div class="card-header"><i class="bi bi-folder2-open me-2"></i>File Browser <span id="current-path" class="ms-3 badge bg-secondary">/</span></div>
  <div class="card-body"><ul id="file-list" class="file-list"><li>Loading...</li></ul></div>
</div>
EOF

cat > templates/logs.html <<'EOF'
<div class="card">
  <div class="card-header"><i class="bi bi-file-text me-2"></i>Log Viewer <span class="badge badge-tail">tail -f</span></div>
  <div class="card-body">
    <div class="mb-3">
      <input id="log-path" class="form-control bg-dark text-light border-secondary" placeholder="/var/log/syslog" value="/var/log/syslog">
      <button id="load-log" class="btn btn-primary mt-2"><i class="bi bi-arrow-clockwise"></i> Load</button>
    </div>
    <div id="log-content" class="log-view">Select a log file to view.</div>
  </div>
</div>
EOF

cat > templates/system.html <<'EOF'
<div class="card">
  <div class="card-header"><i class="bi bi-speedometer2 me-2"></i>System Dashboard</div>
  <div class="card-body">
    <div class="stats-grid" id="stats-grid">
      <div class="stat-item"><div class="value" id="cpu">--%</div><div class="label">CPU</div></div>
      <div class="stat-item"><div class="value" id="mem">--%</div><div class="label">Memory</div></div>
      <div class="stat-item"><div class="value" id="disk">--%</div><div class="label">Disk</div></div>
      <div class="stat-item"><div class="value" id="uptime">--</div><div class="label">Uptime</div></div>
    </div>
    <button id="refresh-stats" class="btn btn-outline-secondary btn-sm mt-3"><i class="bi bi-arrow-repeat"></i> Refresh</button>
  </div>
</div>
EOF

cat > templates/processes.html <<'EOF'
<div class="card">
  <div class="card-header"><i class="bi bi-hdd-stack me-2"></i>Process List</div>
  <div class="card-body p-0">
    <div style="max-height: 70vh; overflow-y: auto;">
      <table class="table table-dark table-hover table-striped mb-0">
        <thead><tr><th>PID</th><th>Name</th><th>CPU%</th></tr></thead>
        <tbody id="process-table"></tbody>
      </table>
    </div>
  </div>
</div>
EOF

# ---------- Install dependencies and start ----------
echo "$MSG_INSTALL_DEPS"
uv sync

echo "$MSG_STARTING"
nohup uv run python app.py > server.log 2>&1 &
SERVICE_PID=$!
sleep 3

if ps -p $SERVICE_PID > /dev/null; then
    IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
    if [ -z "$IP" ]; then
        IP="127.0.0.1"
    fi
    echo ""
    echo "$MSG_SUCCESS"
    echo "$MSG_ACCESS: http://${IP}:5000"
    echo "$MSG_LOG: ${PROJECT_DIR}/server.log"
    echo "$MSG_STOP: kill $SERVICE_PID"
    echo ""
    echo "如果浏览器打开后终端区域空白，请按 F12 查看 Console 是否有报错。"
    echo "常见问题：若 WebSocket 连接失败，请检查防火墙是否允许 5000 端口。"
else
    echo "$MSG_FAIL ${PROJECT_DIR}/server.log"
    exit 1
fi
