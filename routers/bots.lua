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

function new_proxy()
    local servers = red:get("SERVERS_INSTANCES_AVAILABLES")
    if not (servers == ngx.null) then
        servers, err = ngx_re.split(servers, " ")

        proxy = servers[1]
        table.remove(servers, 1)
        table.insert(servers, proxy)
        servers = table.concat(servers, " ")
        red:set("SERVERS_INSTANCES_AVAILABLES", servers)

        return proxy
    else
        ngx.say("No servers availables (memory full)")
    end
end

function remove_server_instance(server_ip)
    local bots = red:get("SERVER-" .. server_ip)
    bots, err = ngx_re.split(bots, " ")
    for index, bot in ipairs(bots) do
        red:del(bot)
    end
    red:del("SERVER-" .. server_ip)

    local servers = red:get("SERVERS_INSTANCES_AVAILABLES")
    servers, err = ngx_re.split(servers, " ")

    for index, server in ipairs(servers) do
        if server == server_ip then
            table.remove(servers, index)
            break
        end
    end
    servers = table.concat(servers, " ")
    red:set("SERVERS_INSTANCES_AVAILABLES", servers)
end

function get_proxy_alive(p)
    local check_server_alive = red:get("SERVER-ALIVE-" .. p)
    if check_server_alive == ngx.null then
        remove_server_instance(p)
        get_proxy_alive(new_proxy())
    else
        return proxy
    end
end

local proxy = red:get("BOT-" .. ngx.var.arg_uuid)
if proxy == ngx.null then
    proxy = new_proxy()
else
    local check_server_alive = red:get("SERVER-ALIVE-" .. proxy)
    if check_server_alive == ngx.null then
        proxy = get_proxy_alive(new_proxy())
    end
end

ngx.var.proxy_addr = proxy