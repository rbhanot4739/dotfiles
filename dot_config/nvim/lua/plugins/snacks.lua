local M = {}
local exclude_patterns = { "__pycache__", "*.typed" }

M.switch_to_grep = nil
M.grep_alt_picker = nil
---@param picker snacks.Picker
local function switch_to_grep(picker, _)
  local picker_type = picker.opts.source
  local allowed_pickers = { "files", "buffers", "recent", "smart", "grep" }
  if not vim.tbl_contains(allowed_pickers, picker_type) then
    Snacks.notify.warn("Switching to grep is not supported for `" .. picker_type .. "`", { title = "Snacks Picker" })
    return
  end

  if picker_type == "grep" then
    M.switch_to_grep = false
    M.grep_alt_picker = M.grep_alt_picker or "files"
  else
    M.switch_to_grep = true
    if picker_type == "recent_files" then
      picker_type = "recent"
    end
    M.grep_alt_picker = picker_type
  end
  local snacks = require("snacks")
  local cwd = picker.input.filter.cwd

  picker:close()

  if M.switch_to_grep then
    local pattern = picker.input.filter.pattern or ""
    ---@diagnostic disable-next-line: missing-fields
    snacks.picker.grep({ cwd = cwd, search = pattern })
  else
    local pattern = picker.input.filter.search or ""
    ---@diagnostic disable-next-line: missing-fields
    snacks.picker.pick(M.grep_alt_picker, { cwd = cwd, pattern = pattern })
  end
end

-- Todo: Snacks picker for Octo/Obsidian/Toggleterm
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    { "<leader>e", false },
    {
      "<leader>,",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      desc = "Open recent files",
    },
    {
      "<leader>Z",
      function()
        Snacks.picker.zoxide()
      end,
      desc = "Open zoxide",
    },
    {
      "?",
      function()
        Snacks.picker.lines()
      end,
      desc = "Fuzzy find current word",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.search_history({ layout = { preset = "dropdown", preview = false } })
      end,
      desc = "Fuzzy find files",
    },
    -- {
    --   "<leader>?",
    --   function()
    --     Snacks.picker.command_history({ layout = { preset = "dropdown", preview = false } })
    --   end,
    -- },
    {
      "<c-r>",
      mode = { "i" },
      [[<cmd>YankyRingHistory<cr>]],
      desc = "Paste yank ring",
    },
    {
      "<leader>=",
      function()
        Snacks.picker.spelling({
          layout = {
            preset = "select",
            layout = {
              relative = "cursor",
              width = 30,
              min_width = 0,
              row = 1,
            },
          },
        })
      end,
      desc = "Spell suggest",
    },
    {
      "<leader>fa",
      function()
        Snacks.picker.files({ ignored = true, cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Find adjacent files",
    },
    {
      "<leader>sa",
      function()
        Snacks.picker.grep({ ignored = true, cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Find adjacent files",
    },
    {
      "<leader>fP",
      function()
        require("snacks").picker.pick("files", {
          cwd = vim.fn.stdpath("data")[1] or vim.fn.stdpath("data"),
          cmd = "fd",
          args = { "--type", "f", ".lua$" },
        })
      end,
      desc = "Find Plugin files",
    },
    -- grep mappings
    { "<leader>sw", LazyVim.pick("grep_word"), desc = "Grep Visual selection or word (Root Dir)", mode = { "n", "x" } },
    {
      "<leader>sW",
      function()
        Snacks.picker.pick("grep_word", { cwd = Snacks.git.get_root() })
      end,
      desc = "Grep Visual selection or word (Git root)",
      mode = { "n", "x" },
    },
    {
      "<leader>sg",
      function()
        Snacks.picker.git_grep()
        -- Snacks.picker.pick("grep", {
        --   cwd = Snacks.git.get_root(),
        --   prompt_title = "Grep (Args Git root)",
        -- })
      end,
      mode = { "n", "v" },
      desc = "Grep (Git root)",
    },
    {
      "<leader>ss",
      function()
        table.insert(LazyVim.config.kind_filter.default, "Constant")
        Snacks.picker.lsp_symbols({
          filter = LazyVim.config.kind_filter,
        })
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>sS",
      function()
        table.insert(LazyVim.config.kind_filter.default, "Constant")
        Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
      end,
      desc = "LSP Workspace Symbols",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.smart({ filter = { cwd = true } })
      end,
      desc = "Smart Picker",
    },
    -- git
    {
      "<leader>gb",
      function()
        Snacks.picker.git_branches({ layout = "ivy" })
      end,
      desc = "Git branches",
    },
    {
      "<leader>gc",
      function()
        Snacks.picker.git_log({ current_file = true })
      end,
      desc = "Git log Current file",
    },
    {
      "<leader>gy",
      function()
        local get_url = function(link_type)
          Snacks.gitbrowse.open({
            notify = false,
            what = link_type,
            open = function(url)
              print("open called with", url)
              vim.fn.setreg("+", url)
            end,
          })
        end
        local picker = Snacks.picker.pick({
          title = "Select link type",
          items = {
            { text = "repo" },
            { text = "file" },
            { text = "branch" },
            { text = "commit" },
            { text = "permalink" },
          },
          preview = function(ctx)
            -- local r_url = get_url(ctx.item.text)
            ctx.preview:set_title("Git link preview")
            -- ctx.preview:set_lines({ "hello" })
            ctx.preview:show(ctx.picker)
          end,
          layout = {
            layout = {
              backdrop = false,
              width = 0.3,
              min_width = 80,
              height = 0.3,
              min_height = 3,
              box = "vertical",
              border = "rounded",
              title = "{title}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", height = 0.4, border = "top" },
            },
          },
          format = "text",
          ---@param picker snacks.Picker
          confirm = function(picker, item)
            picker:close()
            Snacks.gitbrowse.open({ what = item.text, notify = false })
            return true
          end,
          actions = {
            copy_link = function(picker, item)
              picker:close()
              ---@diagnostic disable-next-line: missing-fields
              Snacks.gitbrowse.open({
                notify = false,
                what = item.text,
                open = function(url)
                  vim.fn.setreg("+", url)
                  Snacks.notify(
                    string.format("Copied %s url ( %s ) to clipboard", item.text, url),
                    { title = "Git Browse" }
                  )
                end,
              })
            end,
          },
          win = {
            input = {
              keys = {
                ["<S-Cr>"] = { "copy_link", desc = "Copy link", mode = { "i", "n" } },
                -- ["<c-k>"] = { "copy_link", desc = "Copy link", mode = { "i", "n" } },
              },
            },
          },
        })
        picker:show()
      end,
    },
    {
      "<M-/>",
      mode = { "n", "t", "i" },
      function()
        local ft = vim.bo.filetype
        local ft_cmds = { python = "ipython", lua = "lua" }
        if ft == "snacks_terminal" then
          vim.cmd("close")
        else
          Snacks.terminal.toggle(ft_cmds[ft], { interactive = false })
        end
      end,
      desc = "Toggle floating terminal",
    },
    {
      "<c-\\>",
      mode = { "t" },
      function()
        Snacks.terminal.toggle(nil, { win = { style = "split" } })
      end,
      ft = "snacks_terminal",
      desc = "Toggle terminal",
    },
  },
  opts = {
    -- matcher = { frecency = true},
    picker = {

      -- layout = {
      --   preset = "ivy",
      -- },
      ---@class snacks.picker.previewers.Config
      previewers = {
        diff = {
          builtin = false, -- use Neovim for previewing diffs (true) or use an external tool (false)
          cmd = { "delta" }, -- example to show a diff with delta
        },
        git = {
          builtin = false, -- use Neovim for previewing git output (true) or use git (false)
          -- args = {"-c", "delta"}, -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
        },
      },
      layouts = {
        ivy = {
          layout = {
            box = "vertical",
            backdrop = true,
            row = -1,
            width = 0,
            height = 0.4,
            border = "top",
            title = " {title} {live} {flags}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            {
              box = "horizontal",
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", width = 0.8, border = "left" },
            },
          },
        },
        --   select = {
        --     layout = {
        --       relative = "cursor",
        --       -- width = 70,
        --       -- min_width = 0,
        --       -- row = 1,
        --     },
        --   },
      },
      sources = {
        explorer = {
          auto_close = true,
        },
        smart = {
          actions = {
            switch_grep_files = function(picker, _)
              switch_to_grep(picker, _)
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        recent = {
          actions = {
            switch_grep_files = function(picker, _)
              switch_to_grep(picker, _)
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        buffers = {
          actions = {
            switch_grep_files = function(picker, _)
              switch_to_grep(picker, _)
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        files = {
          exclude = exclude_patterns,
          -- live = true,
          actions = {
            switch_grep_files = function(picker, _)
              switch_to_grep(picker, _)
            end,
            cd_up = function(picker, _)
              picker:set_cwd(vim.fs.dirname(picker:cwd()))
              picker:find()
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
                ["<c-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        grep = {
          exclude = exclude_patterns,
          actions = {
            switch_grep_files = function(picker, _)
              switch_to_grep(picker, _)
            end,
            cd_up = function(picker, _)
              picker:set_cwd(vim.fs.dirname(picker:cwd()))
              picker:find()
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
                ["<c-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        git_log = {
          previewers = {
            diff = { builtin = false },
          },
          toggles = {
            current_file = "cf",
            current_line = "cl",
          },
          confirm = function(picker, item)
            local commit = item.commit
            require("diffview")
            local filename = vim.api.nvim_buf_get_name(picker.finder.filter.current_buf)
            local cmd = "DiffviewOpen " .. commit .. "^! " .. " -- " .. filename
            print(cmd)
            vim.cmd(cmd)
          end,
          actions = {
            log_file = function(picker, _)
              if not picker.opts["current_file"] and not picker.opts["current_line"] then
                picker.opts["current_file"] = true
                picker.opts["follow"] = false
              elseif picker.opts["current_file"] then
                picker.opts["current_line"] = true
                picker.opts["current_file"] = false
                picker.opts["follow"] = false
              else
                picker.opts["current_line"] = false
                picker.opts["current_file"] = false
                -- picker.opts["follow"] = true
              end
              picker:find()
            end,
          },
          win = {
            input = {
              keys = {
                ["<A-l>"] = { "log_file", desc = "Switch git_log mode", mode = { "i", "n" } },
                ["<S-Cr>"] = { "git_checkout", desc = "Checkout commit", mode = { "i", "n" } },
              },
            },
          },
        },
      },
      formatters = {
        file = {
          filename_first = true, -- display filename before the file path
        },
      },
      icons = {
        kinds = require("config.utils").icons.kinds,
      },
      win = {
        -- input window
        input = {
          keys = {
            ["<TAB>"] = { "list_down", mode = { "i", "n" } },
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<C-Space>"] = { "select_and_next", mode = { "i", "n" } },
            ["<A-Space>"] = { "select_and_prev", mode = { "i", "n" } },
          },
        },
      },
    },
    indent = { enabled = true },
    scroll = { enabled = true },
    gitbrowse = {
      enabled = true,
      config = function(opts, defaults)
        table.insert(opts.remote_patterns, { "^(https://).+@(.*):(.*)", "%1%2/%3" })
        -- table.insert(opts.remote_patterns, { "^(org-.*):(.*)", "https://%1/%2" })
      end,
    },
    dashboard = {
      enabled = false,
      preset = {
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Find File",
            action = function()
              local has_telescope, telescope = pcall(require, "telescope")
              local has_fzf, fzf = pcall(require, "fzf-lua")
              local has_snacks, snacks = pcall(require, "snacks")
              if has_telescope then
                telescope.extensions.smart_open.smart_open({ cwd_only = true })
              elseif has_fzf then
                fzf.files({ hidden = true })
              else
                snacks.picker.pick("files")
              end
            end,
          },
          {
            icon = " ",
            key = "g",
            desc = "Grep",
            action = function()
              local has_telescope, telescope = pcall(require, "telescope")
              local has_fzf, fzf = pcall(require, "fzf-lua")
              local has_snacks, snacks = pcall(require, "snacks")
              if has_telescope then
                telescope.extensions.live_grep_args.live_grep_args({
                  prompt_title = "Live Grep",
                })
              elseif has_fzf then
                fzf.grep({ hidden = true })
              else
                snacks.picker.pick("grep")
              end
            end,
          },
          -- { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", action = ":SessionRestore" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "l", desc = "Sessions", action = ":SessionSearch" },
          { icon = "󰒲 ", key = "x", desc = "LazyExtras", action = ":LazyExtras" },
          { icon = "? ", key = "h", desc = "Help", action = ":Telescope help_tags" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    scratch = {
      win_by_ft = {
        lua = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
        python = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
      },
    },
    terminal = {
      win = {
        border = "rounded",
      },
      start_insert = true,
    },
  },
}
