function wifi_as_sta(cfg_sta)  
    wifi.setmode(wifi.STATION)
    wifi.sta.config(cfg_sta.ssid, cfg_sta.pwd)
    wifi.sta.setip(cfg_sta)
    wifi.sta.connect()
end
function wifi_as_staAp()
    wifi.setmode(wifi.STATIONAP)
    wifi.setphymode(wifi.PHYMODE_G)
    wifi.ap.config(cfg_ap)
    wifi.ap.dhcp.start()
    searchBestAp()
    --print(wifi.getphymode())
--    wifi.sta.config(cfg_sta.ssid, cfg_sta.pwd)
--    wifi.sta.setip(cfg_sta)
--    wifi.sta.connect()
end

function searchBestAp() 
    wifi_unreg_event()   
    wifi_reg_event_scan()
    wifi.sta.getap(1, gApList) 
end

function wifi_reg_event_scan()
    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, eMonConnScan)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, eMonDiscScan)
    --wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, eMonGotIpScan)
    --wifi.sta.eventMonStart()
end
function wifi_unreg_event_scan()
    wifi.eventmon.unregister(wifi.eventmon.STA_CONNECTED)
    wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
    --wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, eMonGotIp)
    --wifi.sta.eventMonStart()
end
function wifi_reg_event()
    --wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, eMonConn)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, eMonDisc)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, eMonGotIp)
    --wifi.sta.eventMonStart()
end

function wifi_unreg_event()
    --wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, eMonConn)
    wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
    wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
    --wifi.sta.eventMonStart()
end

function eMonConnScan(T)
    --print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
    print("STA - CONNECTED ".." tSSID: "..T.SSID.." BSSID: "..T.BSSID.." Channel: "..T.channel)    
    print(ApList[T.BSSID])
    --print(apB)
    local ssid, rssi, authmode, channel = string.match(ApList[T.BSSID], "([^,]+),([^,]+),([^,]+),([^,]*)")
    if (apB.rssi == nil or  rssi < apB.rssi ) then
        print("Found new best AP " .. ssid .. " with rssi " .. rssi)
        apB.bssid = T.BSSID
        apB.ssid = T.SSID
        apB.rssi = rssi
        apB.authmode = authmode
    end
    wifi.sta.disconnect()
end

function eMonGotIpScan(T) 
    print(" STA - GOT IP ".." Station IP: "..T.IP.." Subnet mask: ".. T.netmask.." Gateway IP: "..T.gateway)
end

function eMonDiscScan(T) 
    print("STA - DISCONNECTED".." SSID: "..T.SSID.." BSSID: "..T.BSSID.." reason: "..T.reason) 
    if (ApList[T.BSSID] ~= nil) then
        ApList[T.BSSID] = nil
        print("Try getting another ..")
        gBestAp()
    end
end

function eMonDisc(T)  
    print("STA - DISCONNECTED".." SSID: "..T.SSID.." BSSID: "..T.BSSID.." reason: "..T.reason)
    apB = {}
    collectgarbage()
    searchBestAp()    
end

function eMonGotIp(T) 
    print("STA - GOT IP ".." tStation IP: "..T.IP.." Subnet mask: ".. T.netmask.." Gateway IP: "..T.gateway)
end

function gApList(t)
    ApList = t
    --pApList()
    gBestAp()
end

function pApList()     
    print("\n")
    for bssid,v in pairs(ApList) do
        local ssid, rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        print(bssid.."  "..rssi.." "..authmode.." "..channel.." ".. ssid)      
    end
end

function gBestAp()
    local tmpAp = {} 
    for bssid,v in pairs(ApList) do
        if bssid ~= nil then
            tmpAp.bssid = bssid
            tmpAp.ssid, tmpAp.rssi, tmpAp.authmode, tmpAp.channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
            if (apB.rssi == nil or tmpAp.rssi < apB.rssi)  then
                print("Trying connect to " .. tmpAp.ssid .. " : " .. tmpAp.bssid .. " : ".. tmpAp.authmode)
                staConn(tmpAp)
                break;
            else 
                print("Discarding checking " .. tmpAp.ssid .. " because rssi: " .. tmpAp.rssi .. " its bigger than the best " .. apB.rssi)
                ApList[tmpAp.bssid] = nil               
            end
        end
    end

    local count = 0
    for _ in pairs(ApList) do count = count + 1 end
    if (apB.bssid ~= nil and apB.ssid ~= nil and count <= 0) then
        print("connBestAp called")
        connBestAp()
    elseif (apB.ssid == nil and count <= 0) then
        print("Search again...")
        searchBestAp()      
    end        
end

function staConn(Ap) 
    if Ap.authmode == "0" then
        wifi.sta.config(Ap.ssid, "", 0, Ap.bssid)
        wifi.sta.connect() 
    elseif  Ap.authmode == "3" then
        wifi.sta.config(Ap.ssid, cfg_sta.pwd, 0, Ap.bssid)
        wifi.sta.connect() 
    else 
        print("Connect mode unknonw " .. Ap.authmode)
    end
end

function connBestAp() 
    ApList = nil
    wifi_unreg_event_scan()
    wifi_reg_event()
    print("Connecting to best ap: " .. apB.ssid)
    staConn(apB)
    collectgarbage()
end
