dofile("file_func.lua")
dofile("httpd_func.lua")

if (srv ~= nil ) then
   srv:close()
   svr, conn = nil
   collectgarbage()
end
tKeys = {}

srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
  local filename = nil
  local bSent = 0  
  local hxtra = ""
  local ctype = "text/html"
  local fullPl
  local pl_lenght
  
  conn:on("receive", function(conn, pl)    
    --print(pl)
    collectgarbage()
    
    -- Check if we have full content   (Safari problem...)
    local pl_lenght_tmp = tonumber(string.match(pl, "Content%-Length: ([%d/-]+)"))
    print("Payload size: " .. #pl)
    if pl_lenght_tmp then
        print("Payload content lenght: " .. pl_lenght_tmp)
        local pl_content = pl:sub(pl:find("\r\n\r\n",1 , true) +4, #pl)
        if (pl_lenght_tmp > #pl_content) then
            pl_lenght = pl_lenght_tmp
            if fullPl ~= nil then
                fullPl = fullPl .. pl
            else
                fullPl = pl
            end
            pl_lenght_tmp = nil
            return
       end
    else        
        if (fullPl ~= nil and pl_lenght ~= nil) then
            pl = fullPl .. pl     
            local pl_content = pl:sub(pl:find("\r\n\r\n",1 , true) +4, #pl)       
            if (pl_lenght > #pl_content) then
                return
            else
                pl_content, pl_lenght, fullPl = nil
                collectgarbage()
            end
        end
    end
    -- end check
    
    local req = dofile("http-request.lua")(pl)
    if (req.ext == "css") then
        ctype = "text/css"
        hxtra = "Cache-Control: max-age=2592000, public\r\n"
    elseif (req.ext == "jpg" or req.ext == "jpeg") then
        ctype = "image/jpeg"
        hxtra = "Cache-Control: max-age=2592000, public\r\n"
    end

    filename = req.file .. "." .. req.ext

    if ( (file_exists(filename) ) and (req.ext == "html" or req.ext == "css" or req.ext == "jpg")) then
        if req.method == "POST" then
            post_process(req)
        end
        filename = req.file .. "." .. req.ext
        conn:send("HTTP/1.0 200 OK\r\nContent-Type: " .. ctype .. "\r\nServer: NodeMCU\r\n" .. hxtra .. "Connection: close\r\n\r\n")            
    else
        filename = nil
        req = nil
        conn:send("HTTP/1.1 404 Not Found\r\nContent-type: text/html\r\nServer: NodeMCU\r\nConnection: close\r\n\r\n")
    end

  end)

    local function sendFile(sk, filename, bSent) 
        local chunkSz = 1400
        local data = get_file_chunk(filename, bSent, chunkSz)

        if data ~= nil then
            if (file_exists(filename .. ".lua")) then
                -- avoid cutting tags search for last spaces
                local space_end = findLast(data, "%s")
                data = data.sub(data, 0, space_end)
                bSent = bSent + #data
                if ( tKeys == nil or tKeys.page ~= filename ) then -- avoid exec each chunk
                    dofile(filename .. ".lua")
                end
                data = tpl_replace(data, tKeys)
                --print(data)
            else 
                bSent = bSent + #data
            end
            sk:send(data)
        else
            skClose(sk)
        end

        data = nil
        return bSent
    end
    
    local function skClose(sk)    
        bSent = 0
        filename = nil
        sk:close()
        sk = nil
        tKeys = nil
        req = nil
        hxtra = nil
        --print (node.heap())
        collectgarbage()
    end

    local function Disconnect(sk, payload) 
        --print("Disconnect Trigged")
        collectgarbage()
    end

    local function MySent(sk)
        if ( filename ~= nil ) then
           local fsize = {}
           fsize = file.list()[filename]
           
           if (bSent < fsize) then
                bSent = sendFile(sk, filename, bSent)
            else
                skClose(sk)
            end
        else 
            skClose(sk)
        end
    end

    conn:on("sent", MySent)
    conn:on("disconnection", Disconnect)   
end)
