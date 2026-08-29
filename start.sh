#!/usr/bin/env bash
set -e

PROJECT_DIR="${HOME}/www/qyqw"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "🔧 Checking uv..."
if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv..."
    sudo pacman -S --noconfirm uv || {
        echo "⚠️  Failed to install via pacman, trying pip..."
        pip install uv --user
    }
fi

echo "📁 Generating project files..."

# pyproject.toml
cat > pyproject.toml <<'EOF'
[project]
name = "devconsole"
version = "0.1.0"
dependencies = [
    "flask>=3.0.0",
    "flask-socketio>=5.3.4",
    "eventlet>=0.33.3",
    "psutil>=5.9.6",
]
requires-python = ">=3.8"
EOF

# app.py (Base64 encoded to avoid indentation issues)
cat > app.py.b64 <<'B64'
aW1wb3J0IG9zLCBwdHksIHN1YnByb2Nlc3MsIHRocmVhZGluZywgdGltZSwganNvbiwgcHN1dGlsLCBwbGF0Zm9ybSwgc29ja2V0
aW1wb3J0IGZyb20gZmxhc2sgSW1wb3J0IEZsYXNrLCByZW5kZXJfdGVtcGxhdGUsIHJlcXVlc3QsIGpzb25pZnkKaW1wb3J0IGZy
b20gZmxhc2tfc29ja2V0aW8gaW1wb3J0IFNvY2tldElPLCBlbWl0CnVzZV9kZWJ1ZyA9IEZhbHNlCgphcHAgPSBGbGFzayhfX25h
bWVfXykKYXBwLmNvbmZpZ1snU0VDUkVUX0tFWSddID0gJ3NlY3JldCEnCnNvY2tldGlvID0gU29ja2V0SU8oYXBwLCBhc3luY19t
b2RlPSdldmVudGxldCcpCnNoZWxsX3Byb2Nlc3NlcyA9IHt9CgpkZWYgcmVhZF9zaGVsbF9vdXRwdXQoc2lkLCBmZCk6CiAgICB3
aGlsZSBUcnVlOgogICAgICAgIHRyeToKICAgICAgICAgICAgb3V0cHV0ID0gb3MucmVhZChmZCwgMTAyNCkuZGVjb2RlKCd1dGYt
OCcsIGVycm9ycz0naWdub3JlJykKICAgICAgICAgICAgaWYgb3V0cHV0OgogICAgICAgICAgICAgICAgc29ja2V0aW8uZW1pdCgn
c2hlbGxfb3V0cHV0JywgeyAnZGF0YSc6IG91dHB1dCB9LCByb29tPXNpZCkKICAgICAgICBleGNlcHQgT1NFcnJvcjoKICAgICAg
ICAgICAgYnJlYWsKICAgICAgICB0aW1lLnNsZWVwKDAuMDEpCgpAc29ja2V0aW8ub24oJ2Nvbm5lY3QnKQpkZWYgaGFuZGxlX2Nv
bm5lY3QoKToKICAgIHNpZCA9IHJlcXVlc3Quc2lkCiAgICBtYXN0ZXJfZmQsIHNsYXZlX2ZkID0gcHR5Lm9wZW5wdHkoKQogICAg
cHJvY2VzcyA9IHN1YnByb2Nlc3MuUG9wZW4oWycvYmluL2Jhc2gnXSwgc3RkaW49c2xhdmVfZmQsIHN0ZG91dD1zbGF2ZV9mZCwg
c3RkZXJyPXNsYXZlX2ZkLCBwcmVleGVjX2ZuPW9zLnNldHNpZCwgc2hlbGw9RmFsc2UpCiAgICBzaGVsbF9wcm9jZXNzZXNbc2lk
XSA9IHsncHJvY2Vzcyc6IHByb2Nlc3MsICdtYXN0ZXJfZmQnOiBtYXN0ZXJfZmQsICdzbGF2ZV9mZCc6IHNsYXZlX2ZkfQogICAg
dGhyZWFkID0gdGhyZWFkaW5nLlRocmVhZCh0YXJnZXQ9cmVhZF9zaGVsbFvdXRwdXQsIGFyZ3M9KHNpZCwgbWFzdGVyX2ZkKSkK
ICAgIHRocmVhZC5kYWVtb24gPSBUcnVlCiAgICB0aHJlYWQuc3RhcnQoKQogICAgZW1pdCgnc2hlbGxfcmVhZHknLCB7J3N0YXR1
cyc6ICdDb25uZWN0ZWQgdG8gc2hlbGwnfSkKCkBzb2NrZXRpby5vbignaW5wdXQnKQpkZWYgaGFuZGxlX2lucHV0KGRhdGEpOgog
ICAgc2lkID0gcmVxdWVzdC5zaWQKICAgIGlmIHNpZCBpbiBzaGVsbF9wcm9jZXNzZXM6CiAgICAgICAgb3Mud3JpdGUoc2hlbGxf
cHJvY2Vzc2VzW3NpZF1bJ21hc3Rlcl9mZCddLCBkYXRhWydkYXRhJ10uZW5jb2RlKCkpCgpAc29ja2V0aW8ub24oJ2Rpc2Nvbm5l
Y3QnKQpkZWYgaGFuZGxlX2Rpc2Nvbm5lY3QoKToKICAgIHNpZCA9IHJlcXVlc3Quc2lkCiAgICBpZiBzaWQgaW4gc2hlbGxfcHJv
Y2Vzc2VzOgogICAgICAgIHAgPSBzaGVsbF9wcm9jZXNzZXNbc2lkXVsncHJvY2VzcyddCiAgICAgICAgcC50ZXJtaW5hdGUoKQog
ICAgICAgIHAud2FpdCgpCiAgICAgICAgb3MuY2xvc2Uoc2hlbGxfcHJvY2Vzc2VzW3NpZF1bJ21hc3Rlcl9mZCddKQogICAgICAg
IG9zLmNsb3NlKHNoZWxsX3Byb2Nlc3Nlc1tzaWRdWydzbGF2ZV9mZCddKQogICAgICAgIGRlbCBzaGVsbF9wcm9jZXNzZXNbc2lk
XQoKQGFwcC5yb3V0ZSgnLycpCmRlZiBpbmRleCgpOgogICAgcmV0dXJuIHJlbmRlcl90ZW1wbGF0ZSgnaW5kZXguaHRtbCcpCgph
cHAucm91dGUoJy9hcGkvc3lzdGVtJykKZGVmIGFwaV9zeXN0ZW0oKToKICAgIGRhdGEgPSB7CiAgICAgICAgJ2NwdSc6IHBzdXRs
aS5jcHVfcGVyY2VudChpbnRlcnZhbD0wLjEpLnBlcmNlbnQsCiAgICAgICAgJ21lbW9yeSc6IHBzdXRpbC52aXJ0dWFsX21lbW9y
eSgpLAogICAgICAgICdkaXNrJzogcHN1dGlsLmRpc2tfdXNhZ2UoJy8nKSwKICAgICAgICAndXB0aW1lJzogcHN1dGlsLmJvb3Rf
dGltZSgpLnNlbmRzLAogICAgfQogICAgcmV0dXJuIGpzb25pZnkoZGF0YSkKCmFwcC5yb3V0ZSgnL2FwaS9wcm9jZXNzJykKZGVm
IGFwaV9wcm9jZXNzKCk6CiAgICBwcm9jcyA9IFtdCiAgICBmb3IgcCBpbiBwc3V0aWwucHJvY2Vzc19pdGVyYXRvcigpOgogICAg
ICAgIHRyeToKICAgICAgICAgICAgcHJvY3MuYXBwZW5kKHsncGlkJzogcC5pbmZvLnBpZCwgJ25hbWUnOiBwLmluZm8ubmFtZSwg
J2NwdSc6IHAuaW5mby5jcHVfcGVyY2VudH0pCiAgICAgICAgZXhjZXB0OgogICAgICAgICAgICBwYXNzCiAgICByZXR1cm4ganNv
bmlmeShwcm9jcykKCmFwcC5yb3V0ZSgnL2FwaS9maWxlcycpCmRlZiBhcGlfZmlsZXMoKToKICAgIHBhdGggPSByZXF1ZXN0LmFy
Z3MuZ2V0KCdwYXRoJywgJy4nKQogICAgaWYgbm90IG9zLnBhdGguaXNkaXIoKHBhdGgpKToKICAgICAgICByZXR1cm4ganNvbmlm
eSh7J2Vycm9yJzogJ0ludmFsaWQgcGF0aCd9KSwgNDAwCiAgICBmaWxlcyA9IFtdCiAgICBmb3IgaXRlbSBpbiBvcy5saXN0ZGly
KHBhdGgpOgogICAgICAgIGZ1bGwgPSBvcy5wYXRoLmpvaW4ocGF0aCwgaXRlbSkKICAgICAgICBpZiBvcy5wYXRoLmlzZGlyKChm
dWxsKSk6CiAgICAgICAgICAgIHR5cGUgPSAnZGlyJwogICAgICAgIGVsc2U6CiAgICAgICAgICAgIHR5cGUgPSAnZmlsZScKICAg
ICAgICBmaWxlcy5hcHBlbmQoeyduYW1lJzogaXRlbSwgJ3R5cGUnOiB0eXBlfSkKICAgIHJldHVybiBqc29uaWZ5KHsncGF0aCc6
IHBhdGgsICdmaWxlcyc6IGZpbGVzfSkKCmFwcC5yb3V0ZSgnL2FwaS90YWlsJykKZGVmIGFwaV90YWlsKCk6CiAgICBmaWxlID0g
cmVxdWVzdC5hcmdzLmdldCgnZmlsZScsICcvdmFyL2xvZy9zeXNsb2cnKQogICAgaWYgbm90IG9zLnBhdGguZXhpc3RzKGZpbGUp
OgogICAgICAgIHJldHVybiBqc29uaWZ5KHsnZXJyb3InOiAnRmlsZSBub3QgZm91bmQnfSksIDQwNAogICAgdHJ5OgogICAg
ICAgIHdpdGggb3BlbihmaWxlLCAncicpIGFzIGY6CiAgICAgICAgICAgIGNvbnRlbnQgPSBmLnJlYWQoKQogICAgICAgIHJl
dHVybiBqc29uaWZ5KHsnY29udGVudCc6IGNvbnRlbnR9KQogICAgZXhjZXB0IElvZXJyb3I6CiAgICAgICAgcmV0dXJuIGpz
b25pZnkoeydlcnJvcic6ICdDYW5ub3QgcmVhZCBmaWxlJ30pLCA1MDAKCmlmIF9fbmFtZV9fID09ICdfX21haW5fXyc6CiAgICBz
b2NrZXRpby5ydW4oYXBwLCBob3N0PScwLjAuMC4wJywgcG9ydD01MDAwLCBkZWJ1Zz1UcnVlKQ==
B64
base64 -d app.py.b64 > app.py
rm app.py.b64

# templates/index.html
mkdir -p templates
cat > templates/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>DevOps Web Console</title>
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
    <!-- Sidebar -->
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

    <!-- Main -->
    <main class="col-md-10 col-lg-10 main-content">
      <!-- Terminal Section -->
      <div id="section-terminal" class="section">
        <div class="card">
          <div class="card-header"><i class="bi bi-console me-2"></i>Interactive Shell</div>
          <div class="card-body p-0"><div id="terminal-container"><div id="terminal"></div></div></div>
        </div>
      </div>

      <!-- Files Section -->
      <div id="section-files" class="section" style="display:none;">
        <div class="card">
          <div class="card-header"><i class="bi bi-folder2-open me-2"></i>File Browser <span id="current-path" class="ms-3 badge bg-secondary">/</span></div>
          <div class="card-body"><ul id="file-list" class="file-list"><li>Loading...</li></ul></div>
        </div>
      </div>

      <!-- Logs Section -->
      <div id="section-logs" class="section" style="display:none;">
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
      </div>

      <!-- System Section -->
      <div id="section-system" class="section" style="display:none;">
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
      </div>

      <!-- Processes Section -->
      <div id="section-processes" class="section" style="display:none;">
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
      </div>
    </main>
  </div>
</div>

<!-- Scripts -->
<script src="https://cdn.socket.io/4.6.0/socket.io.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/xterm/lib/xterm.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Navigation
document.querySelectorAll('.sidebar .nav-link').forEach(link => {
  link.addEventListener('click', function(e) {
    document.querySelectorAll('.sidebar .nav-link').forEach(l => l.classList.remove('active'));
    this.classList.add('active');
    const section = this.dataset.section;
    document.querySelectorAll('.section').forEach(s => s.style.display = 'none');
    document.getElementById('section-'+section).style.display = 'block';
    if (section === 'terminal') setTimeout(() => { term && term.resize(term.cols, term.rows); }, 100);
    if (section === 'system') refreshStats();
    if (section === 'processes') refreshProcesses();
    if (section === 'files') loadFiles();
  });
});

// Terminal
const socket = io();
const term = new Terminal({ cursorBlink: true, theme: { background: '#0d1117', foreground: '#e6edf3' } });
term.open(document.getElementById('terminal'));
term.focus();

socket.on('shell_ready', (msg) => term.writeln('\x1b[32m' + msg.status + '\x1b[0m'));
socket.on('shell_output', (data) => term.write(data.data));
term.onData((data) => socket.emit('shell_input', { data: data }));
socket.on('disconnect', () => term.writeln('\x1b[31mDisconnected\x1b[0m'));

// Files
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
        if (f.type === 'dir') {
          li.addEventListener('click', () => loadFiles(data.path + '/' + f.name));
        }
        ul.appendChild(li);
      });
    });
}
document.querySelector('[data-section="files"]').addEventListener('click', loadFiles);

// Logs
document.getElementById('load-log').addEventListener('click', function() {
  const path = document.getElementById('log-path').value;
  fetch(`/api/tail?file=${encodeURIComponent(path)}`)
    .then(r => r.json())
    .then(data => {
      const el = document.getElementById('log-content');
      if (data.error) el.textContent = 'Error: ' + data.error;
      else el.textContent = data.content;
    });
});

// System
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

// Processes
function refreshProcesses() {
  fetch('/api/process')
    .then(r => r.json())
    .then(data => {
      const tbody = document.getElementById('process-table');
      tbody.innerHTML = data.map(p => `<tr><td>${p.pid}</td><td>${p.name}</td><td>${p.cpu}</td></tr>`).join('');
    });
}
document.querySelector('[data-section="processes"]').addEventListener('click', refreshProcesses);

window.addEventListener('resize', () => { term.resize(term.cols, term.rows); });
</script>
</body>
</html>
EOF

echo "📦 Installing dependencies via uv..."
uv sync

echo "🚀 Starting service in background..."
nohup uv run python app.py > server.log 2>&1 &
SERVICE_PID=$!
sleep 2

# Check if service is running
if ps -p $SERVICE_PID > /dev/null; then
    IP=$(hostname -I | awk '{print $1}')
    echo ""
    echo "✅ Service started successfully!"
    echo "🌐 Access your web console at: http://$IP:5000"
    echo "📄 Log file: $PROJECT_DIR/server.log"
    echo "🛑 To stop: kill $SERVICE_PID"
else
    echo "❌ Failed to start service. Check $PROJECT_DIR/server.log for errors."
    exit 1
fi
