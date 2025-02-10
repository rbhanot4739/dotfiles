local get_path = function()
  -- convert the path to a short form
  -- vim.fn.expand("%:~:.:h") will first get the path to file
  -- then replace the homedir with `~` and then replace the
  -- current directory with `.` and finally will pick just the directory part of the path
  local path = vim.fn.expand("%:~:.:h")
  if string.len(path) > 50 then
    local parts = vim.split(path, "/")
    for i = 1, #parts - 1 do
      if string.len(parts[i]) > 2 then
        parts[i] = string.sub(parts[i], 1, 2)
      end
    end
    path = table.concat(parts, "/")
  end
  return path
end
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    local icons = LazyVim.config.icons
    opts.options = {
      theme = "auto",
      disabled_filetypes = {
        globalstatus = vim.o.laststatus == 3,
        statusline = { "neo-tree", "dashboard", "alpha", "ministarter" },
        winbar = { "neo-tree", "dashboard", "alpha", "ministarter", "toggleterm" },
      },
    }
    opts.winbar = {
      -- lualine_a = {
      --   {
      --     "buffers",
      --     symbols = {
      --       modified = " ●", -- Text to show when the buffer is modified
      --       alternate_file = "", -- Text to show to identify the alternate file
      --       directory = "", -- Text to show when the buffer is a directory
      --     },
      --   },
      -- },
      lualine_a = {
        {
          get_path,
          -- cond = function()
          --   local excluded_fts = { "dashboard", "alpha", "ministarter", "toggleterm" }
          --   return not vim.tbl_contains(excluded_fts, vim.bo.filetype)
          -- end,
        },
      },
      lualine_z = {
        function()
          local buffers = vim.fn.getbufinfo({ buflisted = 1 })
          return "open buffers: " .. tostring(#buffers)
        end,
      },
    }
    -- remove the file icon and pretty_path sections
    -- Note: when we remove 3rd section then 4th section becomes next 3rd so we again need to remmove the same again
    table.remove(opts.sections.lualine_c, 3)
    table.remove(opts.sections.lualine_c, 3)
    local trouble = require("trouble")
    local symbols = trouble.statusline({
      mode = "symbols",
      groups = {},
      title = false,
      filter = { range = true },
      format = "{kind_icon}{symbol.name:Normal}",
      hl_group = "lualine_c_normal",
    })
    opts.sections.lualine_c = {
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { "filename", file_status = true, path = 0 },
      { symbols.get },
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
    }

    opts.extensions = { "neo-tree", "lazy" }
    return opts
  end,
}
