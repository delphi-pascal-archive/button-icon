unit ImageIcon;

interface

uses windows;

type TImageIcon = record
  Icons: array of HIcon;
  Count: integer;
  Width, Height: integer;
end;

type PImageIcon = ^TImageIcon;

procedure createImageIcon(ImageIcon: PImageIcon; Width, Height: integer);
procedure ImageAddIcon(ImageIcon: PImageIcon; Module: Thandle; IconName: WideString);
procedure DestroyImageIcons(ImageIcon: PImageIcon);

implementation

procedure createImageIcon(ImageIcon: PImageIcon; Width, Height: integer);
begin
  ImageIcon.Count := 0;
  ImageIcon.Icons := nil;
  ImageIcon.Width := Width;
  ImageIcon.Height := Height;
end;

procedure ImageAddIcon(ImageIcon: PImageIcon; Module: Thandle; IconName: WideString);
begin
  inc(ImageIcon.Count);
  SetLength(ImageIcon.Icons, ImageIcon.Count);
  ImageIcon.Icons[ImageIcon.Count - 1] :=
    LoadImageW(Module, PWideChar(IconName), IMAGE_ICON, ImageIcon.Width, ImageIcon.Height, LR_DEFAULTSIZE or LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS);
end;

procedure DestroyImageIcons(ImageIcon: PImageIcon);
var i: integer;
begin
  for I := 0 to ImageIcon.Count - 1 do
    DestroyIcon(ImageIcon.Icons[i]);
  ImageIcon.Count := 0;
  ImageIcon.Icons := nil;
end;

end.
