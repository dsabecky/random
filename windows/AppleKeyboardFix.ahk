; Command / Alt key remap
LAlt::LWin
LWin::LAlt
RAlt::RWin
RWin::RAlt

; Shift + F7 - F12 media keys
+F7::Media_Prev
+F8::Media_Play_Pause
+F9::Media_Next
+F10::Volume_Mute
+F11::Volume_Down
+F12::Volume_Up

; F13 screenshot
F13::Send, {Printscreen}

; F14  screenshot window
F14::Send, !{Printscreen}

; F15 screenshot (snippet)
F15::Send, #+s

; lock workstation
#l::DllCall("LockWorkStation")