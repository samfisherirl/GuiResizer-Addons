#Include SetButtonStyle.ahk
#Include required_libs\GuiResizer.ahk
#Include required_libs\CreateImageButton.ahk
#Include required_libs\AHKpy.ahk
#Include required_libs\UseGDIP.ahk

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

OkayAgain := myGui.Add("Button", "x+10", "&OK")
ButtonOK.wp := 0.5
OkayAgain.xp := -0.45
OkayAgain.wp := 0.4
StyleButton(ButtonOK, 0, "success")
StyleButton(OkayAgain, 0, "critical-round")

Finished := myGui.Add("Button", "", "Finished")
GuiReSizer.FormatOpt(Finished, .1, .2, 0.8, 0.2)
Cancel := myGui.Add("Button", "", "Cancel")
GuiReSizer.FormatOpt(Cancel, .1, .5, 0.8, 0.2)

StyleButton(Finished, 0, "info-round")
StyleButton(Cancel, 0, "critical-round")

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h320")
SetWindowAttribute(myGUi)
SetWindowTheme(myGui)
