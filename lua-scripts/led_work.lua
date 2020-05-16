do

local step=10
local max_delay=256*step


if animation_timer == nil then 
    animation_timer = tmr.create() -- if timer doesn't exist - create timer
else
    animation_timer:unregister() -- if timer exist - stop timer and unregister callback function
end



if mode == 0 then
    buffer:fill(0, 0, 0) -- turn off led strip
    ws2812.write(buffer)
    
elseif mode == 1 then -- static mode fill the buffer with given color (default RED)
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    buffer:fill(green, red, blue)
    ws2812.write(buffer)
    
elseif mode == 2 then -- blink with given color and speed
    local blink_state=0
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    animation_timer:alarm(max_delay-speed*step, tmr.ALARM_AUTO, function()
        if blink_state==0 then
            buffer:fill(0, 0, 0)
        else
            buffer:fill(green, red, blue)
        end
        ws2812.write(buffer)
        blink_state = (blink_state == 0) and 1 or 0
    end)

elseif mode == 3 then -- blink with random color each time
    local blink_state=0
    animation_timer:alarm(max_delay-speed*step, tmr.ALARM_AUTO, function()
        if blink_state==0 then
            buffer:fill(0, 0, 0)
        else
            local hue = node.random(0, 359)
            local green, red, blue = color_utils.hsv2grb(hue, saturation, brightness)
            buffer:fill(green, red, blue)
        end
        ws2812.write(buffer)
        blink_state = (blink_state == 0) and 1 or 0
    end)
    
elseif mode == 4 then -- smooth blink with given color and speed
    local value=0
    local blink_state=2
    if brightness<=1 then brightness=2 end
    animation_timer:alarm(max_delay/4-speed*step/4, tmr.ALARM_AUTO, function()
        local green, red, blue = color_utils.hsv2grb(color, saturation, value)
        buffer:fill(green, red, blue)
        ws2812.write(buffer)
        value = value + blink_state
        if value >= (brightness-1) then blink_state=-2
        elseif value <= 1 then blink_state=2
        end
    end)
    
elseif mode == 5 then -- all strip goes throw rainbow
    local angle=0
    animation_timer:alarm(max_delay/4-speed*step/4, tmr.ALARM_AUTO, function()
        local green, red, blue = color_utils.hsv2grb(angle, saturation, brightness)
        buffer:fill(green, red, blue)
        ws2812.write(buffer)
        angle = angle + 1
        if angle == 360 then angle = 0 end
    end)
    
elseif mode == 6 then -- circle rainbow, number of leds <= 360 !!!
    local angle = 0
    local angle_step = 360/buffer:size()
    for i=1, buffer:size() do
        local green, red, blue = color_utils.hsv2grb(angle, saturation, brightness)
        buffer:set(i, green, red, blue)
        angle = angle + angle_step
        if angle >= 360 then angle = 0 end
    end
    animation_timer:alarm(max_delay/4-speed*step/4, tmr.ALARM_AUTO, function()
        buffer:shift(1, ws2812.SHIFT_CIRCULAR)
        ws2812.write(buffer)
    end)

elseif mode == 7 then -- smooth blink goes throw rainbow color
    local value=0
    local blink_state=2
    local angle=0
    local counter = 0
    animation_timer:alarm(max_delay/4-speed*step/4, tmr.ALARM_AUTO, function()
        if counter==20 then 
            angle=angle + 1
            if angle==360 then angle = 0 end 
            counter = 0 
        end
        local green, red, blue = color_utils.hsv2grb(angle, saturation, value)
        buffer:fill(green, red, blue)
        ws2812.write(buffer)
        value = value + blink_state
        if value >= (brightness-1) then blink_state=-2
        elseif value <= 1 then blink_state=2
        end
        counter = counter + 1
    end)
    
elseif mode == 8 then -- flicker random pixel with given color
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    buffer:fill(green, red, blue)
    local green_flick, red_flick, blue_flick = color_utils.hsv2grb(color, saturation, 255)
    local pixel=node.random(1, buffer:size())
    animation_timer:alarm(max_delay-speed*step, tmr.ALARM_AUTO, function()
        buffer:set(pixel, green, red, blue)
        pixel=node.random(1, buffer:size())
        buffer:set(pixel, green_flick, red_flick, blue_flick)
        ws2812.write(buffer)
    end)

elseif mode == 9 then -- runnung circle LED
    buffer:fill(0, 0, 0)
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    buffer:set(1, green, red, blue)
    animation_timer:alarm(max_delay/4-speed*step/4, tmr.ALARM_AUTO, function()
        buffer:shift(1, ws2812.SHIFT_CIRCULAR)
        ws2812.write(buffer)
    end)

elseif mode == 10 then -- flicker random pixels with given color
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    buffer:fill(green, red, blue)
    local green_flick, red_flick, blue_flick = color_utils.hsv2grb(color, saturation, 255)
    local pixel={}
    local number_of_lights=node.random(1, buffer:size()/5)
    animation_timer:alarm(max_delay-speed*step, tmr.ALARM_AUTO, function()
        buffer:fill(green, red, blue)
        for i=1, number_of_lights do
           pixel[i]=node.random(1, buffer:size())
           buffer:set(pixel[i], green_flick, red_flick, blue_flick) 
        end
        number_of_lights=node.random(1, buffer:size()/5)
        ws2812.write(buffer)
    end)    

elseif mode == 11 then -- smooth flicker random pixels with given color
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    buffer:fill(green, red, blue)
    local number_of_lights=buffer:size()/5
    local pixel={}
    local value={}
    local state_blink={}
    if brightness<=10 then brightness=10
    elseif brightness>=245 then brightness=245
    end
    

    local function check2(t, str)
      for k, v in pairs(t) do
        if v == str then return true end
      end
      return false
    end
    
    for i=1,number_of_lights do
        local check=true
        local p=0
        while(check) do
            p = node.random(1,buffer:size())
            check=check2(pixel,p)
        end    
        pixel[i]=p     
        value[i]=node.random(brightness,(mode_11_max_brightness-10))
        if node.random(1,2)==1 then state_blink[i]=10
        else state_blink[i]=-10;
        end
    end
    animation_timer:alarm(max_delay/4-speed*step/4, tmr.ALARM_AUTO, function()
        for i, val in pairs(value) do
            green, red, blue = color_utils.hsv2grb(color, saturation, value[i])
            buffer:set(pixel[i], green, red, blue)
            value[i]=value[i]+state_blink[i]
            if value[i] >= (mode_11_max_brightness-9) then state_blink[i]=-10
            elseif value[i] <= (brightness+9) then 
                state_blink[i]=10
                local check=true
                local p=0
                while(check) do
                    p = node.random(1,buffer:size())
                    check=check2(pixel,p)
                end
                pixel[i]=p
            end
        end
        ws2812.write(buffer)
    end) 

elseif mode == 12 then -- runnung circle fading LED (minimum 10 leds)
    local j=1;
    local direction=1
    animation_timer:alarm(max_delay/2-speed*step/2, tmr.ALARM_AUTO, function()
        buffer:fill(0, 0, 0)
        if direction==1 then
            for i=1,buffer:size()/10 do
                local green, red, blue = color_utils.hsv2grb(color, saturation, brightness/i)
                buffer:set(buffer:size()/10+j-i, green, red, blue)
            end
        else
            for i=1,buffer:size()/10 do
                local green, red, blue = color_utils.hsv2grb(color, saturation, brightness/i)
                buffer:set(buffer:size()-(buffer:size()/10+j-i), green, red, blue)
            end
        end
        j=j+1
        if j>(buffer:size()-buffer:size()/10) then 
            j=1 
            if direction==1 then direction=-1
            else
                direction=1
            end
        end
        
        ws2812.write(buffer)
    end)
    
elseif mode==13 then -- vertical fire effect
    local heat = {}
    for i=1, number_of_leds do
        heat[i]=0;
    end
    
    local function setPixelHeatColor(Pixel, temperature)
        t=(temperature*191)/255
        heatramp = bit.band(t,0x3F)
        heatramp=bit.lshift(heatramp, 2)
    
        if t>0x80 then buffer:set(Pixel, 255, 255, heatramp) --hot
        elseif t>0x40 then buffer:set(Pixel, heatramp, 255, 0) --mid
        else buffer:set(Pixel, 0, heatramp, 0) -- cool
        end
    end
    
    local function Fire(Cooling, Sparking)
        local cooldown
        for i=1, number_of_leds do
            cooldown=node.random(0, ((Cooling*10)/number_of_leds)+2)
            if cooldown>heat[i] then
                heat[i]=0
            else
                heat[i]=heat[i]-cooldown
            end
        end
    
        for k=buffer:size(), 4, -1 do
            heat[k]=(heat[k-1]+heat[k-2]+heat[k-3])/3
        end
    
        if node.random(0, 255) < Sparking then
            local y=node.random(1, 7)
            heat[y]=heat[y]+node.random(160,255)
        end
    
        for j=1, buffer:size() do
            setPixelHeatColor(j, heat[j])
        end
        ws2812.write(buffer)
    end
    animation_timer:alarm(max_delay-speed*step+50, tmr.ALARM_AUTO, function()
        Fire(100,25)
    end)
    
elseif mode==14 then -- horizontal fire effect
    local heat = {}
    for i=1, number_of_leds do
        heat[i]=0;
    end

    local function setPixelHeatColor(Pixel, temperature)
        t=(temperature*191)/255
        heatramp = bit.band(t,0x3F)
        heatramp=bit.lshift(heatramp, 2)
    
        if t>0x80 then buffer:set(Pixel, 255, 255, heatramp) --hot
        elseif t>0x40 then buffer:set(Pixel, heatramp, 255, 0) --mid
        else buffer:set(Pixel, 0, heatramp, 0) -- cool
        end
    end

    local function Fire(Cooling, Sparking)
        local cooldown
        for i=1, number_of_leds do
            cooldown=node.random(0, ((Cooling*(10))/number_of_leds)+2)
            if cooldown>heat[i] then
                heat[i]=0
            else
                heat[i]=heat[i]-cooldown
            end
        end
    
        local x={}
        for k=1, number_of_leds do
            if k==1 then x[k]=(heat[k]+heat[k+1])/3
            elseif k==number_of_leds then x[k]=(heat[k]+heat[k-1])/3
            else x[k]=(heat[k+1]+heat[k-1]+heat[k])/3
            end
        end
        for k=1, number_of_leds do
            heat[k]=x[k]
        end
    
        if node.random(1, 255) < Sparking then
            local y=node.random(1, number_of_leds)
            heat[y]=heat[y]+node.random(400,700)
        end
        
        for j=1, number_of_leds  do
            setPixelHeatColor(j, heat[j])
        end
        ws2812.write(buffer)
    end
    
    animation_timer:alarm(max_delay-speed*step+50, tmr.ALARM_AUTO, function()
        Fire(30,110)
    end)
    
elseif mode==15 then -- random noise
    local FIRE_STEP = 15
    local HUE_GAP = 21
    local MAX_SAT = 255
    local MIN_SAT = 245
    local MIN_BRIGHT = 70
    local MAX_BRIGHT = 255
    
    local noise= {}
    
    for i=1, buffer:size() do
        noise[i]=0
    end

    local function map(x, in_min, in_max, out_min, out_max)
        local ans = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
        if ans>out_max then ans=out_max 
        elseif ans<out_min then ans=out_min end
    
        return ans
    end

    animation_timer:alarm(100, tmr.ALARM_AUTO, function()
        for i=1, buffer:size() do
            noise[i]=node.random(0,255)
        end
        for i=1, buffer:size() do
            if i>1 and i<buffer:size() then
                noise[i]=(noise[i]+noise[i-1]+noise[i+1])/3
            end
            local H=color+ map(noise[i], 0, 255, 0, HUE_GAP)
            local S=map(noise[i], 0, 255, MIN_SAT, MAX_SAT)
            local V=map(noise[i], 0, 255, MIN_BRIGHT, MAX_BRIGHT)
            local green, red, blue = color_utils.hsv2grb(H, S, V)
            buffer:set(i, green, red, blue)
        end
        ws2812.write(buffer)
    end)    
end

end
