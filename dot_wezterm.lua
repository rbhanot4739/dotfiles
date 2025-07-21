local wezterm = require("wezterm")
local config = wezterm.config_builder()

local HOME = os.getenv("HOME")
local mode_file = HOME .. "/.bg_mode"

-- === THEMING WORKFLOW ===
--
-- STARTUP:
-- 1. get_current_scheme() reads system appearance → writes ~/.bg_mode → reads ~/.theme_* → maps to WezTerm scheme
-- 2. File watchers set up for ~/.theme_light and ~/.theme_dark
-- 3. Event handler registered for config reloads
--
-- SYSTEM THEME CHANGE:
-- 1. System appearance changes → triggers "window-config-reloaded" event
-- 2. get_current_scheme() detects new appearance → updates ~/.bg_mode → reads different theme file
-- 3. New scheme applied via window:set_config_overrides()
--
-- THEME FILE CHANGE:
-- 1. External tool modifies ~/.theme_* → file watcher triggers reload event
-- 2. get_current_scheme() reads updated file content (same ~/.bg_mode)
-- 3. New scheme applied immediately
--
-- FILES: ~/.bg_mode (tracks light/dark), ~/.theme_light, ~/.theme_dark (contain theme names)

-- Simplified theme mapping
local themes = {
	everforest = { light = "Everforest Light Hard (Gogh)", dark = "Everforest Dark Hard (Gogh)" },
	["gruvbox-material"] = { light = "Gruvbox light, hard (base16)", dark = "Gruvbox Material (Gogh)" },
	dawnfox = "dawnfox",
	dayfox = "dayfox",
	["tokyonight-day"] = "tokyonight_day",
	nightfox = "nightfox",
	nordfox = "nordfox",
	["tokyonight-moon"] = "tokyonight_moon",
	["tokyonight-night"] = "tokyonight_night",
	["tokyonight-storm"] = "tokyonight_storm",
}

-- Helper functions
local function read_file(path)
	local file = io.open(path, "r")
	if file then
		local content = file:read("*line")
		file:close()
		return content and content:match("%S") and content:gsub("%s+", "")
	end
end

local function write_file(path, content)
	local file = io.open(path, "w")
	if file then
		file:write(content)
		file:close()
	end
end

local function get_theme_scheme(theme_name, bg_mode)
	local theme = themes[theme_name]
	if type(theme) == "table" then
		wezterm.log_warn("Using theme: " .. theme[bg_mode] .. " for mode: " .. bg_mode)
		return theme[bg_mode] or theme.dark
	end
	if theme then
		return theme
	end
	-- If theme doesn't exist in our themes table, use a safe default
	wezterm.log_warn("Unknown theme: " .. tostring(theme_name) .. ", falling back to default")
	return bg_mode == "dark" and "nordfox" or "dawnfox"
end

local function get_current_scheme()
	local is_dark = wezterm.gui and wezterm.gui.get_appearance():find("Dark")
	local bg_mode = is_dark and "dark" or "light"

	write_file(mode_file, bg_mode)

	local theme = read_file(HOME .. "/.theme_" .. bg_mode)
	if theme then
		return get_theme_scheme(theme, bg_mode)
	end

	return bg_mode == "dark" and "nordfox" or "dawnfox"
end

-- === THEMING & CONFIG RELOAD ===
-- Flow: System appearance change OR theme file change → reload event → update color scheme
-- Watch theme files for changes
wezterm.add_to_config_reload_watch_list(HOME .. "/.theme_light")
wezterm.add_to_config_reload_watch_list(HOME .. "/.theme_dark")

-- Handle config reloads: update color scheme when watched files change
wezterm.on("window-config-reloaded", function(window)
	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = get_current_scheme()
	window:set_config_overrides(overrides)
end)

-- Core configuration
config.initial_cols = 180
config.initial_rows = 60
config.enable_kitty_keyboard = true
config.color_scheme = get_current_scheme()
config.font = wezterm.font("JetBrainsMonoNL Nerd Font")
config.font_size = 13

-- UI settings
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_background_opacity = 1
config.macos_window_background_blur = 5
config.window_padding = { left = 1, right = 0, top = 2, bottom = 0 }

-- Key bindings
local disable_keys = {
	{ key = "UpArrow", mods = "SHIFT|CTRL" },
	{ key = "DownArrow", mods = "SHIFT|CTRL" },
	{ key = "LeftArrow", mods = "SHIFT|CTRL" },
	{ key = "RightArrow", mods = "SHIFT|CTRL" },
	{ key = "RightArrow", mods = "CTRL" },
	{ key = "LeftArrow", mods = "CTRL" },
	{ key = "Enter", mods = "ALT" },
	{ key = "Enter", mods = "CTRL" },
}

config.keys = {}
for _, key in ipairs(disable_keys) do
	table.insert(config.keys, { key = key.key, mods = key.mods, action = wezterm.action.DisableDefaultAssignment })
end

-- Custom key bindings
local custom_keys = {
	{ key = "Enter", mods = "SHIFT|CTRL", action = wezterm.action.ToggleFullScreen },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b[13;2u" }) },
	{ key = "C", mods = "SHIFT|CTRL", action = wezterm.action.ActivateCopyMode },
	{
		key = "E",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "T",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			overrides.color_scheme = get_current_scheme()
			window:set_config_overrides(overrides)
		end),
	},
}

for _, key in ipairs(custom_keys) do
	table.insert(config.keys, key)
end

return config
