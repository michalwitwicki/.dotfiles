return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      'clangd',
      'rust_analyzer',
      'bashls',
      'pyright',
      'lua_ls',
      'marksman',
      'autotools_ls',
    },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
}
