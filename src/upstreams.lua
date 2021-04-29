local http = require "socket.http"
local ltn12 = require "ltn12"
local cjson = require "cjson"

local _M = {}

_M._VERSION="0.1"

function _M:update_upstreams()
    local resp = {}

    http.request{
        url = "http://127.0.0.1:8500/v1/catalog/service/moguhu_server", sink = ltn12.sink.table(resp)
    }

    local resp = cjson.decode(resp)

    local upstreams = {}
    for i, v in ipairs(resp) do
        upstreams[i+1] = {ip=v.Address, port=v.ServicePort}
    end

    ngx.shared.upstream_list:set("moguhu_server", cjson.encode(upstreams))
end

function _M:get_upstreams()
    local upstreams_str = ngx.shared.upstream_list:get("moguhu_server")
    return upstreams_str
end

return _M