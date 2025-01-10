return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    -- ft = "markdown",
    -- cmd= "ObsidianSearch",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
      --   -- refer to `:h file-pattern` for more examples
      "BufReadPre "
        .. vim.fn.expand("~")
        .. "/Google Drive/My Drive/Obsedian",
      "BufNewFile " .. vim.fn.expand("~") .. "/Google Drive/My Drive/Obsedian",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>oo", "<cmd>ObsidianSearch<CR>", { noremap = true, silent = true, desc = "Open ObsidianSearch" } },
      { "<leader>ol", "<cmd>ObsidianLinks<CR>", { noremap = true, silent = true, desc = "Open ObsidianLinks" } },
      { "<leader>oL", "<cmd>ObsidianBacklinks<CR>", { noremap = true, silent = true, desc = "Obsidian Backlinks" } },
      { "<leader>ot", "<cmd>ObsidianTags<cr>", { noremap = true, silent = true, desc = "Open ObsidianTags" } },
    },
    opts = {
      ui = {
        enable = false,
      },
      workspaces = {
        {
          name = "personal",
          path = vim.fn.expand("~") .. "/Google Drive/My Drive/Obsedian",
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
  },
}
