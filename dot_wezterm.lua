local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- File watcher to monitor theme changes
local function setup_theme_watcher()
	-- Get current bg_mode to determine which file to watch
	local bg_mode_file = io.open("/tmp/.bg_mode", "r")
	local bg_mode = "dark" -- default
	if bg_mode_file then
		bg_mode = bg_mode_file:read("*line") or "dark"
		bg_mode_file:close()
	end

	-- Watch both light and dark theme files
	local theme_files = {
		"/tmp/.theme_light",
		"/tmp/.theme_dark",
	}

	for _, file_path in ipairs(theme_files) do
		wezterm.add_to_config_reload_watch_list(file_path)
	end
end

-- Theme name mapping
local theme_map = {
	["dawnfox"] = "dawnfox",
	["dayfox"] = "dayfox",
	["everforest"] = { light = "Everforest Light Hard (Gogh)", dark = "Everforest Dark Hard (Gogh)" },
	["gruvbox-material"] = { light = "Gruvbox light, hard (base16)", dark = "Gruvbox Material (Gogh)" },
	["tokyonight-day"] = "tokyonight_day",
	["nightfox"] = "nightfox",
	["nordfox"] = "nordfox",
	["tokyonight-moon"] = "tokyonight_moon",
	["tokyonight-night"] = "tokyonight_night",
	["tokyonight-storm"] = "tokyonight_storm",
}

function get_wezterm_scheme(theme_name, bg_mode)
	local mapping = theme_map[theme_name]
	if mapping then
		if type(mapping) == "table" then
			return mapping[bg_mode] or mapping.dark
		else
			return mapping
		end
	end
	return theme_name
end

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
end

function scheme_for_appearance(appearance)
	local bg_mode
	if appearance:find("Dark") then
		bg_mode = "dark"
	else
		bg_mode = "light"
	end

	-- Write bg_mode to file
	local bg_file = io.open("/tmp/.bg_mode", "w")
	if bg_file then
		bg_file:write(bg_mode)
		bg_file:close()
	end

	-- Read theme from file
	local file = io.open("/tmp/.theme_" .. bg_mode, "r")
	if file then
		local theme = file:read("*line")
		file:close()
		if theme and theme:match("%S") then
			local clean_theme = theme:gsub("%s+", "")
			return get_wezterm_scheme(clean_theme, bg_mode)
		end
	end

	-- Fallback to original themes
	return bg_mode == "dark" and "nordfox" or "dawnfox"
end

-- config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
config.initial_cols = 180
config.initial_rows = 60
config.enable_kitty_keyboard = true
config.color_scheme = scheme_for_appearance(get_appearance())

-- Minimal event handler to force theme update on appearance change
wezterm.on("window-config-reloaded", function(window)
	local overrides = window:get_config_overrides() or {}
	overrides.color_scheme = scheme_for_appearance(get_appearance())
	window:set_config_overrides(overrides)
end)

-- Set up file watcher for theme files
setup_theme_watcher()

config.font = wezterm.font("JetBrainsMonoNL Nerd Font")
config.font_size = 13

-- Tab bar settings
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
	left = 1,
	right = 0,
	top = 2,
	bottom = 0,
}

config.window_decorations = "RESIZE"
config.window_background_opacity = 1
config.macos_window_background_blur = 5
config.quick_select_patterns = {}
config.keys = {
	-- Disable some default keys,
	{ key = "UpArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "DownArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "LeftArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "RightArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "RightArrow", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "LeftArrow", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Enter", mods = "ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Enter", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Enter", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{
		key = "Enter",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},

	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b[13;2u" }) },
	{
		key = "C",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		-- rename the current tab
		key = "E",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		-- Manual theme switch for testing
		key = "T",
		mods = "CTRL|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local overrides = window:get_config_overrides() or {}
			local current_appearance = get_appearance()
			overrides.color_scheme = scheme_for_appearance(current_appearance)
			window:set_config_overrides(overrides)
		end),
	},
}
-- and finally, return the configuration to wezterm
return config
