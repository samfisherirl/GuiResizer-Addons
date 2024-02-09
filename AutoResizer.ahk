#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn all, off
#Include <GuiResizer>

;Convert Guis with standard format to GuiResizer without code change 
; AutoResizer(myGui)

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
    static scaleObj := false
    
    static Call(guiObj, scale := "", path?)
    {
        if AutoResizer.hwnd != false || AutoResizer.hwnd != 0
            return
        guiObj.Opt("-DPIScale +Resize +MinSize450x350")
        if scale != ""
        {
            AutoResizer.scaleObj := AutoResizer.getScale(scale)
            if AutoResizer.scaleObj = false
                MsgBox "failed to scale gui"
        }
        guiObj.OnEvent("Size", GuiResizer)
        AutoResizer.hwnd := guiObj.hwnd, AutoResizer.path := IsSet(path) ? path : ""
        AutoResizer.timer := { Call: AutoResizer.wait4GuiShow }
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
        setPosFunc := AutoResizer.setPos.Bind(GuiFromHwnd(AutoResizer.hwnd), AutoResizer.path = ""
            ? AutoResizer.path : false)
        SetTimer(setPosFunc, -100)
    }
    static setPos(guiObj, path := "")
    {
        guiObj := !IsObject(guiObj) ? GuiFromHwnd(AutoResizer.hwnd) : guiObj
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
            ctrl.XP := Round(Number(x / AutoResizer.GuiW), 4)
            ctrl.YP := Round(Number(y / AutoResizer.GuiH), 4)
            ctrl.WidthP := Round(Number(w / AutoResizer.GuiW), 4)
            ctrl.HeightP := Round(Number(h / AutoResizer.GuiH), 4)
            ;Toolbox_.FormatOpt(ctrl,ctrl.xp,ctrl.yp,ctrl.widthp,ctrl.heightp)
            try {
                ctrl.Redraw()
            }
        }
        GuiFromHwnd(SausageGUI.hwnd).GetPos(, , &w, &h)
        GuiResizer.Now(guiObj)
        obj := AutoResizer.resizeWindow
        if AutoResizer.scaleObj
            Settimer({Call:AutoResizer.resizeWindow}, -200)
            ,Settimer({ Call: AutoResizer.refreshUI }, -220)
        if !AutoResizer.is__file__
            return
    }
    static resizeWindow()
    {
        GuiFromHwnd(SausageGUI.hwnd).GetPos(,,&w, &h)
        WinMove(, , w * Number(AutoResizer.scaleObj.w), h * Number(AutoResizer.scaleObj.h), 'ahk_id ' SausageGUI.hwnd)
    }
    static refreshUI()
    {
        for _, ctrl in GuiFromHwnd(AutoResizer.hwnd)
        {
            ctrl.redraw()
        }
    }
    static getScale(stringIn)
    {
        ; Define a regular expression pattern to match "w" followed by numbers (including decimal point)
        w_pattern := "w(\d*\.?\d+)"

        ; Define a regular expression pattern to match "h" followed by numbers (including decimal point)
        h_pattern := "h(\d*\.?\d+)"
        try {
            return ExtractNumbers(stringIn)
        } catch as e {
            Msgbox e.message
            return false
        }
        ; Function to extract numbers attached to "w" and "h"
        ExtractNumbers(input_string) {
            RegExMatch(input_string, "w\.(\d+)\s+h\.(\d+)", &match)

            if IsObject(match) {
                w_number := match[1]
                h_number := match[2]
            }

            scaleObj := {w: "0." w_number, h: "0." h_number}
            return scaleObj
        }
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


FormatOpt(ctrl, xp?, yp?, wp?, hp?, anchor?) {
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
RelativeFormat(ctrl, ctrlToCopy, x?, y?, w?, h?)
{
    if ctrlToCopy = GuiReSizer.lastCtrlObj
        GuiResizer.FormatOpt(ctrl,
            IsSet(x) ? ctrlToCopy.XP + x : ctrlToCopy.XP,
            IsSet(y) ? ctrlToCopy.YP + y : ctrlToCopy.YP,
                IsSet(w) ? ctrlToCopy.WidthP + w : ctrlToCopy.WidthP,
                IsSet(h) ? ctrlToCopy.HeightP + h : ctrlToCopy.HeightP)
}
; easily copy an existing controls format to another control, for parent/child gui usage
; make changes where wanted
Duplicate(ctrl, ctrlToCopy, x?, y?, w?, h?)
{
    GuiResizer.FormatOpt(ctrl, ctrlToCopy.XP, ctrlToCopy.YP, ctrlToCopy.WidthP, ctrlToCopy.HeightP)
}
FO(ctrl, xp?, yp?, wp?, hp?, anchor?) => GuiReSizer.FormatOpt(ctrl, xp?, yp?, wp?, hp?, anchor?)
