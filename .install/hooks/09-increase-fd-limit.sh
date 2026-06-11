# Raise soft file descriptor limit from systemd's default of 1024 to 65536
# so dev tools (VS Code, Docker, dev servers, databases) get the headroom they need
sudo mkdir -p /etc/systemd/system.conf.d /etc/systemd/user.conf.d

sudo tee /etc/systemd/system.conf.d/99-nofile.conf >/dev/null <<'EOF'
[Manager]
DefaultLimitNOFILE=65536:524288
EOF

sudo cp /etc/systemd/system.conf.d/99-nofile.conf \
        /etc/systemd/user.conf.d/99-nofile.conf


echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/90-file-watchers.conf >/dev/null
sudo sysctl --system >/dev/null 2>&1
