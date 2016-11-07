LUCES = 6 -- 16
BUZZER = 1 -- 5
gpio.mode(LUCES,gpio.OUTPUT)
gpio.mode(BUZZER,gpio.OUTPUT)
--gpio.mode(2,gpio.OUTPUT)
--gpio.mode(3,gpio.OUTPUT)
--gpio.mode(4,gpio.OUTPUT)
--gpio.mode(5,gpio.OUTPUT) -- 14
--gpio.write(outpin,gpio.LW)
--gpio.write(LIGHTS, gpio.HIGH)
gpio.write(BUZZER, gpio.LOW)
gpio.write(LUCES, gpio.LOW)
--gpio.write(BUZZER, gpio.LOW)
-- End Ports Config
