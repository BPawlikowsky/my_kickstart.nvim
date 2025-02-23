local state = {
  floating = {
    win = -1,
    buf = -1,
  },
}

--- width: 0.0 .. 1.0 scale of screen width
--- height: 0.0 .. 1.0 scale of screen height
---@param opts { width: number?, height: number?, border?: string, buf: integer }
--- returns buffer and window ids
---@return { buf: integer, win: integer }
local function create_floating_window(opts)
  -- Default options
  opts = opts or {}
  local width = math.floor(vim.o.columns * (opts.width or 0.8))
  local height = math.floor(vim.o.lines * (opts.height or 0.8))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create a scratch buffer
  local buf = nil

  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = opts.border or 'rounded', -- Options: "single", "double", "rounded", "solid", "shadow"
  })

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end

  if not vim.api.nvim_buf_is_valid(state.floating.buf) then
    -- Create a scratch buffer
    state.floating.buf = vim.api.nvim_create_buf(false, true)
  end
end

vim.api.nvim_create_user_command('FloatingTerm', toggle_terminal, {})

-- keymaps
vim.keymap.set('n', '<space>ot', toggle_terminal, { desc = 'toggle terminal floating window' })
vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>')
