function get_file(filename)
    if (file.open(filename, "r")) then  
        local data = file.read()
        file.close()
        filename = nil
        return data
    end
    filename = nil
    return nil
end
function get_file_chunk(filename, pos, chunk)
    if (file.open(filename, "r")) then
        file.seek("set", pos)
        local file_data = file.read(chunk)
        file.close()
        return file_data
    end
    return nil
end
function tpl_replace(tpl, tKeys)
    for k,v in pairs(tKeys) do
        local pattern = "%[" .. k .. "%]"
        local value = v
        tpl = tpl.gsub(tpl, pattern, value)
    end
    return tpl
end

function file_exists(filename) 
    if (file.open(filename, "r")) then
        return true
    else
        return false
    end
end

function findLast(string, needle)
    local i=string:match(".*"..needle.."()")
    if i==nil then return nil else return i-1 end
end
