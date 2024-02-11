/*
    Class: StyleButton
    ButtonStyle(ButtonOK, 0, "success")

    IBStyles["info"]
    IBStyles["success"]
    IBStyles["warning"]
    IBStyles["critical"]

    IBStyles["info-outline"]
    IBStyles["success-outline"]
    IBStyles["warning-outline"]
    IBStyles["critical-outline"]

    IBStyles["info-round"]
    IBStyles["success-round"]
    IBStyles["warning-round"]
    IBStyles["critical-round"]

    IBStyles["info-outline-round"]
    IBStyles["success-outline-round"]
    IBStyles["warning-outline-round"]
    IBStyles["critical-outline-round"]


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

*/
class ButtonStyle
{
    static err := 0
    static buttons := []
    static params := []
    
    static Call(ctrl, offset:=0, style:="info")
    {
        DetectHiddenWindows("off")
        ctrl.GetPos(, , &w, &h)
        btn := {ctrl: ctrl, offset: offset, style: style, w: w, h: h}
        ButtonStyle.buttons.Push(btn)
        ctrl.Gui.OnEvent("Size", ButtonStyle.enumButtons)
        if w != 0 && h != 0 && WinActive(ctrl.Gui.hwnd)
        { 
            ButtonStyle.params.Push([btn, offset, style])
            ButtonStyle.Set(btn, offset, style)
        }
    }
    
    static Set(btn, offset, style)
    {
        try{
            btn.ctrl.Gui.GetPos(, , &w, &h)
        } catch as e {
            return false
        }

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
        return true
    }
    
    static refresh()
    {
        for p in ButtonStyle.params
        {
            if p.Length = 3
                ButtonStyle.Set(p[1], p[2], p[3])
        }
    }
    static enumButtons(*)
    {
        for btn in ButtonStyle.buttons
        {
            if !ButtonStyle.Set(btn, btn.offset, btn.style)
                ButtonStyle.buttons.RemoveAt(A_Index)
        }
    }
}

myStyleMap(ctrl, offset, style) => CreateImageButton(ctrl, offset, IBStyles[style]*)



; gui__.cutsheetcrud.CSLV.ModifyCol(4, "SortDesc")

; LV.Sort(coloumn, direction := "D" or "A")   D = Descending, A = Ascending
Gui.Button.Prototype.DefineProp("Style", { Call: setStyle })
; define the prototype

class setStyle
{
    static Call(ctrl, style := "info")
    {
        Try
        {
            ButtonStyle(ctrl, 0, style)
        } catch as e {
            return ctrl
        }
        return ctrl
    }
}


IBStyles := Map()
; credit to jNizM
; https://www.autohotkey.com/boards/memberlist.php?mode=viewprofile&u=75  

IBStyles["info"] := [[0xFF46B8DA, , , , ,], [0xFF8ED1F0], [0xFF25739E], [0xFFD6D6D6]]
IBStyles["success"] := [[0xFF5CB85C, , , , ,], [0xFFA0EBA0], [0xFF3C7A3C], [0xFFD6D6D6]]
IBStyles["warning"] := [[0xFFF0AD4E, , , , ,], [0xFFFFDC8A], [0xFFBF7E30], [0xFFD6D6D6]]
IBStyles["critical"] := [[0xFFD43F3A, , , , ,], [0xFFFF8780], [0xFFAE2B26], [0xFFD6D6D6]]

IBStyles["info-outline"] := [[0xFFF0F0F0, , , , 0xFF46B8DA, 2], [0xFFB4E5FC], [0xFFA6D6E7], [0xFFF0F0F0]]
IBStyles["success-outline"] := [[0xFFF0F0F0, , , , 0xFF5CB85C, 2], [0xFFD9F2D9], [0xFFB8DAB8], [0xFFF0F0F0]]
IBStyles["warning-outline"] := [[0xFFF0F0F0, , , , 0xFFF0AD4E, 2], [0xFFFFF5DB], [0xFFFFE3B3], [0xFFF0F0F0]]
IBStyles["critical-outline"] := [[0xFFF0F0F0, , , , 0xFFD43F3A, 2], [0xFFFFDFDD], [0xFFFFB3B1], [0xFFF0F0F0]]

IBStyles["info-round"] := [[0xFF46B8DA, , , 8, 0xFF46B8DA, 2], [0xFF8ED1F0], [0xFF25739E], [0xFFF0F0F0]]
IBStyles["success-round"] := [[0xFF5CB85C, , , 8, 0xFF5CB85C, 2], [0xFFA0EBA0], [0xFF3C7A3C], [0xFFF0F0F0]]
IBStyles["warning-round"] := [[0xFFF0AD4E, , , 8, 0xFFF0AD4E, 2], [0xFFFFDC8A], [0xFFBF7E30], [0xFFF0F0F0]]
IBStyles["critical-round"] := [[0xFFD43F3A, , , 8, 0xFFD43F3A, 2], [0xFFFF8780], [0xFFAE2B26], [0xFFF0F0F0]]

IBStyles["info-outline-round"] := [[0xFFF0F0F0, , , 8, 0xFF46B8DA, 2], [0xFFB4E5FC], [0xFFA6D6E7], [0xFFF0F0F0]]
IBStyles["success-outline-round"] := [[0xFFF0F0F0, , , 8, 0xFF5CB85C, 2], [0xFFD9F2D9], [0xFFB8DAB8], [0xFFF0F0F0]]
IBStyles["warning-outline-round"] := [[0xFFF0F0F0, , , 8, 0xFFF0AD4E, 2], [0xFFFFF5DB], [0xFFFFE3B3], [0xFFF0F0F0]]
IBStyles["critical-outline-round"] := [[0xFFF0F0F0, , , 8, 0xFFD43F3A, 2], [0xFFFFDFDD], [0xFFFFB3B1], [0xFFF0F0F0]]

IBStyles["info-outline-white"] := [[0xFF0000FF, 0xFFFFFFFF, , , , 2], [0xFF0000FF, 0xFFFFFFFF], [0xFF0000D0], [0xFF0000B0]]
IBStyles["success-outline-white"] := [[0xFFF0F0F0, , , , 0xFF5CB85C, 2], [0xFFFFFFFF], [0xFFB8DAB8], [0xFFF0F0F0]]
IBStyles["warning-outline-white"] := [[0xFFF0F0F0, , , , 0xFFF0AD4E, 2], [0xFFFFFFFF], [0xFFFFE3B3], [0xFFF0F0F0]]
IBStyles["critical-outline-white"] := [[0xFFF0F0F0, , , , 0xFFD43F3A, 2], [0xFFFFFFFF], [0xFFFFB3B1], [0xFFF0F0F0]]

IBStyles["info-outline-white-round"] := [[0xFF0000FF, 0xFFFFFFFF, , , , 2], [0xFF0000FF, 0xFFFFFFFF], [0xFF0000D0], [0xFF0000B0]]
IBStyles["success-outline-white-round"] := [[0xFFF0F0F0, , , 8, 0xFF5CB85C, 2], [0xFFFFFFFF], [0xFFB8DAB8], [0xFFF0F0F0]]
IBStyles["warning-outline-white-round"] := [[0xFFF0F0F0, , , 8, 0xFFF0AD4E, 2], [0xFFFFFFFF], [0xFFFFE3B3], [0xFFF0F0F0]]
IBStyles["critical-outline-white-round"] := [[0xFFF0F0F0, , , 8, 0xFFD43F3A, 2], [0xFFFFFFFF], [0xFFFFB3B1], [0xFFF0F0F0]]

#Include <CreateImageButton>
#Include <UseGDIP>