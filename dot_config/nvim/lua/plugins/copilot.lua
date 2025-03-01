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
}
