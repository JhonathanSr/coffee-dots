-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--hl.monitor({
--    output   = "",
--    mode     = "preferred",
--    position = "auto",
--    scale    = "auto",
--})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "1920x0",
	scale = 1.5,
})

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@240",
	position = "0x0",
	scale = 1,
	--transform = 3,
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use

-- Obtener el directorio HOME del usuario actual
local home = os.getenv("HOME")
local rofi_scripts = home .. "/.config/rofi/scripts/"

local terminal = "ghostty"
local tui_launcher = 'uwsm app -- ghostty --title="tui" -e '
local fileManager = 'uwsm app -- ghostty --title="tui" -e yazi'
local browser = "zen-browser"
local visual = "code"
local editor = "uwsm app -- ghostty -e nvim"
local docker = "lazydocker"
local btop = "btop"
local music = "spotify-launcher"
local obsidian = "obsidian"
local bitwarden = "uwsm app -- bitwarden-desktop"
local bin_path = "~/.config/coffee/"

local active_border_color = { colors = { "rgba(8a8588ee)", "rgba(e2dddcee)" }, angle = 45 }
local inactive_border_color = "rgba(584e51aa)"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--hl.env("AQ_DRM_DEVICES", "/dev/dri/by-path/pci-0000:05:00.0-card:/dev/dri/by-path/pci-0000:01:00.0-card")
--hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
--hl.env("XDG_CONFIG_DIR", "$HOME")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("TERMINAL", terminal)
--hl.env("XDG_CONFIG_HOME", "$HOME/.config")
-- Force all apps to use Wayland.
hl.env("NVD_BACKEND", "direct")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GTK_THEME", "Adwaita:dark")

-- Allow better support for screen sharing (Google Meet, Discord, etc).
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
hl.on("hyprland.start", function()
	-- 1. Sincronizar el entorno D-Bus y SYSTEMD de forma limpia para Wayland e UWSM
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XAUTHORITY")
	hl.exec_cmd("uwsm env WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XAUTHORITY") -- Avisar a UWSM del entorno vivo

	-- 2. Forzar el reinicio de los portales XDG dentro del entorno limpio
	hl.exec_cmd(
		"systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gnome 2>/dev/null"
	)
	hl.exec_cmd("systemctl --user start xdg-desktop-portal")

	-- 3. Inicializar Daemons del Sistema y Llaveros (Antes de las Apps)
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("uwsm-app -- gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("uwsm-app -- swayosd-server")
	hl.exec_cmd("start-power-profile")

	-- 4. Servicios de Usuario persistentes
	hl.exec_cmd("systemctl --user start hypridle.service")
	hl.exec_cmd("systemctl --user start hyprpaper.service")

	-- 5. Componentes de la Interfaz
	hl.exec_cmd("uwsm-app -- waybar")
	hl.exec_cmd("uwsm-app -- fcitx5 --disable notificationitem")
	hl.exec_cmd("uwsm-app -- mako")

	-- 6. Configuraciones estéticas de Hyprland
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
end)

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 2,

		border_size = 1,

		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,

		shadow = {
			enabled = true,
			range = 2,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},

		blur = {
			enabled = true,
			size = 2,
			passes = 2,
			special = true,
			brightness = 0.60,
			contrast = 0.75,
		},
	},
	group = {
		col = {
			border_active = active_border_color,
			border_inactive = inactive_border_color,
		},

		groupbar = {
			font_size = 12,
			font_family = "monospace",
			font_weight_active = "ultraheavy",
			font_weight_inactive = "normal",
			indicator_height = 0,
			indicator_gap = 5,
			height = 22,
			gaps_in = 5,
			gaps_out = 0,
			text_color = "rgb(ffffff)",
			text_color_inactive = "rgba(ffffff90)",
			col = {
				active = "rgba(00000040)",
				inactive = "rgba(00000020)",
			},
			gradients = true,
			gradient_rounding = 0,
			gradient_round_only_edges = false,
		},
	},
})

hl.config({
	general = {
		col = {
			active_border = active_border_color,
		},
	},

	group = {
		col = {
			border_active = active_border_color,
		},
	},
})

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},

	ecosystem = {
		no_update_news = true,
	},
})
-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "1", monitor = "eDP-1DP-1", persistent = true })
-- hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true })
-- hl.workspace_rule({ workspace = "5", monitor = "eDP-1", persistent = true })
-- hl.workspace_rule({ workspace = "7", monitor = "eDP-1", persistent = true })
--
-- hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", persistent = true })
-- hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", persistent = true })
-- hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1", persistent = true })
-- hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-1", persistent = true })
--
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		preserve_split = true,
		force_split = 2,
	},

	scrolling = {
		column_width = 0.49,
	},

	master = {
		new_status = "master",
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		disable_scale_notification = true,
		focus_on_activate = true,
		anr_missed_pings = 3,
		on_focus_under_fullscreen = 1,
	},

	cursor = {
		hide_on_key_press = true,
		warp_on_change_workspace = 1,
		no_hardware_cursors = true,
	},

	binds = {
		hide_special_on_workspace_change = true,
	},
})
---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "intl",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		repeat_rate = 25,
		repeat_delay = 300,
		numlock_by_default = true,

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			clickfinger_behavior = true,
			natural_scroll = false,
			scroll_factor = 0.4,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local secondMainmod = "SUPER + SHIFT"

-- Defaults
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(
	secondMainmod .. " + DELETE",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- Apps
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(editor))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(rofi_scripts .. "launcher_t1"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(rofi_scripts .. "powermenu_t2"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(visual))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(tui_launcher .. docker))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(tui_launcher .. btop))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(music))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("steam"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(obsidian))
hl.bind(mainMod .. " + SLASH", hl.dsp.exec_cmd(bitwarden))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("uwsm-app -- gnome-calculator"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))

-- Tilling
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(secondMainmod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + LEFT", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + UP", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + DOWN", hl.dsp.focus({ direction = "down" }))
--hl.bind(secondMainmod .. " + L", hl.dsp.window.move({ direction = "right" }))
--hl.bind(secondMainmod .. " + K", hl.dsp.window.move({ direction = "up" }))
--hl.bind(secondMainmod .. " + H", hl.dsp.window.move({ direction = "left" }))
--hl.bind(secondMainmod .. " + J", hl.dsp.window.move({ direction = "down" }))
-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(secondMainmod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind(secondMainmod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i }))
end
-- Menú de Workspaces y Ventanas activas con Rofi
hl.bind(
	mainMod .. " + TAB",
	hl.dsp.exec_cmd("rofi -show window -theme-str 'window { width: 35%; }' -window-format '{workspace} -> {c} : {t}'")
)
hl.bind(secondMainmod .. " + TAB", hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(secondMainmod .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio controls.
hl.bind(
	"ALT + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --output-volume +1"),
	{ locked = true, repeating = true }
)
hl.bind(
	"ALT + XF86AudioLowerVolume",
	hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --output-volume -1)", { locked = true, repeating = true })
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --output-volume +5%"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --output-volume raise"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --output-volume -5%)"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --output-volume lower"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --output-volume mute-toggle"),
	{ locked = true, repeating = true }
)
hl.bind(mainMod .. " + XF86AudioMute", hl.dsp.exec_cmd("audio-toggle"), { locked = true })

-- Media controls.
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(bin_path .. "swayosd-wrapper --playerctl previous"), { locked = true })

-- Brightness controls.
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(bin_path .. "display-brightness +5%"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(bin_path .. "display-brightness 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"ALT + XF86MonBrightnessUp",
	hl.dsp.exec_cmd(bin_path .. "display-brightness +1%"),
	{ locked = true, repeating = true }
)
hl.bind(
	"ALT + XF86MonBrightnessDown",
	hl.dsp.exec_cmd(bin_path .. "display-brightness 1%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86MonBrightnessUp",
	hl.dsp.exec_cmd(bin_path .. "display-brightness 100%"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86MonBrightnessDown",
	hl.dsp.exec_cmd(bin_path .. "display-brightness 1%"),
	{ locked = true, repeating = true }
)

-- Keyboard brightness controls.
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(bin_path .. "kbd-brightness up"), { locked = true, repeating = true })
hl.bind(
	"XF86KbdBrightnessDown",
	hl.dsp.exec_cmd(bin_path .. "kbd-brightness down"),
	{ locked = true, repeating = true }
)
hl.bind("XF86KbdLightOnOff", hl.dsp.exec_cmd(bin_path .. "kbd-brightness cycle"), { locked = true })

-- Touchpad controls.
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd(bin_path .. "touchpad-toggle"), { locked = true })
hl.bind("XF86TouchpadOn", hl.dsp.exec_cmd(bin_path .. "touchpad-toggle on"), { locked = true })
hl.bind("XF86TouchpadOff", hl.dsp.exec_cmd(bin_path .. "touchpad-toggle off"), { locked = true })

hl.bind("XF86RFKill", hl.dsp.exec_cmd(bin_path .. "airplane-mode toggle"), { locked = true })

-- Screenshots and screen recording.
--hl.bind("PRINT", hl.dsp.exec_cmd(bin_path .. "screenshot"))
hl.bind("PRINT", hl.dsp.exec_cmd(bin_path .. "screenshot smart slurp"))

--hl.bind("ALT + PRINT", hl.dsp.exec_cmd("screenrecord"))

hl.bind("SUPER + PRINT", hl.dsp.exec_cmd("pkill hyprpicker || hyprpicker -a"))

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(bin_path .. "monitor-internal off"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(bin_path .. "monitor-internal on"), { locked = true })

local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
	local current = hl.get_config("cursor.zoom_factor")
	if offset ~= nil then
		current = current + offset
	elseif current ~= MIN_ZOOM then
		current = MIN_ZOOM
	else
		current = ZOOM_TOGGLE_FACTOR
	end
	current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
	hl.config({ cursor = { zoom_factor = current } })
end

hl.bind("SUPER + Z", zoom)
hl.bind("SUPER + KP_ADD", function()
	zoom(0.5)
end)
hl.bind("SUPER + minus", function()
	zoom(-0.5)
end)
--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

--https://wiki.hypr.land/Configuring/Basics/Window-Rules/#layer-rules
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name = "tui",
	match = {
		title = "tui",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.5)", "(monitor_h*0.5)" },
})

hl.window_rule({
	name = "yazi",
	match = {
		title = "yazi",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
})

hl.window_rule({
	name = "power",
	match = {
		title = "power",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.1)", "(monitor_h*0.1)" },
})

hl.window_rule({
	name = "steam.*",
	match = {
		class = "steam.*",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.5)", "(monitor_h*0.5)" },
})

hl.window_rule({
	name = "steam",
	match = {
		title = "Steam",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.8)", "(monitor_h*0.8)" },
})

hl.window_rule({
	name = "spotify",
	match = {
		class = "Spotify",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
})

hl.window_rule({
	name = "xdg-desktop-portal-gtk",
	match = {
		class = "xdg-desktop-portal-gtk",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
})

hl.window_rule({
	name = "KDE connect",
	match = {
		class = "org.kde.kdeconnect.*",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
})

hl.window_rule({
	name = "obsidian",
	match = {
		class = "obsidian",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.8)", "(monitor_h*0.8)" },
})

hl.window_rule({
	name = "Bitwarden",
	match = {
		class = "Bitwarden",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.8)", "(monitor_h*0.8)" },
})

hl.window_rule({
	name = "WinDocker",
	match = {
		class = "com.freerdp.client.sdl3",
	},
	workspace = "special:magic",
})

hl.window_rule({
	name = "Calculator",
	match = {
		class = "org.gnome.Calculator",
	},
	float = true,
	fullscreen = false,
	center = true,
	size = { "(monitor_w*0.3)", "(monitor_h*0.3)" },
})
