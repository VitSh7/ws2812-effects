require("settings")--load setting

node.setcpufreq(node.CPU160MHZ)-- set CPU 160MHz for faster operation

-- initialization of modules
dofile("wifi_init.lua")

local function setup_N() -- send number_of_leds to atmega
    local id = 0
    local dev_addr = 66
    local sda = 2
    local scl = 1
    i2c.setup(id, sda, scl, i2c.SLOW)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, 2, number_of_leds)
    i2c.stop(id)
end
-- create timer wating for wifi connection
local t = tmr.create()        
t:alarm(250, tmr.ALARM_AUTO, function() 
    if wifi.sta.getip()~=nil 
        then
        print("WIFI IP: "..wifi.sta.getip())
        dofile("server_create.lua") -- create server
        -- strip initialization
        ws2812.init()
        buffer = ws2812.newBuffer(number_of_leds, 3) -- strip initialization
        setup_N()
        t:unregister() 
        t=nil
    end 
end)
