/*
    Function: array_contains
    Description: Checks if an array contains a specific value.
    Parameters:
        - arr: The array to search in.
        - search: The value to search for.
        - case_sensitive (optional): Specifies whether the search is case-sensitive. Default is 0 (case-insensitive).
    Returns:
        - The index of the first occurrence of the value in the array, or 0 if not found.
*/
Array.Prototype.DefineProp("Contains", { Call: array_contains })
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

/*
    Class: get_row
    Description: Represents a method to get the focused row of a ListView control.
    Methods:
        - Call(LV): Retrieves the focused row of the ListView control.
            Parameters:
                - LV: The ListView control.
            Returns:
                - An array containing the values of the focused row.

            Example usage:
            GetRow(LV)  ; LV is an instance of Gui.Listview
            Returns: ["Value1", "Value2", "Value3", ...]
*/

Gui.Listview.Prototype.DefineProp("GetRow", { Call: get_row })
; define the prototype

class get_row
{
    static Call(LV)
    {
        if not IsObject(LV)
            return 0
        FocusedRow := []
        Loop LV.GetCount("Column")
        {
            FocusedRow.Push(LV.GetText(LV.GetNext(), A_Index))
        }
        return FocusedRow
    }
}

/*
    Class: set_cell

    Description:
    This class provides a static method to set the value of a cell in a ListView control.

    Methods:
    - Call(LV, row, col, value): Sets the value of the specified cell in the ListView control.

    Parameters:
    - LV (object): The ListView control object.
    - row (integer): The row index of the cell.
    - col (integer): The column index of the cell.
    - value (string): The value to set in the cell.

    Example usage:
    ```
    LV := Gui.Add("ListView")
    set_cell.Call(LV, 1, 2, "New Value")
    ```
*/
Gui.Listview.Prototype.DefineProp("SetCell", { Call: set_cell })
class set_cell
{
    static Call(LV, row, col, value)
    {
        LV.Modify(row, "Col" col, value)
    }
}

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



; This function defines a property called "ToggleVisible" on the prototype of the Object class.
; When called, it hides or shows all GUI controls from the given object.
; The function returns 1 if any controls were hidden or shown, otherwise it returns 0.
Object.Prototype.DefineProp("ToggleEnabled", { Call: ToggleEnabledCtrl })

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
ToggleEnabledCtrl(selfObj)
{
    status := 0
    for index, value in selfObj.OwnProps() {
        if !IsSet(value)
            continue
        else if IsObject(value)
        {
            if not InStr(value.__Class, "Gui.")
                status := HideAll_guiCtrls_fromObj(value)
            else if value.HasProp("Enabled")
            {
                value.Enabled := !value.Enabled
                status := 1
            }
        }
    }
    return status
}


; This function defines a property called "ToggleVisible" on the prototype of the Object class.
; When called, it hides or shows all GUI controls from the given object.
; The function returns 1 if any controls were hidden or shown, otherwise it returns 0.
Object.Prototype.DefineProp("VisibleStatus", { Call: GuiCtrlVisibleStatus })

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
GuiCtrlVisibleStatus(selfObj)
{
    for index, value in selfObj.OwnProps() {
        if IsSet(status)
            return status
        if !IsSet(value)
            continue
        else if IsObject(value)
        {
            if not InStr(value.__Class, "Gui.")
            {
                temp := GuiCtrlVisibleStatus(value)
                if IsSet(temp)
                    status := temp
            }
            else if value.HasProp("Visible")
            {
                status := value.Visible
            }
        }
    }
    if IsSet(status)
        return status
    else
        return
}


Array.Prototype.DefineProp("Join", { Call: array_join })


array_join(arr, delimiter)
{
    str := ""
    for index, value in arr {
        if !IsSet(value)
            continue
        else
            str .= value .= delimiter
    }
    return str
}

; Explanation for Map.Prototype.DefineProp("Keys", { Call: get_keys })
; This method is added to the prototype of the Map class to retrieve an array of keys.
Map.Prototype.DefineProp("Keys", { Call: get_keys })

get_keys(mp)
{
    mapKeys := []
    for k, v in mp {
        if !IsSet(k)
            continue
        else if k is string or k is number
            mapKeys.Push(k)
    }
    return mapKeys
}

; Explanation for Map.Prototype.DefineProp("Values", { Call: get_values })
    ; This method is added to the prototype of the Map class to retrieve an array of string values.
    ; M := Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
    ; M.Keys()  ; returns ["Key1", "Key2", "Key3"]
Map.Prototype.DefineProp("Values", { Call: get_values })

get_values(mp)
{
    mapValues := []
    for k, v in mp {
        if !IsSet(v)
            continue
        else if v is string
            mapValues.Push(v)
    }
    return mapValues
}



SetWindowAttribute(GuiObj, DarkMode := True)
{
    global DarkColors          := Map("Background", "0x202020", "Controls", "0x404040", "Font", "0xE0E0E0")
    global TextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkColors["Background"], "Ptr")
    static PreferredAppMode    := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)

    if (VerCompare(A_OSVersion, "10.0.17763") >= 0)
    {
        DWMWA_USE_IMMERSIVE_DARK_MODE := 19
        if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
        {
            DWMWA_USE_IMMERSIVE_DARK_MODE := 20
        }
        uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
        SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
        FlushMenuThemes     := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
        switch DarkMode
        {
            case True:
            {
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)
                DllCall(SetPreferredAppMode, "Int", PreferredAppMode["ForceDark"])
                DllCall(FlushMenuThemes)
                GuiObj.BackColor := DarkColors["Background"]
            }
            default:
            {
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", False, "Int", 4)
                DllCall(SetPreferredAppMode, "Int", PreferredAppMode["Default"])
                DllCall(FlushMenuThemes)
                GuiObj.BackColor := "Default"
            }
        }
    }
}


SetWindowTheme(GuiObj, DarkMode := True)
{
    static GWL_WNDPROC        := -4
    static GWL_STYLE          := -16
    static ES_MULTILINE       := 0x0004
    static LVM_GETTEXTCOLOR   := 0x1023
    static LVM_SETTEXTCOLOR   := 0x1024
    static LVM_GETTEXTBKCOLOR := 0x1025
    static LVM_SETTEXTBKCOLOR := 0x1026
    static LVM_GETBKCOLOR     := 0x1000
    static LVM_SETBKCOLOR     := 0x1001
    static LVM_GETHEADER      := 0x101F
    static GetWindowLong      := A_PtrSize = 8 ? "GetWindowLongPtr" : "GetWindowLong"
    static SetWindowLong      := A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong"
    static Init               := False
    static LV_Init            := False
    global IsDarkMode         := DarkMode

    Mode_Explorer  := (DarkMode ? "DarkMode_Explorer"  : "Explorer" )
    Mode_CFD       := (DarkMode ? "DarkMode_CFD"       : "CFD"      )
    Mode_ItemsView := (DarkMode ? "DarkMode_ItemsView" : "ItemsView")
    for hWnd, GuiCtrlObj in GuiObj
    {
        switch GuiCtrlObj.Type
        {
            case "Button", "CheckBox", "ListBox", "UpDown":
            {
                DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
            }
            case "ComboBox", "DDL":
            {
                DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
            }
            case "Edit":
            {
                if (DllCall("user32\" GetWindowLong, "Ptr", GuiCtrlObj.hWnd, "Int", GWL_STYLE) & ES_MULTILINE)
                {
                    DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
                }
                else
                {
                    DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_CFD, "Ptr", 0)
                }
            }
            case "ListView":
            {
                if !(LV_Init)
                {
                    static LV_TEXTCOLOR   := SendMessage(LVM_GETTEXTCOLOR,   0, 0, GuiCtrlObj.hWnd)
                    static LV_TEXTBKCOLOR := SendMessage(LVM_GETTEXTBKCOLOR, 0, 0, GuiCtrlObj.hWnd)
                    static LV_BKCOLOR     := SendMessage(LVM_GETBKCOLOR,     0, 0, GuiCtrlObj.hWnd)
                    LV_Init := True
                }
                GuiCtrlObj.Opt("-Redraw")
                switch DarkMode
                {
                    case True:
                    {
                        SendMessage(LVM_SETTEXTCOLOR,   0, DarkColors["Font"],       GuiCtrlObj.hWnd)
                        SendMessage(LVM_SETTEXTBKCOLOR, 0, DarkColors["Background"], GuiCtrlObj.hWnd)
                        SendMessage(LVM_SETBKCOLOR,     0, DarkColors["Background"], GuiCtrlObj.hWnd)
                    }
                    default:
                    {
                        SendMessage(LVM_SETTEXTCOLOR,   0, LV_TEXTCOLOR,   GuiCtrlObj.hWnd)
                        SendMessage(LVM_SETTEXTBKCOLOR, 0, LV_TEXTBKCOLOR, GuiCtrlObj.hWnd)
                        SendMessage(LVM_SETBKCOLOR,     0, LV_BKCOLOR,     GuiCtrlObj.hWnd)
                    }
                }
                DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_Explorer, "Ptr", 0)
                
                ; To color the selection - scrollbar turns back to normal
                ;DllCall("uxtheme\SetWindowTheme", "Ptr", GuiCtrlObj.hWnd, "Str", Mode_ItemsView, "Ptr", 0)

                ; Header Text needs some NM_CUSTOMDRAW coloring
                LV_Header := SendMessage(LVM_GETHEADER, 0, 0, GuiCtrlObj.hWnd)
                DllCall("uxtheme\SetWindowTheme", "Ptr", LV_Header, "Str", Mode_ItemsView, "Ptr", 0)
                GuiCtrlObj.Opt("+Redraw")
            }
        }
    }

    if !(Init)
    {
        ; https://www.autohotkey.com/docs/v2/lib/CallbackCreate.htm#ExSubclassGUI
        global WindowProcNew := CallbackCreate(WindowProc)  ; Avoid fast-mode for subclassing.
        global WindowProcOld := DllCall("user32\" SetWindowLong, "Ptr", GuiObj.Hwnd, "Int", GWL_WNDPROC, "Ptr", WindowProcNew, "Ptr")
        Init := True
    }
    
    for ctrl in GuiObj
    {
        if ctrl.HasProp("Opt")
        {
                ctrl.Opt("Background101011")
        }
    }
}



WindowProc(hwnd, uMsg, wParam, lParam)
{
    critical
    static WM_CTLCOLOREDIT    := 0x0133
    static WM_CTLCOLORLISTBOX := 0x0134
    static WM_CTLCOLORBTN     := 0x0135
    static WM_CTLCOLORSTATIC  := 0x0138
    static DC_BRUSH           := 18

    if (IsDarkMode)
    {
        switch uMsg
        {
            case WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX:
            {
                DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
                DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Controls"])
                DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Controls"], "UInt")
                return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
            }
            case WM_CTLCOLORBTN:
            {
                DllCall("gdi32\SetDCBrushColor", "Ptr", wParam, "UInt", DarkColors["Background"], "UInt")
                return DllCall("gdi32\GetStockObject", "Int", DC_BRUSH, "Ptr")
            }
            case WM_CTLCOLORSTATIC:
            {
                DllCall("gdi32\SetTextColor", "Ptr", wParam, "UInt", DarkColors["Font"])
                DllCall("gdi32\SetBkColor", "Ptr", wParam, "UInt", DarkColors["Background"])
                return TextBackgroundBrush
            }
        }
    }
    return DllCall("user32\CallWindowProc", "Ptr", WindowProcOld, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
}
