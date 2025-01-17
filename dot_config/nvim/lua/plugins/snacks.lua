return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<leader>oo",
      function()
        local vault = vim.fn.expand("~/obsidian-vault/")
        require("snacks").picker.grep({ dirs = { vault } })
      end,
    },
    {
      "<leader>fP",
      function()
        require("snacks").picker.files({
          cwd = vim.fn.stdpath("data"),
          find_command = { "fd", "--type", "f", ".lua$" },
        })
      end,
      desc = "Find Plugin files",
    },
  },
  opts = {
    indent = { enabled = true },
    scroll = { enabled = true },
    gitbrowse = {
      enabled = true,
      remote_patterns = {
        { "^(https://).+@(.*):(.*)", "%1%2/%3" },
        { "^https://%w*@(.*)", "https://%1" },
        { "^(https?://.*)%.git$", "%1" },
        { "^git@(.+):(.+)%.git$", "https://%1/%2" },
        { "^git@(.+):(.+)$", "https://%1/%2" },
        { "^git@(.+)/(.+)$", "https://%1/%2" },
        { "^ssh://git@(.*)$", "https://%1" },
        { "^ssh://([^:/]+)(:%d+)/(.*)$", "https://%1/%3" },
        { "^ssh://([^/]+)/(.*)$", "https://%1/%2" },
        { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
        { "^git@(.*)", "https://%1" },
        { ":%d+", "" },
        { "%.git$", "" },
      },
    },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Find File",
            action = [[:lua require("telescope").extensions.smart_open.smart_open({cwd_only=true})]],
          },
          -- { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", action = ":SessionRestore" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "l", desc = "Sessions", action = ":SessionSearch" },
          { icon = "󰒲 ", key = "x", desc = "LazyExtras", action = ":LazyExtras" },
          { icon = "? ", key = "h", desc = "Help", action = ":Telescope help_tags" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    scratch = {
      win_by_ft = {
        lua = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
        python = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
      },
    },
  },
}
