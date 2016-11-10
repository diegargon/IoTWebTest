tKeys = {
    page = "index.html",
    ssid = cfg_ap.ssid,
    owner = cfg.owner,
    name = cfg_ap.ssid,
    tlf = cfg.tlf,
    chip = cfg.chip,
    title = cfg.network
} 

if (gpio.read(LUCES) == 0) then
    tKeys["C_LUCES"] = "btnOff"
else
    tKeys["C_LUCES"] = "btnOn"
end
if (gpio.read(BUZZER) == 0) then
    tKeys["C_PITIDO"] = "btnOff"
else
    tKeys["C_PITIDO"] = "btnOn"
end
 --print(gpio.read(LIGHTS) .. ":" .. gpio.read(BUZZER))
