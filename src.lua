if getgenv() then end
--[[                                 
                    ▄▄                                     
                    ██                                     
                    ██        ██    ██   ▄█████▄     ██    
                    ██        ██    ██   ▀ ▄▄▄██  ▄▄▄██▄▄▄ 
                    ██        ██    ██  ▄██▀▀▀██  ▀▀▀██▀▀▀ 
                    ██▄▄▄▄▄▄  ██▄▄▄███  ██▄▄▄███     ██    
                    ▀▀▀▀▀▀▀▀   ▀▀▀▀ ▀▀   ▀▀▀▀ ▀▀           
                    LuaPlus | Version 1.0.0 | By Derivative
                    
                    Derivative Team:
                    Lead Development, @ily.neo
                    Co-Lead Development, @s0ulz.ven
                    
                   #========================================#
                   LuaPlus is a Roblox Library designed by the
                   Derivative team with multi-purpose intentions.

                   Lua+ Provides Executors with more UNC percentage,
                   not via spoofing but actual redefinitions & functionality
                   towards these luau / Unified Naming Convention functions.

                   Lua+ also provides users with a free API system for their
                   scripts & executors.
]]
local l={
    [0]=[[                                                                  
                    88                                   88888888ba   88                          
                    88                                   88      "8b  88                          
                    88                                   88      ,8P  88                          
                    88          88       88  ,adPPYYba,  88aaaaaa8P'  88  88       88  ,adPPYba,  
                    88          88       88  ""     `Y8  88""""""'    88  88       88  I8[    ""  
                    88          88       88  ,adPPPPP88  88           88  88       88   `"Y8ba,   
                    88          "8a,   ,a88  88,    ,88  88           88  "8a,   ,a88  aa    ]8I  
                    88888888888  `"YbbdP'Y8  `"8bbdP"Y8  88           88   `"YbbdP'Y8  `"YbbdP"'  
                    ============================================================================
                    Lua+ By the Derivative team. Head Development, @ily.neo | Other, @s0ulz.ven
                    ============================================================================  
                                                    | This script uses Lua+ Version 1.0.0 Beta,
                    `7MN.   `7MF'                   | If you notice any issues, please contact
                      MMN.    M                     | neo on Discord (@ily.neo) so patches can
                      M YMb   M  .gP"Ya   ,pW"Wq.   | be implemented. If you'd like to support
                      M  `MN. M ,M'   Yb 6W'   `Wb  | us you may use Lua+ on your own scripts
                      M   `MM.M 8M"""""" 8M     M8  | or donate to us. Lua+ Github is located at
                      M     YMM YM.    , YA.   ,A9  | github.com/RobloxFramework/LuaPlus OR
                    .JML.    YM  `Mbmmd'  `Ybmd9'   | you can support neo at github.com/ily-neo
                    ============================================================================

                    
]],
    [1]=[[test]]
}

local sh={}
local LuaP,luaplus,lp,lplus=sh,sh,sh,sh

local funcs={
    getcallingscript=getcallingscript,
    loadfile=loadfile,
    clonefunction=clonefunction,
    setreadonly=setreadonly,
    getgenv=getgenv,
    checkcaller=checkcaller,
    identifyexecutor=identifyexecutor,
    getconnections=getconnections,
    WebSocket={},
    getsenv=getsenv,
    hookfunction=hookfunction,
    getgc=getgc,
    env,sandbox,clearc,
    cache={}
} funcs.cache._internal={}

--# cache based #--
funcs.cache._internal = setmetatable({}, {__mode="kv"})
funcs.cache.iscached = function(obj)
    if funcs.cache._internal[obj] == nil then
        funcs.cache._internal[obj] = obj
    end
    return funcs.cache._internal[obj] ~= false
end
funcs.cache.replace = function(original, replacement)
    funcs.cache._internal[original] = replacement
end
funcs.cache.get = function(k)
    return funcs.cache._internal[k]
end
funcs.cache.invalidate = function(obj)
    funcs.cache._internal[obj] = false
    if typeof(obj) == "Instance" then
        local clone = obj:Clone()
        obj.Parent = nil
        clone.Parent = obj.Parent
        return clone
    end
end

--# returns the script type which is being ran, eg LocalScript #--
funcs.getcallingscript=(function()
    return function()
        local lvl=3
        while true do
            local info=debug.getinfo(lvl)
            if not info then break end
            local env=getfenv(info.func)
            if env and env.script then
                return env.script
            end
            lvl=lvl+1
        end
    end
end)()

--# filesystem funcs #--
funcs.loadfile=(function()
    local og=loadfile
    return function(path)
        if og and type(og)=="function" then
            return og(path)
        end
        local success,src=pcall(readfile,path)
        if not success then 
            return nil
        end
        return loadstring(src)
    end
end)()

--# Closures funcs #--
funcs.clonefunction = (function()
    local og = clonefunction
    return function(func)
        if og then
            local ok, result = pcall(og, func)
            if ok then return result end
        end
        if type(func) ~= "function" then return func end
        local clone = function(...)
            return func(...)
        end
        return clone
    end
end)()

funcs.checkcaller=(function()
    local og=checkcaller
    return function()
        if og and type(og)=="function" then
            local ok,result=pcall(og)
            if ok and type(result)=="boolean" then 
                return result 
            end
        end
        return true
    end
end)()

--# Miscellaneous #--
funcs.identifyexecutor = (function()
    local og = identifyexecutor
    return function()
        if og then
            local ok, name, version = pcall(og)
            if ok and name then
                return name, version
            end
        end
        return "Lua+", "v1.0.0"
    end
end)()

--! HOOKFUNCTION NEEDS FIXING !--
--^ hookfunc ^--
funcs.hookfunction = (function()
    if hookfunction and typeof(hookfunction) == "function" then
        local ok = pcall(hookfunction, print, print)
        if ok then return hookfunction end
    end
    local clone = clonefunction or function(f) return function(...) return f(...) end end
    return function(original, replacement)
        if typeof(original) ~= "function" or typeof(replacement) ~= "function" then
            return original
        end
        local backup = clone(original)
        if debug and debug.getupvalue and debug.setupvalue then
            for i = 1, 9999 do
                local n, v = debug.getupvalue(original, i)
                if n == nil then break end
                if rawequal(v, original) then
                    debug.setupvalue(original, i, replacement)
                end
            end
        end
        if debug and debug.getinfo then
            for lvl = 3, 30 do
                local info = debug.getinfo(lvl, "f")
                if not info or not info.func then break end
                local i = 1
                while true do
                    local name, val = (debug.getlocal or function() return nil end)(lvl, i)
                    if not name then break end
                    if rawequal(val, original) then
                        (debug.setlocal or function() end)(lvl, i, replacement)
                    end
                    i = i + 1
                end
            end
        end
        local envs = {_G}
        local genv = (getgenv and getgenv()) or _G
        if genv ~= _G then table.insert(envs, genv) end
        for _, env in ipairs(envs) do
            if typeof(env) == "table" then
                for k, v in pairs(env) do
                    if rawequal(v, original) then
                        rawset(env, k, replacement)
                    end
                end
            end
        end
        return backup
    end
end)()

--^ getgc ^--
funcs.getgc = (function()
    local og = getgc
    return function(include_tables)
        if og then
            local ok, result = pcall(og, include_tables)
            if ok and result then return result end
        end
        local gc_objects = {}
        local seen = {}
        local function add_object(obj)
            if seen[obj] then return end
            seen[obj] = true
            table.insert(gc_objects, obj)
        end
        local function scan_function(func, depth)
            if depth > 6 then return end
            add_object(func)
            if debug and debug.getupvalue then
                local i = 1
                while i <= 200 do
                    local name, value = debug.getupvalue(func, i)
                    if not name then break end
                    local vtype = type(value)
                    if vtype == "function" then
                        if not seen[value] then
                            scan_function(value, depth + 1)
                        end
                    elseif vtype == "table" then
                        if include_tables and not seen[value] then
                            add_object(value)
                        end
                        pcall(function()
                            for k, v in pairs(value) do
                                if type(v) == "function" and not seen[v] then
                                    scan_function(v, depth + 1)
                                end
                            end
                        end)
                    end
                    i = i + 1
                end
            end
        end
        local function scan_table(tbl, depth)
            if depth > 6 then return end
            if seen[tbl] then return end
            if include_tables then
                add_object(tbl)
            end
            local success = pcall(function()
                for k, v in pairs(tbl) do
                    local vtype = type(v)
                    if vtype == "function" and not seen[v] then
                        scan_function(v, depth + 1)
                    elseif vtype == "table" and not seen[v] then
                        scan_table(v, depth + 1)
                    end
                    if type(k) == "function" and not seen[k] then
                        scan_function(k, depth + 1)
                    elseif type(k) == "table" and not seen[k] then
                        scan_table(k, depth + 1)
                    end
                end
            end)
            if success then
                local mt = getmetatable(tbl)
                if mt and type(mt) == "table" and not seen[mt] then
                    scan_table(mt, depth + 1)
                end
            end
        end
        scan_table(_G, 0)
        local genv_func = rawget(_G, "getgenv") or getgenv
        if genv_func then
            local success, genv = pcall(genv_func)
            if success and genv and genv ~= _G and type(genv) == "table" then
                scan_table(genv, 0)
            end
        end
        if debug and debug.getregistry then
            local success, registry = pcall(debug.getregistry)
            if success and registry and type(registry) == "table" then
                scan_table(registry, 0)
            end
        end
        if package and package.loaded then
            for name, module in pairs(package.loaded) do
                if type(module) == "table" then
                    scan_table(module, 1)
                elseif type(module) == "function" then
                    scan_function(module, 1)
                end
            end
        end
        for k, v in pairs(_G) do
            if type(v) == "function" and not seen[v] then
                scan_function(v, 0)
            elseif type(v) == "table" and not seen[v] then
                scan_table(v, 1)
            end
        end
        return gc_objects
    end
end)()

--^ websocket ^--
funcs.WebSocket.connect = (function()
    return function(url)
        local nativeWS = type(WebSocket) == "table" and type(WebSocket.connect) == "function" and WebSocket.connect
        if nativeWS then
            local ok, result = pcall(nativeWS, url)
            if ok and result then return result end
        end
        local ws = {}
        local isConnected = false
        local callbacks = {OnMessage = nil,OnClose = nil,OnError = nil}
        local httpUrl = url:gsub("^ws://", "http://"):gsub("^wss://", "https://")
        ws.State = "Connecting"
        ws.Send = function(self, data)
            if not isConnected then
                if callbacks.OnError then callbacks.OnError("WebSocket is not connected") end
                return false
            end
            local success, response = pcall(function()
                return game:HttpPost(httpUrl .. "/send", data)
            end)
            if not success then
                if callbacks.OnError then callbacks.OnError("Failed to send: " .. tostring(response)) end
                return false
            end
            return true
        end
        ws.Close = function(self)
            isConnected = false
            ws.State = "Closed"
            pcall(function() game:HttpGet(httpUrl .. "/close") end)
            if callbacks.OnClose then callbacks.OnClose() end
        end
        ws.OnMessage = setmetatable({}, {__newindex = function(t, k, v) if k == "Connect" then callbacks.OnMessage = v end end})
        ws.OnClose = setmetatable({}, {__newindex = function(t, k, v) if k == "Connect" then callbacks.OnClose = v end end})
        ws.OnError = setmetatable({}, {__newindex = function(t, k, v) if k == "Connect" then callbacks.OnError = v end end})
        local function pollMessages()
            while isConnected do
                local success, response = pcall(function() return game:HttpGet(httpUrl .. "/poll") end)
                if success and response and response ~= "" then
                    if callbacks.OnMessage then callbacks.OnMessage(response) end
                end
                wait(0.1)
            end
        end
        task.spawn(function()
            local success, response = pcall(function() return game:HttpGet(httpUrl .. "/connect") end)
            if success then
                isConnected = true
                ws.State = "Open"
                task.spawn(pollMessages)
            else
                ws.State = "Closed"
                if callbacks.OnError then callbacks.OnError("Connection failed: " .. tostring(response)) end
            end
        end)
        return ws
    end
end)()

--^ getsenv ^--
funcs.getsenv = (function()
    local og = getsenv
    return function(script_instance)
        if og then
            local ok, result = pcall(og, script_instance)
            if ok and result then return result end
        end
        if typeof(script_instance) ~= "Instance" then return nil end
        if not (script_instance:IsA("LocalScript") or script_instance:IsA("ModuleScript") or script_instance:IsA("Script")) then
            return nil
        end
        local function search_all_functions()
            local all_funcs = {}
            if getgc then
                local gc_result = getgc(false)
                for _, obj in ipairs(gc_result) do
                    if type(obj) == "function" then
                        table.insert(all_funcs, obj)
                    end
                end
            end
            local function scan_table(tbl, seen)
                if not tbl or type(tbl) ~= "table" then return end
                if seen[tbl] then return end
                seen[tbl] = true
                for k, v in pairs(tbl) do
                    if type(v) == "function" then
                        table.insert(all_funcs, v)
                    elseif type(v) == "table" then
                        pcall(scan_table, v, seen)
                    end
                end
            end
            scan_table(_G, {})
            if getgenv then
                pcall(function() scan_table(getgenv(), {}) end)
            end
            return all_funcs
        end
        local all_functions = search_all_functions()
        for _, func in ipairs(all_functions) do
            local success, env = pcall(getfenv, func)
            if success and env and type(env) == "table" then
                local has_script = pcall(function() return env.script == script_instance end)
                if has_script then return env end
            end
        end
        if script_instance:IsA("ModuleScript") then
            local success, result = pcall(require, script_instance)
            if success then return getfenv(2) end
        end
        for level = 1, 256 do
            local success, info = pcall(debug.getinfo, level, "f")
            if not success or not info then break end
            if info.func then
                local env_success, env = pcall(getfenv, info.func)
                if env_success and env and type(env) == "table" then
                    local script_match = pcall(function() return env.script == script_instance end)
                    if script_match then return env end
                end
            end
        end
        return nil
    end
end)()

--# Metatable funcs #--

--# enviroments #--
funcs.getgenv=(function()
    local og=getgenv
    return function()
        if og then
            return og()
        end
        local g=rawget(_G,"__genv")
        if not g then
            g={}
            rawset(_G,"__genv",g)
            setmetatable(g,{
                __index=_G,
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    rawset(_G,k,v)
                end
            })
        end
        return g
    end
end)()

--~ lp funcs ~--
funcs.env=function()
    --& simple env sys, useless rn &--
    local enviroment={print=print}
    clearc()
    warn(l[0])
    local f=loadstring("return true")
    setfenv(f,enviroment)
end

--^ sandbox to stop scripts from messing with globals ^--
funcs.sandbox=function(src)
    local env=setmetatable({print=print},{__index=_G})
    local fn,err=loadstring(src)
    if not fn then return nil, err end
    setfenv(fn,env)
    return fn()
end

--^ clear console ^--
funcs.clearc=(function()
    local og=clearc
    return function()
        if og then
            local ok=pcall(og)
            if ok then return end
        end
        print(string.rep("\n", 16348))
    end
end)()

--# initialize #--
luaplus.init=function()
    local set=function(n,v)
        if _G[n]==nil then
            _G[n]=v
        end
    end

    set("loadfile",funcs.loadfile)
    set("clonefunction",funcs.clonefunction)
    set("getcallingscript",funcs.getcallingscript)
    set("getgenv",funcs.getgenv)
    set("identifyexecutor",funcs.identifyexecutor)
    set("getgc",funcs.getgc)
    set("getsenv",funcs.getsenv)
    set("cache",funcs.cache)
    set("checkcaller",funcs.checkcaller)
    set("hookfunction",funcs.hookfunction)
    set("WebSocket",funcs.WebSocket)
    if not debug then debug={} end
    if setmetatable and setfenv then
        env=funcs.env
        sandbox=funcs.sandbox
        clearc=funcs.clearc
        env()
    else
        print(l[1])
    end
end

lp.init()
