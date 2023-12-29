; ----------------------------------------------------------------------------------------------------------------------
; Loads and initializes the Gdiplus.dll.
; Must be called once before you use any of the DLL functions.
; ----------------------------------------------------------------------------------------------------------------------
#DllLoad "Gdiplus.dll"
UseGDIP() {
   Static GdipObject := 0
   If !IsObject(GdipObject) {
      GdipToken := 0
      SI := Buffer(24, 0) ; size of 64-bit structure
      NumPut("UInt", 1, SI)
      If DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", &GdipToken, "Ptr", SI, "Ptr", 0, "UInt") {
         MsgBox("GDI+ could not be startet!`n`nThe program will exit!", A_ThisFunc, 262160)
         ExitApp
      }
      GdipObject := {__Delete: UseGdipShutDown}
   }
   UseGdipShutDown(*) {
      DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GdipToken)
   }
}