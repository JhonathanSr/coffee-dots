# Install omarchy SDDM theme
#omarchy-refresh-sddm

CRE=$(tput setaf 1); 
CYE=$(tput setaf 3); 
CGR=$(tput setaf 2); 
CBL=$(tput setaf 4); 
BLD=$(tput bold); 
CNC=$(tput sgr0)

ERROR_LOG="$HOME/coffee-dots/coffee-errors.log"

# Captura exacta del usuario real (no-root) para no corromper la sesión gráfica
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
REAL_HOME=$(eval echo "~$REAL_USER")


export COFFEE_PATH="${REAL_HOME}/coffee-dots"

# Setup SDDM login service
sudo mkdir -p /usr/local/share/wayland-sessions
sudo cp "$COFFEE_PATH/default/wayland-sessions/coffee.desktop" /usr/local/share/wayland-sessions/coffee.desktop
sudo cp "$COFFEE_PATH/default/sddm/hyprland.lua" /usr/share/sddm/hyprland.lua
sudo rm -f /usr/share/sddm/hyprland.conf

sudo mkdir -p /etc/sddm.conf.d
cat <<EOF | sudo tee /etc/sddm.conf.d/10-wayland.conf >/dev/null
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=start-hyprland -- --config /usr/share/sddm/hyprland.lua
EOF

if [[ ! -f /etc/sddm.conf.d/autologin.conf ]]; then
  cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf
[Autologin]
User=$USER
Session=coffee

[Theme]
Current=coffee
EOF
else
  sudo sed -i 's/^Session=hyprland-uwsm$/Session=coffee/' /etc/sddm.conf.d/autologin.conf
fi

# Prevent password-based SDDM logins from creating an encrypted login keyring
# (which conflicts with the passwordless Default_keyring used for auto-unlock)
sudo sed -i '/-auth.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
sudo sed -i '/-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm

# Don't use chrootable here as --now will cause issues for manual installs
sudo systemctl enable sddm.service
