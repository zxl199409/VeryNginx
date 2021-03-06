-- -*- coding: utf-8 -*-
-- @Date    : 2016-01-02 00:46
-- @Author  : Alexa (AlexaZhou@163.com)
-- @Link    : 
-- @Disc    : filter request'uri maybe attack

local _M = {}

local VeryNginxConfig = require "VeryNginxConfig"


function _M.ip_in_whitelist()
    if VeryNginxConfig.configs["filter_ipwhitelist_enable"] ~= true then
        return false
    end

    local remote_addr = ngx.var.remote_addr
    for i, v in ipairs( VeryNginxConfig.configs['filter_ipwhitelist_rule'] ) do
        if v[1] == remote_addr  then
            return true
        end
    end

    return false
end

function _M.filter_ip()
    if VeryNginxConfig.configs["filter_ip_enable"] ~= true then
        return false;
    end
    
    local remote_addr = ngx.var.remote_addr
    for i, v in ipairs( VeryNginxConfig.configs['filter_ip_rule'] ) do
        if v[1] == remote_addr then
            return true
        end
    end
    
    return false
end

function _M.filter_useragent()
    if VeryNginxConfig.configs["filter_useragent_enable"] ~= true then
        return true;
    end

    local find = ngx.re.find
    local http_user_agent = ngx.var.http_user_agent

    for i, v in ipairs( VeryNginxConfig.configs["filter_useragent_rule"] ) do
        if find( http_user_agent, v[1], "is" ) then
            return false
        end
    end

    return true
end

function _M.filter_uri()
    if VeryNginxConfig.configs["filter_uri_enable"] ~= true then
        return true;
    end
    
    local find = ngx.re.find
    local uri = ngx.var.uri
    
    for i, v in ipairs( VeryNginxConfig.configs["filter_uri_rule"] ) do
        if find( uri, v[1], "is" ) then
            return false
        end
    end

    return true
end

function _M.filter_args()

    if VeryNginxConfig.configs["filter_arg_enable"] ~= true then
        return true
    end
  
    local find = ngx.re.find
    local tbl_concat = table.concat

  
    for i,re in ipairs( VeryNginxConfig.configs["filter_arg_rule"] ) do
        for k,v in pairs( ngx.req.get_uri_args()) do 
            local arg_str
            if type(v) == "table" then
                arg_str = tbl_concat(v, ", ")
            else
                arg_str = v
            end

            if find( arg_str, re[1], "is" ) then
                return false
            end
        end
    end

    return true
end



function _M.filter()
    if _M.ip_in_whitelist() == true then
        return
    end

    if _M.filter_ip() == true then
        ngx.exit( ngx.HTTP_SERVICE_UNAVAILABLE ) 
    end
    
    if _M.filter_useragent() ~= true then
        ngx.exit( ngx.HTTP_SERVICE_UNAVAILABLE ) 
    end
    
    if _M.filter_uri() ~= true then
        ngx.exit( ngx.HTTP_SERVICE_UNAVAILABLE ) 
    end
    
    if _M.filter_args() ~= true then
        ngx.exit( ngx.HTTP_SERVICE_UNAVAILABLE ) 
    end
    

end

return _M
