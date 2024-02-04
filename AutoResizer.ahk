#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn all, off
#Include <GuiResizer>

class Convert2Resizer extends GuiResizer
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
        guiObj.Opt("-DPIScale")
        guiObj.OnEvent("Size", GuiResizer)
        Convert2Resizer.hwnd := guiObj.hwnd, Convert2Resizer.path := IsSet(path) ? path : ""
        Convert2Resizer.timer := {Call: Convert2Resizer.wait4GuiShow}
        ;Convert2Resizer.f := ObjBindMethod(Convert2Resizer.wait4GuiShow, "Call")
        ;Convert2Resizer.F.timer.Call := ObjBindMethod(Convert2Resizer.wait4GuiShow, "Call")
        if !WinExist("ahk_id " guiObj.hwnd)
            SetTimer(Convert2Resizer.timer, 100)
        else
            IsSet(path) ? Convert2Resizer.getPos(guiObj, path) : Convert2Resizer.getPos(guiObj)
    }
    static wait4GuiShow(*)
    {
        while !WinExist("ahk_id " Convert2Resizer.hwnd)
            return
        g := GuiFromHwnd(Convert2Resizer.hwnd)
        g.GetPos(&x, &y, &w, &h)
        if (w = 0 || h = 0)
            return
        SetTimer(Convert2Resizer.timer, 0)
            
        Convert2Resizer.setPos(GuiFromHwnd(Convert2Resizer.hwnd), Convert2Resizer.path = ""
            ? Convert2Resizer.path : false)
    }
    static setPos(guiObj, path := "")
    {
        Sleep(50)
        guiObj.GetPos(&x, &y, &w, &h)
        Convert2Resizer.GuiW := w
        Convert2Resizer.GuiH := h
        Convert2Resizer.GuiX := x
        Convert2Resizer.GuiY := y
        ctrls := []
        replacementCtrls := []
        for hwnd, ctrl in guiObj
        {
            ControlGetPos(&x, &y, &w, &h, ctrl)
            if (w = 0 || h = 0)
                continue
            ;replacementCtrls.Push(Convert2Resizer.Mapify(ctrl, x, y, w, h, &ctrls))
            ctrl.XP := Round(Number(x / Convert2Resizer.GuiW), 3)
            ctrl.YP := Round(Number(y / Convert2Resizer.GuiH), 3)
            ctrl.WidthP := Round(Number(w / Convert2Resizer.GuiW), 3)
            ctrl.HeightP := Round(Number(h / Convert2Resizer.GuiH), 3)
            ;Toolbox_.FormatOpt(ctrl,ctrl.xp,ctrl.yp,ctrl.widthp,ctrl.heightp)
            try{
                ctrl.Redraw()
            }
        }
        guiObj.Opt("+Resize +MinSize250x150")
        guiObj.OnEvent("Size", GuiResizer)
        GuiResizer.Now(guiObj)
        if !Convert2Resizer.is__file__
            return
    }
    ; #########################################
    ; placeholder for converting to real GuiResize format perminately 
    ; #########################################

    ; static Mapify(ctrl, x, y, w, h, &ctrls)
    ; {
    ;     m := Map()
    ;     m["WP"] := Round(w / Convert2Resizer.GuiW, 2)
    ;     m["HP"] := Round(h / Convert2Resizer.GuiH, 2)
    ;     m["XP"] := Round(x / Convert2Resizer.GuiW, 2)
    ;     m["YP"] := Round(y / Convert2Resizer.GuiH, 2)
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
    ;     newScript := Convert2Resizer.GUify(replacementCtrls, contents)
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
