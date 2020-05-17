do
--wifi.sta.clearconfig() -- очистка от барахла
wifi.setmode(wifi.STATION) -- установка режима
local scfg={} -- таблица установок ржима
scfg.auto = true -- входить и поддерживать сеть автоматически
scfg.save = true -- запомнить эти установки во флэше
scfg.ssid = ssid -- название сетки
scfg.pwd = password-- пароль сетки
wifi.sta.config(scfg) -- конфигурируем сеть
wifi.sta.setip(ip_config) -- set static ip
wifi.sta.connect() -- старт соединения
end
