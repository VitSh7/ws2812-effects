-- define standart values
number_of_leds = 95;   -- set number of leds in strip
normal_brightness=150;  -- set normal brightness from 0 to 255
max_brightness=255;     -- set max brightness from 0 to 255
-- ---------------------------------------------------------
-- Wifi settings
static_ip=true; -- allows to use static ip; set it to false if you don't want to use static ip
ssid = 'SweetHome' -- name of the acces point
password = 'eltechsux'-- password
-- static ip parameters
ip_config = {
  ip = "192.168.0.120",
  netmask = "255.255.255.0",
  gateway = "192.168.0.1"
}
-- initial values
speed = 150;
color = 100;
saturation=255;
brightness = 100;
mode = 0;

channel_average=1;

mode_11_max_brightness=max_brightness;
