local utils = require("utils")
local lsp_symbols = LazyVim.config.kind_filter.default
table.insert(lsp_symbols, "Constant")

local M = {}
local exclude_patterns = { "__pycache__", "*.typed" }

---@param picker snacks.Picker
local function switch_to_grep(picker, _)
  local snacks = require("snacks")
  local cwd = picker.input.filter.cwd
  local picker_type = picker.opts.source
  local allowed_pickers = { "files", "buffers", "recent", "smart", "grep", "git_grep", "grep_buffers" }

  if not vim.tbl_contains(allowed_pickers, picker_type) then
    Snacks.notify.warn("Switching to grep is not supported for `" .. picker_type .. "`", { title = "Snacks Picker" })
    return
  end

  if vim.tbl_contains({ "grep", "git_grep", "grep_buffers" }, picker_type) then
    local pattern = picker.input.filter.search or ""

    if picker_type == "grep_buffers" then
      ---@diagnostic disable-next-line: missing-fields
      M.grep_alt_picker = "buffers"
    else
      M.grep_alt_picker = M.grep_alt_picker or "files"
    end
    snacks.picker(M.grep_alt_picker, { cwd = cwd, pattern = pattern })
  else
    local pattern = picker.input.filter.pattern or ""
    if picker_type == "recent_files" then
      picker_type = "recent"
    end
    if picker_type == "buffers" then
      snacks.picker.grep_buffers({ search = pattern })
    else
      local grep_picker = snacks.git.get_root() and "git_grep" or "grep"
      snacks.picker(grep_picker, { cwd = cwd, search = pattern })
    end
    M.grep_alt_picker = picker_type
  end
  picker:close()
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    { "<leader>e", false },
    {
      "<leader>,",
      function()
        Snacks.picker.recent()
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
      desc = "Grep adjacent files",
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
        if Snacks.git.get_root() == nil then
          Snacks.picker.grep({ cwd = Snacks.git.get_root() })
        else
          Snacks.picker.git_grep()
        end
      end,
      mode = { "n", "v" },
      desc = "Grep (Git root)",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols({})
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>sS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
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
        local start_line, end_line
        start_line, end_line = utils.get_visual_selection()
        local get_url = function(link_type, copy)
          local l_url = ""
          copy = copy == nil and true or false
          ---@diagnostic disable-next-line: missing-fields
          local opts = {
            notify = false,
            line_start = start_line or nil,
            line_end = end_line or nil,
            what = link_type,
          }
          if copy then
            opts["open"] = function(url)
              l_url = url
              vim.fn.setreg("+", url)
            end
          end
          Snacks.gitbrowse.open(opts)
          return l_url
        end

        local picker = Snacks.picker.pick({
          title = "Select link type",
          items = {
            { text = "repo", preview = { text = get_url("repo") } },
            { text = "branch", preview = { text = get_url("branch") } },
            { text = "file", preview = { text = get_url("file") } },
            { text = "commit", preview = { text = get_url("commit") } },
            { text = "permalink", preview = { text = get_url("permalink") } },
          },
          preview = "preview",
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
            ---@diagnostic disable-next-line: missing-fields
            get_url(item.text, false)
            return true
          end,
          actions = {
            copy_link = function(picker, item)
              picker:close()
              local url = get_url(item.text)
              Snacks.notify(
                string.format("Copied %s url ( %s ) to clipboard", item.text, url),
                { title = "Git Browse" }
              )
            end,
          },
          win = {
            input = {
              keys = {
                ["<S-Cr>"] = { "copy_link", desc = "Copy link", mode = { "i", "n" } },
              },
            },
          },
        })
        picker:show()
      end,
      mode = { "n", "x" },
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
    picker = {
      matcher = { frecency = true },
      actions = {
        switch_grep_files = switch_to_grep,
        cd_up = function(picker, _)
          picker:set_cwd(vim.fs.dirname(picker:cwd()))
          local dir = utils.trim_path(picker:cwd())
          picker.title = utils.title(picker.opts.source) .. " (" .. dir .. ")"
          picker:find()
        end,
      },
      ---@class snacks.picker.previewers.Config
      previewers = {
        diff = {
          builtin = false, -- use Neovim for previewing diffs (true) or use an external tool (false)
          cmd = { "delta" }, -- example to show a diff with delta
        },
        git = {
          builtin = false, -- use Neovim for previewing git output (true) or use git (false)
          args = { "-c", "delta" }, -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
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
      },
      sources = {
        explorer = {
          auto_close = true,
        },
        smart = {
          filter = { cwd = true },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
                ["<c-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        recent = {
          filter = { cwd = true },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        buffers = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        grep_buffers = {
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
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to files", mode = { "i", "n" } },
                ["<c-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        git_grep = {
          exclude = exclude_patterns,
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to files", mode = { "i", "n" } },
                ["<c-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        lsp_workspace_symbols = {
          actions = {
            switch_to_ws = function(picker, item)
              picker:close()
              local pattern = picker.input.filter.search or ""
              Snacks.picker.lsp_symbols({ pattern = pattern })
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_to_ws", desc = "Switch to workspace symbols", mode = { "i", "n" } },
              },
            },
          },
        },
        lsp_symbols = {
          filter = { default = lsp_symbols },
          actions = {
            switch_to_ws = function(picker, _)
              picker:close()
              local pattern = picker.input.filter.pattern or ""
              Snacks.picker.lsp_workspace_symbols({ search = pattern })
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_to_ws", desc = "Switch to workspace symbols", mode = { "i", "n" } },
              },
            },
          },
        },
        git_log = {
          toggles = {
            current_file = "cf",
            current_line = "cl",
          },
          confirm = function(picker, item)
            local commit = item.commit
            require("diffview")
            local filename = vim.api.nvim_buf_get_name(picker.finder.filter.current_buf)
            local cmd = "DiffviewOpen " .. commit .. "^! " .. " -- " .. filename
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
                ["<C-k>"] = { "log_file", desc = "Switch git_log mode", mode = { "i", "n" } },
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
      end,
    },
    dashboard = {
      enabled = true,
      config = function(opts)
        for _, keymap in ipairs(opts.preset.keys) do
          local desc = string.lower(keymap.desc)
          if string.find(desc, "find file") then
            keymap.action = ":lua Snacks.picker.smart()"
          end
          if string.find(desc, "recent files") then
            keymap.action = ":lua Snacks.picker.recent()"
          end
          if string.find(desc, "grep") or string.find(desc, "find text") then
            keymap.action = Snacks.git.get_root() == nil and ":lua Snacks.picker.grep()"
              or ":lua Snacks.picker.git_grep()"
          end
          if string.find(desc, "projects") then
            keymap.action = ":lua Snacks.picker.zoxide()"
          end
        end
      end,
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
