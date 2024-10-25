---@class NtfySubscriptor
local M = {}

local socket = require("socket")
local mime = require("mime")
local json = require("dkjson")

local isempty = function(s) return s == nil or s == '' end

local handle_sse = function(event)
    local decoded_data, pos, err = json.decode(event)

    if decoded_data.event == "keepalive" then
      -- ignore keepalive
      return 0
    end

    if err then
      vim.notify("ERROR - could not parse JSON: " .. event)
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
      vim.notify(parsed_event)
    end
end

M.subscribe = function(config)
    local client = assert(socket.tcp())

    client:settimeout(10)

    assert(client:connect(config.host, config.port))

    local request = "GET /" .. config.topic .. "/sse HTTP/1.1\r\n" ..
                    "Host: " .. config.host .. "\r\n" ..
                    "Accept: text/event-stream\r\n"

    -- Basic auth support
    if not isempty(config.username) and not isempty(config.password) then
      request = request .. "Authorization: " .. "Basic " .. mime.b64(username .. ":" .. password) .. "\r\n"
    end

    request = request .. "Connection: keep-alive\r\n\r\n"

    client:send(request)
    client:settimeout(0)

    local buffer = ""

    while true do
        local chunk, status, partial = client:receive(1024)
        local data = chunk or partial
        if data then
            buffer = buffer .. data
            for line in buffer:gmatch("[^\r\n]+") do
                if line:find("data:") then
                    -- Remove "data: " prefix
                    local event_data = line:sub(6)
                    handle_sse(event_data)
                end
            end

            buffer = ""
        end

        if status == "closed" then
            vim.notify("Connection closed")
            break
        end
        
        socket.sleep(0.1)
    end

    client:close()
end

return M
