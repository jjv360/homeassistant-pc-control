import std/asyncdispatch
import std/os
import std/parsecfg
import std/strutils
import std/streams
import traymenu
import nmqtt

# Load tray icon data
const trayIconData = staticRead("home-button.png")

# Create a tray icon
let tray = TrayMenu.init()
tray.tooltip = "HomeAssistant Control"
tray.loadIconFromData(trayIconData)
tray.show()

# Add a menu item
tray.contextMenu.add(TrayMenuItem(title: "Exit", onClick: proc() = quit(0)))

# Configuration vars
var mqttHost = "homeassistant.local"
var mqttPort = 1883
var mqttUser = "mqtt"
var mqttPass = ""

# Load configuration from user folder
var configFilePath = getHomeDir() / ".homeassistant" / "pc-control.ini"
var configFile = newFileStream(configFilePath, fmRead)
if configFile == nil: raiseAssert("Error: Cannot open config file: " & configFilePath)
var p: CfgParser
open(p, configFile, configFilePath)
while true:
    var e = next(p)
    if e.kind == cfgKeyValuePair and e.key == "host": mqttHost = e.value
    if e.kind == cfgKeyValuePair and e.key == "port": mqttPort = parseInt(e.value)
    if e.kind == cfgKeyValuePair and e.key == "user": mqttUser = e.value
    if e.kind == cfgKeyValuePair and e.key == "pass": mqttPass = e.value
    if e.kind == cfgEof: break
close(p)

# Create MQTT client
let ctx = newMqttCtx("nmqttClient")
ctx.set_host(mqttHost, mqttPort)
ctx.set_auth(mqttUser, mqttPass)
ctx.set_ping_interval(30)

# Called when an MQTT message arrives
proc on_data(topic: string, message: string) =
    
    # Check what to do
    if message == "screen off":

        # Turn off the PC screen
        var cmd = "powershell (Add-Type '[DllImport(\\\"user32.dll\\\")]public static extern int PostMessage(int h,int m,int w,int l);' -Name a -Pas)::PostMessage(-1,0x0112,0xF170,2)"
        discard execShellCmd(cmd)

        # Done
        echo "Screen off"


# Subscribe to channel
proc mqttSub() {.async.} =
    await ctx.start()
    await ctx.subscribe("global/command", 0, on_data)
asyncCheck mqttSub()

# Ensure asyncdispatch is running
drain(int.high)