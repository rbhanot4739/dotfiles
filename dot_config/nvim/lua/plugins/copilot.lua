return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        hgcommit = false,
        svn = false,
        cvs = false,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    opts = {
      mappings = {
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        accept_diff = {
          normal = "<A-y>",
          insert = "<A-yt>",
        },
      },
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    enabled = false,
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "copilot",
      openai = {
        -- model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        temperature = 0,
        max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
        --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
