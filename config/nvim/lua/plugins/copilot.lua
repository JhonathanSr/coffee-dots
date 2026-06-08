return {
  "zbirenbaum/copilot.lua",
  optional = true,
  opts = function(_, opts)
    opts.copilot_node_command = vim.g.node_host_prog or "/usr/bin/node"

    opts.filetypes = vim.tbl_deep_extend("force", opts.filetypes or {}, {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    })
  end,
}
