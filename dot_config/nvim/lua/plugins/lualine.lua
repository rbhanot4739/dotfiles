local get_path = require("utils").trim_path
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local icons = LazyVim.config.icons
    local trouble = require("trouble")
    local symbols = trouble.statusline({
      mode = "symbols",
      groups = {},
      title = false,
      filter = { range = true },
      format = "{kind_icon}{symbol.name:Normal}",
      hl_group = "lualine_c_normal",
    })
    local excluded_fts = {
      "neo-tree",
      "dashboard",
      "alpha",
      "ministarter",
      "toggleterm",
      "snacks_terminal",
      "man",
      "snacks_dashboard",
      "DiffviewFiles",
      "DiffviewFileHistory",
    }
    opts.options = {
      theme = "auto",
      disabled_filetypes = {
        globalstatus = vim.o.laststatus == 3,
        statusline = excluded_fts,
        winbar = excluded_fts,
      },
    }
    opts.winbar = {
      lualine_c = {
        get_path,
        -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        { "filename", file_status = true, path = 0 },
        { symbols.get },
      },
      lualine_x = {
        {
          function()
            return "󱉭  " .. vim.fs.basename(LazyVim.root.cwd())
          end,
          color = { fg = Snacks.util.color("Special") },
        },
      },
      lualine_z = {
        function()
          local buffers = vim.fn.getbufinfo({ buflisted = 1 })
          return "open buffers: " .. tostring(#buffers)
        end,
      },
    }
    opts.sections.lualine_c = {
      {
        function()
          -- get value of VIRTUAL_ENV variable if it exists
          local venv = vim.env.VIRTUAL_ENV
          if venv then
            -- return only the basename of the path
            venv = vim.fn.fnamemodify(venv, ":t")
            return string.format("  %s ", venv)
          else
            return ""
          end
        end,
        color = { fg = Snacks.util.color("Special") },
      },
    }
    -- table.remove(opts.sections.lualine_y, 1)
    -- table.remove(opts.sections.lualine_y, 1)
    opts.sections.lualine_y = {
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
    }
    opts.sections.lualine_z = {
      {
        "filetype",
        colored = false, -- Displays filetype icon in color if set to true
        icon_only = false, -- Display only an icon for filetype
        icon = { align = "right" }, -- Display filetype icon on the right hand side
      },
    }

    return opts
  end,
}
