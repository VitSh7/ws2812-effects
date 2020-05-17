# ws2812-Effects
This project implements great static and music effect at LED strip on chip ws2812b. There is used ESP8266 (Wemos D1 board) on NodeMCU as the main chip. Atmega328p (Arduino Nano V3) handles with audio processing and send data to ESP via I2C. All effects are controlled via webserver deployed on the ESP.

# How To Use It
If you are dev and want to implement something new or change something, go ahead and feel free to contact me. Any suggestions for improving the project are welcome. If you want just to repeat it you can find instruction below.

# Project Structure
There are two folders, one is "Atmega328p code" with Atmel Studio 7 project files and the other is "lua-scripts" with lua scripts and LFS image for ESP8266. In the main folder there is "server.html" file, which is the html page for the project.

# Step-by-Step Instruction
1. Download all files.
2. First you need to flash your ESP board with new firmware. You can build firmware [here](https://nodemcu-build.com) or use file "ESP_firmware" in main directory. If you have decided build it yourself you need to add at least these modules:
  - bit
  - color utils
  - file
  - GPIO
  - net
  - nodemcu-build
  - timer
  - UART
  - WIFI
  - WS2812
After you have got the firmware it's time to flash it to the chip. I recommend to use NodeMCU-PyFlasher, you can download runnable exe file from [here](https://github.com/marcelstoer/nodemcu-pyflasher/releases) or build it [yourself](https://github.com/marcelstoer/nodemcu-pyflasher).
3. Now you should change number of leds matching your strip and setup wifi connection. Open file settings.lua with ESPlorer or any editor you use and set appropriate settings. You need to configure "number_of_leds" matching your led strip and wifi parameters, such as name and password. You can also configure wether you want or not to use static ip by setting "static_ip" to true or false. ip, netmask and gateway are configured in the field "ip_config". I recommend to use static ip, because by each reboot of the ESP ip could change and it might be some problems with finding your device in local network. By the way after reboot when device is connected to net it sends ip in terminal, so you can see it, if your computer is connected to esp at that moment.
4. Using avrdude or any other tool that could flash hex files to avr chips flash the hex from "Atmega328p code/Debug" to Arduino Nano.
5. Here is the connection scheme, connect and solder all components as shown here.
6. Turn on the power and input in browser ip of your device, here what the appeared page should look like.
![Opera](https://github.com/Vitve4/ws2812-effects/images/Opera.png)
![Opera-mobile](https://github.com/Vitve4/ws2812-effects/images/Opera-mobile.png)
