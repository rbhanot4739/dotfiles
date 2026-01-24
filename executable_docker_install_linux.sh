#!/bin/bash
set -e

# --- 1. Safety Checks ---
if pgrep -x "dockerd" > /dev/null || [ -S /var/run/docker.sock ]; then
    echo "ERROR: Docker daemon is already running. Please stop it first."
    exit 1
fi

if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Please run this script as your regular user, NOT with sudo/root."
    exit 1
fi

# --- 2. Configuration ---
DOCKER_VER="27.5.1"
BUILDX_VER="v0.30.1"

# NOTE: Docker static site uses 'x86_64', GitHub plugins use 'amd64'
ENGINE_ARCH="x86_64"
PLUGIN_ARCH="amd64"

PLUGIN_DIR="$HOME/.docker/cli-plugins"

# --- 3. Install Docker Engine Binaries ---
echo "Installing Docker Engine $DOCKER_VER..."
curl -L "https://download.docker.com/linux/static/stable/${ENGINE_ARCH}/docker-${DOCKER_VER}.tgz" | \
    sudo tar -xz -C /usr/local/bin --strip-components=1

# --- 4. Install Plugins (User Scope) ---
mkdir -p "$PLUGIN_DIR"

echo "Installing Docker Compose Plugin (latest)..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${ENGINE_ARCH}" \
    -o "$PLUGIN_DIR/docker-compose"

echo "Installing Docker Buildx Plugin ($BUILDX_VER)..."
curl -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-${PLUGIN_ARCH}" \
    -o "$PLUGIN_DIR/docker-buildx"

# Ensure both are executable
chmod 755 "$PLUGIN_DIR/docker-compose" "$PLUGIN_DIR/docker-buildx"

# --- 5. Setup Systemd Service ---
if [ ! -f /etc/systemd/system/docker.service ]; then
    echo "Configuring systemd service..."
    sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Application Container Engine
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/local/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable docker
fi

# --- 6. Start and Verify ---
echo "Starting Docker service..."
sudo systemctl start docker

# Add user to docker group if not already there
if ! groups | grep -q "\bdocker\b"; then
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"
    echo "NOTE: User '$USER' added to 'docker' group. Log out and back in for this to take effect."
fi

echo "--- Verification ---"
docker version --format 'Engine: {{.Client.Version}}'
docker compose version
docker buildx version
