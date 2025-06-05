-- require("neotest").run.run(vim.fn.expand("%")) -- run tests in file
-- require("neotest").run.run(vim.uv.cwd()) -- run all tests in given dir
-- require("neotest").run.run({ suite = true }) -- run all tests in the "suite"
-- require("neotest").run.run() -- run nearest test in the active buffer
return {
  "nvim-neotest/neotest",
  keys = {
    {
      "<leader>ta",
      function()
        require("neotest").run.run({ suite = true })
        require("neotest").summary.open()
      end,
      desc = "Run all tests",
    },
    {
      "<leader>tO",
      function()
        require("neotest").output.open({ enter = true, auto_close = true })
      end,
      desc = "Show Output (Neotest)",
    },
    {
      "<leader>to",
      function()
        require("neotest").output_panel.toggle()
      end,
      desc = "Toggle Output Panel (Neotest)",
    },
  },

  opts = {
    adapters = {
      ["neotest-python"] = {
        dap = { justMyCode = true },
        pytest_discover_instances = true,
      },
    },
  },
}
