return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = {
          -- Añade los argumentos globales para Prettier
          prepend_args = { "--trailing-comma", "none" },
        },
      },
    },
  },
}
