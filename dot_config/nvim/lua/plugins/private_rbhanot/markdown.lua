return {
  {
    "gaoDean/autolist.nvim",
    ft = {
      "markdown",
      "text",
      "tex",
      "plaintex",
      "norg",
    },
    config = function()
      require("autolist").setup()

      vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>")
      vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>")
      -- vim.keymap.set("i", "<c-t>", "<c-t><cmd>AutolistRecalculate<cr>") -- an example of using <c-t> to indent
      vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>")
      vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>")
      vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>")
      -- vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>")
      -- vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>")

      -- cycle list types with dot-repeat
      vim.keymap.set("n", "<leader>cn", require("autolist").cycle_next_dr, { expr = true })
      vim.keymap.set("n", "<leader>cp", require("autolist").cycle_prev_dr, { expr = true })

      -- if you don't want dot-repeat
      -- vim.keymap.set("n", "<leader>cn", "<cmd>AutolistCycleNext<cr>")
      -- vim.keymap.set("n", "<leader>cp", "<cmd>AutolistCycleNext<cr>")

      -- functions to recalculate list on edit
      vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>")
      vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>")
      vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>")
      vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>")
    end,
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    enabled = not vim.env.SSH_TTY,
    ft = { "markdown" },
    -- event = {
    --   "BufReadPre " .. vim.fn.expand("~") .. "/obsidian-vault/",
    --   "BufNewFile " .. vim.fn.expand("~") .. "/obsidian-vault",
    -- },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>on",
        "<cmd>Obsidian new<CR>",
        noremap = true,
        silent = true,
        desc = "Obsidian New Note",
        ft = { "markdown" },
      },
      {
        "<leader>oN",
        "<cmd>Obsidian rename<CR>",
        noremap = true,
        silent = true,
        desc = "Obsidian Rename Note",
        ft = { "markdown" },
      },
      {
        "<leader>of",
        "<cmd>Obsidian quick_switch<CR>",
        noremap = true,
        silent = true,
        desc = "Obsidian Find notes",
        ft = { "markdown" },
      },
      {
        "<leader>og",
        "<cmd>Obsidian search<CR>",
        noremap = true,
        silent = true,
        desc = "Obsidian Grep notes",
        ft = { "markdown" },
      },
      {
        "<leader>ol",
        "<cmd>Obsidian links<CR>",
        noremap = true,
        silent = true,
        desc = "Obsidian Links",
        ft = { "markdown" },
      },
      {
        "<leader>oL",
        "<cmd>Obsidian backlinks<CR>",
        noremap = true,
        silent = true,
        desc = "Obsidian Backlinks",
        ft = { "markdown" },
      },
      {
        "<leader>ot",
        "<cmd>Obsidian tags<cr>",
        noremap = true,
        silent = true,
        desc = "Obsidian Tags",
        ft = { "markdown" },
      },
      {
        "<leader>oT",
        "<cmd>Obsidian toc<cr>",
        noremap = true,
        silent = true,
        desc = "Obsidian TOC",
        ft = { "markdown" },
      },
    },
    opts = {
      callbacks = {
        enter_note = function(note)
          vim.keymap.set("n", "<leader><CR>", require("obsidian.api").smart_action, {
            buffer = true,
            desc = "Toggle checkbox",
          })
        end,
      },
      -- completion = {
      --   nvim_cmp = false,
      --   blink = true,
      -- },
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
      new_notes_location = "current_dir",
      notes_subdir = "notes",
      daily_notes = {
        folder = "dailies",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        default_tags = { "daily-notes" },
        template = "daily.md",
        -- Optional, if you want `Obsidian yesterday` to return the last work day or `Obsidian tomorrow` to return the next work day.
        workdays_only = true,
      },
      templates = {
        folder = "_extras/templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        -- A map for custom variables, the key should be the variable and the value a function.
        -- Functions are called with obsidian.TemplateContext objects as their sole parameter.
        -- See: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template#substitutions
        substitutions = {},

        -- A map for configuring unique directories and paths for specific templates
        --- See: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template#customizations
        customizations = {},
      },
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
        -- return tostring(os.time()) .. "-" .. suffix
        return tostring(os.date("%Y-%m-%d")) .. "_" .. suffix
      end,
      checkbox = {
        order = { " ", "x" },
      },
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      preset = "obsidian",
      code = {
        sign = true,
        width = "full",
      },
      completions = {
        -- Settings for blink.cmp completions source
        blink = { enabled = true },
        -- Settings for in-process language server completions
        lsp = { enabled = true },
        filter = {
          callout = function()
            -- example to exclude obsidian callouts
            -- return value.category ~= 'obsidian'
            return true
          end,
          checkbox = function()
            return true
          end,
        },
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
        enabled = true,
        right_pad = 1,
        checked = { scope_highlight = "@markup.strikethrough" },
        custom = {
          Right = { raw = "[>]", rendered = "", highlight = "ObsidianRightArrow" },
          Tilde = { raw = "[~]", rendered = "󰋽", highlight = "RenderMarkdownInfo" },
          Important = { raw = "[!]", rendered = "󰅾", highlight = "RenderMarkdownError" },
          todo = { raw = "[-]", rendered = "󰗡", highlight = "RenderMarkdownTodo", scope_highlight = nil },
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
