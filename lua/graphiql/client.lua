local curl = require "plenary.curl"

local GraphQLClient = {}

function GraphQLClient:new(url, options)
  options = options or {}

  self.__index = self

  local client = setmetatable({
    url = url,
    headers = options.headers or {},
  }, self)

  return client
end

function GraphQLClient:request(operation, variables)
  local body = vim.tbl_extend('force',
    {
      query = operation,
    },
    {
      variables = variables or nil,
    }
  )

  if variables ~= nil then
    body.variables = variables
  end

  body = vim.fn.json_encode(body)

  local response = curl.post(self.url, {
    headers = vim.tbl_extend("force", self.headers, {
      ["Content-Type"] = "application/json",
    }),
    body = body
  })

  if response.status ~= 200 then
    error("GraphQL request failed: " .. tostring(response.status))
  end

  return vim.fn.json_decode(response.body)
end

return GraphQLClient