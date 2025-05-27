local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local config_utils = require("config.utils")
require("lazy").setup({

  spec = {
    -- add LazyVim and import its plugins
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = function()
          -- read theme value from/tmp/theme
          -- or use the environment variable THEME
          local theme_file = "/tmp/theme"
          if vim.fn.filereadable(theme_file) == 1 then
            local file = io.open(theme_file, "r")
            if file then
              local theme = file:read("*l")
              file:close()
              if theme == "" then
                theme = "tokyonight" -- default theme
              end
              vim.cmd.colorscheme(theme)
              return
            end
          end
        end,
        icons = {
          kinds = config_utils.icons.kinds,
        },
      },
    },
    { import = "plugins" },
    { import = "disabled" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can` set` this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  change_detection = {
    enabled = true,
    notify = true, -- get a notification when changes are found
  },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  ui = { border = "single" },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "matchparen",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ruby_provider",
        "perl_provider",
      },
    },
  },
})
-- vim.cmd([[command! -nargs=0 Grep :lua Snacks.picker.grep()]])

local function set_shada_file()
  local git_root = require("snacks").git.get_root()
  local dir = git_root ~= nil and git_root or vim.fn.getcwd()
  local shada_file = vim.fs.joinpath(vim.fn.stdpath("state"), "shada", vim.fn.fnamemodify(dir, ":t") .. ".shada")
  vim.o.shadafile = shada_file
end

set_shada_file()
