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
 * @returns {Class} GuiReSizer instance.
 * 
 * @example
 * 
 * ; GuiObj.OnEvent("Size", GuiReSizer)
 * 
 * @property {Number} X - X positional offset from margins.
 * @property {Number} Y - Y positional offset from margins.
 * @property {Number} XP - X positional offset from margins as a percentage of Gui width.
 * @property {Number} YP - Y positional offset from margins as a percentage of Gui height.
 * @property {Number} OriginX (OX) - Control origin X, defaults to 0 (left side of control), this relocates the origin.
 * @property {Number} OriginXP (OXP) - Control origin X as a percentage of Gui width, defaults to 0 (left side of control), this relocates the origin.
 * @property {Number} OriginY (OY) - Control origin Y, defaults to 0 (top side of control), this relocates the origin.
 * @property {Number} OriginYP (OYP) - Control origin Y as a percentage of Gui height, defaults to 0 (top side of control), this relocates the origin.
 * @property {Number} Width (W) - Width of control.
 * @property {Number} WidthP (WP) - Width of control as a percentage of Gui width.
 * @property {Number} Height (H) - Height of control.
 * @property {Number} HeightP (HP) - Height of control as a percentage of Gui height.
 * @property {Number} MinX - Minimum X offset.
 * @property {Number} MaxX - Maximum X offset.
 * @property {Number} MinY - Minimum Y offset.
 * @property {Number} MaxY - Maximum Y offset.
 * @property {Number} MinWidth (MinW) - Minimum control width.
 * @property {Number} MaxWidth (MaxW) - Maximum control width.
 * @property {Number} MinHeight (MinH) - Minimum control height.
 * @property {Number} MaxHeight (MaxH) - Maximum control height.
 * @property {Boolean} Cleanup (C) - When set to true, will redraw this control each time to clean up artifacts (normally not required and causes flickering).
 * @property {Function} Function (F) - Custom function that will be called for this control.
 * @property {Object} Anchor (A) - Control object anchor so that size and position commands are in relation to another control.
 * @property {Boolean} AnchorIn (AI) - Controls where the control is restricted to the inside of another control.
 * 
 * @method Now
 * @description Forces a manual Call now for {GuiObj}.
 * @param {Object} GuiObj - Gui Object.
 * 
 * @method Opt
 * @description Same as Options method.
 * @param {Object} switches - Switches for Options method.
 * 
 * @method Options
 * @description All options are set as a string with each switch separated by a space "x10 yp50 oCM".
 * @param {Object} switches - Switches for setting options.
 * @param {Number} x - X.
 * @param {Number} y - Y.
 * @param {Number} xp - XP.
 * @param {Number} yp - YP.
 * @param {Number} wp - WidthP.
 * @param {Number} hp - HeightP.
 * @param {Number} w - Width.
 * @param {Number} h - Height.
 * @param {Number} minx - MinX.
 * @param {Number} maxx - MaxX.
 * @param {Number} miny - MinY.
 * @param {Number} maxy - MaxY.
 * @param {Number} minw - MinWidth.
 * @param {Number} maxw - MaxWidth.
 * @param {Number} minh - MinHeight.
 * @param {Number} maxh - MaxHeight.
 * @param {Number} oxp - OriginXP.
 * @param {Number} oyp - OriginYP.
 * @param {Number} ox - OriginX.
 * @param {Number} oy - OriginY.
 * @param {String} o - Origin: "L" left, "C" center, "R" right, "T" top, "M" middle, "B" bottom; may use 1 or 2 letters.
 * 
 * @property {Object} Gui Properties:
 * @property {Number} Init - {Gui}.Init := 1, will cause all controls of the Gui to be redrawn on the next function call.
 *                           {Gui}.Init := 2, will also reinitialize abbreviations.
 */
Class GuiReSizer
{

    ;{ Call GuiReSizer
    Static Call(GuiObj, WindowMinMax, GuiW, GuiH)
    {
        ; On Initial display of Gui use redraw to cleanup first positioning
        Try
        (GuiObj.Init)
        Catch
            GuiObj.Init := 2 ; Redraw Twice on Initial Call(called on initial Show)

        If WindowMinMax = -1 ; Do nothing if window minimized
            Return

        ;{ Loop through all Controls of Gui
        For Hwnd, CtrlObj in GuiObj
        {
            ;{ Initializations on First Call
            If GuiObj.Init = 2
            {
                Try CtrlObj.OriginX := CtrlObj.OX
                Try CtrlObj.OriginXP := CtrlObj.OXP
                Try CtrlObj.OriginY := CtrlObj.OY
                Try CtrlObj.OriginYP := CtrlObj.OYP
                Try CtrlObj.Width := CtrlObj.W
                Try CtrlObj.WidthP := CtrlObj.WP
                Try CtrlObj.Height := CtrlObj.H
                Try CtrlObj.HeightP := CtrlObj.HP
                Try CtrlObj.MinWidth := CtrlObj.MinW
                Try CtrlObj.MaxWidth := CtrlObj.MaxW
                Try CtrlObj.MinHeight := CtrlObj.MinH
                Try CtrlObj.MaxHeight := CtrlObj.MaxH
                Try CtrlObj.Function := CtrlObj.F
                Try CtrlObj.Cleanup := CtrlObj.C
                Try CtrlObj.Anchor := CtrlObj.A
                Try CtrlObj.AnchorIn := CtrlObj.AI
                If !CtrlObj.HasProp("AnchorIn")
                    CtrlObj.AnchorIn := true
            }
            ;}
            ;{ Initialize Current Positions and Sizes
            CtrlObj.GetPos(&CtrlX, &CtrlY, &CtrlW, &CtrlH)
            LimitX := AnchorW := GuiW, LimitY := AnchorH := GuiH, OffsetX := OffsetY := 0
            ;}
            ;{ Check for Anchor
            If CtrlObj.HasProp("Anchor")
            {
                If Type(CtrlObj.Anchor) = "Gui.Tab"
                {
                    CtrlObj.Anchor.GetPos(&AnchorX, &AnchorY, &AnchorW, &AnchorH)
                    Offset(CtrlObj, &TabX, &TabY)
                    CtrlX := CtrlX - TabX, CtrlY := CtrlY - TabY
                    AnchorW := AnchorW + AnchorX - TabX, AnchorH := AnchorH + AnchorY - TabY
                }
                Else
                {
                    CtrlObj.Anchor.GetPos(&AnchorX, &AnchorY, &AnchorW, &AnchorH)
                    If CtrlObj.HasProp("X") or CtrlObj.HasProp("XP")
                        OffsetX := AnchorX
                    If CtrlObj.HasProp("Y") or CtrlObj.HasProp("YP")
                        OffsetY := AnchorY
                }
                If CtrlObj.AnchorIn
                    LimitX := AnchorW, LimitY := AnchorH
            }
            ;}
            ;{ OriginX
            If CtrlObj.HasProp("OriginX") and CtrlObj.HasProp("OriginXP")
                OriginX := CtrlObj.OriginX + (CtrlW * CtrlObj.OriginXP)
            Else If CtrlObj.HasProp("OriginX") and !CtrlObj.HasProp("OriginXP")
                OriginX := CtrlObj.OriginX
            Else If !CtrlObj.HasProp("OriginX") and CtrlObj.HasProp("OriginXP")
                OriginX := CtrlW * CtrlObj.OriginXP
            Else
                OriginX := 0
            ;}
            ;{ OriginY
            If CtrlObj.HasProp("OriginY") and CtrlObj.HasProp("OriginYP")
                OriginY := CtrlObj.OriginY + (CtrlH * CtrlObj.OriginYP)
            Else If CtrlObj.HasProp("OriginY") and !CtrlObj.HasProp("OriginYP")
                OriginY := CtrlObj.OriginY
            Else If !CtrlObj.HasProp("OriginY") and CtrlObj.HasProp("OriginYP")
                OriginY := CtrlH * CtrlObj.OriginYP
            Else
                OriginY := 0
            ;}
            ;{ X
            If CtrlObj.HasProp("X") and CtrlObj.HasProp("XP")
                CtrlX := Mod(LimitX + CtrlObj.X + (AnchorW * CtrlObj.XP) - OriginX, LimitX)
            Else If CtrlObj.HasProp("X") and !CtrlObj.HasProp("XP")
                CtrlX := Mod(LimitX + CtrlObj.X - OriginX, LimitX)
            Else If !CtrlObj.HasProp("X") and CtrlObj.HasProp("XP")
                CtrlX := Mod(LimitX + (AnchorW * CtrlObj.XP) - OriginX, LimitX)
            ;}
            ;{ Y
            If CtrlObj.HasProp("Y") and CtrlObj.HasProp("YP")
                CtrlY := Mod(LimitY + CtrlObj.Y + (AnchorH * CtrlObj.YP) - OriginY, LimitY)
            Else If CtrlObj.HasProp("Y") and !CtrlObj.HasProp("YP")
                CtrlY := Mod(LimitY + CtrlObj.Y - OriginY, LimitY)
            Else If !CtrlObj.HasProp("Y") and CtrlObj.HasProp("YP")
                CtrlY := Mod(LimitY + AnchorH * CtrlObj.YP - OriginY, LimitY)
            ;}
            ;{ Width
            If CtrlObj.HasProp("Width") and CtrlObj.HasProp("WidthP")
            (CtrlObj.Width > 0 and CtrlObj.WidthP > 0 ? CtrlW := CtrlObj.Width + AnchorW * CtrlObj.WidthP : CtrlW := CtrlObj.Width + AnchorW + AnchorW * CtrlObj.WidthP - CtrlX)
            Else If CtrlObj.HasProp("Width") and !CtrlObj.HasProp("WidthP")
            (CtrlObj.Width > 0 ? CtrlW := CtrlObj.Width : CtrlW := AnchorW + CtrlObj.Width - CtrlX)
            Else If !CtrlObj.HasProp("Width") and CtrlObj.HasProp("WidthP")
            (CtrlObj.WidthP > 0 ? CtrlW := AnchorW * CtrlObj.WidthP : CtrlW := AnchorW + AnchorW * CtrlObj.WidthP - CtrlX)
            ;}
            ;{ Height
            If CtrlObj.HasProp("Height") and CtrlObj.HasProp("HeightP")
            (CtrlObj.Height > 0 and CtrlObj.HeightP > 0 ? CtrlH := CtrlObj.Height + AnchorH * CtrlObj.HeightP : CtrlH := CtrlObj.Height + AnchorH + AnchorH * CtrlObj.HeightP - CtrlY)
            Else If CtrlObj.HasProp("Height") and !CtrlObj.HasProp("HeightP")
            (CtrlObj.Height > 0 ? CtrlH := CtrlObj.Height : CtrlH := AnchorH + CtrlObj.Height - CtrlY)
            Else If !CtrlObj.HasProp("Height") and CtrlObj.HasProp("HeightP")
            (CtrlObj.HeightP > 0 ? CtrlH := AnchorH * CtrlObj.HeightP : CtrlH := AnchorH + AnchorH * CtrlObj.HeightP - CtrlY)
            ;}
            ;{ Min Max
            (CtrlObj.HasProp("MinX") ? MinX := CtrlObj.MinX : MinX := -999999)
            (CtrlObj.HasProp("MaxX") ? MaxX := CtrlObj.MaxX : MaxX := 999999)
            (CtrlObj.HasProp("MinY") ? MinY := CtrlObj.MinY : MinY := -999999)
            (CtrlObj.HasProp("MaxY") ? MaxY := CtrlObj.MaxY : MaxY := 999999)
            (CtrlObj.HasProp("MinWidth") ? MinW := CtrlObj.MinWidth : MinW := 0)
            (CtrlObj.HasProp("MaxWidth") ? MaxW := CtrlObj.MaxWidth : MaxW := 999999)
            (CtrlObj.HasProp("MinHeight") ? MinH := CtrlObj.MinHeight : MinH := 0)
            (CtrlObj.HasProp("MaxHeight") ? MaxH := CtrlObj.MaxHeight : MaxH := 999999)
            CtrlX := MinMax(CtrlX, MinX, MaxX)
            CtrlY := MinMax(CtrlY, MinY, MaxY)
            CtrlW := MinMax(CtrlW, MinW, MaxW)
            CtrlH := MinMax(CtrlH, MinH, MaxH)
            ;}
            ;{ Move and Size
            CtrlObj.Move(CtrlX + OffsetX, CtrlY + OffsetY, CtrlW, CtrlH)
            ;}
            ;{ Redraw on Cleanup or GuiObj.Init
            If GuiObj.Init or (CtrlObj.HasProp("Cleanup") and CtrlObj.Cleanup = true)
                CtrlObj.Redraw()
            ;}
            ;{ Custom Function Call
            If CtrlObj.HasProp("Function")
                CtrlObj.Function(GuiObj) ; CtrlObj is hidden 'this' first parameter
            ;}
        }
        ;}
        ;{ Reduce GuiObj.Init Counter and Check for Call again
        If (GuiObj.Init := Max(GuiObj.Init - 1, 0))
        {
            GuiObj.GetClientPos(, , &AnchorW, &AnchorH)
            GuiReSizer(GuiObj, WindowMinMax, AnchorW, AnchorH)
        }
        ;}
        ;{ Functions: Helpers
        MinMax(Num, MinNum, MaxNum) => Min(Max(Num, MinNum), MaxNum)
        Offset(CtrlObj, &OffsetX, &OffsetY)
        {
            Hwnd := CtrlObj.Hwnd
            hParentWnd := DllCall("GetParent", "Ptr", Hwnd, "Ptr")
            RECT := Buffer(16, 0)
            DllCall("GetWindowRect", "Ptr", hParentWnd, "Ptr", RECT)
            DllCall("MapWindowPoints", "Ptr", 0, "Ptr", DllCall("GetParent", "Ptr", hParentWnd, "Ptr"), "Ptr", RECT, "UInt", 1)
            OffsetX := NumGet(RECT, 0, "Int"), OffsetY := NumGet(RECT, 4, "Int")
        }
        ;}
    }
    ;}
    ;{ Methods:
    ;{ Options
    Static Opt(CtrlObj, Options) => GuiReSizer.Options(CtrlObj, Options)
    Static Options(CtrlObj, Options)
    {
        For Option in StrSplit(Options, " ")
        {
            For Abbr, Cmd in Map(
                "xp", "XP", "yp", "YP", "x", "X", "y", "Y",
                "wp", "WidthP", "hp", "HeightP", "w", "Width", "h", "Height",
                "minx", "MinX", "maxx", "MaxX", "miny", "MinY", "maxy", "MaxY",
                "minw", "MinWidth", "maxw", "MaxWidth", "minh", "MinHeight", "maxh", "MaxHeight",
                "oxp", "OriginXP", "oyp", "OriginYP", "ox", "OriginX", "oy", "OriginY")
                If RegExMatch(Option, "i)^" Abbr "([\d.-]*$)", &Match)
                {
                    CtrlObj.%Cmd% := Match.1
                    Break
                }
            ; Origin letters
            If SubStr(Option, 1, 1) = "o"
            {
                Flags := SubStr(Option, 2)
                If Flags ~= "i)l"           ; left
                    CtrlObj.OriginXP := 0
                If Flags ~= "i)c"           ; center (left to right)
                    CtrlObj.OriginXP := 0.5
                If Flags ~= "i)r"           ; right
                    CtrlObj.OriginXP := 1
                If Flags ~= "i)t"           ; top
                    CtrlObj.OriginYP := 0
                If Flags ~= "i)m"           ; middle (top to bottom)
                    CtrlObj.OriginYP := 0.5
                If Flags ~= "i)b"           ; bottom
                    CtrlObj.OriginYP := 1
            }
        }
    }
    ;}
    ;{ Now
    Static Now(GuiObj, Redraw := true, Init := 2)
    {
        If Redraw
            GuiObj.Init := Init
        GuiObj.GetClientPos(, , &Width, &Height)
        GuiReSizer(GuiObj, WindowMinMax := 1, Width, Height)
    }
    ;}
    ;}
    Static Add(GuiObj, CtrlType, sizePos, LabelVar)
    {
        matchCount := RegExMatch(sizePos, "([xywh])(\d+%)\s*([xywh])?(\d+%)?", &matchObj)
        if (matchCount)
        {
            lettersToLookFor := ["y", "x", "h", "w"]
            index := 1
            count := matchCount / 2
            _new_sizePos := ""
            returnCtrlVar := GuiObj.Add(CtrlType, , LabelVar)
            Loop count
            {
                if InStr("y", matchObj[index])
                {
                    percentage := StrReplace(matchObj[index + 1], "%", "")
                    percentage := percentage / 100
                    returnCtrlVar.YP := percentage
                }
                index := index + 2
            }
        }
    }
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
     * // Usage:
     * GuiReSizer.FormatOpt(myControl, 10, 20, 30, 40);
     * 
     * // This will set the X position to 10% of the Gui width,
     * // Y position to 20% of the Gui height,
     * // Width to 30% of the Gui width,
     * // Height to 40% of the Gui height.
     */
    static FormatOpt(ctrl, xp?, yp?, wp?, hp?) 
    {
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
}
;}

; Gui.Control.Prototype.DefineProp("Format", { Call: format_control_pos_size })

; class format_control_pos_size
; {
;     static Call(self, xp?, yp?, wp?, hp?)
;     {
;         options := ""
;         if IsSet(xp)
;             options .= format_control_pos_size.math(xp, "xp") 
;         if IsSet(yp)
;             options .= format_control_pos_size.math(yp, "yp")
;         if IsSet(wp)
;             options .= format_control_pos_size.math(wp, "wp")
;         if IsSet(hp)
;             options .= format_control_pos_size.math(hp, "hp")
;         options := StrReplace(options, "0.", ".")
;         self.Opt(options)
;     }
;     static math(val, str)
;     {
;         if val < 0
;             val += 1
;         return str Round(val, 2) " "
;     }
; }