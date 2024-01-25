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

SplitPath(A_ScriptFullPath, &fn)
if fn = "convert2Resizer.ahk"
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
        Loop parse, contents, "`n" "`r" 
        {
            if InStr(A_LoopField, "Gui(")
            {
                if InStr(A_LoopField, ":=")
                    guiName := Trim(StrSplit(A_LoopField, ":=")[1]) 
            }
            else if InStr(A_LoopField, "Show(")
            {
                tmp := StrSplit(A_LoopField, "Show(")[2]
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
            }
            if !InStr(A_LoopField, "Show(") && !InStr(A_LoopField, "#Include")
                script .= A_LoopField "`n"
        }
        tempFileContents := Lib "`n" script "`n" guiName . ".Show(`"" 
        tempFileContents .= (width != "") ? width : (height != "") ? height : ""
        tempFileContents .= "`")"
        FileOpen(A_MyDocuments "\tempFile.ahk", "w").Write(tempFileContents)
        Run(A_AhkPath " `"" A_MyDocuments "\tempFile.ahk" "`"") 
        Sleep(100)
        try{
            FileDelete(A_MyDocuments "\tempFile.ahk")
        }
        ExitApp()
    }

    return myGui
}