return {
  {
    "mfussenegger/nvim-dap",
      -- stylua: ignore
        keys = {
    { "<leader>dt", "", desc = "+[T]ests", mode = {"n", "v"} },
      { "<leader>dT", function() require("dap").terminate() end, desc = "Terminate" },
  },
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local pydap = require("dap-python")
      pydap.setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
      pydap.test_runner = "pytest"
    end,
    keys = {
      {
        "<leader>dtm",
        function()
          require("dap-python").test_method()
        end,
        desc = "[M]ethod",
        ft = "python",
      },
      {
        "<leader>dtc",
        function()
          require("dap-python").test_class()
        end,
        desc = "[C]lass",
        ft = "python",
      },
    },
  },
  -- Don't mess up DAP adapters provided by nvim-dap-python
  -- {
  --   "jay-babu/mason-nvim-dap.nvim",
  --   optional = true,
  --   opts = {
  --     handlers = {
  --       python = function() end,
  --     },
  --   },
  -- },
}
