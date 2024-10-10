return {
  "nvim-neotest/neotest",
  keys = {
    {
      "<leader>tT",
      function()
        require("neotest").run.run(LazyVim.root())
      end,
      desc = "Run All Test Files",
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
