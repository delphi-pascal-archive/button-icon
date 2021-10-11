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

        createImageIcon(@imageIcon1, 24, 24);//создаем массив icon
        ImageAddIcon(@imageIcon1, hinstance, '#101');//загружаем icon из ресурсов
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
        DestroyWindow(hTestBtn);//удаляем кнопку
        DestroyWindow(hTestBtn2);
        DestroyWindow(hTestBtn3);
        DestroyImageIcons(@imageIcon1);//удаляем значки кнопок
        destroyButtonList;//удаляем массив с информацией о кнопоках
        PostQuitMessage(0);
      end;

  end;
Result := DefWindowProc(HWnd, uMsg, WParam, LParam);
end;

Procedure WinMain;

Var

Msg: TMsg;

{ Оконный класс }

WndClassEx: TWndClassEx;

screenW, screenH: integer;

Begin

{ Подготовка структуры класса окна }

ZeroMemory(@WndClassEx, SizeOf(WndClassEx));

{************* Заполнение структуры нужными значениями ******************* }

{ Размер структуры }

WndClassEx.cbSize := SizeOf(TWndClassEx);

{ Имя класса окна }

WndClassEx.lpszClassName := 'Window_in_button';

{ Стиль класса, не окна }

WndClassEx.style := CS_VREDRAW Or CS_HREDRAW;

{ Дескриптор программы (для доступа к сегменту данных) }

WndClassEx.hInstance := HInstance;

{ Адрес оконной процедуры }

WndClassEx.lpfnWndProc := @MainDlgProc;

{ Иконки }

WndClassEx.hIcon :=  LoadIcon(HInstance, MakeIntResource('MAINICON'));

WndClassEx.hIconSm := LoadIcon(HInstance, MakeIntResource('MAINICON'));

{ Курсор }

WndClassEx.hCursor := LoadCursor(0, IDC_ARROW);

{ Кисть для заполнения фона }

WndClassEx.hbrBackground := COLOR_BTNFACE + 1;

{ Меню }

WndClassEx.lpszMenuName := NIL;



{ Регистрация оконного класса в Windows }

If RegisterClassEx(WndClassEx) = 0 Then

   MessageBox(0, 'Невозможно зарегистрировать класс окна',

     'Ошибка', MB_OK Or MB_ICONHAND)

Else

Begin

   { Создание окна по зарегистрированному классу }

   screenW:=GetSystemMetrics(SM_CXSCREEN);//Получить ширину экрана
   screenH:=GetSystemMetrics(SM_CYSCREEN);//Получить высоту экрана


   MainWnd := CreateWindow(WndClassEx.lpszClassName,

       'Window in button', ws_visible or WS_OVERLAPPEDWINDOW And Not WS_BORDER

        And Not WS_MAXIMIZEBOX And Not WS_SIZEBOX,

        (screenW - 250) div 2, (screenH - 170) div 2, 250, 170, 0, 0,

        HInstance, NIL);



   If MainWnd = 0 Then

     MessageBox (0, 'Окно не создалось!',

       'Ошибка', MB_OK Or MB_ICONHAND)

   Else

   Begin

     { Показ окна }

     ShowWindow(MainWnd, SW_SHOWNORMAL);

     { Обновление окна }

     UpdateWindow(MainWnd);

     { Цикл обработки сообщений }

     While GetMessage(Msg, 0, 0, 0) Do

     Begin

      if (not IsDialogMessage(MainWnd, msg)) then begin

        TranslateMessage(Msg);

        DispatchMessage(Msg);

      end;

     End;

     { Выход по прерыванию цикла }

     Halt(Msg.WParam);

   End;

End;

End;



Begin

InitCommonControls;

{ Создание окна }

WinMain;

End.
