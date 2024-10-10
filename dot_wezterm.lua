-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Macchiato"
	else
		return "Catppuccin Latte"
	end
end

-- config.color_scheme = scheme_for_appearance(get_appearance())
config.color_scheme = "tokyonight_moon"
-- config.color_scheme = "catppuccin-mocha"

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 16

-- Tabbar settings
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 1
config.macos_window_background_blur = 35
config.keys = {
	-- Disable some default keys,
	{ key = "UpArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "DownArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "LeftArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "RightArrow", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "RightArrow", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "LeftArrow", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{
		key = "Enter",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
}
-- and finally, return the configuration to wezterm
return config
