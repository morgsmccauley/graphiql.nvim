local Job = require('plenary.job')

local parser = require('graphiql.parser')
local GraphQLClient = require('graphiql.client')

local M = {}

local results_file_path = os.tmpname()
local results_window = nil

local function write_response_to_file(response)
  local file = io.open(results_file_path, "w")

  if file == nil then
    error("Could not open file: " .. results_file_path)
  end

  file:write(vim.json.encode(response))
  file:close()

  if results_window and vim.api.nvim_win_is_valid(results_window) then
    vim.api.nvim_set_current_win(results_window)
    vim.api.nvim_command('edit ' .. results_file_path)
  else
    vim.cmd.vsplit(results_file_path)

    results_window = vim.api.nvim_get_current_win()
  end

  vim.bo.modifiable = true

  -- use luarocks instead?
  vim.cmd('%! jq')
  vim.cmd.write()

  vim.bo.filetype = "json"
  vim.bo.modifiable = false
end

function M.run_at_cursor()
  local client    = GraphQLClient:new(
    "https://graphqlpokemon.favware.tech/v7"
  )

  local operation = parser.operation_at_cursor()
  local response  = client:request(operation)

  write_response_to_file(response)
end

return M
