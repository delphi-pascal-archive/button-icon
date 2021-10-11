unit F_Constants;

interface

uses
  Windows, Messages, F_UxThemes;

const
  ID_BUTTON = 101;
  ID_BUTTON2 = 102;
  ID_BUTTON3 = 103;
  Button = 'Button';

var
  BtnTheme: hTheme;
  BtnProc : Pointer;
  IsManXP : Boolean;
  MainWnd : THandle;
  hTestBtn, hTestBtn2, hTestBtn3: thandle;
  wndFocus: THandle;

implementation

end.