local plugins = {}

-- List of custom plugin files
local custom_plugins = {
  "colorscheme",
  "debugger",
  "disabled",
  "flash",
  -- "lsp-tools",
  "lualine",
  "mini",
  -- "neo-tree",
  "neogit",
  "neotest",
  "noice",
  "nvim-cmp",
  "telescope",
  "todo-comments",
  "toggle-term",
  "trouble",
  "undotree",
  "util-plugins",
  -- "venv-selector",
}

-- Require each custom plugin and add it to the plugins table
for _, plugin in ipairs(custom_plugins) do
  table.insert(plugins, require("plugins.custom." .. plugin))
end

return plugins
