vim.keymap.set({ 'n', 'x' }, 's', '<Nop>')
vim.bo.tabstop = 4
vim.opt.relativenumber = true

vim.g.netrw_liststyle = 3

require('catppuccin').setup {
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    notify = false,
    mini = {
      enabled = true,
      indentscope_color = '',
    },
  },
}

require('netrw').setup {
  -- File icons to use when `use_devicons` is false or if
  -- no icon is found for the given file type.
  icons = {
    symlink = '',
    directory = '',
    file = '',
  },
  -- Uses mini.icon or nvim-web-devicons if true, otherwise use the file icon specified above
  use_devicons = true,
  mappings = {
    -- Function mappings receive an object describing the node under the cursor
    -- ['p'] = function(payload)
    --   print(vim.inspect(payload))
    -- end,
    -- String mappings are executed as vim commands
    -- ['<Leader>p'] = ":echo 'hello world'<CR>",
  },
}

require 'monokai-setup'

vim.cmd.colorscheme 'monokai-pro-spectrum'

return {}
