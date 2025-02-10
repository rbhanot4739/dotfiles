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
    opts = {
      mappings = {
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
      },
    },
  },
}
