-- Configuration for GitHub Copilot Chat tailored for Jhonathan
local prompts = {
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  JsDocs = "Please provide JsDocs for the following code.",
  DocumentationForGithub = "Please provide documentation for the following code ready for GitHub using markdown.", -- Prompt to generate GitHub documentation
  Summarize = "Please summarize the following text.", -- Prompt to summarize text
  Spelling = "Please correct any grammar and spelling errors in the following text.", -- Prompt to correct spelling and grammar
  Wording = "Please improve the grammar and wording of the following text.", -- Prompt to improve wording
  Concise = "Please rewrite the following text to make it more concise.", -- Prompt to make text concise
  TranslateComments = [[
Read the currently open file.

Translate ONLY comments and inline documentation from English to technical Latin American Spanish.

STRICT RULES:
- Modify only comments and documentation text
- Do NOT modify code
- Do NOT rename variables, functions, classes, methods, interfaces, imports, packages, modules, paths, or identifiers
- Do NOT change logic or structure
- Preserve exact formatting and indentation
- Preserve documentation style and structure
- Edit the current file directly
- Apply changes automatically
- Output no explanation
]],
}

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = "CopilotChat",
    keys = {
      -- Abre/Cierra el chat de forma alternada (Toggle) con: Espacio + c
      {
        "<leader>ai",
        function()
          require("CopilotChat").toggle()
        end,
        desc = "CopilotChat (Toggle Izquierda)",
        mode = { "n", "v" }, -- Funciona en modo Normal y Visual (con código seleccionado)
      },
      -- Resetea el chat (Limpia el historial) con: Espacio + cx
      {
        "<leader>ax",
        function()
          require("CopilotChat").reset()
        end,
        desc = "CopilotChat (Resetear Historial)",
        mode = { "n" },
      },
      {
        "<leader>ae",
        "<cmd>CopilotChatExplain<cr>",
        desc = "CopilotChat - Explicar código",
        mode = { "n", "v" },
      },
      {
        "<cmd>CopilotChatReview<cr>",
        desc = "CopilotChat - Revisar código",
        mode = { "n", "v" },
      },
      {
        "<leader>ar",
        "<cmd>CopilotChatRefactor<cr>",
        desc = "CopilotChat - Refactorizar código",
        mode = { "n", "v" },
      },
      {
        "<leader>af",
        "<cmd>CopilotChatFixCode<cr>",
        desc = "CopilotChat - Corregir código",
        mode = { "n", "v" },
      },
      {
        "<leader>ad",
        "<cmd>CopilotChatDocumentationForGithub<cr>",
        desc = "CopilotChat - Docu para GitHub",
        mode = { "n", "v" },
      },
      {
        "<leader>at",
        "<cmd>CopilotChatTranslateComments<cr>",
        desc = "CopilotChat - Traducir comentarios",
        mode = { "n", "v" },
      },
    },
    opts = {
      prompts = prompts,
      -- model removido por defecto para delegar la gestión del modelo al plugin o al comando directo
      answer_header = "   ArchVim Assistant    ",
      auto_insert_mode = true,
      separator = "───", -- Separador continuo minimalista para los bloques del chat
      window = {
        layout = "float", -- Diseño flotante moderno estilo Cursor AI / Popup
        relative = "editor", -- Posición relativa al editor para un comportamiento más predecible
        row = 1,
        col = vim.o.columns,
        width = 0.30, -- Ocupa el 70% del ancho total de tu pantalla de 144Hz
        height = vim.o.lines - 3, -- Ocupa el 75% del alto total de tu pantalla
        border = "rounded", -- Bordes curvos idóneos para entornos Hyprland
        zindex = 45, -- Se dibuja siempre por encima de tus buffers
        title = "    Copilot Chat ", -- Encabezado con icono integrado en el borde superior
      },
      system_prompt = [[
Eres el asistente técnico personal de Jhonathan, un Ingeniero de Software Senior especializado en desarrollo de aplicaciones web de alto rendimiento y un apasionado del ecosistema técnico de Linux de última generación.

Tu rol es actuar como un consultor de software principal y un experto en automatización en la terminal. Tus respuestas deben ser sumamente precisas, técnicamente impecables y optimizadas para un flujo de trabajo moderno y rápido.

Tus principales áreas de competencia e instrucciones de comportamiento son:
1. DESARROLLO FRONTEND AVANZADO: Eres experto en Angular, TypeScript y optimización de interfaces Web. Cuando te pida refactorizar o analizar código frontend, prioriza la legibilidad, la separación de conceptos, arquitecturas limpias y el uso eficiente de herramientas modernas como RxJS y Signals.
2. INFRAESTRUCTURA Y ENTORNO LINUX: Entiendes a la perfección la administración de sistemas basados en Arch Linux y optimizaciones del kernel de alto rendimiento (como CachyOS). Sabes cómo estructurar scripts en Zsh y scripts de automatización en Python.
3. CONFIGURACIÓN DE TERMINAL: Tienes conocimientos profundos sobre Neovim (LazyVim moderno), configuraciones de terminal avanzados como Ghostty, gestores de ventanas tipo Tiling (Hyprland, Waybar) y gestión de configuraciones personales (dotfiles).
4. TONO Y ESTILO: Háblale a Jhonathan con un tono profesional, directo al grano, técnico pero cercano y pragmático. No uses introducciones aburridas ni formalidades innecesivas. Ve directo a la solución del código o del script. Si un comando o herramienta puede fallar por problemas de rutas o entornos del sistema, adviértelo de antemano y propón soluciones defensivas.
5. IDIOMA: Responde siempre en español fluido, manteniendo los tecnicismos de código en inglés cuando sea natural en la industria de software.
]],
      mappings = {
        complete = { insert = "<Tab>" },
        close = { normal = "q", insert = "<C-c>" },
        reset = { normal = "<C-l>", insert = "<C-l>" },
        submit_prompt = { normal = "<CR>", insert = "<C-s>" },
        toggle_sticky = { normal = "grr" },
        clear_stickies = { normal = "grx" },
        accept_diff = { normal = "<C-y>", insert = "<C-y>" },
        jump_to_diff = { normal = "gj" },
        quickfix_answers = { normal = "gqa" },
        quickfix_diffs = { normal = "gqd" },
        yank_diff = { normal = "gy", register = '"' },
        show_diff = { normal = "gd", full_diff = false },
        show_info = { normal = "gi" },
        show_context = { normal = "gc" },
        show_help = { normal = "gh" },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = false
        end,
      })

      -- 🎨 Ajuste de colores (Highlights) adaptados a temas oscuros modernos (como Catppuccin)
      vim.api.nvim_set_hl(0, "CopilotChatHeader", { fg = "#89b4fa", bold = true }) -- Azul para el header de la respuesta
      vim.api.nvim_set_hl(0, "CopilotChatSeparator", { fg = "#45475a" }) -- Gris sutil para la línea divisoria
      vim.api.nvim_set_hl(0, "CopilotChatTitle", { fg = "#a6e3a1", bold = true }) -- Verde para el título de la ventana flotante

      chat.setup(opts)
    end,
  },
  -- Blink integration
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        providers = {
          path = {
            enabled = function()
              return vim.bo.filetype ~= "copilot-chat"
            end,
          },
        },
      },
    },
  },
}
