#Include SetButton.ahk
#Include GuiResizer.ahk
#Requires Autohotkey v2
#SingleInstance Force
SetWinDelay(10)
;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

myGui := Gui()
myGui.opt("+Resize +MinSize250x150")
myGui.OnEvent("Size", GuiResizer)
ButtonOK := myGui.Add("Button", "", "&OK")

OkayAgain := myGui.Add("Button", "", "&OK")
ButtonOK.wp := 0.5
OkayAgain.wp := 0.5
StyleButton(ButtonOK, 0, "success")
StyleButton(OkayAgain, 0, "success")
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h420")

