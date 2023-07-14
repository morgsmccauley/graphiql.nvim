local M = {}

function M.operations()
  local parser = vim.treesitter.get_parser(0, "graphql")

  local query = vim.treesitter.query.parse("graphql", [[
    ((operation_type) @op)
    ((operation_definition) @def)
  ]])

  local matches = {}

  for _, tree in pairs(parser:parse()) do
    for id, node in query:iter_captures(tree:root(), 0) do
      local name = query.captures[id]
      if name == "def" then
        local start_row, _, end_row, _ = node:range()
        local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
        table.insert(matches, table.concat(lines, "\n"))
      end
    end
  end

  return matches
end

function M.operation_at_cursor()
  local parser = vim.treesitter.get_parser(0, "graphql")

  if not parser then
    print("This buffer's filetype is not supported by Tree-sitter")
    return nil
  end

  local query = vim.treesitter.query.parse("graphql", [[
    ((operation_definition) @def)
  ]])

  local cursor_row, _ = unpack(vim.api.nvim_win_get_cursor(0))

  for _, tree in pairs(parser:parse()) do
    for id, node in query:iter_captures(tree:root(), 0) do
      local name = query.captures[id]
      if name == "def" then
        local start_row, _, end_row, _ = node:range()
        if start_row <= cursor_row and cursor_row <= end_row then
          local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
          return table.concat(lines, "\n")
        end
      end
    end
  end

  print("No GraphQL operation found at cursor position")
  return nil
end

return M
