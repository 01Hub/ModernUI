;======================================================================================================================================
;
; ModernUI Control - ModernUI_Text v1.0.0.0
;
; Copyright (c) 2016 by fearless
;
; All Rights Reserved
;
; http://www.LetTheLight.in
;
; http://github.com/mrfearless/ModernUI
;
;======================================================================================================================================
.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

;DEBUG32 EQU 1
;
;IFDEF DEBUG32
;    PRESERVEXMMREGS equ 1
;    includelib M:\Masm32\lib\Debug32.lib
;    DBG32LIB equ 1
;    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
;    include M:\Masm32\include\debug32.inc
;ENDIF

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

include ModernUI.inc
includelib ModernUI.lib

include ModernUI_Text.inc

PUBLIC MUITextFontTable

;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_MUI_TextWndProc                PROTO :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TextInit                   PROTO :DWORD
_MUI_TextPaint                  PROTO :DWORD
_MUI_TextPaintBackground        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TextPaintText              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_MUI_TextCheckMultiline         PROTO :DWORD, :DWORD
_MUI_TextSetFontFamilySize      PROTO :DWORD, :DWORD

_MUI_TextGetFontTableHandle     PROTO :DWORD, :DWORD
_MUI_TextSetFontTableHandle     PROTO :DWORD, :DWORD, :DWORD

;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; External public properties
MUI_TEXT_PROPERTIES             STRUCT
    dwTextFont                  DD ?
    dwTextColor                 DD ?
    dwTextColorAlt              DD ?
    dwTextColorDisabled         DD ?
    dwTextBackColor             DD ?
    dwTextBackColorAlt          DD ?
    dwTextBackColorDisabled     DD ?
MUI_TEXT_PROPERTIES             ENDS

; Internal properties
_MUI_TEXT_PROPERTIES            STRUCT
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
_MUI_TEXT_PROPERTIES            ENDS


MUI_TEXT_FONT_ENTRY             STRUCT
    hFont                       DD 0
    hFontBold                   DD 0
    hFontItalic                 DD 0
    hFontUnderline              DD 0
    hFontBoldItalic             DD 0
    hFontBoldUnderline          DD 0
    hFontBoldItalicUnderline    DD 0
    hFontItalicUnderline        DD 0
MUI_TEXT_FONT_ENTRY             ENDS






.CONST
MUI_TEXT_MAX_CHARS              EQU 2048
MUI_TEXT_NO_FONTTYPES           EQU 7
MUI_TEXT_NO_FONTSIZES           EQU 16
MUI_TEXT_FONT_ENTRIES_SIZE      EQU (MUI_TEXT_NO_FONTSIZES * SIZEOF MUI_TEXT_FONT_ENTRY)

MUI_TEXT_FONTSIZE_MASK          EQU 0000000Fh
MUI_TEXT_FONTTYPE_MASK          EQU 00000070h
MUI_TEXT_ALIGN_MASK             EQU 00000300h


; Internal properties
@TextEnabledState               EQU 0
@TextMouseOver                  EQU 4



.DATA
;szLorumIpsumText                DB "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. " 
;                                DB "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. " 
;                                DB "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. " 
;                                DB "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",0

;szLorumIpsumText                DB "Lorem ipsum dolor sit amet, cu meis summo platonem ius. Est solet abhorreant constituto id, minim nominavi appetere at qui. "
;                                DB "Sed ea feugait officiis. Cu commodo persecuti nam, et minimum omittam prodesset mei. Usu ei duis feugiat platonem.",13,10,13,10
;                                DB "Autem antiopam eam et. Qui omnesque concludaturque no, duo ad accusam philosophia. Graeci convenire theophrastus ea has, "
;                                DB "eu mei paulo forensibus concludaturque. Ad sea ignota habemus adipiscing.",13,10,13,10
;                                DB "Duo iusto minimum id, eos animal graecis et, eu mel tota minimum corpora. Te vix latine conclusionemque, cu eam brute posse primis. "
;                                DB "Has an cibo elitr voluptatum, legere tritani te his. Consul libris gloriatur in nam, unum meliore sea an, graeci gloriatur id has. "
;                                DB "Justo ornatus mnesarchum ius eu, ex suscipit voluptua incorrupte vim.",0,0,0,0     


szLorumIpsumText                DB "Lorem ipsum dolor sit amet, explicari maluisset te cum, ea vel debitis omittam. Duis sale feugait id duo, sit minimum deleniti facilisis ne. "
                                DB "Sea et prompta legendos. Bonorum reprehendunt et nam. Nullam volutpat ut vim, in tempor nostrum assentior sed. In libris singulis gloriatur pri, "
                                DB "mei cetero comprehensam no. Has ne doming labore salutatus, vix ex timeam argumentum."
                                DB 13,10,13,10
                                DB "Quidam melius cum ei. Id invenire percipitur has, dicant partiendo sit ei. Sea et affert percipit nominati, mea ex minimum philosophia, "
                                DB "ad aliquid ponderum phaedrum nec. At option numquam mea. Nec reque scripta et, te mea regione senserit, sed ea partiendo sapientem delicatissimi. "
                                DB "Oporteat accommodare sed an. At has ornatus adolescens elaboraret."
                                DB 13,10,13,10
                                DB "Cu eam admodum senserit maluisset. Mel id probo elitr instructior. Illud velit efficiantur mea ne, audire adolescens no pri, pro fabellas intellegat ex." 
                                DB "Vis illum falli constituto ad, eum tantas dolore eirmod cu. Et zril malorum meliore usu."
                                DB 13,10,13,10
                                DB "No sea modus menandri scriptorem, nec cu petentium signiferumque. Cu causae suscipiantur duo, nam nibh inani corrumpit ad. Porro causae ut pri. "
                                DB "Duo paulo aperiri at, qui ne eripuit vulputate, sit facilisi antiopam salutandi id. At vidisse efficiendi cum."
                                DB 13,10,13,10
                                DB "Eos vidisse indoctum dissentiunt id. Alia duis tota ne est, in mea deleniti pertinax, amet senserit no his. His mollis intellegebat ut. "
                                DB "Sed reque quando ei. Ea per atqui integre deseruisse, pri et summo congue. Affert fuisset salutandi per te."
                                DB 13,10,13,10
                                DB "Ea dico timeam voluptaria qui, vel ea viderer recteque. Quas scaevola ad vim, harum omnes vulputate his ex, quo accusamus hendrerit id. "
                                DB "Ex mea solum constituam, no quo tritani definiebas intellegebat. Qui saperet insolens no, ex pri homero accumsan. Ad nemore vocibus qui. "
                                DB "Mundi volumus comprehensam ad per, in assentior cotidieque sit. Pro ut iudico incorrupte, duo in populo suscipit."
                                DB 0,0,0,0


szMUITextClass                  DB 'ModernUI_Text',0    ; Class name for creating our ModernUI_Text control


szMUITextFontSegoe              DB 'Segoe UI',0 
szMUITextFontTahoma             DB 'Tahoma',0
szMUITextFontArial              DB 'Arial',0
szMUITextFontTimes              DB 'Times New Roman',0
szMUITextFontCourier            DB 'Courier New',0
szMUITextFontVerdana            DB 'Verdana',0


MUITextFontTable                MUI_TEXT_FONT_ENTRY ((MUI_TEXT_NO_FONTTYPES+1) * (MUI_TEXT_NO_FONTSIZES+1)) DUP (<>)

.CODE

align 4

;-------------------------------------------------------------------------------------
; Set property for ModernUI_Text control
;-------------------------------------------------------------------------------------
MUITextSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, MUI_SETPROPERTY, dwProperty, dwPropertyValue
    ret
MUITextSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for ModernUI_Text control
;-------------------------------------------------------------------------------------
MUITextGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, MUI_GETPROPERTY, dwProperty, NULL
    ret
MUITextGetProperty ENDP


;-------------------------------------------------------------------------------------
; MUITextRegister - Registers the ModernUI_Text control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as ModernUI_Text
;-------------------------------------------------------------------------------------
MUITextRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx,hinstance,addr szMUITextClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, szMUITextClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        lea eax, _MUI_TextWndProc
    	mov wc.lpfnWndProc, eax 
        mov wc.hCursor, NULL ;eax
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
        Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret

MUITextRegister ENDP


;-------------------------------------------------------------------------------------
; MUITextCreate - Returns handle in eax of newly created control
;-------------------------------------------------------------------------------------
MUITextCreate PROC PUBLIC hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
    LOCAL dwNewStyle:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke MUITextRegister
    
    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
    
    Invoke CreateWindowEx, NULL, Addr szMUITextClass, lpszText, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        
    .ENDIF
    mov eax, hControl
    ret
MUITextCreate ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextWndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_MUI_TextWndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName   
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        Invoke MUIAllocMemProperties, hWin, 0, SIZEOF _MUI_TEXT_PROPERTIES ; internal properties
        Invoke MUIAllocMemProperties, hWin, 4, SIZEOF MUI_TEXT_PROPERTIES ; external properties
        Invoke _MUI_TextInit, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        Invoke MUIFreeMemProperties, hWin, 0
        Invoke MUIFreeMemProperties, hWin, 4
        mov eax, 0
        ret        
        
    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        Invoke _MUI_TextPaint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUITS_HAND
        .IF eax == MUITS_HAND
            invoke LoadCursor, NULL, IDC_HAND
        .ELSE
            invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
        mov eax, 0
        ret  

    .ELSEIF eax == WM_LBUTTONUP
        ; simulates click on our control, delete if not required.
        Invoke GetDlgCtrlID, hWin
        mov ebx,eax
        Invoke GetParent, hWin
        Invoke PostMessage, eax, WM_COMMAND, ebx, hWin

   .ELSEIF eax == WM_MOUSEMOVE
        Invoke MUIGetIntProperty, hWin, @TextEnabledState
        .IF eax == TRUE   
            Invoke MUISetIntProperty, hWin, @TextMouseOver, TRUE
            .IF eax != TRUE
                ;Invoke ShowWindow, hWin, SW_HIDE
                Invoke InvalidateRect, hWin, NULL, TRUE
                ;Invoke ShowWindow, hWin, SW_SHOW
                mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
                mov TE.dwFlags, TME_LEAVE
                mov eax, hWin
                mov TE.hwndTrack, eax
                mov TE.dwHoverTime, NULL
                Invoke TrackMouseEvent, Addr TE
            .ENDIF
        .ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        Invoke MUISetIntProperty, hWin, @TextMouseOver, FALSE
        ;Invoke ShowWindow, hWin, SW_HIDE
        Invoke InvalidateRect, hWin, NULL, TRUE
        ;Invoke ShowWindow, hWin, SW_SHOW
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_KILLFOCUS
        Invoke MUISetIntProperty, hWin, @TextMouseOver, FALSE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke LoadCursor, NULL, IDC_ARROW
        Invoke SetCursor, eax

    .ELSEIF eax == WM_ENABLE
        Invoke MUISetIntProperty, hWin, @TextEnabledState, wParam
        Invoke ShowWindow, hWin, SW_HIDE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke ShowWindow, hWin, SW_SHOW
        mov eax, 0

    .ELSEIF eax == WM_SETTEXT
        Invoke _MUI_TextCheckMultiline, hWin, lParam
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        Invoke ShowWindow, hWin, SW_HIDE
        Invoke InvalidateRect, hWin, NULL, TRUE
        Invoke ShowWindow, hWin, SW_SHOW
        ret
        
    .ELSEIF eax == WM_SETFONT
        ;PrintText '_MUI_TextWndProc::WM_SETFONT'
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, MUI_TEXT_FONTTYPE_MASK
        .IF eax == MUITS_FONT_DIALOG
            ;PrintDec wParam
            Invoke MUISetExtProperty, hWin, @TextFont, wParam
            .IF lParam == TRUE
                Invoke InvalidateRect, hWin, NULL, TRUE
            .ENDIF            
        .ELSE
            ret
        .ENDIF
        
    ; custom messages start here
    
    .ELSEIF eax == MUI_GETPROPERTY
        Invoke MUIGetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == MUI_SETPROPERTY  
        mov eax, wParam
        .IF eax == @TextFont
            Invoke MUIGetExtProperty, hWin, @TextFont
            .IF eax != NULL
                Invoke DeleteObject, eax
            .ENDIF
            Invoke MUISetExtProperty, hWin, wParam, lParam
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ELSE
            Invoke MUISetExtProperty, hWin, wParam, lParam
        .ENDIF
        ret

    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret

_MUI_TextWndProc ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextInit - set initial default values
;-------------------------------------------------------------------------------------
_MUI_TextInit PROC PRIVATE hWin:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    LOCAL BackColor:DWORD

    Invoke GetParent, hWin
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle
    .ENDIF
     
    ; Set default initial external property values  
    mov eax, dwStyle
    and eax, WS_DISABLED
    .IF eax == WS_DISABLED
        Invoke MUISetIntProperty, hWin, @TextEnabledState, FALSE
    .ELSE
        Invoke MUISetIntProperty, hWin, @TextEnabledState, TRUE
    .ENDIF  
    Invoke MUISetExtProperty, hWin, @TextColor, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hWin, @TextColorAlt, MUI_RGBCOLOR(51,51,51)
    Invoke MUISetExtProperty, hWin, @TextColorDisabled, MUI_RGBCOLOR(204,204,204)
    
    Invoke MUIGetParentBackgroundColor, hWin
    .IF eax == -1 ; if background was NULL then try a color as default
        Invoke GetSysColor, COLOR_WINDOW
    .ENDIF
    mov BackColor, eax
    Invoke MUISetExtProperty, hWin, @TextBackColor, BackColor ;MUI_RGBCOLOR(255,255,255)   
    ;Invoke MUISetExtProperty, hWin, @TextBackColor, MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hWin, @TextBackColorAlt, BackColor ;MUI_RGBCOLOR(255,255,255)
    Invoke MUISetExtProperty, hWin, @TextBackColorDisabled, BackColor ;MUI_RGBCOLOR(192,192,192)
    
    Invoke _MUI_TextSetFontFamilySize, hWin, dwStyle

    mov eax, dwStyle
    and eax, MUITS_LORUMIPSUM
    .IF eax == MUITS_LORUMIPSUM
        Invoke SetWindowText, hWin, Addr szLorumIpsumText
    .ENDIF

    ret

_MUI_TextInit ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextPaint
;-------------------------------------------------------------------------------------
_MUI_TextPaint PROC PRIVATE hWin:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL EnabledState:DWORD
    LOCAL MouseOver:DWORD
    LOCAL BackColor:DWORD

    Invoke BeginPaint, hWin, Addr ps
    mov hdc, eax

    ;----------------------------------------------------------
    ; Get some property values
    ;----------------------------------------------------------
    Invoke GetClientRect, hWin, Addr rect
    Invoke MUIGetIntProperty, hWin, @TextEnabledState
    mov EnabledState, eax
    Invoke MUIGetIntProperty, hWin, @TextMouseOver
    mov MouseOver, eax
    Invoke MUIGetExtProperty, hWin, @TextBackColor
    mov BackColor, eax

    .IF BackColor != -1 ; Not Transparent, background color is specified

        ;----------------------------------------------------------
        ; Setup Double Buffering
        ;----------------------------------------------------------
        Invoke CreateCompatibleDC, hdc
        mov hdcMem, eax
        Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
        mov hbmMem, eax
        Invoke SelectObject, hdcMem, hbmMem
        mov hOldBitmap, eax
    
        ;----------------------------------------------------------
        ; Background
        ;----------------------------------------------------------
        Invoke _MUI_TextPaintBackground, hWin, hdcMem, Addr rect, EnabledState, MouseOver
    
        ;----------------------------------------------------------
        ; Text
        ;----------------------------------------------------------
        Invoke _MUI_TextPaintText, hWin, hdcMem, Addr rect, EnabledState, MouseOver
    
        ;----------------------------------------------------------
        ; BitBlt from hdcMem back to hdc
        ;----------------------------------------------------------
        Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY
    
        ;----------------------------------------------------------
        ; Cleanup
        ;----------------------------------------------------------
        .IF hOldBitmap != 0
            Invoke SelectObject, hdcMem, hOldBitmap
            Invoke DeleteObject, hOldBitmap
        .ENDIF
        Invoke SelectObject, hdcMem, hbmMem
        Invoke DeleteObject, hbmMem
        Invoke DeleteDC, hdcMem

    .ELSE ; Text on Transparent Background
    
        ;----------------------------------------------------------
        ; Text
        ;----------------------------------------------------------    
        Invoke _MUI_TextPaintText, hWin, hdc, Addr rect, EnabledState, MouseOver
    
    .ENDIF
     
    Invoke EndPaint, hWin, Addr ps

    ret
_MUI_TextPaint ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextPaintBackground
;-------------------------------------------------------------------------------------
_MUI_TextPaintBackground PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD

    .IF bEnabledState == TRUE
        .IF bMouseOver == FALSE
            Invoke MUIGetExtProperty, hWin, @TextBackColor              ; Normal back color
        .ELSE
            Invoke MUIGetExtProperty, hWin, @TextBackColorAlt           ; Mouse over back color
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @TextBackColorDisabled          ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @TextBackColor                  ; fallback to default Normal back color
    .ENDIF
    mov BackColor, eax
    
    .IF BackColor == -1 ; transparent
        ret
    .ENDIF

    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    Invoke FillRect, hdc, lpRect, hBrush

    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF      
    
    ret

_MUI_TextPaintBackground ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextPaintText
;-------------------------------------------------------------------------------------
_MUI_TextPaintText PROC PRIVATE hWin:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL LenText:DWORD    
    LOCAL dwTextStyle:DWORD
    LOCAL dwStyle:DWORD
    LOCAL rect:RECT
    LOCAL szMUITextBuffer[MUI_TEXT_MAX_CHARS]:BYTE
    
    Invoke CopyRect, Addr rect, lpRect

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax
    
    Invoke MUIGetExtProperty, hWin, @TextFont        
    mov hFont, eax

    .IF bEnabledState == TRUE
        .IF bMouseOver == FALSE
            Invoke MUIGetExtProperty, hWin, @TextBackColor        ; Normal back color
        .ELSE
            Invoke MUIGetExtProperty, hWin, @TextBackColorAlt     ; Mouse over back color
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @TextBackColorDisabled        ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @TextBackColor                ; fallback to default Normal back color
    .ENDIF    
    mov BackColor, eax    

    .IF bEnabledState == TRUE
        .IF bMouseOver == FALSE
            Invoke MUIGetExtProperty, hWin, @TextColor        ; Normal text color
        .ELSE
            Invoke MUIGetExtProperty, hWin, @TextColorAlt     ; Mouse over text color
        .ENDIF
    .ELSE
        Invoke MUIGetExtProperty, hWin, @TextColorDisabled        ; Disabled text color
    .ENDIF
    .IF eax == 0 ; try to get default text color if others are set to 0
        Invoke MUIGetExtProperty, hWin, @TextColor                ; fallback to default Normal text color
    .ENDIF  
    mov TextColor, eax
    
    Invoke GetWindowText, hWin, Addr szMUITextBuffer, MUI_TEXT_MAX_CHARS;SIZEOF szText
    
    Invoke lstrlen, Addr szMUITextBuffer ;szText
    mov LenText, eax
    
    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax

    .IF BackColor != -1 ; transaprent
        Invoke SetBkMode, hdc, OPAQUE
        Invoke SetBkColor, hdc, BackColor
    .ELSE
        Invoke SetBkMode, hdc, TRANSPARENT
    .ENDIF
    Invoke SetTextColor, hdc, TextColor

    mov eax, dwStyle
    and eax, MUITS_SINGLELINE
    .IF eax == MUITS_SINGLELINE
        mov dwTextStyle, DT_SINGLELINE
    .ELSE
        mov dwTextStyle, DT_WORDBREAK or DT_EDITCONTROL
    .ENDIF
    mov eax, dwStyle
    and eax, (MUITS_ALIGN_CENTER or MUITS_ALIGN_RIGHT)
    .IF eax == MUITS_ALIGN_CENTER
        or dwTextStyle, DT_CENTER
    .ELSEIF eax == MUITS_ALIGN_RIGHT
        or dwTextStyle, DT_RIGHT
    .ELSEIF eax == MUITS_ALIGN_CENTER or MUITS_ALIGN_RIGHT ; MUITS_ALIGN_JUSTIFY
        or dwTextStyle, DT_LEFT
    .ELSE
        or dwTextStyle, DT_LEFT
    .ENDIF

    Invoke DrawText, hdc, Addr szMUITextBuffer, LenText, Addr rect, dwTextStyle
    
    .IF hOldFont != 0
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF

    ret
_MUI_TextPaintText ENDP


;-------------------------------------------------------------------------------------
; Returns TRUE if CR LF found in string, otherwise returns FALSE
;-------------------------------------------------------------------------------------
_MUI_TextCheckMultiline PROC USES EBX hWin:DWORD, lpszText:DWORD
    LOCAL lenText:DWORD
    LOCAL Cnt:DWORD
    LOCAL bMultiline:DWORD
    LOCAL dwStyle:DWORD
    
    ;PrintText '_MUI_TextCheckMultiline'
    
    .IF lpszText == 0
        ret
    .ENDIF
    Invoke lstrlen, lpszText
    mov lenText, eax
    
    mov bMultiline, FALSE
    mov ebx, lpszText
    mov Cnt, 0
    mov eax, 0
    .WHILE eax < lenText
        movzx eax, byte ptr [ebx]
        .IF al == 0
            mov bMultiline, FALSE
            .BREAK
        .ELSEIF al == 10 || al == 13
            mov bMultiline, TRUE
            .BREAK 
        .ENDIF
        inc ebx
        inc Cnt
        mov eax, Cnt
    .ENDW

    Invoke GetWindowLong, hWin, GWL_STYLE
    mov dwStyle, eax  
    mov eax, dwStyle
    .IF bMultiline == FALSE
        or eax, MUITS_SINGLELINE
    .ELSE
        and eax, (-1 xor MUITS_SINGLELINE)
    .ENDIF
    mov dwStyle, eax
    Invoke SetWindowLong, hWin, GWL_STYLE, dwStyle

    mov eax, bMultiline
    ret

_MUI_TextCheckMultiline ENDP


;-------------------------------------------------------------------------------------
; Create Text size and font family based on style flags passed to control
;-------------------------------------------------------------------------------------
_MUI_TextSetFontFamilySize PROC USES EBX hWin:DWORD, dwStyle:DWORD
    LOCAL MUITextFont:DWORD
    LOCAL hFont:DWORD
    LOCAL dwFontHeight:DWORD
    LOCAL dwFontWeight:DWORD
    LOCAL dwFontFamily:DWORD
    LOCAL dwFontSize:DWORD
    LOCAL bFontBold:DWORD
    LOCAL bFontItalic:DWORD
    LOCAL bFontUnderline:DWORD

    Invoke MUIGetExtProperty, hWin, @TextFont
    mov hFont, eax
    .IF hFont != NULL
        Invoke DeleteObject, hFont
    .ENDIF

    ;--------------------------------
    ; Get font family
    ;--------------------------------
    mov eax, dwStyle
    and eax, MUI_TEXT_FONTTYPE_MASK ;0F0h
    mov dwFontFamily, eax
 
    .IF eax == MUITS_FONT_DIALOG
        Invoke GetParent, hWin
        Invoke SendMessage, eax, WM_GETFONT, 0, 0 ; hope parent is the dialog or container that has a font being used.
        mov hFont, eax
        Invoke MUISetExtProperty, hWin, @TextFont, hFont
    .ELSE
        mov eax, dwFontFamily
        .IF eax == MUITS_FONT_SEGOE
            lea eax, szMUITextFontSegoe
        .ELSEIF eax == MUITS_FONT_TAHOMA
            lea eax, szMUITextFontTahoma
        .ELSEIF eax == MUITS_FONT_ARIAL
            lea eax, szMUITextFontArial
        .ELSEIF eax == MUITS_FONT_TIMES
            lea eax, szMUITextFontTimes
        .ELSEIF eax == MUITS_FONT_COURIER
            lea eax, szMUITextFontCourier
        .ELSEIF eax == MUITS_FONT_VERDANA    
            lea eax, szMUITextFontVerdana
        .ELSE
            lea eax, szMUITextFontSegoe
        .ENDIF
        mov MUITextFont, eax

        ;--------------------------------
        ; Get font size
        ;--------------------------------
        mov eax, dwStyle
        and eax, MUI_TEXT_FONTSIZE_MASK
        mov dwFontSize, eax
        .IF eax == MUITS_7PT
            Invoke MUIPointSizeToLogicalUnit, hWin, 7
        .ELSEIF eax == MUITS_8PT ; 8pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 8
        .ELSEIF eax == MUITS_9PT
            Invoke MUIPointSizeToLogicalUnit, hWin, 9
         .ELSEIF eax == MUITS_10PT ; 10pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 10
        .ELSEIF eax == MUITS_11PT; 11pt 
            Invoke MUIPointSizeToLogicalUnit, hWin, 11
        .ELSEIF eax == MUITS_12PT; 12pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 12
         .ELSEIF eax == MUITS_13PT; 13pt 
            Invoke MUIPointSizeToLogicalUnit, hWin, 13
        .ELSEIF eax == MUITS_14PT ; 14pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 14
         .ELSEIF eax == MUITS_15PT ; 15pt 
            Invoke MUIPointSizeToLogicalUnit, hWin, 15
        .ELSEIF eax == MUITS_16PT ; 16pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 16
        .ELSEIF eax == MUITS_18PT ; 18pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 18
        .ELSEIF eax == MUITS_20PT ; 20pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 20
        .ELSEIF eax == MUITS_22PT ; 22pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 22
        .ELSEIF eax == MUITS_24PT ; 24pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 24
        .ELSEIF eax == MUITS_28PT ; 28pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 28
        .ELSEIF eax == MUITS_32PT ; 32pt
            Invoke MUIPointSizeToLogicalUnit, hWin, 32
        .ELSE
            Invoke MUIPointSizeToLogicalUnit, hWin, 8
        .ENDIF
        mov dwFontHeight, eax
        
        ;--------------------------------
        ; Get font bold, italic, underline
        ;--------------------------------
        mov eax, dwStyle
        and eax, MUITS_FONT_BOLD
        .IF eax == MUITS_FONT_BOLD
            mov bFontBold, TRUE
            mov dwFontWeight, FW_BOLD
        .ELSE
            mov bFontBold, FALSE
            mov dwFontWeight, FW_NORMAL
        .ENDIF
        mov eax, dwStyle
        and eax, MUITS_FONT_ITALIC
        .IF eax == MUITS_FONT_ITALIC
            mov bFontItalic, TRUE
        .ELSE
            mov bFontItalic, FALSE
        .ENDIF
        mov eax, dwStyle
        and eax, MUITS_FONT_UNDERLINE
        .IF eax == MUITS_FONT_UNDERLINE
            mov bFontUnderline, TRUE
        .ELSE
            mov bFontUnderline, FALSE
        .ENDIF
        
        ;--------------------------------
        ; Create font 
        ;--------------------------------
        Invoke _MUI_TextGetFontTableHandle, hWin, dwStyle
        mov hFont, eax
        .IF eax == 0 ; no handle found in fonttable
            ;PrintText 'New Font'
            Invoke CreateFont, dwFontHeight, 0,0,0, dwFontWeight, bFontItalic, bFontUnderline,0,0,0,0, PROOF_QUALITY, FF_DONTCARE, MUITextFont
            mov hFont, eax
            ; save handle to fonttable
            Invoke _MUI_TextSetFontTableHandle, hWin, dwStyle, hFont
        .ELSE ; use handle from fonttable instead
        .ENDIF
        Invoke MUISetExtProperty, hWin, @TextFont, hFont
    .ENDIF
    mov eax, hFont
    ret

_MUI_TextSetFontFamilySize ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextGetFontTableHandle
;
; Gets handle to font in our font table, allows us to re-use existing font handle
; if a previous ModernUI_Text control has created that font already. Instead of
; creating many fonts for each control individually this allows us to share the font
; handle when its already been created for a specific font family, and size and for
; bold or italic or underline (or combination)
;-------------------------------------------------------------------------------------
_MUI_TextGetFontTableHandle PROC USES EBX hWin:DWORD, dwStyle:DWORD
    LOCAL dwFontSizeValue:DWORD
    LOCAL dwFontTypeValue:DWORD
    LOCAL dwFontTypeIndex:DWORD
    LOCAL bFontBold:DWORD
    LOCAL bFontItalic:DWORD
    LOCAL bFontUnderline:DWORD
    LOCAL OffsetTextFont:DWORD
    LOCAL OffsetTextFontSize:DWORD
    LOCAL ptrTextFontEntry:DWORD
    
    lea eax, MUITextFontTable
    .IF eax == 0
        ret
    .ENDIF
    
    mov eax, dwStyle
    and eax, MUITS_FONT_BOLD
    .IF eax == MUITS_FONT_BOLD
        mov bFontBold, TRUE
    .ELSE
        mov bFontBold, FALSE
    .ENDIF

    mov eax, dwStyle
    and eax, MUITS_FONT_ITALIC
    .IF eax == MUITS_FONT_ITALIC
        mov bFontItalic, TRUE
    .ELSE
        mov bFontItalic, FALSE
    .ENDIF

    mov eax, dwStyle
    and eax, MUITS_FONT_UNDERLINE
    .IF eax == MUITS_FONT_UNDERLINE
        mov bFontUnderline, TRUE
    .ELSE
        mov bFontUnderline, FALSE
    .ENDIF

    mov eax, dwStyle
    and eax, MUI_TEXT_FONTSIZE_MASK
    mov dwFontSizeValue, eax

    ; text font entry is (index * MUI_TEXT_FONT_ENTRIES_SIZE) + (sizevalue * MUI_TEXT_FONT_ENTRY)

    mov eax, dwStyle
    and eax, MUI_TEXT_FONTTYPE_MASK
    mov dwFontTypeValue, eax
    shr eax, 4
    mov dwFontTypeIndex, eax
    mov ebx, MUI_TEXT_FONT_ENTRIES_SIZE
    mul ebx
    mov OffsetTextFont, eax

    mov ebx, SIZEOF MUI_TEXT_FONT_ENTRY
    mov eax, dwFontSizeValue
    mul ebx
    mov OffsetTextFontSize, eax
    
    lea eax, MUITextFontTable
    add eax, OffsetTextFont
    add eax, OffsetTextFontSize    
    mov ptrTextFontEntry, eax
    
    mov ebx, ptrTextFontEntry
    
    .IF bFontBold == FALSE && bFontItalic == FALSE && bFontUnderline == FALSE ; normal
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFont
        
    .ELSEIF bFontBold == TRUE && bFontItalic == FALSE && bFontUnderline == FALSE ; bold only
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFontBold
        
    .ELSEIF bFontBold == FALSE && bFontItalic == TRUE && bFontUnderline == FALSE ; italic only
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFontItalic
    
    .ELSEIF bFontBold == FALSE && bFontItalic == FALSE && bFontUnderline == TRUE ; underline only 
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFontUnderline
    
    .ELSEIF bFontBold == TRUE && bFontItalic == TRUE && bFontUnderline == FALSE ; bold + italic
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFontBoldItalic
    
    .ELSEIF bFontBold == TRUE && bFontItalic == FALSE && bFontUnderline == TRUE ; bold + underline
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFontBoldUnderline
    
    .ELSEIF bFontBold == TRUE && bFontItalic == TRUE && bFontUnderline == TRUE ; bold + italic + underline
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFontBoldItalicUnderline
    
    .ELSEIF bFontBold == FALSE && bFontItalic == TRUE && bFontUnderline == TRUE ; italic + underline
        mov eax, [ebx].MUI_TEXT_FONT_ENTRY.hFontItalicUnderline       

    .ENDIF

    ret
_MUI_TextGetFontTableHandle ENDP


;-------------------------------------------------------------------------------------
; _MUI_TextSetFontTableHandle
;
; Sets handle to font in our font table, allows us to re-use existing font handle
; if a previous ModernUI_Text control has created that font already. Instead of
; creating many fonts for each control individually this allows us to share the font
; handle when its already been created for a specific font family, and size and for
; bold or italic or underline (or combination)
;-------------------------------------------------------------------------------------
_MUI_TextSetFontTableHandle PROC USES EBX hWin:DWORD, dwStyle:DWORD, hFont:DWORD
    LOCAL dwFontSizeValue:DWORD
    LOCAL dwFontTypeValue:DWORD
    LOCAL dwFontTypeIndex:DWORD
    LOCAL bFontBold:DWORD
    LOCAL bFontItalic:DWORD
    LOCAL bFontUnderline:DWORD
    LOCAL OffsetTextFont:DWORD
    LOCAL OffsetTextFontSize:DWORD
    LOCAL ptrTextFontEntry:DWORD
    
    lea eax, MUITextFontTable
    .IF eax == 0 || hFont == 0
        ret
    .ENDIF
    
    mov eax, dwStyle
    and eax, MUITS_FONT_BOLD
    .IF eax == MUITS_FONT_BOLD
        mov bFontBold, TRUE
    .ELSE
        mov bFontBold, FALSE
    .ENDIF

    mov eax, dwStyle
    and eax, MUITS_FONT_ITALIC
    .IF eax == MUITS_FONT_ITALIC
        mov bFontItalic, TRUE
    .ELSE
        mov bFontItalic, FALSE
    .ENDIF

    mov eax, dwStyle
    and eax, MUITS_FONT_UNDERLINE
    .IF eax == MUITS_FONT_UNDERLINE
        mov bFontUnderline, TRUE
    .ELSE
        mov bFontUnderline, FALSE
    .ENDIF

    mov eax, dwStyle
    and eax, MUI_TEXT_FONTSIZE_MASK
    mov dwFontSizeValue, eax

    ; text font entry is (index * MUI_TEXT_FONT_ENTRIES_SIZE) + (sizevalue * MUI_TEXT_FONT_ENTRY)

    mov eax, dwStyle
    and eax, MUI_TEXT_FONTTYPE_MASK
    mov dwFontTypeValue, eax
    shr eax, 4
    mov dwFontTypeIndex, eax
    mov ebx, MUI_TEXT_FONT_ENTRIES_SIZE
    mul ebx
    mov OffsetTextFont, eax

    mov ebx, SIZEOF MUI_TEXT_FONT_ENTRY
    mov eax, dwFontSizeValue
    mul ebx
    mov OffsetTextFontSize, eax
    
    lea eax, MUITextFontTable
    add eax, OffsetTextFont
    add eax, OffsetTextFontSize    
    mov ptrTextFontEntry, eax

    mov ebx, ptrTextFontEntry
    mov eax, hFont
    
    .IF bFontBold == FALSE && bFontItalic == FALSE && bFontUnderline == FALSE ; normal
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFont, eax
        
    .ELSEIF bFontBold == TRUE && bFontItalic == FALSE && bFontUnderline == FALSE ; bold only
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFontBold, eax
        
    .ELSEIF bFontBold == FALSE && bFontItalic == TRUE && bFontUnderline == FALSE ; italic only
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFontItalic, eax
    
    .ELSEIF bFontBold == FALSE && bFontItalic == FALSE && bFontUnderline == TRUE ; underline only 
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFontUnderline, eax
    
    .ELSEIF bFontBold == TRUE && bFontItalic == TRUE && bFontUnderline == FALSE ; bold + italic
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFontBoldItalic, eax
    
    .ELSEIF bFontBold == TRUE && bFontItalic == FALSE && bFontUnderline == TRUE ; bold + underline
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFontBoldUnderline, eax
    
    .ELSEIF bFontBold == TRUE && bFontItalic == TRUE && bFontUnderline == TRUE ; bold + italic + underline
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFontBoldItalicUnderline, eax
    
    .ELSEIF bFontBold == FALSE && bFontItalic == TRUE && bFontUnderline == TRUE ; italic + underline
        mov [ebx].MUI_TEXT_FONT_ENTRY.hFontItalicUnderline, eax

    .ENDIF

    ret
_MUI_TextSetFontTableHandle ENDP


END