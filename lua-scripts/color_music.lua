do

local step=10
local max_delay=256*step

local id = 0
local dev_addr = 66

if animation_timer == nil then 
    animation_timer = tmr.create() -- if timer doesn't exist - create timer
else
    animation_timer:unregister() -- if timer exist - stop timer and unregister callback function
end

local function setup_i2c()
    local sda = 2
    local scl = 1
    i2c.setup(id, sda, scl, i2c.SLOW)
end

local function setup_mode(M) -- mode=0 then send Rlenght, Llenght else send band
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, 1, M)
    i2c.stop(id)
end

local function get_audio()
    if mode==18 then
        i2c.start(id)
        i2c.address(id, dev_addr, i2c.RECEIVER)
        local i2c_buffer = i2c.read(id, 3)
        i2c.stop(id)
        local band1=string.byte(i2c_buffer, 1);
        local band2=string.byte(i2c_buffer, 2);
        local band3=string.byte(i2c_buffer, 3);
        return band1, band2, band3
    else
        i2c.start(id)
        i2c.address(id, dev_addr, i2c.RECEIVER)
        local i2c_buffer = i2c.read(id, 2)
        i2c.stop(id)
        local L=string.byte(i2c_buffer, 1);
        local R=string.byte(i2c_buffer, 2);
        return R, L;
    end
end


if mode == 16 then

    local MAX_CH = buffer:size()/2;
    local EMPTY_COLOR = 345
    local EMPTY_BRIGHT = 0

    setup_i2c()
    setup_mode(0)
    
    animation_timer:alarm(20, tmr.ALARM_AUTO, function()
        local Rlenght, Llenght=get_audio()
        
        local green, red, blue = color_utils.hsv2grb(EMPTY_COLOR, saturation, EMPTY_BRIGHT)
        buffer:fill(green, red, blue) -- заливка подложки
        if Rlenght>2 and Llenght>2 then
            -- заливка от зеленого к красному от hue=120 до 0
            local hue_step=2
            local hue=color    
            for i=MAX_CH,(MAX_CH+1-Rlenght), -1 do
                green, red, blue = color_utils.hsv2grb(hue, saturation, brightness)
                buffer:set(i, green, red, blue)
                hue = hue-hue_step;
                if hue<0 then hue=359 end
            end
            
            hue=color
            
            for i=(MAX_CH+1),(MAX_CH+Llenght), 1 do
                green, red, blue = color_utils.hsv2grb(hue, saturation, brightness)
                buffer:set(i, green, red, blue)
                hue = hue-hue_step;
                if hue<0 then hue=359 end
            end
        end
        ws2812.write(buffer)
    end)

elseif mode == 17 then

    local MAX_CH = buffer:size()/2;
    local EMPTY_COLOR = 345
    local EMPTY_BRIGHT = 0
    local hue_start=color

    setup_i2c()
    setup_mode(0)
    
    animation_timer:alarm(20, tmr.ALARM_AUTO, function()
        
        local Rlenght, Llenght=get_audio()
        
        local green, red, blue = color_utils.hsv2grb(EMPTY_COLOR, saturation, EMPTY_BRIGHT)
        buffer:fill(green, red, blue) -- заливка подложки
        if Rlenght>2 then
            -- заливка от зеленого к красному от hue=120 до 0
            local hue_step=2
            hue_start = hue_start+2
            if hue_start>=360 then hue_start=0 end
            local hue=hue_start
            for i=MAX_CH,(MAX_CH+1-Rlenght), -1 do
                green, red, blue = color_utils.hsv2grb(hue, saturation, brightness)
                buffer:set(i, green, red, blue)
                hue = hue-hue_step;
                if hue<0 then hue=359 end
            end
            
            hue=hue_start
            for i=(MAX_CH+1),(MAX_CH+Llenght), 1 do
                green, red, blue = color_utils.hsv2grb(hue, saturation, brightness)
                buffer:set(i, green, red, blue)
                hue = hue-hue_step;
                if hue<0 then hue=359 end
            end
        end
        
        ws2812.write(buffer)
    end)

elseif mode == 18 then

    --local SMOOTH_STEP=20
    local hue_low=color
    local hue_mid=hue_low+15
    if hue_mid>359 then hue_mid=hue_mid-359 end
    local hue_high=hue_mid+15
    local EMPTY_COLOR = 345
    local EMPTY_BRIGHT = 0

    setup_i2c()
    setup_mode(1)
    
    animation_timer:alarm(15, tmr.ALARM_AUTO, function()

        local green, red, blue = color_utils.hsv2grb(EMPTY_COLOR, saturation, EMPTY_BRIGHT)
        buffer:fill(green, red, blue) -- заливка подложки
        local band_bright = {0, 0, 0}
        band_bright[1], band_bright[2], band_bright[3] = get_audio()

        local width=(buffer:size())/5
        if(band_bright[1]>0) then
            green, red, blue = color_utils.hsv2grb(hue_low, saturation, band_bright[1])
            for i=(width*2+1),width*3 do
                buffer:set(i, green, red, blue)
            end
        end
        if(band_bright[2]>0) then
            green, red, blue = color_utils.hsv2grb(hue_mid, saturation, band_bright[2])
            for i=(width+1),width*2 do
                buffer:set(i, green, red, blue)
            end
            for i=(width*3+1),width*4 do
                buffer:set(i, green, red, blue)
            end
        end
        if(band_bright[3]>0) then
            green, red, blue = color_utils.hsv2grb(hue_high, saturation, band_bright[3])
            for i=1,width do
                buffer:set(i, green, red, blue)
            end
            for i=(width*4+1),width*5 do
                buffer:set(i, green, red, blue)
            end
        end
        ws2812.write(buffer)
    end)
--[[    
elseif mode == 19 then -- flicker random pixels with given color
    
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    buffer:fill(green, red, blue)
    local green_flick, red_flick, blue_flick = color_utils.hsv2grb(color, saturation, 255)
    local pixel={}
    local number_of_lights=0;

    setup_i2c()
    
    animation_timer:alarm(20, tmr.ALARM_AUTO, function()
        buffer:fill(green, red, blue)
        
        local Rlenght, Llenght=get_audio()
        
        for i=1, Rlenght do
           pixel[i]=node.random(1, buffer:size())
           buffer:set(pixel[i], green_flick, red_flick, blue_flick) 
        end
        ws2812.write(buffer)
    end)
]]
elseif mode == 19 then -- smooth flicker random pixels with given color
    local number_of_lights=0
    local pixel={}
    local value={}
    local state_blink={}
    local run={}
    --if brightness<=0 then brightness=0
    if brightness>=245 then brightness=245
    end
    local green, red, blue = color_utils.hsv2grb(color, saturation, brightness)
    buffer:fill(green, red, blue)
    

    local function check2(t, str)
      for k, v in pairs(t) do
        if v == str then return true end
      end
      return false
    end

    setup_i2c()
    setup_mode(0)

    animation_timer:alarm(25, tmr.ALARM_AUTO, function()
        local Rlenght, Llenght=get_audio()
        Llenght=(Llenght+Rlenght+Llenght)/3
        if Llenght>number_of_lights then
            for i=number_of_lights+1,Llenght do
                local check=true
                local p=0
                while(check) do
                    p = node.random(1,buffer:size())
                    check=check2(pixel,p)
                end    
                pixel[i]=p     
                value[i]=node.random(brightness,(mode_11_max_brightness-10))
                run[i]=true;
                if node.random(1,2)==1 then state_blink[i]=10
                else state_blink[i]=-10;
                end
            end
            number_of_lights=Llenght
        elseif Llenght<number_of_lights then
            for i=Llenght+1, number_of_lights do
                run[i]=false;
            end
        end
        
        
        for i=#value, 1, -1 do
            value[i]=value[i]+state_blink[i]
            if value[i] >= (mode_11_max_brightness) then value[i]=mode_11_max_brightness;
            elseif value[i] <= (brightness) then value[i]=brightness
            end
            green, red, blue = color_utils.hsv2grb(color, saturation, value[i])
            buffer:set(pixel[i], green, red, blue)
            if value[i] == (mode_11_max_brightness) then state_blink[i]=-10;
            elseif value[i] == (brightness) then
                if run[i]==true then
                    state_blink[i]=10
                    local check=true
                    local p=0
                    while(check) do
                        p = node.random(1,buffer:size())
                        check=check2(pixel,p)
                    end
                    pixel[i]=p
                else 
                    number_of_lights=number_of_lights-1;
                    table.remove(pixel,i)
                    table.remove(value,i)
                    table.remove(state_blink,i)
                    table.remove(run,i)
                end
            end

        end
        ws2812.write(buffer)
    end)

elseif mode == 20 then -- mode 16 with flicking

    local MAX_CH = buffer:size()/2;
    local EMPTY_COLOR = 345
    local EMPTY_BRIGHT = 0

    setup_i2c()
    setup_mode(0)

    local flick ={}
    flick[1]=0
    animation_timer:alarm(30, tmr.ALARM_AUTO, function()
        local Rlenght, Llenght=get_audio()
        
        local green, red, blue = color_utils.hsv2grb(EMPTY_COLOR, saturation, EMPTY_BRIGHT)
        buffer:fill(green, red, blue) -- заливка подложки
        if Rlenght>1 and Llenght>1 then
            -- заливка от зеленого к красному от hue=120 до 0
            local hue_step=2
            local hue=color   
            for i=MAX_CH,(MAX_CH+1-Rlenght), -1 do
                green, red, blue = color_utils.hsv2grb(hue, saturation, brightness)
                buffer:set(i, green, red, blue)
                hue = hue-hue_step;
                if hue<0 then hue=359 end
            end
            
            hue=color
            
            for i=(MAX_CH+1),(MAX_CH+Llenght), 1 do
                green, red, blue = color_utils.hsv2grb(hue, saturation, brightness)
                buffer:set(i, green, red, blue)
                hue = hue-hue_step;
                if hue<0 then hue=359 end
            end
            if --[[node.random(1, 60)==10 or]] Rlenght==MAX_CH then flick[#flick+1]=1 end
            N=#flick
            for i=N, 2, -1 do
                buffer:set(flick[i]+MAX_CH-1, brightness, brightness, brightness)
                buffer:set(-flick[i]+MAX_CH+1, brightness, brightness, brightness)
                flick[i]=flick[i]+1
                if flick[i]>Rlenght then table.remove(flick, i) end
            end
        end
        ws2812.write(buffer)
    end)


elseif mode==21 then
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

    local last_Rlenght=0
    local aver_temp = 0

    local function Fire(Cooling, Sparking, Rlenght)
        local cooldown
        for i=1, number_of_leds do
            cooldown=node.random(0, (((Cooling+aver_temp/5)*(10))/number_of_leds)+2)
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
            aver_temp=aver_temp+x[k]
        end
        aver_temp=aver_temp/number_of_leds
    
        if node.random(1, number_of_leds/2) < Rlenght then
            local y=node.random(1, number_of_leds)
            heat[y]=heat[y]+node.random(400,700)
        end
        --[[
        for i=1, Rlenght/4 do
            local y=node.random(1, number_of_leds)
            if heat[y]<100 then
            heat[y]=heat[y]+node.random(400,700)
            end
        end
        ]]
        
        for j=1, number_of_leds  do
            setPixelHeatColor(j, heat[j])
        end
        ws2812.write(buffer)
    end
    
    setup_i2c()
    setup_mode(0)
    animation_timer:alarm(70, tmr.ALARM_AUTO, function()
        local Rlenght, Llenght = get_audio()
        Fire(50,110, Rlenght)
    end)        

elseif mode==22 then

    local heat = {}
    for i=1, number_of_leds/2 do
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
    
    local last_Rlenght=0
    
    local function Fire(Cooling, Sparking, Rlenght, Llenght)
        local cooldown
        local MAX_CH=number_of_leds/2
        for i=1, MAX_CH do
            cooldown=node.random(0, ((Cooling*(10+heat[MAX_CH]/8+Rlenght/2))/number_of_leds)+2)
            if cooldown>heat[i] then
                heat[i]=0
            else
                heat[i]=heat[i]-cooldown
            end
        end
    
    
        for k=MAX_CH, 4, -1 do
            heat[k]=(heat[k-1]+heat[k-2]+heat[k-3])/3
        end
    
        if node.random(1, number_of_leds*2) < Rlenght then
            if heat[MAX_CH-10]<255 or Rlenght>MAX_CH-10 then
                local y=node.random(1, 4)
                heat[y]=heat[y]+node.random(160,255)
            end
        end
        last_Rleght=Rlenght
        
        for j=MAX_CH, number_of_leds-2  do
            setPixelHeatColor(j, heat[j-MAX_CH+1])
        end
        for j=MAX_CH-1, 1, -1  do
            setPixelHeatColor(j, heat[MAX_CH-j+1])
        end
        ws2812.write(buffer)
    end

    setup_i2c()
    setup_mode(0)
    animation_timer:alarm(60, tmr.ALARM_AUTO, function()
        local Rlenght, Llenght = get_audio()
        Fire(100,20, Rlenght, Llenght)
    end)
end

end
