return {
  "zbirenbaum/copilot.lua",
  optional = true,
  opts = function(_, opts)
    -- 1. BYPASS DEFINITIVO: Obligamos a Copilot a usar el Node v26 global guardado en Neovim
    -- Esto evita que herede el Node 18 dynamic shim de Mise dentro del proyecto
    opts.copilot_node_command = vim.g.node_host_prog or "/usr/bin/node"

    -- 2. Tus bloqueos de filetypes inyectados de forma segura sobre la configuración base
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
