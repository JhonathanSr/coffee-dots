-- Theme: Transparent Prism - Lavender
-- Optimized for LazyVim & Transparent Terminals (Ghostty)

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "transparent-prism",
    },
  },
  {
    "transparent-prism",
    virtual = true,
    lazy = false,
    priority = 1000,
    config = function()
      -- 1. Definición de la paleta de colores convertida a HEX
      local p = {
        bg             = "#0f0d17",
        neutral_0      = "#1c1a29",
        neutral_1      = "#262433",
        neutral_2      = "#2e2b3b",
        neutral_3      = "#383640",
        neutral_4      = "#42404a",
        neutral_5      = "#4c4a54",
        neutral_6      = "#5c5963",
        neutral_7      = "#706e78",
        neutral_8      = "#8f8c96",
        neutral_9      = "#c2bfc9",
        neutral_10     = "#f7f2ff",
        
        accent_blue    = "#59d4e6",
        accent_indigo  = "#948ae3",
        accent_purple  = "#948ae3",
        accent_pink    = "#fc618c",
        accent_red     = "#fc618c",
        accent_orange  = "#fc9454",
        accent_yellow  = "#fce666",
        accent_green   = "#7ad98f",
        
        gray_1         = "#333040",
        gray_2         = "#3b3847",
      }

      -- 2. Función helper para aplicar los highlights de forma limpia
      local hl = function(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
      end

      -- Clear existing highlights
      vim.cmd("highlight clear")
      if vim.fn.exists("syntax_on") == 1 then
        vim.cmd("syntax reset")
      end
      vim.g.colors_name = "transparent-prism"

      -- 3. UI Core (Mantenemos bg = "NONE" para respetar la transparencia de Ghostty)
      hl("Normal",       { fg = p.neutral_10, bg = "NONE" })
      hl("NormalNC",     { fg = p.neutral_10, bg = "NONE" })
      hl("NormalFloat",  { fg = p.neutral_10, bg = "NONE" })
      hl("FloatBorder",  { fg = p.accent_indigo, bg = "NONE" })
      hl("None",         { bg = "NONE" })
      
      -- Cursores y Selección
      hl("Cursor",       { fg = p.bg, bg = p.neutral_10 })
      hl("CursorLine",   { bg = p.neutral_1, blend = 40 })
      hl("CursorColumn", { bg = p.neutral_1 })
      hl("Selection",    { bg = p.neutral_3 })
      hl("Visual",       { bg = p.neutral_3 })
      
      -- Componentes de la Interfaz
      hl("LineNr",       { fg = p.neutral_5 })
      hl("CursorLineNr", { fg = p.accent_indigo, bold = true })
      hl("MatchParen",   { fg = p.accent_blue, bold = true })
      hl("StatusLine",   { fg = p.neutral_9, bg = "NONE" })
      hl("StatusLineNC", { fg = p.neutral_5, bg = "NONE" })
      hl("VertSplit",    { fg = p.neutral_3, bg = "NONE" })
      hl("WinSeparator", { fg = p.neutral_3, bg = "NONE" })
      hl("Pmenu",        { fg = p.neutral_9, bg = p.neutral_1 })
      hl("PmenuSel",     { fg = p.neutral_10, bg = p.neutral_3 })
      hl("Search",       { fg = p.bg, bg = p.accent_yellow })
      hl("IncSearch",    { fg = p.bg, bg = p.accent_orange })

      -- 4. Sintaxis Standard & Treesitter (Reflejando el ecosistema TypeScript/Angular/Java)
      hl("Comment",      { fg = p.neutral_6, italic = true })
      hl("Constant",     { fg = p.accent_orange })
      hl("String",       { fg = p.accent_green })
      hl("Character",    { fg = p.accent_green })
      hl("Number",       { fg = p.accent_orange })
      hl("Boolean",      { fg = p.accent_orange, bold = true })
      hl("Float",        { fg = p.accent_orange })
      
      hl("Identifier",   { fg = p.neutral_10 })
      hl("Function",     { fg = p.accent_blue, bold = true })
      hl("Statement",    { fg = p.accent_purple })
      hl("Conditional",  { fg = p.accent_purple, italic = true })
      hl("Repeat",       { fg = p.accent_purple })
      hl("Label",        { fg = p.accent_blue })
      hl("Operator",     { fg = p.accent_indigo })
      hl("Keyword",      { fg = p.accent_purple, bold = true })
      hl("Exception",    { fg = p.accent_red })
      
      hl("PreProc",      { fg = p.accent_pink })
      hl("Include",      { fg = p.accent_purple })
      hl("Define",       { fg = p.accent_purple })
      hl("Macro",        { fg = p.accent_pink })
      
      hl("Type",         { fg = p.accent_blue })
      hl("StorageClass", { fg = p.accent_orange })
      hl("Structure",    { fg = p.accent_yellow })
      hl("Typedef",      { fg = p.accent_blue })
      
      hl("Special",      { fg = p.accent_pink })
      hl("SpecialChar",  { fg = p.accent_orange })
      hl("Tag",          { fg = p.accent_pink })
      hl("Delimiter",    { fg = p.neutral_8 })
      hl("Todo",         { fg = p.bg, bg = p.accent_yellow, bold = true })
      hl("Underlined",   { underline = true })
      hl("Bold",         { bold = true })
      hl("Italic",       { italic = true })

      -- 5. Diagnósticos LSP
      hl("DiagnosticError", { fg = p.accent_red })
      hl("DiagnosticWarn",  { fg = p.accent_yellow })
      hl("DiagnosticInfo",  { fg = p.accent_blue })
      hl("DiagnosticHint",  { fg = p.neutral_7 })
      
      hl("DiagnosticUnderlineError", { undercurl = true, sp = p.accent_red })
      hl("DiagnosticUnderlineWarn",  { undercurl = true, sp = p.accent_yellow })
      hl("DiagnosticUnderlineInfo",  { undercurl = true, sp = p.accent_blue })
      hl("DiagnosticUnderlineHint",  { undercurl = true, sp = p.neutral_7 })

      -- 6. Git Gutter / Signs
      hl("SignColumn", { bg = "NONE" })
      hl("GitSignsAdd",    { fg = p.accent_green })
      hl("GitSignsChange", { fg = p.accent_yellow })
      hl("GitSignsDelete", { fg = p.accent_red })

      -- 7. Plugins populares en LazyVim
      -- Telescope
      hl("TelescopeBorder",   { fg = p.accent_indigo, bg = "NONE" })
      hl("TelescopeNormal",   { fg = p.neutral_10, bg = "NONE" })
      hl("TelescopeSelection",{ bg = p.neutral_2 })
      
      -- Neo-tree
      hl("NeoTreeNormal",     { fg = p.neutral_9, bg = "NONE" })
      hl("NeoTreeNormalNC",   { fg = p.neutral_9, bg = "NONE" })
      hl("NeoTreeWinSeparator",{ fg = p.neutral_2, bg = "NONE" })
      
      -- Bufferline
      hl("BufferLineFill",    { bg = "NONE" })
      hl("BufferLineBackground", { fg = p.neutral_6, bg = "NONE" })
      hl("BufferLineBufferSelected", { fg = p.neutral_10, bg = "NONE", bold = true })
      hl("BufferLineTabSelected", { fg = p.accent_indigo, bg = "NONE" })
    end,
  },
}