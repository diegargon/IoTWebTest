dofile("config.lua")
dofile("wifi_func.lua")
-- Setup
dofile("setup.lua")
-- Begin Global Variables
ApList = {} --List of all scanned
apB = {} -- best ap
--IgApList = {} -- List of all ignored aps

-- End Global Varaibles
-- Begin Wifi
if (cfg.mode == 1) then
    wifi_as_sta()
end
if (cfg.mode == 3) then
    wifi.sta.disconnect()
    wifi_as_staAp()     
end
--  End Wifi
-- Begin Start httpd
dofile("httpd.lua")
-- End Start httpd
-- Begin Clean
collectgarbage()
-- End Clean
