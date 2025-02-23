local zls_dir = os.getenv 'HOME' .. '/dev/tools/zls'
local zls_bin = '/zig-out/bin/'
local address = 'https://releases.zigtools.org/v1/zls/select-version?zig_version={version}&compatibility=full'
local zls_path = zls_dir .. zls_bin .. 'zls'
local zig_version_file = 'zig_version.txt'
local zls_commit_file = 'zls_commit.txt'

if vim.fn.isdirectory(zls_dir) then
  vim.fn.mkdir(zls_dir, 'p')
end

local function save_json(obj)
  local file = io.write(obj.project_root .. '/zls.json')
  if file ~= nil then
    file:write(vim.json.encode(obj))
    file:close()
  end
end

local zls_json = {
  version = '',
  global_cache_dir = os.getenv 'HOME' .. '/.cache/zls/',
  local_config_dir = '',
  log_file = '/var/log/zls/zls.log',
}

local function save_zig_version(zig_version)
  local file = io.open(zls_dir .. '/' .. zig_version_file, 'w')
  if file ~= nil then
    file:write(zig_version)
    file:close()
    print 'saved zig vesion to file'
  end
end

---comment
---@param zls_resp string?
---@return boolean
local isResponseEmpty = function(zls_resp)
  return zls_resp == nil or zls_resp == '' or zls_resp == '\n' or zls_resp == '\t\n'
end

local function get_zig_version()
  local out = vim.system({ 'zig', 'version' }, { text = true }):wait().stdout
  return out
end

local get_last_good_zig_zls = function(file)
  local file = io.open(zls_dir .. '/' .. file, 'r')
  if file ~= nil then
    local result = file:read '*a'
    file:close()
    return result
  end

  return nil
end

---@param zig_version string
---@return string?
local function get_zls_response(zig_version)
  local address_wrapped = '"' .. string.gsub(address, '{version}', zig_version) .. '"'
  print('running command: ', 'wget -qO- ' .. address_wrapped)
  local wget_cmd = { 'wget', '-qO-', address_wrapped }
  local out = vim
    .system(wget_cmd, {
      text = true,
    })
    :wait()

  return out.stdout
end

---@param zls_commit string
---@param zig_version string
---@return table?
local function compile_zls(zls_commit, zig_version)
  os.execute('cd ' .. zls_dir .. ' && git checkout ' .. zls_commit)
  os.execute('cd ' .. zls_dir .. ' && zig build -Doptimize=ReleaseSafe')
  print('ZLS compiled for Zig version: ' .. zig_version)
  local file = io.open(zls_dir .. '/' .. zls_commit_file, 'w')
  if file ~= nil then
    file:write(zls_dir .. '/' .. zls_commit_file)
    file:close()
  end
  print 'saved zls commit to file'
end

return {
  cmd = { zls_path },
  filetypes = { 'zig', 'zir' },
  single_file_support = true,
  on_init = function()
    local lsp_folders = vim.lsp.buf.list_workspace_folders()
    local project_root = lsp_folders[1] or vim.fn.getcwd()

    zls_json.local_config_dir = project_root

    local zig_version = get_zig_version()
    if not vim.fn.isdirectory(zls_dir) then
      os.execute('git clone https://github.com/zigtools/zls ' .. zls_dir)
    end

    local zls_resp = get_zls_response(zig_version:gsub('\n', ''))

    if isResponseEmpty(zls_resp) then
      local last_zig_version = get_last_good_zig_zls(zig_version_file)

      if last_zig_version == nil then
        error('Error: Could not find last good zig version', vim.log.levels.ERROR)
        return
      end

      save_zig_version(last_zig_version)

      local last_zls_commit = get_last_good_zig_zls(zls_commit_file)

      if last_zls_commit == nil then
        error('Error: Could not find last good zls commit', vim.log.levels.ERROR)
        return
      end

      if not vim.fn.isdirectory(zls_dir .. zls_bin) then
        compile_zls(last_zls_commit, last_zig_version)
      end
      print 'Reverted to last good zls version successfully'
      zls_json.version = zig_version
      save_json(zls_json)
    else
      save_zig_version(zig_version)
      ---@diagnostic disable-next-line
      local resp_table = vim.json.decode(zls_resp)
      local zls_commit = string.match(resp_table.version, '+%w+$')

      compile_zls(zls_commit:sub(2), zig_version)

      zls_json.version = zig_version
      save_json(zls_json)
      print 'Updated zls version successfully'
    end
  end,
  settings = {
    zls = {
      enable_snippets = true, -- Enable snippet support (if needed)
      -- Additional settings can be added here
    },
  },
}
