# GuiResizer Addons

 - Colorful Buttons combined with GuiResizer
    - ButtonStyle.ahk
 - Convert standard GUIs to GuiREsizer format
    - convert2Resizer.ahk
 - Runtime Converter
    - AutoResizer.ahk


### Credits for CreateImageButton: 
https://www.autohotkey.com/boards/viewtopic.php?f=83&t=93339

### Credits for GuiResizer: 
https://www.autohotkey.com/boards/viewtopic.php?f=83&t=113921

![ezgif-4-758975f959](https://github.com/samfisherirl/GuiResizer-plus-CreateImageButton.ahk-for-v2/assets/98753696/b30eccaa-faa9-42a7-ae3a-ef345383c1b8)

Im finally trying out this whole gdpi thing @jNizM, using your bootstrap buttons.
I also use @FanaticGuru's GuiResizer and decided - might as well combine the two.

Here's a method that allows for the responsive design of GuiResizer.ahk while using CreaeteImageButton. I put it together in an hour, I'll clean up any excess variables or inefficiencies over the next day.
 

```ahk
;example 
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
```
