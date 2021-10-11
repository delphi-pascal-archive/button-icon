unit ButtonStyle;

interface

uses windows, messages, F_Constants, F_SysUtils, F_UxThemes, ImageIcon;

type buttonDanTyp = record
  Caption: WideString;
  WidthIcon, HeightIcon: integer;
  ImageIcon: PImageIcon;
  indexIcon: integer;
end;

type buttonDan_ = record
  Count: integer;
  button: array of buttonDanTyp;
end;

var tme: tagTRACKMOUSEEVENT;
    bNextButtonTrack: boolean = false;
    ButtonDan: buttonDan_;
    ButtonPress: boolean = false;

function PrewWndFunc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
procedure paintButton(h:THandle; DC: HDC; r: TRect; Styl: integer);
procedure OwnerdrawButtonLparam(lpdlParam: LPARAM);
procedure createButton(h:PHandle; x, y, width, height: integer; hwnd: Thandle; idBut: integer; Capt: WideString; ImageIcon: PImageIcon; idexIcon: integer);
procedure destroyButtonList;

implementation

procedure destroyButtonList;
begin
  ButtonDan.Count := 0;
  ButtonDan.button := nil;
end;

procedure ProverkaClassName(h: Thandle);
var Point : TPoint; // Запись, содержит координаты по X и Y
    Bufer, Bufer2 : array[0..255] of WideChar; // будем записывать имя класса
    hNew : THandle;  // Хендл Окна под курсором
begin
  GetCursorPos(Point); // Получаем координаты курсора
  hNew := WindowFromPoint(Point); // Получаем хендл окна под курсором
  FillChar(Bufer,sizeof(Bufer),#0);// Заполняем массив #0
  FillChar(Bufer2,sizeof(Bufer),#0);
  GetClassNameW(hNew,Bufer,255); // Получаем имя класса под курсором
  GetClassNameW(h,Bufer2,255); // Получаем имя класса
  if WideString(bufer) = WideString(bufer2) then invalidateRect(hNew, nil, false);
end;

function PrewWndFunc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := 0;
  case uMsg of
    WM_MOUSEMOVE:
      begin
        if not bNextButtonTrack then begin
          tme.cbSize := SizeOf(tagTRACKMOUSEEVENT);
          tme.hwndTrack := hwnd;
          tme.dwFlags := TME_LEAVE;
          tme.dwHoverTime := 0;
          bNextButtonTrack := TrackMouseEvent(tme);
          invalidateRect(hwnd, nil, false);
        end;
        Result := CallWindowProcW(BtnProc, hWnd, uMsg, wParam, lParam);
      end;
    wm_lbuttonup:begin
      ProverkaClassName(hwnd);
      buttonPress := false;
      Result := CallWindowProcW(BtnProc, hWnd, uMsg, wParam, lParam);
    end;
    WM_MOUSELEAVE: begin
      bNextButtonTrack := not bNextButtonTrack;
      invalidateRect(hwnd, nil, false);
    end
  else
    Result := CallWindowProcW(BtnProc, hWnd, uMsg, wParam, lParam);
  end;
end;

procedure createButton(h:PHandle; x, y, width, height: integer; hwnd: Thandle; idBut: integer; Capt: WideString; ImageIcon: PImageIcon; idexIcon: integer);
begin
  if ButtonDan.Count < 0 then ButtonDan.Count := 0;
  inc(ButtonDan.Count);
  SetLength(ButtonDan.button, ButtonDan.Count);
  ButtonDan.button[ButtonDan.Count - 1].Caption := Capt;
  ButtonDan.button[ButtonDan.Count - 1].ImageIcon := ImageIcon;
  ButtonDan.button[ButtonDan.Count - 1].indexIcon := idexIcon;

  h^ := CreateWindowW(Button, PWideChar(int2str(ButtonDan.Count)), BS_OWNERDRAW
                                          or WS_CHILD or WS_VISIBLE, x, y, width, height,
                                          hWnd, idBut, HInstance, nil);
  if ButtonDan.Count = 1 then begin
    BtnProc := Pointer(GetWindowLongW(h^, GWL_WNDPROC));
  end;
  SetWindowLongW(h^, GWL_WNDPROC, Integer(@PrewWndFunc));
end;

procedure paintButton(h:THandle; DC: HDC; r: TRect; Styl: integer);
var NewStylte: DWORD;
    OldStylte: DWORD;
    lpBuffer : Array [0..MAX_PATH - 1] of WideChar;
    indexBut: integer;
    lb: LOGBRUSH;
    PenOld, Pen: HPEN;
    b: boolean;
    LeftIcon: integer;
begin
b := false;
{ копируем текст кнопки во временный буфер }
SendMessageW(h, WM_GETTEXT, SizeOf(lpBuffer), LPARAM(@lpBuffer));
indexBut := str2int(lpBuffer) - 1;

NewStylte := 0; oldStylte := 0;
case Styl of
PBS_NORMAL:begin
  NewStylte := PBS_NORMAL;
  OldStylte := DFCS_BUTTONPUSH;
end;
PBS_HOT:begin
  NewStylte := PBS_HOT;
  OldStylte := DFCS_BUTTONPUSH or DFCS_HOT;
end;
PBS_PRESSED:begin
  NewStylte := PBS_PRESSED;
  OldStylte := DFCS_BUTTONPUSH or DFCS_PUSHED;
end;
PBS_DISABLED:begin
  NewStylte := PBS_DISABLED;
  OldStylte := DFCS_BUTTONPUSH or DFCS_INACTIVE;
end;
PBS_DEFAULTED:begin
  NewStylte := PBS_DEFAULTED;
  OldStylte := DFCS_BUTTONPUSH;
end;
end;
if InitThemeLibrary and UseThemes then
    begin
      if IsManXP then
        DrawThemeBackground(BtnTheme, DC, BP_PUSHBUTTON, NewStylte, r, nil)
      else begin
        DrawFrameControl(DC, r, DFC_BUTTON, OldStylte);
        b := true;
      end;
    end
  else begin
    DrawFrameControl(DC, r, DFC_BUTTON, OldStylte);
    b := true;
  end;

if b and (GetFocus = h) then begin

  // Инициализация кисти пера.
  lb.lbStyle := BS_SOLID;
  lb.lbColor := 0;
  lb.lbHatch := 10;
  Pen := ExtCreatePen(PS_COSMETIC or PS_ALTERNATE, 1, lb, 0, nil);//создаём перо
  PenOld := SelectObject(dc, Pen);//выбираем перо

  MoveToEx(dc, 3, 3, nil);
  LineTo(dc, r.Right - 4, 3);
  MoveToEx(dc, 3, r.Bottom - 4, nil);
  LineTo(dc, r.Right - 4, r.Bottom - 4);

  MoveToEx(dc, 3, 3, nil);
  LineTo(dc, 3, r.Bottom - 4);
  MoveToEx(dc, r.Right - 4, 3, nil);
  LineTo(dc, r.Right - 4, r.Bottom - 4);

  SelectObject(dc, PenOld);//возвращаем старое перо
  DeleteObject(Pen);//удаляем перо
end;

if buttonDan.button[indexBut].ImageIcon.Icons[buttonDan.button[indexBut].indexIcon] <> 0 then begin
{ пересчитываем координаты и отображаем значок }
  LeftIcon := buttonDan.button[indexBut].ImageIcon.Width div 2;
  r.Left  := r.Left + LeftIcon;
  r.Right := r.Right - LeftIcon;
  DrawIconEx(DC, r.Left, r.Top + ((r.Bottom - r.Top) div 2) - (LeftIcon), buttonDan.button[indexBut].ImageIcon.Icons[buttonDan.button[indexBut].indexIcon], buttonDan.button[indexBut].ImageIcon.Width, buttonDan.button[indexBut].ImageIcon.Height, 0, 0, DI_NORMAL);
  r.Left  := r.Left - LeftIcon;
  r.Right := r.Right + LeftIcon;
  r.Left  := LeftIcon + buttonDan.button[indexBut].ImageIcon.Width;
  r.Right := r.Right - LeftIcon;
end;
{ отображаем текстовую информацию на кнопке }
  if InitThemeLibrary and UseThemes then
    begin
      if IsManXP then
        DrawThemeText(BtnTheme, DC, BP_PUSHBUTTON, NewStylte, PWideChar(buttonDan.button[indexBut].Caption), -1, DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER or DT_CENTER, 0, r)
      else
        DrawTextW(DC, PWideChar(buttonDan.button[indexBut].Caption), -1, r, DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER or DT_CENTER);
    end
  else
    DrawTextW(DC, PWideChar(buttonDan.button[indexBut].Caption), -1, r, DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER or DT_CENTER);
end;

procedure OwnerdrawButtonLparam(lpdlParam: LPARAM);
var
  lpdis    : PDrawItemStruct;
  Font, oldFont: hfont;
  DCButton: HDC;
  BitmapButton, oldBitmapButton: hbitmap;
  Brush, oldBrush: HBrush;
  pt: TPoint;
  wndMouse: THandle;

  procedure CreatePaintButton;
  begin
    DCButton := CreateCompatibleDC(lpdis.hDC);
    brush:=CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
    OldBrush := SelectObject(DCButton, brush);
    Font := CreateFont(-11, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET or ANSI_CHARSET or RUSSIAN_CHARSET or SYMBOL_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, 'MS sans-serif');
    oldFont := SelectObject(DCButton, Font);
    BitmapButton := CreateCompatibleBitmap(lpdis.hDC, lpdis.rcItem.Right, lpdis.rcItem.Bottom);
    oldBitmapButton := SelectObject(DCButton, BitmapButton);
    SetBkMode(DCButton, TRANSPARENT);
    FillRect(DCButton, lpdis.rcItem, brush);
  end;

  procedure DestroyPaintButton;
  begin
    SelectObject(DCButton, oldFont);
    SelectObject(DCButton, oldbrush);
    SelectObject(DCButton, oldBitmapButton);
    DeleteObject(Font);
    DeleteObject(Brush);
    DeleteObject(BitmapButton);
    DeleteDC(DCButton);
  end;

begin
  lpdis := PDrawItemStruct(lpdlParam);
  { отображаем фоновое изображение кнопки }
  CreatePaintButton;
  GetCursorPos(pt);
  wndMouse := WindowFromPoint(Pt);
  if (lpdis.itemState and ODS_SELECTED) <> 0 then
  begin
    paintButton(lpdis.hwndItem,DCButton, lpdis.rcItem, PBS_PRESSED);
    buttonPress := true;
  end else begin
    if wndMouse = lpdis.hwndItem then begin
      paintButton(lpdis.hwndItem,DCButton, lpdis.rcItem, PBS_Hot);
    end else
    if (wndMouse <> lpdis.hwndItem) and (GetKeyState(1) and 128 = 128) and (GetFocus = lpdis.hwndItem) and buttonPress then begin
      paintButton(lpdis.hwndItem,DCButton, lpdis.rcItem, PBS_Hot);
    end else begin
      if (lpdis.itemState and ODS_FOCUS) <> 0 then begin
        paintButton(lpdis.hwndItem, DCButton, lpdis.rcItem, PBS_DEFAULTED);
      end else
        paintButton(lpdis.hwndItem, DCButton, lpdis.rcItem, PBS_NORMAL);
    end;
  end;
  BitBlt(lpdis.hDC, 0, 0, lpdis.rcItem.Right, lpdis.rcItem.Bottom, DCButton, 0, 0, SRCCOPY);
  { удаляем все созданные ранее объекты }
  DestroyPaintButton;
end;

end.
