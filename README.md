# GuiResizer Addons

 - Colorful Buttons combined with GuiResizer
    - ButtonStyle.ahk
 - Convert standard GUIs to GuiREsizer format
    - convert2Resizer.ahk
 - Runtime Converter
    - AutoResizer.ahk
 - Parent / Child GUIs built in
 - VSCode Tooltips
    


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

### Preamble

Originally I wrote a converter, as GuiResizer requires custom formatted Sizing. I have changed the primary goal and outcome, this class now takes standard guiControl.Opt("x5 y+5 w500 y500") at runtime and adjusts to the thousandth decimal. There are 3 other libs at the bottom made for use with GuiResizer

Caveats:
- It is better to use the converter below than the runtime converter
- Converter is made for use with Easy AutoGui, found here github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2
- this was written in a couple hours time, Ill be making adjustments here over the following days
- there will likely be errors for use-cases I didn't think of, I used easy autogui output code for test cases. viewtopic.php?f=83&t=116159 Please share any issues you come across
- right now it does not account for negative pos
- functions found here: https://github.com/samfisherirl/GuiResizer-Addons.
 
### AutoResizer  
```ahk
#Requires Autohotkey v2
;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2
#Include <AutoResizer>
myGui := Gui()
AutoResizer(myGui) ; only function call needed

ButtonOK := myGui.Add("Button", "x16 y304 w269 h98", "&OK")
CheckBox1 := myGui.Add("CheckBox", "x16 y27 w120 h23", "CheckBox")
ComboBox1 := myGui.Add("ComboBox", "x16 yp+50 w120", ["ComboBox"])
Edit1 := myGui.Add("Edit", "x16 yp+50 w120 h21")
myGui.Add("GroupBox", "x488 y24 w120 h80", "GroupBox")
myGui.Add("Link", "x232 y24 w120 h23", "<a href=`"https://autohotkey.com`">autohotkey.com</a>")
myGui.Add("ListBox", "x230 y77 w120 h154", ["ListBox"])
ButtonOK.OnEvent("Click", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h420")

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n"
	. "Active GUI element values include:`n"  
	. "ButtonOK => " ButtonOK.Text "`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}
```

AutoResizer.ahk
```ahk
#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn all, off
#Include <GuiResizer>

class AutoResizer extends GuiResizer
{
    static GuiW := 0
    static GuiH := 0
    static GuiX := 0
    static GuiY := 0
    static hwnd := false
    static path := ""
    static is__file__ := false
    static func := {}
    static timer := {}
     
    static Call(guiObj, path?)
    {
        if AutoResizer.hwnd != false || AutoResizer.hwnd != 0
            return
        guiObj.Opt("-DPIScale +Resize +MinSize250x150")
        
        guiObj.OnEvent("Size", GuiResizer)
        AutoResizer.hwnd := guiObj.hwnd, AutoResizer.path := IsSet(path) ? path : ""
        AutoResizer.timer := {Call: AutoResizer.wait4GuiShow}
        if !WinExist("ahk_id " guiObj.hwnd)
            SetTimer(AutoResizer.timer, 100)
        else
            IsSet(path) ? AutoResizer.setPos(guiObj, path) : AutoResizer.setPos(guiObj)
    }
    static wait4GuiShow(*)
    {
        while !WinExist("ahk_id " AutoResizer.hwnd)
            return
        g := GuiFromHwnd(AutoResizer.hwnd)
        g.GetPos(&x, &y, &w, &h)
        if (w = 0 || h = 0)
            return
        SetTimer(AutoResizer.timer, 0)
            
        AutoResizer.setPos(GuiFromHwnd(AutoResizer.hwnd), AutoResizer.path = ""
            ? AutoResizer.path : false)
    }
    static setPos(guiObj, path := "")
    {
        Sleep(50)
        guiObj.GetPos(&x, &y, &w, &h)
        AutoResizer.GuiW := w
        AutoResizer.GuiH := h
        AutoResizer.GuiX := x
        AutoResizer.GuiY := y
        ctrls := []
        replacementCtrls := []
        for hwnd, ctrl in guiObj
        {
            ControlGetPos(&x, &y, &w, &h, ctrl)
            if (w = 0 || h = 0)
                continue
            ;replacementCtrls.Push(AutoResizer.Mapify(ctrl, x, y, w, h, &ctrls))
            ctrl.XP := Round(Number(x / AutoResizer.GuiW), 3)
            ctrl.YP := Round(Number(y / AutoResizer.GuiH), 3)
            ctrl.WidthP := Round(Number(w / AutoResizer.GuiW), 3)
            ctrl.HeightP := Round(Number(h / AutoResizer.GuiH), 3)
            ;Toolbox_.FormatOpt(ctrl,ctrl.xp,ctrl.yp,ctrl.widthp,ctrl.heightp)
            try{
                ctrl.Redraw()
            }
        }
        guiObj.OnEvent("Size", GuiResizer)
        GuiResizer.Now(guiObj)
        if !AutoResizer.is__file__
            return
    }
    ; #########################################
    ; placeholder for converting to real GuiResize format perminately 
    ; #########################################

    ; static Mapify(ctrl, x, y, w, h, &ctrls)
    ; {
    ;     m := Map()
    ;     m["WP"] := Round(w / AutoResizer.GuiW, 2)
    ;     m["HP"] := Round(h / AutoResizer.GuiH, 2)
    ;     m["XP"] := Round(x / AutoResizer.GuiW, 2)
    ;     m["YP"] := Round(y / AutoResizer.GuiH, 2)
    ;     m['Text'] := ctrl.HasProp("Text") ? ctrl.text : false
    ;     m['Value'] := ctrl.HasProp("Value") ? ctrl.Value : false
    ;     m['Type'] := ctrl.HasProp("Type") ? ctrl.Type : false
    ;     for k, v in m
    ;     {
    ;         if (InStr(v, "0."))
    ;         {
    ;             temp := StrSplit(v, ".")
    ;             m[k] := (temp.Has(2)) ? "." temp[2] : v
    ;         }
    ;     }
    ;     return m
    ; }
    ; static writeToFile(path?)
    ; {
    ;     if path != ""
    ;         path := A_ScriptFullPath
    ;     contents := FileOpen(path, "r").Read()
    ;     newScript := AutoResizer.GUify(replacementCtrls, contents)
    ;     SplitPath(path, , &dir, , &name)
    ;     FileOpen(dir "\" name "_converted.ahk", "w").Write(newScript)
    ;     Run("notepad.exe `"" dir "\" name "_converted.ahk`"")
    ;     ExitApp()
    ; }
}

class Toolbox_ extends GuiResizer
{
    static FormatOpt(ctrl, xp?, yp?, wp?, hp?, anchor?) 
    {
        if IsSet(anchor)
            ctrl.A := anchor
        options := ""
        if IsSet(xp)
            options .= DoTheMath(xp, "xp")
        if IsSet(yp)
            options .= DoTheMath(yp, "yp")
        if IsSet(wp)
            options .= DoTheMath(wp, "wp")
        if IsSet(hp)
            options .= DoTheMath(hp, "hp")
        options := StrReplace(options, "0.", ".")
        GuiResizer.Opt(ctrl, options)
        doTheMath(val, str)
        {
            if val < 0
                val += 1
            return str Round(val, 2) " "
        }
    }
    static FO(ctrl, xp?, yp?, wp?, hp?, anchor?) => GuiReSizer.FormatOpt(ctrl, xp?, yp?, wp?, hp?, anchor?)
}

``` 
### Converter Gui

Convert standard guis to guiresizer 
```ahk
#Requires AutoHotkey v2.0
#SingleInstance Force  
#Warn all, off

class Convert2Resizer
{
    static GuiW := 0
    static GuiH := 0
    static GuiX := 0
    static GuiY := 0
    
    static Call(guiObj, path?) 
    {
        guiObj.Show()
        guiObj.GetPos(&x, &y, &w, &h)
        Convert2Resizer.GuiW := w
        Convert2Resizer.GuiH := h
        Convert2Resizer.GuiX := x
        Convert2Resizer.GuiY := y
        ctrls := []
        replacementCtrls := []
        for hwnd, ctrl in guiObj
        {
            replacementCtrls.Push(Convert2Resizer.Mapify(ctrl, &ctrls))
        }
        if !IsSet(path)
            path := A_ScriptFullPath
        contents := FileOpen(path, "r").Read()
        newScript := Convert2Resizer.GUify(replacementCtrls, contents)
        SplitPath(path, , &dir, , &name)
        FileOpen(dir "\" name "_converted.ahk", "w").Write(newScript)
        Run("notepad.exe `"" dir "\" name "_converted.ahk`"")
        exitapp()
    }
    static Mapify(ctrl, &ctrls)
    {
        m := Map()
        ctrl.GetPos(&ctrlX, &ctrlY, &ctrlW, &ctrlH)
        m["WP"] := Round(ctrlW / Convert2Resizer.GuiW, 2)
        m["HP"] := Round(ctrlH / Convert2Resizer.GuiH, 2)
        m["XP"] := Round(ctrlX / Convert2Resizer.GuiW, 2)
        m["YP"] := Round(ctrlY / Convert2Resizer.GuiH, 2)
        m['Text'] := ctrl.HasProp("Text") ? ctrl.text : false
        m['Value'] := ctrl.HasProp("Value") ? ctrl.Value : false
        m['Type'] := ctrl.HasProp("Type") ? ctrl.Type : false
        for k, v in m
        {
            if (InStr(v, "0."))
            {
                temp := StrSplit(v, ".")
                m[k] := (temp.Has(2)) ? "." temp[2] : v
            }
        }
        return m
    }
    static GUify(replacementCtrls, contents)
    {
        contents := StrReplace(contents, "``t", ""), contents := StrReplace(contents, "``r", "")
        splitLines := StrSplit(contents, "`n")

        storage := "myCtrls"
        guiname := "myGui"
        newScript := "#Requires Autohotkey v2`n#SingleInstance force`n"
            . "#Include <GuiReSizer>`n`n" storage " := {}`n"
            . guiname " := Gui(), " guiname ".Opt(`"+Resize +MinSize250x150`")`n" guiname ".OnEvent(`"Size`", GuiReSizer)`n"
        defaults := Map()
        defaults := ctrlDefault()
        for _map in replacementCtrls
        {
            line := (_map['Value'] != false && _map['Value'] != "") ? array_contains(splitLines,(_map['Value']))
                : (_map['Text'] != false && _map['Text'] != "") ? array_contains(splitLines, (_map['Text'])) : false
            if line
            {
                if InStr(splitLines[line], "Add(") && InStr(splitLines[line], ":=")
                    _map['Name'] := Trim(StrSplit(splitLines[line], " := ")[1]) 
            }
            else {
                _map['Name'] := Trim(_map["Type"]) A_Index
            }
            if !_map.Has('Name')
                _map['Name'] := 'ctrl' A_Index
            ; Start building the AHK script by creating GUI controls based on the information in _map
            newScript .= storage "." _map['Name'] " := " guiname ".Add(`"" _map['Type'] "`", `"`","
            ; Depending on the control 'Type', the generated script will configure it differently
            newScript .= (!InStr(_map['Type'], "List"))
                ? (!InStr(_map['Type'], "ComboBox"))
                    ? " `"`")`n" : "[`"`"])`n"
                : "[`"`"])`n"
                
            ; If there are default settings for the type of GUI control in _map,
            ; check if there's a function associated and it's not false, then add that configuration to the script
            t := _map['Type']
            d := defaults.Has(t) ? defaults[t] : 
            defaults[_map['Type']]
            newScript .= defaults.Has(_map['Type'])
                ? (_map[defaults[_map['Type']]['function']] != false)
                    ? storage "." _map['Name'] "." defaults[_map['Type']]['function'] " := `""
                        . _map[defaults[_map['Type']]['function']] "`"`n"
                        : ""
                : ""

            newScript .= "pushToResizer(" storage "."
                . _map['Name'] ", " _map['XP'] ", " _map['YP'] ", " _map['WP'] ", " _map['HP'] ")`n"
        }
        return newScript . Convert2Resizer.compressionFunc() . "`n" guiname ".Show()`n"
    }
    static  compressionFunc() {
        funcG := ""
        
        return funcG .= "`n`npushToResizer(ctrl, xp, yp, wp, hp)`n{`n"
            . "`tctrl.xp := xp `n"
            . "`tctrl.yp := yp `n"
            . "`tctrl.wp := wp `n"
            . "`tctrl.hp := hp `n}`n"
    }
}

array_contains(arr, search, case_sensitive := 0)
{
    for index, value in arr {
        if !IsSet(value)
            continue
        else if InStr(value, search, CaseSense := case_sensitive)
            return index
    }
    return 0
}

ctrlDefault()
{
    return m := Map("Button", map("ctrl", "Button", "event", "Click", "function", "Text"),
        "DropDownList", map("ctrl", "DropDownList", "event", "Change", "function", "Text"),
        "Edit", map("ctrl", "Edit", "event", "Change", "function", "Value"),
        "DateTime", map("ctrl", "DateTime", "event", "Change", "function", "Value"),
        "MonthCal", map("ctrl", "MonthCal", "event", "Change", "function", "Value"),
        "Radio", map("ctrl", "Radio", "event", "Click", "function", "Value"),
        "CheckBox", map("ctrl", "CheckBox", "event", "Click", "function", "Value"),
        "GroupBox", map("ctrl", "CheckBox", "event", "Click", "function", "Text"),
        "ComboBox", map("ctrl", "ComboBox", "event", "Change", "function", "Text"),
        "ListView", map("ctrl", "ListView", "event", "Click", "function", "GetNext"),
        "ListBox", Map("ctrl", "ListBox", "event", "Click", "function", "Value"))
}

SplitPath(A_ScriptFullPath, &fn)
if InStr(fn, "ert2Re")
    myGui := Constructor_()

Constructor_() {
    myGui := Gui()
    ButtonSelectGUIScript := myGui.Add("Button", "x24 y64 w174 h39", "Select GUI Script")
    Edit1 := myGui.Add("Edit", "x24 y8 w432 h38")
    ButtonConvert := myGui.Add("Button", "x208 y64 w154 h37", "Convert")
    ButtonSelectGUIScript.OnEvent("Click", FS)
    ButtonConvert.OnEvent("Click", Convert)
    myGui.OnEvent('Close', (*) => ExitApp())
    myGui.Title := "Window"
    myGui.Show("w501 h122")
    
    FS(*)
    {
        global F
        F := FileSelect(, "C:\", "Select script for conversion")
        if F != ""
            if !FileExist(F)
                F := false
            else 
                Edit1.Value := F
            
    }
    Convert(*)
    {
        global F
        if !F
        {
            Msgbox "File not Found"
            return
        }
        contents := FileOpen(F, "r").Read()
        Lib := FileOpen(A_ScriptFullPath, "r").Read()
        script := ""
        start := false
        Loop parse, contents, "`n" "`r" 
        {
            if !start
                if InStr(A_LoopField, "Gui(")
                {
                    start := true
                    if InStr(A_LoopField, ":=")
                        guiName := Trim(StrSplit(A_LoopField, ":=")[1]) 
                } else 
                    continue
            if InStr(A_LoopField, ".Add") && InStr(A_LoopField, guiName)
            {
                script .= Trim(A_LoopField) "`n"
                ; e_ := ctrlDefault().__Enum(2)
                ; while e_(&k)
                ;     if InStr(A_LoopField, k)  
            }
            else if InStr(A_LoopField, "Show(")
            {
                tmp := StrSplit(Trim(A_LoopField), "Show(")[2]
                tmp := StrSplit(tmp, ")")[1]
                regexWidth := "w(\d+)"
                regexHeight := "h(\d+)"

                width := ""
                height := ""
                ; Perform the regex search for width
                if RegExMatch(tmp, regexWidth, &widthMatch) && width = "" {
                    width := widthMatch[0] ; The number after 'w'
                }
                ; Perform the regex search for height
                if RegExMatch(tmp, regexHeight, &heightMatch) && height = "" {
                    height := heightMatch[0] ; The number after 'h'
                }
                break
            }
        }
        if !IsSet(guiName)
            return
        
        SplitPath(F, , &D)
        tempFileContents := Lib "`n" guiName " := Gui()`n" script "`n" guiName . ".Show(`"" 
        tempFileContents .= (width != "") ? width : (height != "") ? height : "'w' A_ScreenWidth*.8 ' h' A_ScreenHeight"
        tempFileContents .= "`")" "`nConvert2Resizer(" guiName ", `"" F "`")`n"
        FileOpen(D "\tempFile.ahk", "w").Write(tempFileContents)
        RunWait(A_AhkPath " `"" D "\tempFile.ahk" "`"", , ,&PID)
        Sleep(100)
        x := 0
        While ProcessExist(PID)
        {
            x+=1
            Sleep 100
            if x > 500
                break
        }
        try{
            FileDelete(A_MyDocuments "\tempFile.ahk")
        }
        ExitApp()
    }

    return myGui
}
BetweenStr(text, startDelim, endDelim?) {
    if !IsSet(endDelim)
        endDelim := startDelim
    results := []  ; Initialize an empty array to store the results
    startIndex := 1 ; Start search from the beginning of the string
    while (startIndex := InStr(text, startDelim, true, startIndex + StrLen(startDelim)))
    {
        ; Find the matching end delimiter from the found start delimiter
        endIndex := InStr(text, endDelim, true, startIndex + StrLen(startDelim))
        if (!endIndex)  ; If no ending delimiter is found, break the loop
            break
        extracted := SubStr(text, startIndex + StrLen(startDelim), endIndex - (startIndex + StrLen(startDelim)))
        results.Push(extracted)
        startIndex := endIndex
    }
    return results
}

```
____________________________
### Lib#2

Library for using CreateImageButton with GuiResizer  
```ahk
DetectHiddenWindows("off")

/*
    Class: StyleButton

    Description:
    This class defines a set of functionalities for configuring and styling buttons. Combining GuiResizer's
    Responsive design and accounting for size changes while applying styles to buttons.

    Requires:
    1. CreateImageButton.ahk
    2. UseGDIP.ahk
    3. GuiResizer.ahk

    Example:
    ButtonOK := myGui.Add("Button", "", "&OK")
    SetButton(ButtonOK, 0, "success") ; success being a map key in IBStyles, any style map should do. 

    Class Functions:
    1. Call(ctrl, offset, style)
        ; see CreateImageButton.ahk for more information
        This function handles the button call and applies styling based on parameters. It gets the position of the button
        and pushes the set function with certain parameters to funcArray based on the button's width and height.

    2. Set(ctrl, style, offset, isEvent?)
       This function sets the button's configuration. It gets the button's position, sets the control size in a map,
       and styles the button by calling the myStyleMap function.

    3. enumButtons(*)
       This function enumerates through the buttons, resets the error flag, and runs each function in the funcArray.

    Nested Functions:
    1. myStyleMap(ctrl, offset, style)
       This defined function styles the button by calling the CreateImageButton function with certain parameters.
*/
class StyleButton
{
    static err := 0
    static buttons := []
    
    static Call(ctrl, offset, style)
    {
        ctrl.GetPos(, , &w, &h)
        StyleButton.buttons.Push({ctrl: ctrl, offset: offset, style: style, w: w, h: h})
        ctrl.Gui.OnEvent("Size", StyleButton.enumButtons)
        if w != 0 && h != 0 && WinActive(ctrl.Gui.hwnd)
        {
            StyleButton.Set(StyleButton.buttons[StyleButton.buttons.Length], offset, style)
        }
    }

    static Set(btn, offset, style)
    {
        btn.ctrl.Gui.GetPos(, , &w, &h)

        if h = 0 or w = 0 or !WinActive(btn.ctrl.Gui.hwnd)
        {
            return
        }
        btn.ctrl.GetPos(, , &w, &h)
        if btn.w < w or btn.h < h
        {
            btn.w := w
            btn.h := h
            btn.ctrl.Opt("w" w " h" h)
        }
        
        UseGDIP()
        if btn.ctrl.gui
            myStyleMap(btn.ctrl, offset, style)
    }

    static enumButtons(*)
    {
        for btn in StyleButton.buttons
        {
            StyleButton.set(btn, btn.offset, btn.style)
        }
    }
}

myStyleMap(ctrl, offset, style) => CreateImageButton(ctrl, offset, IBStyles[style]*)


IBStyles := Map()
; credit to jNizM
; https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=75  

IBStyles["info"] := [[0x80C6E9F4, , , 0, 0x8046B8DA, 1], [0x8086D0E7, , , 0, 0x8046B8DA, 1], [0x8046B8DA, , , 0, 0x8046B8DA, 1], [0xFFF0F0F0, , , 0, 0x8046B8DA, 1]]
IBStyles["success"] := [[0x80C6E6C6, , , 0, 0x805CB85C, 1], [0x8091CF91, , , 0, 0x805CB85C, 1], [0x805CB85C, , , 0, 0x805CB85C, 1], [0xFFF0F0F0, , , 0, 0x805CB85C, 1]]
IBStyles["warning"] := [[0x80FCEFDC, , , 0, 0x80F0AD4E, 1], [0x80F6CE95, , , 0, 0x80F0AD4E, 1], [0x80F0AD4E, , , 0, 0x80F0AD4E, 1], [0xFFF0F0F0, , , 0, 0x80F0AD4E, 1]]
IBStyles["critical"] := [[0x80F0B9B8, , , 0, 0x80D43F3A, 1], [0x80E27C79, , , 0, 0x80D43F3A, 1], [0x80D43F3A, , , 0, 0x80D43F3A, 1], [0xFFF0F0F0, , , 0, 0x80D43F3A, 1]]

IBStyles["info-outline"] := [[0xFFF0F0F0, , , 0, 0x8046B8DA, 1], [0x80C6E9F4, , , 0, 0x8046B8DA, 1], [0x8086D0E7, , , 0, 0x8046B8DA, 1], [0xFFF0F0F0, , , 0, 0x8046B8DA, 1]]
IBStyles["success-outline"] := [[0xFFF0F0F0, , , 0, 0x805CB85C, 1], [0x80C6E6C6, , , 0, 0x805CB85C, 1], [0x8091CF91, , , 0, 0x805CB85C, 1], [0xFFF0F0F0, , , 0, 0x805CB85C, 1]]
IBStyles["warning-outline"] := [[0xFFF0F0F0, , , 0, 0x80F0AD4E, 1], [0x80FCEFDC, , , 0, 0x80F0AD4E, 1], [0x80F6CE95, , , 0, 0x80F0AD4E, 1], [0xFFF0F0F0, , , 0, 0x80F0AD4E, 1]]
IBStyles["critical-outline"] := [[0xFFF0F0F0, , , 0, 0x80D43F3A, 1], [0x80F0B9B8, , , 0, 0x80D43F3A, 1], [0x80E27C79, , , 0, 0x80D43F3A, 1], [0xFFF0F0F0, , , 0, 0x80D43F3A, 1]]

IBStyles["info-round"] := [[0x80C6E9F4, , , 8, 0x8046B8DA, 1], [0x8086D0E7, , , 8, 0x8046B8DA, 1], [0x8046B8DA, , , 8, 0x8046B8DA, 1], [0xFFF0F0F0, , , 8, 0x8046B8DA, 1]]
IBStyles["success-round"] := [[0x80C6E6C6, , , 8, 0x805CB85C, 1], [0x8091CF91, , , 8, 0x805CB85C, 1], [0x805CB85C, , , 8, 0x805CB85C, 1], [0xFFF0F0F0, , , 8, 0x805CB85C, 1]]
IBStyles["warning-round"] := [[0x80FCEFDC, , , 8, 0x80F0AD4E, 1], [0x80F6CE95, , , 8, 0x80F0AD4E, 1], [0x80F0AD4E, , , 8, 0x80F0AD4E, 1], [0xFFF0F0F0, , , 8, 0x80F0AD4E, 1]]
IBStyles["critical-round"] := [[0x80F0B9B8, , , 8, 0x80D43F3A, 1], [0x80E27C79, , , 8, 0x80D43F3A, 1], [0x80D43F3A, , , 8, 0x80D43F3A, 1], [0xFFF0F0F0, , , 8, 0x80D43F3A, 1]]

IBStyles["info-outline-round"] := [[0xFFF0F0F0, , , 8, 0x8046B8DA, 1], [0x80C6E9F4, , , 8, 0x8046B8DA, 1], [0x8086D0E7, , , 8, 0x8046B8DA, 1], [0xFFF0F0F0, , , 8, 0x8046B8DA, 1]]
IBStyles["success-outline-round"] := [[0xFFF0F0F0, , , 8, 0x805CB85C, 1], [0x80C6E6C6, , , 8, 0x805CB85C, 1], [0x8091CF91, , , 8, 0x805CB85C, 1], [0xFFF0F0F0, , , 8, 0x805CB85C, 1]]
IBStyles["warning-outline-round"] := [[0xFFF0F0F0, , , 8, 0x80F0AD4E, 1], [0x80FCEFDC, , , 8, 0x80F0AD4E, 1], [0x80F6CE95, , , 8, 0x80F0AD4E, 1], [0xFFF0F0F0, , , 8, 0x80F0AD4E, 1]]
IBStyles["critical-outline-round"] := [[0xFFF0F0F0, , , 8, 0x80D43F3A, 1], [0x80F0B9B8, , , 8, 0x80D43F3A, 1], [0x80E27C79, , , 8, 0x80D43F3A, 1], [0xFFF0F0F0, , , 8, 0x80D43F3A, 1]]

#Include CreateImageButton.ahk
#Include UseGDIP.ahk
```
### Example for Lib#2 
```ahk
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

OkayAgain := myGui.Add("Button", "x+10", "&OK")
ButtonOK.wp := 0.5
OkayAgain.xp := -0.45
OkayAgain.wp := 0.4
StyleButton(ButtonOK, 0, "success")
StyleButton(OkayAgain, 0, "critical-round")

; Finished := myGui.Add("Button", "", "Finished")
; my custom method for GuiResizer formatting
; GuiReSizer.FormatOpt(Finished, .1, .2, 0.8, 0.2)
; Cancel := myGui.Add("Button", "", "Cancel")
; my custom method for GuiResizer formatting
; GuiReSizer.FormatOpt(Cancel, .1, .5, 0.8, 0.2)

StyleButton(Finished, 0, "info-round")
StyleButton(Cancel, 0, "critical-round")

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"
myGui.Show("w620 h320")
``` 
### Lib #3 - Toolbox

GuiResizer (by @FanaticGuru) doesn't mesh well with parent child guis. This provides a simple toggle visibility for script.
Second feature, autoformat standard numeric params for GuiResizer.Opt() which doesnt like 0. before values
```ahk

        ; This function defines a property called "ToggleVisible" on the prototype of the Object class.
        ; When called, it hides or shows all GUI controls from the given object.
        ; The function returns 1 if any controls were hidden or shown, otherwise it returns 0.
        Object.Prototype.DefineProp("ToggleVisible", { Call: HideAll_guiCtrls_fromObj })

        ; This function hides or shows all GUI controls from the given object.
        ; It iterates over the properties of the object and checks if they are set and if they are objects with a "Visible" property.
        ; If a control is found, its "Visible" property is toggled and the status is set to 1.
        ; The function returns the status indicating if any controls were hidden or shown.

        ; Example:
        ; myGui.ParentGui := {}
        ; myGui.ParentGui.Buttons := {}
        ; myGui.ParentGui.Buttons.Next := myGui.Add("Button", , "Hello World")
        ; ...additional buttons may be added to group
        ; myGui.ParentGui.ToggleVisible()
        ;
        HideAll_guiCtrls_fromObj(selfObj)
        {
            status := 0
            for index, value in selfObj.OwnProps() {
                if !IsSet(value)
                    continue
                else if IsObject(value)
                {
                    if not InStr(value.__Class, "Gui.")
                        status := HideAll_guiCtrls_fromObj(value)
                    else if value.HasProp("Visible")
                    {
                        value.Visible := !value.Visible
                        status := 1
                    }
                }
            }
            return status
        }
        
        
        ;@@@@@@@@@@@ add the below function inside of guiresizer.ahk before the class ends @@@@@@@@@@@@@@@@@@@
        
            ; ....the rest of GuiResizer above
    
    /**
     * Formats and sets the positioning and sizing options for a control in the GuiReSizer class.
     * 
     * @memberof GuiReSizer
     * @static
     * @function FormatOpt
     * 
     * @param {Object} ctrl - The control object to apply the formatting to.
     * @param {number} [xp] - X positional offset as a percentage of Gui width.
     * @param {number} [yp] - Y positional offset as a percentage of Gui height.
     * @param {number} [wp] - Width of control as a percentage of Gui width.
     * @param {number} [hp] - Height of control as a percentage of Gui height.
     * 
     * @example
     *  Usage:
     * GuiReSizer.FormatOpt(myControlObj, xp := .10, yp := .20, wp := .30, hp := .40, anchor?);
     * 
     *  This will set the X position to 10% of the Gui width,
     *  Y position to 20% of the Gui height,
     *  Width to 30% of the Gui width,
     *  Height to 40% of the Gui height.
     */
    static FormatOpt(ctrl, xp?, yp?, wp?, hp?, anchor?) 
    {
        if IsSet(anchor)
            ctrl.A := anchor
        options := ""
        if IsSet(xp)
            options .= GuiResizer.doTheMath(xp, "xp")
        if IsSet(yp)
            options .= GuiResizer.doTheMath(yp, "yp")
        if IsSet(wp)
            options .= GuiResizer.doTheMath(wp, "wp")
        if IsSet(hp)
            options .= GuiResizer.doTheMath(hp, "hp")
        options := StrReplace(options, "0.", ".")
        GuiResizer.Opt(ctrl, options)
    }
    
    static doTheMath(val, str) {
        if val < 0
            val += 1
        return str Round(val, 2) " "
    }
    ; easily copy an existing controls format to another control, for parent/child gui usage 
    static Duplicate(ctrl, ctrlToCopy) => GuiResizer.FormatOpt(ctrl, ctrlToCopy.XP, ctrlToCopy.YP, ctrlToCopy.WidthP, ctrlToCopy.HeightP)
    
    ; ....the end of GuiResizer
}
```
### Lib #4 tooltip docs for vscode
```ahk

/**
 * @class GuiReSizer
 * @author Fanatic Guru
 * @version 2023-03-13
 * @description Class to Handle the Resizing of Gui and Move and Resize Controls.
 *   Update 2023-02-15: Add more Min Max properties and renamed some Properties.
 *   Update 2023-03-13: Major rewrite. Converted to Class to allow for Methods.
 * @requires AutoHotkey v2.0.2+
 *
 * @param {Object} GuiObj - Gui Object.
 * @param {Number} WindowMinMax - Window status. 0 = neither minimized nor maximized, 1 = maximized, -1 = minimized.
 * @param {Number} Width - Width of GuiObj.
 * @param {Number} Height - Height of GuiObj.

```
