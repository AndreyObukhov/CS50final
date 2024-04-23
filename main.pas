{Kalkulacka dlouhych cisel}
{Andrey Obukhov}
{1. rocnik, skupina 15/I/12}
{letni semestr 2014/2015}
{zapoctovy program}
Program Kalkulacka;
uses crt;
const MaxCislo = 1000; {Max pocet ctyrcifernych 'cifer' v cisle}
      Zaklad = 10000; {zaklad ciselne soustavy}
type TCislo  = array[-1..MaxCislo] of integer;
    {deklarace dlouheho cisla, v polozke -1 je znamenko,
    v polozke 0 je pocet 'cifer'}

Procedure Nacti(Var T:text; Var A:Tcislo);
Var i:integer; ch:char;
begin
{FillChar(A, SizeOf(A), 0); }
read(T,ch);
if (ch='0') and eoln(T) then begin inc(A[0]); readln(T); exit end;
While not(ch in ['0'..'9','-'] ) do read(T,ch);
if ch='-' then
   begin
   {poznamename zaporne dlouhe cislo}
   A[-1]:=1; read(T,ch)
   end;
while ch in ['0'..'9'] do
   begin
   for i:=A[0] downto 1 do
      begin
      A[i+1]:=A[i+1]+longint(A[i])*10 div Zaklad;
      A[i]:=(longint(A[i])*10) mod Zaklad
      end;
    A[1]:=A[1]+ord(ch)-ord('0');
    if A[A[0]+1]>0 then inc(A[0]);
    read(T,ch)
   end;
readln(T);
if A[0]=0 then
   begin
   writeln('chyba:spatne vstupni data');
   close(T); readln;
   halt
   end
end;  {konec Nacti}

Procedure Vypis(Var T:text; A:TCislo);
Var i:integer; s,s1:string;
begin
str(Zaklad div 10,s1);
if A[0]=0 then begin writeln(T,'prazdne cislo'); exit end;
if (A[-1]=1) and (A[0]+A[1]>1) then write(T,'-');
write(T,A[A[0]]);
for i:=A[0]-1 downto 1 do
   begin
   str(A[i],s);
   while length(s)<length(s1) do s:='0'+ s;
   write(T,s)
   end;
writeln(T);
end; {konec Vypis}

Procedure Secti(const A,B:TCislo; Var C:TCislo; posun:integer);
Var i,pocet:integer;
begin
FillChar(C, SizeOf(C), 0);
if A[0]>B[0]+posun then pocet:=A[0]
             else pocet:=B[0]+posun;
for i:=1 to pocet do
   begin
   if i>posun then
     begin
     C[i+1]:= (C[i]+A[i]+B[i-posun]) div Zaklad;
     C[i]:=  (C[i]+A[i]+B[i-posun]) mod Zaklad
     end
   else
     C[i]:=A[i]
   end;
if C[pocet+1]=0 then C[0]:=pocet else C[0]:=pocet+1
end; {konec Secti}

Function Porovnej(A,B:TCislo; posun:integer):byte;
Var i:integer;
begin
if A[0]>B[0]+posun then begin Porovnej:=0;  exit end;
if A[0]<B[0]+posun then begin Porovnej:=1;  exit end;
i:=A[0];
while (i>posun) and (A[i]=B[i-posun]) do dec(i);
if i = posun then
  begin
  Porovnej:=0;
  for i:=1 to posun do
  if A[i] > 0 then exit;
  Porovnej:=2
  end
  else Porovnej:=Byte(A[i]<B[i-posun])
end; {konec Porovnej}


Procedure NasInt(A:TCislo; cislo:longint; Var C:TCislo);
   Var i:integer;
   begin
   FillChar(C,SizeOf(C), 0);
   if cislo = 0 then begin inc(C[0]); exit end;
   for i:=1 to A[0] do
     begin
     C[i+1]:=(longint(A[i])*cislo+C[i]) div Zaklad;
     C[i]:=(longint(A[i])*cislo+C[i]) mod Zaklad
     end;
     if C[A[0]+1]>0 then C[0]:=A[0]+1
     else C[0]:=A[0]
end; {konec NasInt}


Procedure Nasobeni(A,B:TCislo; Var C:TCislo);
Var i:integer; Q,M:TCislo;
begin
FillChar(C,SizeOf(C), 0);
{nasobeni nulou}
if (A[0]+A[1]=1) or (B[0]+B[1]=1) then begin inc(C[0]); exit end;
FillChar(M,SizeOf(M), 0);
for i:=1 to B[0] do
  begin
  NasInt(A,B[i],Q);
  Secti(C,Q,M,i-1); C:=M
  end;
end; {konec Nasobeni}


Procedure Odecitani(Var A:TCislo; const B:TCislo; const posun:integer);
Var i,j:integer;
begin
  for i:=1 to B[0] do
  begin dec(A[i+posun],B[i]);
        j:=i;
        while (A[j+posun]<0) and (j<=A[0]) do
          begin
          inc(A[j+posun],Zaklad);
          dec(A[j+posun+1]); inc(j)
          end;
  end;
i:=A[0];
while (i>1) and (A[i] = 0) do dec(i);
A[0]:=i
end; {konec Odecitani}

Function BinVyhled(Var Zbytek:TCislo;
const B:TCislo; const posun:integer):longint;
Var Down,Up:Word; C:TCislo;
begin
  Down:=0; Up:=Zaklad;
  while Up-1 > Down do
    begin
    NasInt(B, (Up+Down) div 2,C);
    Case Porovnej(Zbytek,C,posun) of
    0:Down:=(Down+Up)div 2;
    1:Up:=(Down+Up)div 2;
    2: begin Up:=(Down+Up)div 2; Down:=Up end
    end
  end; {konec While-cyklu}
NasInt(B,(Up+Down) div 2,C);
if Porovnej(Zbytek,C,0)=0 then Odecitani(Zbytek,C,posun)
else begin Odecitani(C,Zbytek,posun); Zbytek:=C end;
BinVyhled:=(Up+Down) div 2; {vysledek vyhledavani}
end; {konec BinVyhled}

Procedure DeleniPom(const A,B:TCislo; Var Vysledek,Zbytek:TCislo);
Var posun:integer;
begin
 Zbytek:=A;
 posun:=A[0]-B[0];
 if Porovnej(A,B,posun) = 1 then Dec(posun);
 Vysledek[0]:=posun+1;
 While posun>=0 do
 begin
   Vysledek[posun+1]:=BinVyhled(Zbytek,B,posun);
   dec(posun)
   end
end; {konec DeleniPom}

Procedure Deleni(const A,B:TCislo;Var Vysledek, Zbytek:TCislo);
begin
FillChar(Vysledek,SizeOf(Vysledek), 0);
FillChar(Zbytek,SizeOf(Zbytek), 0);
if (B[0]=1) and (B[1]=0) then begin writeln('chyba:deleni nulou'); readln;
halt end;
Case Porovnej(A,B,0) of
  0:DeleniPom(A,B,Vysledek,Zbytek);
  1:begin inc(Vysledek[0]); Zbytek:=A end;
  2:begin inc(Zbytek[0]); Vysledek[0]:=1; Vysledek[1]:=1 end
  end
end; {konec deleni}

Function Odecit2(A,B:TCislo):TCislo;
{pomocna funkce pro odecitani,
vrati A-B se spravnym znamenkem}
Var c:integer;
begin
if Porovnej(A,B,0) in [0,2] then begin c:=0;
                Odecitani(A,B,0); Odecit2:=A end
else begin c:=1; Odecitani(B,A,0); B[-1]:=1; odecit2:=B end;
odecit2[-1]:=c
end; {konec Odecit2}

Function Vyres(const A,B:TCislo; const operace:char):TCislo;
{provede z A, B prislusnou operace znak
a vrati vysledek}
Var vysledek,C:TCislo;
begin
case operace of
{v komentarech jsou oznaceny pripady,
pro ktere urceny tyto prikazy}
'+':begin
    if A[-1]=B[-1] then
        begin
        {+++ a -+-}
        Secti(A,B,vysledek,0);
        vysledek[-1]:=A[-1]
        end;
    if (A[-1]=0) and (B[-1]=1) then
        begin
        {++-}
        vysledek:= Odecit2(A,B)
        end;
    if (A[-1]=1) and (B[-1]=0) then
        begin
        {-++}
        vysledek:=Odecit2(A,B);
        {menime znamenko}
        if vysledek[-1]=1 then vysledek[-1]:=0
        else vysledek[-1]:=1
        end
end;  {konec +}

'-':begin
    if (A[-1]=0) and (B[-1]=1) then
        begin
        {+--}
        Secti(A,B,Vysledek,0)
        end;
    if (A[-1]=1) and (B[-1]=1) then
        begin
        {---}
        vysledek:=Odecit2(A,B);
        if vysledek[-1]=1 then vysledek[-1]:=0
        else vysledek[-1]:=1
        end;
    if (A[-1]=1) and (B[-1]=0) then
        begin
        {--+}
        Secti(A,B,Vysledek,0);
        Vysledek[-1]:=1
        end;
    if (A[-1]=0) and (B[-1]=0) then
        begin
        {+-+}
        vysledek:=Odecit2(A,B);
        end
end; {konec -}
'*':begin
    Nasobeni(A,B,vysledek);
    case A[-1]+B[-1] of
    0,2: Vysledek[-1]:=0;
    1: Vysledek[-1]:=1
    end
end; {konec *}
'd':begin
    Deleni(A,B,vysledek,C);
    if (A[-1]+B[-1]) in [0,2] then vysledek[-1]:=0;
    if (A[-1]=1) and (B[-1]=0) then vysledek[-1]:=1;
    if (A[-1]=0) and (B[-1]=1) then vysledek[-1]:=1
end; {konec d}
'm':begin
    Deleni(A,B,C,vysledek);
    if (A[-1]=0) and (B[-1]=0) then vysledek[-1]:=0;
    if (A[-1]=1) and (B[-1]=1) then vysledek[-1]:=1;
    if (A[-1]=1) and (B[-1]=0) then vysledek[-1]:=1;
    if (A[-1]=0) and (B[-1]=1) then vysledek[-1]:=0
end; {konec m}
end; {konec Case}
Vyres:=vysledek
end; {konec Vyres}

Var vstup,vystup:text;
i:integer;
A,B,C,D:TCislo;  operace:char;
begin
clrscr;
assign(vstup,'vstup.txt');
reset(vstup);
nacti(vstup,A);
assign(vystup,'vystup.txt'); rewrite(vystup);
while not eof(vstup) do
  begin
  readln(vstup,operace);
  if not (operace in ['+','-','*','m','d']) then
     begin writeln('chyba:neznama operace!'); readln; halt end;
  FillChar(B,SizeOf(B), 0);
  nacti(vstup,B);
  A:=Vyres(A,B,operace);
  {vypisvat mezivysledky:
  write(vystup,':'); vypis(vystup,A);   }
end;
close(vstup);
vypis(vystup,A);
close(vystup)
end.
