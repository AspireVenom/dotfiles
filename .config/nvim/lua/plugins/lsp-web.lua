return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vtsls",
        "tailwindcss-language-server",
        "eslint_d",
        "prettierd",
        "emmet-language-server",
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "prisma-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/schemastore.nvim" },
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
            },
            javascript = {
              updateImportsOnFileMove = { enabled = "always" },
            },
          },
        },
        tailwindcss = {},
        eslint = {},
        prismals = {},
        emmet_language_server = {},
        html = {},
        cssls = {},
        jsonls = {},
      },
      setup = {
        tsserver = function()
          return true
        end,
      },
    },
  },
}
