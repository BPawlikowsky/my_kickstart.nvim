-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

  -- ADDED PLUGINS
  -- add dracula
  { 'Mofiqul/dracula.nvim' },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.everforest_enable_italic = true
      vim.g.everforest_background = 'hard'
    end,
  },
  { 'loctvl842/monokai-pro.nvim' },
  { 'prichrd/netrw.nvim', opts = {} },
  { 'nvim-tree/nvim-web-devicons', opts = {} },
}
