function UNUSED_OLD_EXAMPLE_trlpower(kdesi,pl)
   pwm.close(outpin)
   gpio.mode(outpin,gpio.OUTPUT)
   dotaz=string.sub(pl,kdesi[2]+1,#pl)
   status = dotaz
   if dotaz=="ON"  then gpio.write(outpin,gpio.HIGH) return end
   if dotaz=="OFF" then gpio.write(outpin,gpio.LOW) return end
   if dotaz=="FLC" then pwm.setup(outpin,2,512)pwm.start(outpin) return end
   pwm.setup(outpin,1000,dotaz*10)
   pwm.start(outpin)
end
function get_args(content)
    local args = {}
    local name, value = string.match(content, "(.*)=(.*)")
    args[name] = value
    return args
end
function post_process(req) 
    if req.content ~= nil and args ~= nil then
        return nil
    end
    local args = get_args(req.content)
    for k,v in pairs(args) do
        if k == "btnToggle" then
            local btnPin = _G[v]
            if (gpio.read(btnPin) == 0) then
                gpio.write(btnPin, gpio.HIGH)
            else 
                gpio.write(btnPin, gpio.LOW)
            end
        end
    end
end
