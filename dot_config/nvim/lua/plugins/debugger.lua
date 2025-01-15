return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>dt", "", desc = "+[T]ests", mode = { "n", "v" } },
      {
        "<leader>dT",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            {
              id = "scopes",
              size = 0.25,
            },
            {
              id = "breakpoints",
              size = 0.25,
            },
            {
              id = "stacks",
              size = 0.25,
            },
            {
              id = "watches",
              size = 0.25,
            },
          },
          position = "left",
          size = 50,
        },
        {
          elements = {
            {
              id = "repl",
              size = 1,
            },
            -- {
            --   id = "console",
            --   size = 0.5,
            -- },
          },
          position = "bottom",
          size = 15,
        },
      },
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      -- virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
      virt_text_pos = "eol",
      commented = true,
      virt_text_win_col = 100,
      -- virt_lines = true,
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local pydap = require("dap-python")
      pydap.setup(LazyVim.get_pkg_path("debugpy", "/venv/bin/python"))
      pydap.test_runner = "pytest"
    end,
    -- keys = {
    --   {
    --     "<leader>dtm",
    --     function()
    --       require("dap-python").test_method()
    --     end,
    --     desc = "[M]ethod",
    --     ft = "python",
    --   },
    --   {
    --     "<leader>dtc",
    --     function()
    --       require("dap-python").test_class()
    --     end,
    --     desc = "[C]lass",
    --     ft = "python",
    --   },
    -- },
  },
}
