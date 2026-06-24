return {
  -- Disable LSP stack (add back later per-language when needed)
  { "neovim/nvim-lspconfig", enabled = false },
  { "williamboman/mason.nvim", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = false },

  -- Disable completion
  { "hrsh7th/nvim-cmp", enabled = false },
  { "L3MON4D3/LuaSnip", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },

  -- Disable formatting/linting
  { "stevearc/conform.nvim", enabled = false },
  { "mfussenegger/nvim-lint", enabled = false },
}
