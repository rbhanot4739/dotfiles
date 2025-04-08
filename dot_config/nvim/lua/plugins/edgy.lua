return {
  "folke/edgy.nvim",
  opts = function(_, opts)
    local bottom = {
      { ft = "dap-repl", size = { height = 0.2 }, title = " Debug REPL" },
      { ft = "dapui_console", size = { height = 0.2 }, title = "Debug Console" },
    }
    local right = {
      { ft = "codecompanion", title = " CodeCompanionChat", size = { width = 0.35 } },
      { ft = "dapui_scopes", title = " Scopes" },
      { ft = "dapui_watches", title = " Watches" },
      { ft = "dapui_stacks", title = " Stacks" },
      { ft = "dapui_breakpoints", title = " Breakpoints", size = { width = 0.3 } },
    }
    local function merge_arrays(a1, a2)
      for _, v in ipairs(a2) do
        table.insert(a1, v)
      end
    end
    merge_arrays(opts.bottom, bottom)
    merge_arrays(opts.right, right)
    opts.options = {
      right = { size = 62 },
    }
  end,
}
