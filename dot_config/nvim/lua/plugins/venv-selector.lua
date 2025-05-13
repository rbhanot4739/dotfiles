return {
  "linux-cultist/venv-selector.nvim",
  enabled = true,
  opts = {
    settings = {
      options = {
        dap_enabled = true,
        on_telescope_result_callback = function(filename)
          print(filename)
          return filename
            :gsub(os.getenv("HOME"), "~")
            :gsub("/bin/python", "")
            :gsub("/development/work/multiproducts", "")
        end,
      },
      search = {
        pipx = false,
        mp_evns = {
          command = "fd bin/python$ ~/development/work/multiproducts --full-path -I",
        },
      },
    },
  },
}
