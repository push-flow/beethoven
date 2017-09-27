local redis = require "resty.redis"
local ngx_re = require "ngx.re"
local red = redis:new()

red:set_timeout(1000)

local ok, err = red:connect(os.getenv("REDIS_MASTER_ADDRESS"), tonumber(os.getenv("REDIS_MASTER_PORT")))
if not ok then
    local ok, err = red:connect("127.0.0.1", "6379")
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end
end

red:select(tonumber(os.getenv("REDIS_MASTER_DB")))

local servers = red:get("SERVERS_INSTANCES_AVAILABLE")
servers, err = ngx_re.split(servers, " ")

ngx.var.proxy_addr = servers[1]