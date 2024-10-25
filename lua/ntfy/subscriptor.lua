---@class NtfySubscriptor
local M = {}

local b64 = require("..utils.b64")
local logger = require("..utils.logger")
local isempty = function(s) return s == nil or s == '' end

-- Handles SSE events
local handle_sse = function(event)
    local decoded_data, pos, err = vim.json.decode(event)

    if decoded_data.event == "keepalive" then
      -- ignore keepalive
      return 0
    end

    if err then
      logger.error("Could not parse JSON: " .. event)
      return -1
    end

    local parsed_event = ""

    if decoded_data.event == "open" then
      parsed_event = parsed_event .. "󱘖  - Subscribed to topic " .. decoded_data.topic
    elseif decoded_data.event == "message" then
      parsed_event = parsed_event .. "󰍨  - [" .. decoded_data.topic .. "] - "

      local msg = ""
      if not isempty(decoded_data.title)  then
        msg = msg .. decoded_data.title
      end

      if not isempty(decoded_data.message)  then
        msg = msg .. decoded_data.message
      else
        msg = msg .. "(empty message)"
      end

      parsed_event = parsed_event .. msg
    end

    if not isempty(parsed_event) then
      logger.info(parsed_event)
    end
end

M.subscribe = function(config)
  vim.loop.getaddrinfo(config.host, nil, {}, function(err, res)
    if err then
      logger.error("DNS resolution failed: " .. err)
      return
    end

    local host_ip = res[1].addr
    local client = assert(vim.loop.new_tcp())

    if not client then
      logger.error("Connection failed: " .. err)
      return
    end

    client:connect(host_ip, config.port, function(err)
      if err then
          logger.error("Connection failed: " .. err)
          client:close()
          return
      end

      -- right now we only support 1 topic
      local request = "GET /" .. config.topics[1] .. "/sse HTTP/1.1\r\n" ..
                      "Host: " .. config.host .. "\r\n" ..
                      "Accept: text/event-stream\r\n"
      -- Basic auth support
      if not isempty(config.username) and not isempty(config.password) then
        request = request .. "Authorization: " .. "Basic " .. b64.enc(config.username .. ":" .. config.password) .. "\r\n"
      end
      request = request .. "Connection: keep-alive\r\n\r\n"

      client:write(request)

      local buffer = ""
      client:read_start(function(err, chunk)
        if err then
            logger.error("Read error: " .. err)
            client:close()
            return
        end

        if chunk then
            buffer = buffer .. chunk
            for line in buffer:gmatch("[^\r\n]+") do
                if line:find("data:") then
                    -- Remove "data: " prefix
                    local event_data = line:sub(6)
                    handle_sse(event_data)
                end
            end
            buffer = ""
        else
          logger.info("Connection closed")
          client:close()
        end

      end)
    end)
  end)
end

return M
