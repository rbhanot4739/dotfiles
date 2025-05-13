return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    enabled = not vim.env.SSH_TTY,
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/obsidian-vault/",
      "BufNewFile " .. vim.fn.expand("~") .. "/obsidian-vault",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<CR>", { noremap = true, silent = true, desc = "Obsidian New Note" } },
      { "<leader>of", "<cmd>ObsidianQuickSwitch<CR>", { noremap = true, silent = true, desc = "Obsidian Find notes" } },
      { "<leader>og", "<cmd>ObsidianSearch<CR>", { noremap = true, silent = true, desc = "Obsidian Grep notes" } },
      { "<leader>ol", "<cmd>ObsidianLinks<CR>", { noremap = true, silent = true, desc = "Obsidian Links" } },
      { "<leader>oL", "<cmd>ObsidianBacklinks<CR>", { noremap = true, silent = true, desc = "Obsidian Backlinks" } },
      { "<leader>ot", "<cmd>ObsidianTags<cr>", { noremap = true, silent = true, desc = "Obsidian Tags" } },
      { "<leader>oT", "<cmd>ObsidianTOC<cr>", { noremap = true, silent = true, desc = "Obsidian TOC" } },
    },
    opts = {
      completion = {
        nvim_cmp = false,
        blink = true,
      },
      ui = {
        enable = false,
      },
      picker = { name = "snacks.pick" },
      workspaces = {
        {
          name = "personal",
          path = vim.fn.expand("~") .. "/obsidian-vault",
        },
      },
      notes_subdir = "Main",
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        sign = false,
        width = "full",
      },
      heading = {
        sign = false,
        position = "overlay",
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        signs = { "󰫎 " },
        width = "full",
        above = "▄",
        below = "▀",
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },
      checkbox = {
        checked = { scope_highlight = "@markup.strikethrough" },
        custom = {
          important = { raw = "[~]", rendered = "󰓎 ", highlight = "DiagnosticWarn" },
        },
      },
      quote = { repeat_linebreak = true },
      win_options = {
        showbreak = { default = "", rendered = "  " },
        breakindent = { default = false, rendered = true },
        breakindentopt = { default = "", rendered = "" },
      },
    },
  },
}
