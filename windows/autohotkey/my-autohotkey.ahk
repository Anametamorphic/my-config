#Requires AutoHotkey v2.0
#SingleInstance Force

; Dźwięk potwierdzający załadowanie skryptu
SoundBeep(1000, 150)

; ==============================================================================
; KONFIGURACJA PRĘDKOŚCI (Gears)
; ==============================================================================
; Ustawione rosnąco: Wolny -> Średni -> Szybki
speedModes := [
    {val: 15,  name: "SNAJPER (10)"},   ; Index 1
    {val: 40,  name: "NORMALNY (40)"},  ; Index 2
    {val: 150, name: "SZYBKI (150)"},    ; Index 3
    {val: 300, name: "SUPER SZYBKI (300)"}    ; Index 4
]

currentModeIndex := 4 ; Startujemy od superszybkiego (Normalny)

; ==============================================================================
; FUNKCJE POMOCNICZE
; ==============================================================================

; Zmienia bieg o zadaną wartość (+1 lub -1)
ChangeSpeed(direction) {
    global currentModeIndex
    newIndex := currentModeIndex + direction
    ; Sprawdzamy, czy nie wychodzimy poza zakres (1-3)
    if (newIndex >= 1 && newIndex <= speedModes.Length) {
        currentModeIndex := newIndex
        ShowFeedback()
    } else {
        ; Opcjonalnie: Pokaż status nawet jak nie zmieniliśmy (żeby wiedzieć że to już max)
        ShowFeedback() 
    }
}

; Wyświetla dymek z aktualnym trybem
ShowFeedback() {
    mode := speedModes[currentModeIndex]
    ; Jeśli tryb Snajper (10), dymek wisi dłużej, w innych krótko
    time := (mode.val <= 10) ? -1500 : -600
    
    ToolTip("Tryb: " . mode.name)
    SetTimer () => ToolTip(), time 
}

; Wykonuje ruch myszką zależny od aktualnego trybu
Move(x, y) {
    currentSpeed := speedModes[currentModeIndex].val
    MouseMove(x * currentSpeed, y * currentSpeed, 0, "R")
}

; Rysuje czerwoną kropkę (Debug) przy Focus Fix
ShowDebugDot(x, y) {
    try {
        MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow +LastFound +E0x20")
        MyGui.BackColor := "Red"
        
        WinGetPos(&winX, &winY,,, "A")
        absX := winX + x - 5
        absY := winY + y - 5
        
        MyGui.Show("x" absX " y" absY " w10 h10 NoActivate")
        SetTimer(() => MyGui.Destroy(), -200)
    }
}

; ==============================================================================
; SKRÓTY KLAWISZOWE (Lewy Alt = <!)
; ==============================================================================

; --- 1. ZMIANA PRĘDKOŚCI ---
<!q::ChangeSpeed(-1)  ; Zwolnij (w stronę Snajpera)
<!w::ChangeSpeed(1)   ; Przyspiesz (w stronę Szybkiego)
<!e::{
    global currentModeIndex
    currentModeIndex := 4
    ShowFeedback()
}

timerValue := -10000

SetTimer IncreaseSpeedLoop, -10000

IncreaseSpeedLoop() {
   global currentModeIndex
   if (currentModeIndex != 4) {
       currentModeIndex := 4
       ShowFeedback()
   }
}

; --- 2. RUCH KURSORA (H J K L) ---
<!h::{
    Move(-1,  0)
    SetTimer IncreaseSpeedLoop, timerValue
}

<!j::{
    Move( 0,  1)
    SetTimer IncreaseSpeedLoop, timerValue
}

<!k::{
    Move( 0,  -1)
    SetTimer IncreaseSpeedLoop, timerValue
}

<!l::{
    Move( 1,  0)
    SetTimer IncreaseSpeedLoop, timerValue
}


; --- 3. KLIKANIE I SCROLLOWANIE ---

; LEWY PRZYCISK MYSZY (Z obsługą przeciągania/zaznaczania)
<!1::{
    Click "Down"  ; Wciśnij przycisk i trzymaj
    KeyWait "1"   ; Czekaj, aż użytkownik fizycznie puści klawisz "1"
    Click "Up"    ; Puść przycisk myszy
}

; PRAWY PRZYCISK MYSZY (Też z obsługą gestów, jeśli potrzebne)
<!2::{
    Click "Right Down"
    KeyWait "2"
    Click "Right Up"
}

; SCROLLOWANIE (Bez zmian, tutaj nie trzeba trzymać)
<!u::Click("WheelUp")   ; Scroll do góry
<!n::Click("WheelDown") ; Scroll w dół

; --- 4. FOCUS FIX (Centrowanie na oknie) ---
; <!Space::
; {
;     CoordMode("Mouse", "Window")
;     if WinExist("A") {
;         try {
;             WinGetPos(,, &WinWidth, &WinHeight, "A")
;             centerX := WinWidth / 2
;             centerY := WinHeight / 2
;             Click(centerX, centerY)
;             ShowDebugDot(centerX, centerY)
;         }
;     }
; }

; --- 5. SYSTEMOWE ---
; Blokuje menu Windows (Plik/Edycja) po wciśnięciu samego Alta
; ~LAlt::Send("{Blind}{vkE8}")

