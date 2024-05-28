;EasyCodeName=winblitz,1
.Const
IDS_TIMER 		  Equ 130
IDS_TIMERRECT 	  Equ 140

WM_SHELLNOTIFY Equ WM_USER + 5
IDI_TRAY       Equ 0H
IDM_SHOWHIDE   Equ 100
IDM_EXIT       Equ 101

SKINCRAFTER Struct
       SkinCrafterHeader  SIZEL	<?>    ;ukuran region
       SkinCrafterNumByte DD     ?    ;32bit {128,4,0,0} jumlah RECT region+Region Header
SKINCRAFTER EndS

NOTIFYICONDATAx Struct
  cbSize	       DD ?
  hWnd		       DD ?
  uID		       DD ?
  uFlags	       DD ?
  uCallbackMessage DD ?
  hIcon 	       DD ?
  szTip 	       TCHAR 64 Dup (?)
NOTIFYICONDATAx EndS

.Data?

.Data

hInst	      HINSTANCE	NULL
bm  		  BITMAP <?>
RgnPt         POINT <?>
rc            RECT {0, 0, 256, 256}
RsrcHand      DD ?
RsrcPoint     DD ?
RsrcSize      DD ?
hSkinBmp      DD ?
hdcSkinBmp    DD ?
hOldSkinBmp   DD ?
HeigthFrame   DD ?
HeigthCaption DD ?
hbrush		  DD ?
hRegion       HRGN ?
bRegion       BOOL ?
bBgShow		  BOOL ?
hWndTxt       HWND ?
hWndParent    HWND ?
BaseRect      RECT <?>
buf           DB  256 Dup (?), 0
WndTxtRect    RECT <?>

SizeTxtStrc   SIZEL <?>
LenTxt        DD ?
PosTxt        POINT <?>
TimeTick      DD ?
bTxtShow      DD TRUE
TxtColor      DD 0FFFFH
BgColor		  DD ?
CLSID_TaskbarList GUID {56FDF344FD6D11D0958A006097C9A090}
IID_ITaskbarList GUID {56FDF342FD6D11D0958A006097C9A090}

szShowHide    DB "&Show/Hide", 0
szExit        DB "&Exit", 0
node	      NOTIFYICONDATAx <?>
showflag      DD ?   ; 1 if main window is visible
hTrayMenu     DWord ?
.Code

start:
	Invoke GetModuleHandle, NULL
	Mov hInst, Eax
	Invoke GetCommandLine
	Invoke WinMain, hInst, NULL, Eax, SW_SHOWDEFAULT
	Invoke ExitProcess, Eax

WinMain Proc Private hInstance:HINSTANCE, hPrevInst:HINSTANCE, lpCmdLine:LPSTR, nCmdShow:DWord
	Local msg:MSG, wc:WNDCLASSEX, wc2:WNDCLASSEX
	Local iSw:DWord, iSh:DWord

	Text szClassName, "WNDCLASS" ;"EasyCodeMainWindow"
	Mov wc.cbSize, SizeOf WNDCLASSEX
	Mov wc.style, CS_DBLCLKS
	Mov wc.lpfnWndProc, Offset WndMainProc
	Mov wc.cbClsExtra, 0
	Mov wc.cbWndExtra, 0
	Push hInstance
	Pop wc.hInstance
	Invoke LoadIcon, hInst, IDS_ICON
	Mov wc.hIcon, Eax
    Invoke LoadCursor, NULL, IDC_ARROW
	Mov wc.hCursor, Eax
	Mov wc.hbrBackground, (COLOR_BTNFACE + 1)
	Mov wc.lpszMenuName, NULL
	Mov wc.lpszClassName, Offset szClassName
	Mov wc.hIconSm, NULL
	Invoke RegisterClassEx, Addr wc

	Text szClassName2, "EasyCodeMainWindow2"
	Mov wc2.cbSize, SizeOf WNDCLASSEX
	Mov wc2.style, CS_DBLCLKS
	Mov wc2.lpfnWndProc, Offset WndTextProc
	Mov wc2.cbClsExtra, 0
	Mov wc2.cbWndExtra, 0
	Push hInstance
	Pop wc2.hInstance
	Invoke LoadIcon, hInst, IDS_ICON
	Mov wc2.hIcon, Eax
    Invoke LoadCursor, NULL, IDC_ARROW
	Mov wc2.hCursor, Eax
	Invoke GetStockObject, BLACK_BRUSH
	Mov wc2.hbrBackground, Eax ;(COLOR_BTNFACE + 1)
	Mov wc2.lpszMenuName, NULL
	Mov wc2.lpszClassName, Offset szClassName2
	Mov wc2.hIconSm, NULL
	Invoke RegisterClassEx, Addr wc2

    Invoke  LoadBitmap, hInst, IDS_SKIN
    .If !Eax
	    Mov Eax, -1
	    Ret
    .EndIf
    Mov hSkinBmp, Eax
    Invoke  GetWindowDC, NULL
    Push Eax
    Invoke  CreateCompatibleDC, Eax
    Mov hdcSkinBmp, Eax
    Invoke  SelectObject, Eax, hSkinBmp
    Mov hOldSkinBmp, Eax
    Invoke  GetObject, hSkinBmp, SizeOf BITMAP, Addr bm
    Pop Eax
    Invoke ReleaseDC, NULL, Eax

    ;Thickness, in pixels, of the sizing border around the perimeter of a window that can be resized.
    Mov HeigthFrame, FUNC(GetSystemMetrics, SM_CYFRAME)   ;eax = 6 pixel

    Invoke GetSystemMetrics, SM_CYCAPTION
    Mov HeigthCaption, Eax ;eax = 26 pixel

    ;Get Display width init potition Top Right Display Coordinat
    Invoke GetSystemMetrics, SM_CXSCREEN
    Mov iSw, Eax     ;width
    Sub Eax, bm.bmWidth
    Sub Eax, HeigthCaption
    Mov rc.left, Eax

	szText szTitle, "WinBlitz"
	Invoke CreateWindowEx, WS_EX_TOOLWINDOW, Addr szClassName, Addr szTitle, WS_POPUP,
						rc.left, rc.top, bm.bmWidth, bm.bmHeight,
						HWND_DESKTOP, NULL, hInst, NULL

    Mov hWndParent, Eax

	szText szTitle2, "WinBlitz2"
	Invoke CreateWindowEx, WS_EX_DLGMODALFRAME, Addr szClassName2, Addr szTitle2, WS_POPUP,
						rc.left, bm.bmHeight, bm.bmWidth, HeigthCaption,
						hWndParent, NULL, hInst, NULL
    Mov hWndTxt, Eax
    ;============================================
	Mov showflag, TRUE
	Invoke ShowWindow, hWndParent, SW_SHOW
   	Invoke UpdateWindow, hWndParent

	Invoke ShowWindow, hWndTxt, SW_SHOW
   	Invoke UpdateWindow, hWndTxt

    Invoke SetActiveWindow, hWndParent
    ;============================================

@@:	Invoke GetMessage, Addr msg, NULL, 0, 0
	.If Eax
		Invoke TranslateMessage, Addr msg
		Invoke DispatchMessage, Addr msg
		Jmp Short @B
	.EndIf

	Mov Eax, msg.wParam
	Ret
WinMain EndP

WndMainProc Proc Private Uses Ebx Edi Esi hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	Local ps:PAINTSTRUCT, MovePt:POINT, pt:POINT
	.If uMsg == WM_CREATE
        ; create tray icon
		; fill NOTIFYICONDATA structure
		Mov node.cbSize, SizeOf NOTIFYICONDATAx
		Mov Eax, hWnd
		Mov node.hWnd, Eax
		Mov node.uID, IDI_TRAY
		Mov node.uFlags, (NIF_ICON Or NIF_MESSAGE Or NIF_TIP)
		Mov node.uCallbackMessage, WM_SHELLNOTIFY
		Invoke	LoadIcon, hInst, IDS_ICON
		Mov node.hIcon, Eax
		szText szTipTxt, "Tray Demo"
		Invoke lstrcpy, Addr node.szTip, Addr szTipTxt
		Invoke	Shell_NotifyIcon, NIM_ADD, Addr node		; show icon to system tray
		Invoke	CreatePopupMenu					;
		Mov hTrayMenu, Eax 					; create popup menu
		Invoke	AppendMenu, hTrayMenu, MF_SEPARATOR, 0, 0	;
		Invoke	AppendMenu, hTrayMenu, MF_STRING, IDM_SHOWHIDE, Addr szShowHide	;
		Invoke	AppendMenu, hTrayMenu, MF_STRING, IDM_EXIT, Addr szExit	;

		;Invoke ClientToScreen, hWnd, Addr BasePt
		; --> LOAD REGION_DATA (SEE API REF FOR QUESTIONS)
		Invoke FindResource, hInst, IDS_REGION, RT_FILEDATA
        ;save resourcehandle
		Mov RsrcHand, Eax
	    Invoke LoadResource, hInst, Eax
		Mov RsrcPoint, Eax
		Invoke SizeofResource, hInst, RsrcHand
		Mov RsrcSize, Eax
		Invoke LockResource, RsrcPoint
		Mov RsrcPoint, Eax
        ;Passed this Code to SkinCrafter Region Product
		;Sub RsrcSize, SizeOf SKINCRAFTER
		;Add RsrcPoint, SizeOf SKINCRAFTER
        ; --> CREATE REGION AND PASS IT TO OUR WINDOW
		Invoke ExtCreateRegion, NULL, RsrcSize, RsrcPoint
        Mov hRegion, Eax
		Invoke SetWindowRgn, hWnd, hRegion, TRUE
        Mov bRegion, TRUE
		Xor Eax, Eax
		Ret
	.ElseIf uMsg == WM_PAINT
		Invoke BeginPaint, hWnd, Addr ps
		Invoke BitBlt, ps.hdc, 0, 0, bm.bmWidth, bm.bmHeight, hdcSkinBmp, 0, 0, SRCCOPY
		Invoke EndPaint, hWnd, Addr ps
        Xor Eax, Eax
        Ret
	.ElseIf uMsg == WM_KEYDOWN
		.If wParam == VK_ESCAPE
			Invoke DestroyWindow, hWnd
        .ElseIf wParam == VK_SPACE
        	.If bRegion == FALSE
                ; --> CREATE REGION AND PASS IT TO OUR WINDOW
	        	Invoke ExtCreateRegion, NULL, RsrcSize, RsrcPoint
                Mov hRegion, Eax
		        Invoke SetWindowRgn, hWnd, hRegion, TRUE
		        Mov bRegion, TRUE
        	.ElseIf bRegion == TRUE
		        Invoke SetWindowRgn, hWnd, NULL, TRUE
		        Mov bRegion, FALSE
        	.EndIf
	    .EndIf
        Xor Eax, Eax
        Ret
	.ElseIf uMsg == WM_LBUTTONDOWN
        Invoke SendMessage, hWnd, WM_NCLBUTTONDOWN, HTCAPTION, NULL
        Xor Eax, Eax
        Ret
	.ElseIf uMsg == WM_MOVE
		Invoke GetWindowRect, hWnd, Addr BaseRect
		Mov Eax, BaseRect.left
		Mov MovePt.x, Eax
		Mov Eax, BaseRect.top
        Add Eax, bm.bmHeight
	    Mov MovePt.y, Eax
        Invoke MoveWindow, hWndTxt, MovePt.x, MovePt.y, bm.bmWidth, HeigthCaption, TRUE
        Xor Eax, Eax
        Ret
	.ElseIf uMsg == WM_SHELLNOTIFY
			.If wParam == IDI_TRAY		; like clicking on our icon
			    .If lParam == WM_LBUTTONDOWN
					.If showflag == FALSE
        				;hide:
						Invoke	ShowWindow, hWnd, SW_SHOW
						Invoke	ShowWindow, hWndTxt, SW_SHOW
						Mov showflag, TRUE
					.Else
        				;show:
						Invoke	ShowWindow, hWnd, SW_HIDE
						Invoke	ShowWindow, hWndTxt, SW_HIDE
						Mov showflag, FALSE
				    .EndIf
			    .ElseIf lParam == WM_RBUTTONDOWN
					Invoke	GetCursorPos, Addr pt
					Invoke	SetForegroundWindow, hWnd
					Invoke	TrackPopupMenu, hTrayMenu, TPM_RIGHTALIGN, pt.x, pt.y, NULL, hWnd, NULL
					Invoke	PostMessage, hWnd, WM_NULL, 0, 0
			    .EndIf
			.EndIf
			Xor Eax, Eax
			Ret
	.ElseIf uMsg == WM_DESTROY
		.If hSkinBmp
			Invoke SelectObject, hdcSkinBmp, hOldSkinBmp
			Invoke DeleteObject, hSkinBmp
			Invoke DeleteDC, hdcSkinBmp
		.EndIf
		.If hRegion
			Invoke DeleteObject, hRegion
		.EndIf
		.If RsrcPoint
			Invoke DeleteObject, RsrcPoint
		.EndIf
	    Invoke	Shell_NotifyIcon, NIM_DELETE, Addr node
    	Invoke	DestroyMenu, hTrayMenu
		Invoke  PostQuitMessage, 0
		Xor Eax, Eax
		Ret
	.EndIf
	Invoke DefWindowProc, hWnd, uMsg, wParam, lParam
	Ret
WndMainProc Endp
WndTextProc Proc Private Uses Ebx Edi Esi hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	Local ps:PAINTSTRUCT, hdc:HDC, hPen:HANDLE
	szText szNama, "PAHOR MUSTALY"
 	.If uMsg == WM_CREATE
 			; Init Color ===============
        	RGB 255, 255, 0
        	Mov TxtColor, Eax
        	Mov bTxtShow, TRUE
			RGB 0, 0, 0
        	Mov BgColor, Eax
			Mov bBgShow, TRUE
			; Init Text for Centering ===============
       	    Invoke GetClientRect, hWnd, Addr WndTxtRect
 			Invoke lstrlen, Addr szNama
 			Mov LenTxt, Eax
 			Invoke GetDC, hWnd
 			Mov hdc, Eax
        	Invoke GetTextExtentPoint32, hdc, Addr szNama, LenTxt, Addr SizeTxtStrc
        	Invoke TopXY, SizeTxtStrc.x, WndTxtRect.right
        	Mov PosTxt.x, Eax
        	Invoke TopXY, SizeTxtStrc.y, WndTxtRect.bottom
        	Mov PosTxt.y, Eax
        	Invoke ReleaseDC, hWnd, hdc
			; Init Timer Tick ===============
   	    	Invoke SetTimer, hWnd, IDS_TIMER, 1000, NULL
   	    	Invoke SetTimer, hWnd, IDS_TIMERRECT, 2000, NULL
			Xor Eax, Eax
			Ret
	.ElseIf uMsg == WM_LBUTTONDOWN
	    	Invoke SetActiveWindow, hWndParent
    	    Xor Eax, Eax
        	Ret
	.ElseIf uMsg == WM_RBUTTONDOWN
	    	Invoke SetActiveWindow, hWndParent
    	    Xor Eax, Eax
        	Ret
	.ElseIf uMsg == WM_TIMER
		.If wParam == IDS_TIMER
			.If bTxtShow == TRUE
				m2m TxtColor, BgColor
	            Invoke InvalidateRect, hWnd, Addr WndTxtRect, TRUE
	            Invoke UpdateWindow, hWnd
				Mov bTxtShow, FALSE
			.ElseIf bTxtShow == FALSE
				RGB 255, 255, 0
				Mov TxtColor, Eax
	            Invoke InvalidateRect, hWnd, Addr WndTxtRect, TRUE
	            Invoke UpdateWindow, hWnd
				Mov bTxtShow, TRUE
			.EndIf
		.ElseIf wParam == IDS_TIMERRECT
			.If bBgShow == TRUE
				RGB 0, 128, 255
	        	Mov BgColor, Eax
	            Invoke InvalidateRect, hWnd, Addr WndTxtRect, TRUE
	            Invoke UpdateWindow, hWnd
				Mov bBgShow, FALSE
			.ElseIf bBgShow == FALSE
				RGB 0, 0, 0
	        	Mov BgColor, Eax
	            Invoke InvalidateRect, hWnd, Addr WndTxtRect, TRUE
	            Invoke UpdateWindow, hWnd
				Mov bBgShow, TRUE
			.EndIf
		.EndIf
	Xor Eax, Eax
	Ret
	.ElseIf uMsg == WM_PAINT
            Invoke BeginPaint, hWnd, Addr ps
			Invoke CreateSolidBrush, BgColor
			Mov hbrush, Eax
            Invoke FillRect, ps.hdc, Addr WndTxtRect, hbrush
 			Invoke SetTextColor, ps.hdc, TxtColor
        	Invoke SetBkMode, ps.hdc, TRANSPARENT
 			Invoke TextOut, ps.hdc, PosTxt.x, PosTxt.y, Addr szNama, LenTxt
            Invoke DeleteObject, hbrush
        	Invoke EndPaint, hWnd, Addr ps
       		Xor Eax, Eax
			Ret
	.ElseIf uMsg == WM_DESTROY
			Invoke KillTimer, hWnd, IDS_TIMERRECT
			Invoke KillTimer, hWnd, IDS_TIMER
			Invoke PostQuitMessage, 0
			Xor Eax, Eax
			Ret
	.EndIf
	Invoke DefWindowProc, hWnd, uMsg, wParam, lParam
	Ret
WndTextProc EndP
TopXY Proc wDim:DWord, sDim:DWord
    Shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension
    Return sDim
TopXY EndP
SetTxtClr Proc
    ;ici les trucs de bourin dans le hGIDC
    Sub TxtColor, 100
	RGB 255, 255, 255
    .If TxtColor > Eax
		RGB 255, 255, 0
		Mov TxtColor, Eax
    .ENDIF
    Ret
SetTxtClr EndP
End start

