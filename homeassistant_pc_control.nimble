# Package

version       = "0.1.0"
author        = "jjv360"
description   = "Control PC via HomeAssistant remotely"
license       = "MIT"
srcDir        = "src"
bin           = @["homeassistant_pc_control"]


# Dependencies

requires "nim >= 2.0.4"
requires "nmqtt >= 1.0.6"
requires "https://github.com/jjv360/nim-traymenu.git#master"