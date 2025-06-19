local wezterm = require("wezterm")
local config = wezterm.config_builder()

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "nightfox"
	else
		return "dawnfox"
	end
end

-- config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
config.initial_cols = 180
config.initial_rows = 60
config.debug_key_events = true
config.enable_kitty_keyboard = true
config.color_scheme = scheme_for_appearance(get_appearance())
-- config.color_scheme = "tokyonight_moon"

config.font = wezterm.font("JetBrainsMonoNL Nerd Font")
config.font_size = 13

-- Tab bar settings
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

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
}
-- and finally, return the configuration to wezterm
return config
