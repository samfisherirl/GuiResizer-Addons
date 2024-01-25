#Requires AutoHotkey v2.0
#SingleInstance Force 
 

class Convert2Resizer
{
    static GuiW := 0
    static GuiH := 0
    static GuiX := 0
    static GuiY := 0
    
    static Call(guiObj, path?) {
        Sleep(10)
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
            . guiname " := Gui(), " guiname ".Opt(`" + Resize + MinSize250x150 `")`n" guiname ".OnEvent(`"Size`", GuiReSizer)`n"
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
            } else {
                _map['Name'] := Trim(_map["Type"]) A_Index
            }
            newScript .= storage "." _map['Name'] " := " guiname ".Add(`"" _map['Type'] "`", `"`"," 
            newScript .= (!InStr(_map['Type'], "List")) ? !InStr(_map['Type'], "ComboBox") ?  " `"`")`n" : "[`"`"])`n" : "[`"`"])`n"
                
            newScript .= defaults.Has(_map['Type']) ? (_map[defaults[_map['Type']]['function']] != false)
                ? storage "." _map['Name'] "." defaults[_map['Type']]['function'] " := `""
                    . _map[defaults[_map['Type']]['function']] "`"`n" : "" : ""  ; _map[ defaults['button']['function'] ] == _map["Value"] false ?
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
        "ComboBox", map("ctrl", "ComboBox", "event", "Change", "function", "Text"))
}