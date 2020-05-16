do

-- Close old Server
if sv then
 sv:close()
end
--Create HTTP Server
sv=net.createServer(net.TCP)

function receiver(sck, data)
    --print(data)
    --these booleans indicate whether next string is new mode, speed, color, saturation or brightness
    local modeChange=false 
    local speedChange=false 
    local colorChange=false
    local saturationChange=false
    local brightnessChange=false 

    local sendPage=false -- if sendPage == true then we should return html page as answer

    for line in data:gmatch("(.-)\n") do -- for each line
        local t = line:gsub("\r","") -- remove from string \r symbol
        if t == "GET / HTTP/1.1" then sendPage=true break -- if it - "get" request of html page then get out of loop
        end
        -- if any of booleans==true convert string to number and assign to appropriate variable
        if modeChange==true then 
            mode = tonumber(t)
            if mode>15 then
                dofile("color_music.lua") 
            else
                dofile("led_work.lua")
            end
            modeChange=false
        end
        if speedChange==true then 
            speed = tonumber(t)
            if mode>15 then
                dofile("color_music.lua") 
            else
                dofile("led_work.lua")
            end
            speedChange=false
        end
        if brightnessChange==true then 
            brightness = tonumber(t)
            if mode>15 then
                dofile("color_music.lua") 
            else
                dofile("led_work.lua")
            end
            brightnessChange=false
        end
        if saturationChange==true then 
            saturation = tonumber(t)
            if mode>15 then
                dofile("color_music.lua") 
            else
                dofile("led_work.lua")
            end
            saturationChange=false
        end
        if colorChange==true then 
            color = tonumber(t)
            if mode>15 then
                dofile("color_music.lua") 
            else
                dofile("led_work.lua")
            end
            colorChange=false
        end
        -- if t is equal to any of these lines, then the next line is the corresponding variable
        if t=="mode" then modeChange=true end
        if t=="speed" then speedChange=true end
        if t=="brightness" then brightnessChange=true end
        if t=="color" then colorChange=true end
        if t=="saturation" then saturationChange=true end
    end

    if sendPage==true then -- return html page as answer
        sendPage=false
        fd = file.open("server.html", "r") -- open page file, read-only mode
        if fd then -- if file is opened then do magic with sending file in parts
            local function send(localSocket) 
            local response = fd:read(512)
            if response then
                localSocket:send(response)
            else
                if fd then
                    fd:close()
                end
                localSocket:close()
            end
        end
        sck:on("sent", send)
        send(sck)
      else
          localSocket:close()
      end
   else -- return OK as answer
     sck:send("HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nConnection: keep-alive\r\nContent-Type: text/html\r\nContent-Length: 2\r\n\r\nOK\r\n")
   end
end

if sv then -- if server is existed then listen
  sv:listen(80, function(conn)
    conn:on("receive", receiver)
  end)
end

end
