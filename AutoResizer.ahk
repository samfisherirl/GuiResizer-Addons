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
        guiObj.Opt("-DPIScale +Resize +MinSize450x350")
        
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