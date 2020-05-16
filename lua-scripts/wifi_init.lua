do
--wifi.sta.clearconfig() -- очистка от барахла
wifi.setmode(wifi.STATION) -- установка режима
local scfg={} -- таблица установок ржима
scfg.auto = true -- входить и поддерживать сеть автоматически
scfg.save = true -- запомнить эти установки во флэше
scfg.ssid = 'SweetHome' -- название сетки
scfg.pwd = 'eltechsux'-- пароль сетки
wifi.sta.config(scfg) -- конфигурируем сеть
local ip_config = {
  ip = "192.168.0.120",
  netmask = "255.255.255.0",
  gateway = "192.168.0.1"
}
wifi.sta.setip(ip_config) -- set static ip
wifi.sta.connect() -- старт соединения
end
