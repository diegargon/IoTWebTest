return function (pl) 
    local r = {}
    local spos_ext
    
    -- find num char until HTTP/1.1 and get all before
    local line = pl:sub(1, pl:find("HTTP", 1, true) -1) 
    --Method GET/POST
    r.method = line:sub(1, line:find(" /", 1, true) - 1)

    -- FILE & EXT    
    local reqf_spos = line:find("/", 1, true)
    local reqf_epos = line:find(".", reqf_spos, true)
    if reqf_epos == nil then
        reqf_epos = line:find("%s", reqf_spos)
        r.ext = "html"
    else
       spos_ext = reqf_epos
    end
    r.file = line:sub(reqf_spos +1, reqf_epos -1, 1, true)
    
    if (r.file == nil or r.file == "") then
        r.file = "index"
    end

    if spos_ext ~= nil then
       r.ext = line:sub(spos_ext +1, line:find("%s", spos_ext) -1, 1, true)
    end     

    --FILE GET arguments
    local reqf_spos = line:find("?", reqf_spos, true)
    if( reqf_spos ~= nil ) then -- get args ?login=...
        local reqf_epos = line:find("%s", reqf_spos)
        r.args = line:sub(reqf_spos, reqf_epos -1, 1, true)
    end

    --Content && lenght
     r.clength = string.match(pl, "Content%-Length: ([%d/-]+)")
     if r.clength ~= nil then
        r.content = pl:sub(pl:find("\r\n\r\n",1 , true) +4, #pl)
     end

    return r
end
