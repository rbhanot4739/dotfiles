local lazypath = vim.fn.stdpath("data") .. "/minimal-lazy/lazy.nvim"
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

require("lazy").setup({

	spec = {
		-- add LazyVim and import its plugins
		{
			"LazyVim/LazyVim",
			import = "lazyvim.plugins",
			opts = {},
		},
		{ "akinsho/bufferline.nvim", enabled = false },
		{ "linux-cultist/venv-selector.nvim", enabled = false },
		{ "folke/persistence.nvim", enabled = false },
		{ "nvim-neo-tree/neo-tree.nvim", enabled = false },
		{ "chezmoi.vim", enabled = false },
		{ "edgy.nvim", enabled = false },
		{ "flash.nvim", enabled = false },
		{ "lazy.nvim", enabled = false },
		{ "lualine.nvim", enabled = false },
		{ "mini.ai", enabled = false },
		{ "mini.icons", enabled = false },
		{ "mini.move", enabled = false },
		{ "mini.pairs", enabled = false },
		{ "noice.nvim", enabled = false },
		{ "nui.nvim", enabled = false },
		{ "nvim-treesitter-textobjects", enabled = false },
		{ "trouble.nvim", enabled = false },
		{ "ts-comments.nvim", enabled = false },
		{ "which-key.nvim", enabled = false },
		{ "nvim-treesitter", enabled = false },
		{ "LazyVim", enabled = false },
		{ "tokyonight.nvim", enabled = false },
		-- { "snacks.nvim", enabled = false },
	},
	defaults = {
		-- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
		-- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
		lazy = false,
		-- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
		-- have outdated releases, which may break your Neovim install.
		version = false, -- always use the latest git commit
		-- version = "*", -- try installing the latest stable version for plugins that support semver
	},
	install = { colorscheme = { "tokyonight", "habamax" } },
	checker = {
		enabled = false, -- check for plugin updates periodically
		notify = false, -- notify on update
	}, -- automatically check for plugin updates
	ui = { border = "single" },
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
