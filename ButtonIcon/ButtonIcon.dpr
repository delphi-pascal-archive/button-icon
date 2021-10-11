Program ButtonIcon;

{$R IconButton.res}

uses
  Windows,
  Messages,
  F_UxThemes,
  F_SysUtils,
  F_Constants,
  ButtonStyle in 'ButtonStyle.pas',
  ImageIcon in 'ImageIcon.pas';

Procedure InitCommonControls; Stdcall; External 'comctl32.dll';

var imageIcon1: TImageIcon;

function MainDlgProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): Cardinal; stdcall;
begin
  case uMsg of

    WM_CREATE:
      begin
        if IsManifestAvailableW(ParamStrW()) then
          IsManXP := TRUE
        else
          IsManXP := FALSE;
        if InitThemeLibrary and UseThemes then
          BtnTheme := OpenThemeData(hwnd, Button);

        createImageIcon(@imageIcon1, 24, 24);//������� ������ icon
        ImageAddIcon(@imageIcon1, hinstance, '#101');//��������� icon �� ��������
        ImageAddIcon(@imageIcon1, hinstance, '#102');
        ImageAddIcon(@imageIcon1, hinstance, '#103');

        createButton(@hTestBtn, 45, 20, 150, 32, hwnd, ID_BUTTON, 'TestButton1', @imageIcon1, 0);
        createButton(@hTestBtn2, 45, 55, 150, 32, hwnd, ID_BUTTON2, 'TestButton2', @imageIcon1, 1);
        createButton(@hTestBtn3, 45, 90, 150, 32, hwnd, ID_BUTTON3, 'TestButton3', @imageIcon1, 2);
        wndFocus := hTestBtn;
        SetForegroundWindow(hwnd);
      end;
    wm_activate: begin
      if GetFocus <> 0 then if LOWORD(wParam) = WA_INACTIVE then wndFocus := GetFocus;
    end;
    WM_SYSCOMMAND: begin
      if wParam = SC_MINIMIZE then if GetFocus <> 0 then wndFocus := GetFocus;
    end;
    wm_setfocus: begin
      SetFocus(wndFocus);
    end;
    WM_THEMECHANGED:
      begin
        if IsManifestAvailableW(ParamStrW()) then
          IsManXP := TRUE
        else
          IsManXP := FALSE;
        if InitThemeLibrary and UseThemes then
          begin
            CloseThemeData(BtnTheme);
            BtnTheme := OpenThemeData(hwnd, Button);
          end;
      end;

    {}
    WM_DRAWITEM:
      begin
        case LoWord(wParam) of
          ID_BUTTON, ID_BUTTON2, ID_BUTTON3:
           OwnerdrawButtonLparam(lParam);
        end;
      end;

    {}
    WM_COMMAND:
      begin
        if HiWord(wParam) = BN_CLICKED then
          case LoWord(wParam) of
            ID_BUTTON:
              Messagebox(hwnd,'TestButton1','',0);
            ID_BUTTON2:
              Messagebox(hwnd,'TestButton2','',0);
            ID_BUTTON3:
              Messagebox(hwnd,'TestButton3','',0);
          end;
      end;

   {}
    WM_LBUTTONDOWN:
      SendMessageW(hwnd, WM_NCLBUTTONDOWN, HTCAPTION, lParam);

    {}
    WM_DESTROY, WM_CLOSE:
      begin
        if InitThemeLibrary and UseThemes then
          CloseThemeData(BtnTheme);
        DestroyWindow(hTestBtn);//������� ������
        DestroyWindow(hTestBtn2);
        DestroyWindow(hTestBtn3);
        DestroyImageIcons(@imageIcon1);//������� ������ ������
        destroyButtonList;//������� ������ � ����������� � ��������
        PostQuitMessage(0);
      end;

  end;
Result := DefWindowProc(HWnd, uMsg, WParam, LParam);
end;

Procedure WinMain;

Var

Msg: TMsg;

{ ������� ����� }

WndClassEx: TWndClassEx;

screenW, screenH: integer;

Begin

{ ���������� ��������� ������ ���� }

ZeroMemory(@WndClassEx, SizeOf(WndClassEx));

{************* ���������� ��������� ������� ���������� ******************* }

{ ������ ��������� }

WndClassEx.cbSize := SizeOf(TWndClassEx);

{ ��� ������ ���� }

WndClassEx.lpszClassName := 'Window_in_button';

{ ����� ������, �� ���� }

WndClassEx.style := CS_VREDRAW Or CS_HREDRAW;

{ ���������� ��������� (��� ������� � �������� ������) }

WndClassEx.hInstance := HInstance;

{ ����� ������� ��������� }

WndClassEx.lpfnWndProc := @MainDlgProc;

{ ������ }

WndClassEx.hIcon :=  LoadIcon(HInstance, MakeIntResource('MAINICON'));

WndClassEx.hIconSm := LoadIcon(HInstance, MakeIntResource('MAINICON'));

{ ������ }

WndClassEx.hCursor := LoadCursor(0, IDC_ARROW);

{ ����� ��� ���������� ���� }

WndClassEx.hbrBackground := COLOR_BTNFACE + 1;

{ ���� }

WndClassEx.lpszMenuName := NIL;



{ ����������� �������� ������ � Windows }

If RegisterClassEx(WndClassEx) = 0 Then

   MessageBox(0, '���������� ���������������� ����� ����',

     '������', MB_OK Or MB_ICONHAND)

Else

Begin

   { �������� ���� �� ������������������� ������ }

   screenW:=GetSystemMetrics(SM_CXSCREEN);//�������� ������ ������
   screenH:=GetSystemMetrics(SM_CYSCREEN);//�������� ������ ������


   MainWnd := CreateWindow(WndClassEx.lpszClassName,

       'Window in button', ws_visible or WS_OVERLAPPEDWINDOW And Not WS_BORDER

        And Not WS_MAXIMIZEBOX And Not WS_SIZEBOX,

        (screenW - 250) div 2, (screenH - 170) div 2, 250, 170, 0, 0,

        HInstance, NIL);



   If MainWnd = 0 Then

     MessageBox (0, '���� �� ���������!',

       '������', MB_OK Or MB_ICONHAND)

   Else

   Begin

     { ����� ���� }

     ShowWindow(MainWnd, SW_SHOWNORMAL);

     { ���������� ���� }

     UpdateWindow(MainWnd);

     { ���� ��������� ��������� }

     While GetMessage(Msg, 0, 0, 0) Do

     Begin

      if (not IsDialogMessage(MainWnd, msg)) then begin

        TranslateMessage(Msg);

        DispatchMessage(Msg);

      end;

     End;

     { ����� �� ���������� ����� }

     Halt(Msg.WParam);

   End;

End;

End;



Begin

InitCommonControls;

{ �������� ���� }

WinMain;

End.
