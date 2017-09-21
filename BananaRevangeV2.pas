Program BananaRevange2;
{Szymon Majkut, projekt zaliczeniowy WDI - Space Invaders}
uses crt, DOS, allegro;

type
  przeciwnik = record
    polozenieX : integer;
    polozenieY : integer;
    zyje : integer;
    rodzaj : integer;
    {
    0. Podstawowy, strzela losowo
    1. Strzela tylko tam, gdzie nie ma barier
    2. Snajper, wykorzystuje ten algorytm sztucznej inteligencji, aby zawsze trafic
    3. Boss, potrafi się zaslaniac tarcza, dopoki nie zabije sie jego malp naokolo, a pozniej caly czas szczylo
    i jest troche wiekszy od pozostalych, poza tym stoi w miejscu i schodzi tylko w dol, poki sa jego pomagierzy
    }

  end;

  bonusy = record

    polozenieX : integer;
    polozenieY : integer;
    stan : integer;
    komunikat : integer; {potrzebny do funkcji draw}
    czaskomunikatu : integer; {żeby tak nagle nie zniknąl}
    rodzaj : integer;
    {
     Tu rozpiska rodzajów
     1. Dodatkowe zycie g
     2. Torpeda - likwiduje wszystkie pociski malp g
     3. Broń switcher  g
     4. Kierunek malp switcher g
     5. Przyspieszenie malp g
     6. Spowolnienie malp g
     7. Tarcza - nietykalnosc na krotkoe g
     8. Zamrozenie, ktore trwa az do trafienia kolejnej malpki g
     9. Ognista Kula, zabija dodatokowo malpki zaraz na gorze i po bokach, trwa krotko g
     10. obsolete odbudowa barier
    }
    torpedy : integer;
    CzasTorpedy : integer;
    CzasTarczy : integer;
    CzasOgnia : integer;
    Mroz : integer;
    drugi_stan : integer;
    drugi_polozenieX : integer;
    drugi_polozenieY : integer;
  end;

  gracz = record
    polozenieX : integer;
    punkty : integer;
    zycia : integer;
    pseudonim : string;
    rodzajbroni : integer; {0. - strzalki 1. - laser}
    pociski : array [0..471] of integer;
    lasergotowy : integer; {0 . - wylaczony, 1. - laduje sie 2. - naladowany}
    opoznienielasera : integer;
  end;

  bariera = record
    polozenieX : integer;
    polozenieY : integer;{pojawiaja sie w zakresie 340 - 380}
    stan : integer;
    rodzaj : integer;
  end;

  wyglad = record
    gracz : ^AL_BITMAP;
    malpa : ^AL_BITMAP;
    bariery : ^AL_BITMAP;
    bonus : ^AL_BITMAP;
    pocisk : ^AL_BITMAP;
    bufor : ^AL_BITMAP;
    tlo : ^AL_BITMAP;
    klatka_malp : integer;

    dzwiek_malpa_dead : ^AL_SAMPLE;
    dzwiek_malpa_rzut : ^AL_SAMPLE;
    dzwiek_malpa_slap : ^AL_SAMPLE;
    dzwiek_laser1 : ^AL_SAMPLE;
    dzwiek_laser2 : ^AL_SAMPLE;
    dzwiek_losegame : ^AL_SAMPLE;
    dzwiek_shot : ^AL_SAMPLE;
    dzwiek_wingame : ^AL_SAMPLE;
    dzwiek_yee : ^AL_SAMPLE;
    dzwiek_torpeda : ^AL_SAMPLE;
    dzwiek_fire : ^AL_SAMPLE;
    dzwiek_frost : ^AL_SAMPLE;
    dzwiek_music : ^AL_SAMPLE;
    dzwiek_music2 : ^AL_SAMPLE;
  end;


const

    ScreenWidth= 640;
    ScreenHeight= 480;
    polozenie_karabinuY = 420;

var

grafika : wyglad;
plik:Text;
doplikow:string;
dobitmap : ^al_palette;

koniec : integer;
h1,h2,m1,m2,s1,s2,sek100,sek200:word;
czaszrownowazenia : integer;
endOfgame : integer;
endOflev : integer;
poziom : integer;
ilemalp : integer;
bossprzerwa : integer;

gracz1 : gracz;
gracz2 : gracz;
ilegraczy : integer;
bariery : array [0..100] of bariera;
malpy : array [0..100] of przeciwnik;
zyciebossa : integer;
pozycjegracza : array [0..45] of integer;
ilezyje : integer;
stronaruchu : integer;
opoznieniemalp : integer;
przeskokmalpy : integer;
czestoscwystrzlu : integer;
przeskokwystrzalu : integer;
opoznieniepocisku : integer;
przeskokpocisku : integer;{okresla ile naszych cykli nastapi w jednym cyklu malp}
pociskimalp : array [0..471] of integer;

bonus : bonusy;

procedure inicjalizacja;   {do biblioteki allegro}
begin
al_init;
al_install_keyboard;
al_install_timer;
al_install_sound(AL_DIGI_AUTODETECT, AL_MIDI_AUTODETECT);
al_set_color_depth(32);
al_set_gfx_mode(Al_GFX_AUTODETECT_WINDOWED,ScreenWidth,ScreenHeight,0,0);
al_set_window_title('BananaRevangeV2');

al_set_volume( 200, 200 );

{tworzenie bitmapek i sampli}
grafika.bufor := al_create_bitmap( 640, 480 );
grafika.tlo := al_create_bitmap( 1320, 960 );
grafika.gracz := al_create_bitmap(240,60);
grafika.bonus := al_create_bitmap(20,20);
grafika.pocisk := al_create_bitmap(50,30);
grafika.malpa := al_create_bitmap(120,130);
grafika.bariery := al_create_bitmap(20,20);

grafika.dzwiek_malpa_dead := al_create_sample(16,1,10,1000);
grafika.dzwiek_malpa_rzut := al_create_sample(16,1,10,1000);
grafika.dzwiek_malpa_slap := al_create_sample(16,1,10,1000);
grafika.dzwiek_laser1 := al_create_sample(16,1,10,1000);
grafika.dzwiek_laser2 := al_create_sample(16,1,10,1000);
grafika.dzwiek_losegame := al_create_sample(16,1,10,1000);
grafika.dzwiek_shot := al_create_sample(16,1,10,1000);
grafika.dzwiek_wingame := al_create_sample(16,1,10,1000);
grafika.dzwiek_yee := al_create_sample(16,1,10,1000);
grafika.dzwiek_torpeda := al_create_sample(16,1,10,1000);
grafika.dzwiek_music := al_create_sample(16,1,10,1000);
grafika.dzwiek_music2 := al_create_sample(16,1,10,1000);
grafika.dzwiek_fire := al_create_sample(16,1,10,1000);
grafika.dzwiek_frost := al_create_sample(16,1,10,1000);

grafika.dzwiek_malpa_dead := al_load_sample('malpa_dead.wav');
grafika.dzwiek_malpa_rzut := al_load_sample('malpa_rzut.wav');
grafika.dzwiek_malpa_slap := al_load_sample('malpa_slap.wav');
grafika.dzwiek_laser1 := al_load_sample('laser1.wav');
grafika.dzwiek_laser2 := al_load_sample('laser2.wav');
grafika.dzwiek_losegame := al_load_sample('losegame.wav');
grafika.dzwiek_shot := al_load_sample('shot.wav');
grafika.dzwiek_wingame := al_load_sample('wingame.wav');
grafika.dzwiek_yee := al_load_sample('yee.wav');
grafika.dzwiek_torpeda := al_load_sample('torpeda.wav');
grafika.dzwiek_music := al_load_sample('music_1.wav');
grafika.dzwiek_music2 := al_load_sample('music_2.wav');
grafika.dzwiek_fire := al_load_sample('fire.wav');
grafika.dzwiek_frost := al_load_sample('frost.wav');

end;

procedure Pociskgracza;         {przesuwa pociski gracza}
var wysokosc : integer;
Begin

  wysokosc := 470;

  if (gracz1.rodzajbroni = 0) then
  begin
       repeat
             if (gracz1.pociski[wysokosc]=0) then
             begin
                  if ((wysokosc+5)< 470) then
                  begin
                       gracz1.pociski[wysokosc]:=gracz1.pociski[wysokosc+5];
                       gracz1.pociski[wysokosc+5]:=0;
                  end;
             end
             else
             begin
                  gracz1.pociski[wysokosc-5]:=gracz1.pociski[wysokosc];
                  gracz1.pociski[wysokosc]:=0;

             end;

       wysokosc := wysokosc - 10;
       until wysokosc = 10;
  end
  else if ( gracz1.rodzajbroni = 1) then
  begin

       if (gracz1.lasergotowy = 2) then
       begin
            gracz1.lasergotowy := 0;
       end
       else if (gracz1.lasergotowy = 1) then
       begin
           if (gracz1.opoznienielasera = 0) then
           begin
               gracz1.lasergotowy := 2;
           end
           else
           begin
                gracz1.opoznienielasera := gracz1.opoznienielasera - 1;
           end;
       end;

  end;

  if ( ilegraczy = 2 ) then
  begin
       wysokosc := 470;
       if (gracz2.rodzajbroni = 0) then
       begin
            repeat
                  if (gracz2.pociski[wysokosc]=0) then
                  begin
                       if ((wysokosc+5)< 470) then
                       begin
                            gracz2.pociski[wysokosc]:=gracz2.pociski[wysokosc+5];
                            gracz2.pociski[wysokosc+5]:=0;
                       end;
                  end
                  else
                  begin
                       gracz2.pociski[wysokosc-5]:=gracz2.pociski[wysokosc];
                       gracz2.pociski[wysokosc]:=0;

                  end;

            wysokosc := wysokosc - 10;
            until wysokosc = 10;
       end
       else if ( gracz2.rodzajbroni = 1) then
       begin

            if (gracz2.lasergotowy = 2) then
            begin
                 gracz2.lasergotowy := 0;
            end
            else if (gracz2.lasergotowy = 1) then
            begin
                 if (gracz2.opoznienielasera = 0) then
                 begin
                      gracz2.lasergotowy := 2;
                 end
                 else
                 begin
                      gracz2.opoznienielasera := gracz2.opoznienielasera - 1;
                 end;
            end;

       end;
  end;

 end;

procedure Pociskprzeciwnika;               {przesuwa pociski malp}
var wysokosc : integer;
Begin

  wysokosc := 10;

  repeat
      if (pociskimalp[wysokosc]=0) then
      Begin
          if ((wysokosc-5) <> 0) then
          begin
                pociskimalp[wysokosc]:=pociskimalp[wysokosc-5];
                pociskimalp[wysokosc-5]:=0;
          end;
      end
       else
      Begin
           pociskimalp[wysokosc+5]:=pociskimalp[wysokosc];
           pociskimalp[wysokosc]:=0;

      end;


      wysokosc := wysokosc + 10;
  until wysokosc = 470;

end;

procedure Przesunbonus;       {przesuwa bonus, prezent w dol, kosmite w prawo}
begin

     if (bonus.stan = 1) then
        begin
        if (bonus.polozenieY = 470) then
        begin
             bonus.stan := 0;
        end
        else
        begin
             bonus.polozenieY := bonus.polozenieY + 5;
        end;
     end;
     {przesuwa drugi rodzaj bonusa}
     if (bonus.drugi_stan = 1) then
     begin
          bonus.drugi_polozenieX := bonus.drugi_polozenieX + 10;
     end;

end;

procedure Stworzbonus ( ktorazabita : integer);    {stwarza bonus}
var losowaliczba : integer;
begin

    randomize;
    losowaliczba := random(100+ilemalp);

    if  ( losowaliczba <= ilemalp ) then
    begin
         bonus.stan := 1;
         bonus.rodzaj := losowaliczba mod 6;
         bonus.polozenieY := malpy[ktorazabita].polozenieY;
         bonus.polozenieX := malpy[ktorazabita].polozenieX;
    end;


end;

procedure Efektybonusow(ktory : integer);
var odbuduj : integer; {kurcze, wszystkie do 10 bonusa xd}
var bariera : integer;
var iterator : integer;
var x : integer;
var y : integer;
var r : integer;
begin
  {ta procedura uruchamia sie z procedury 'kolizje' i zawiera efekty uboczne, ktore
  moge wystapic po zlapaniu bonusa, w zaleznosci od tego, jakiego byl rodzaju}

  randomize;
  bonus.komunikat := (random(10) + 1);

   {teraz w zaleznosci od wartosci bonus.komunikat, nastapia odpowiednie zmiany w programie}

   case bonus.komunikat of
        1: if (ktory = 1) then begin inc(gracz1.zycia); end else begin inc(gracz2.zycia) end;
        2: inc(bonus.torpedy);
        3: begin
        if (ktory = 1 ) then
        begin
           if (gracz1.rodzajbroni = 0) then
           begin
                gracz1.rodzajbroni := 1;
                 iterator := 470; {czysci z pociskow}
                 repeat
                       gracz1.pociski[iterator] := 0;
                       iterator := iterator - 10;
                 until iterator = 10;
           end
           else
           begin
                gracz1.rodzajbroni := 0;
                gracz1.lasergotowy := 0;
           end;
        end
        else
        begin
             if (gracz2.rodzajbroni = 0) then
             begin
                  gracz2.rodzajbroni := 1;
                   iterator := 470; {czysci z pociskow}
                   repeat
                         gracz2.pociski[iterator] := 0;
                         iterator := iterator - 10;
                   until iterator = 10;
             end
             else
             begin
                  gracz2.rodzajbroni := 0;
                  gracz2.lasergotowy := 0;
             end;
        end;
        end;
        4: if (stronaruchu = 0) then begin stronaruchu := 1; end else begin stronaruchu := 0; end;
        5: if (opoznieniemalp > 1) then opoznieniemalp := opoznieniemalp - 4;
        6: opoznieniemalp := opoznieniemalp + 4;
        7: bonus.CzasTarczy := 100;
        8: begin
            bonus.Mroz := 1;
            {dzwiek mrozu}
            al_play_sample( grafika.dzwiek_frost, 200, 127, 1000, 1=0 );
        end;
        9: begin
            bonus.CzasOgnia := 100;
            gracz1.rodzajbroni := 0;
            gracz1.lasergotowy := 0;
            {dzwiek ognia}
            al_play_sample( grafika.dzwiek_fire, 200, 127, 1000, 1=0 );
        end;
        10: odbuduj := 1;
   end;
   bonus.czaskomunikatu := 40;

   if (odbuduj = 1) then
   begin
       odbuduj := 0;
       case poziom of
       1: Assign(plik, 'bariery1.txt');
       2: Assign(plik, 'bariery1.txt');
       3: Assign(plik, 'bariery1.txt');
       4: Assign(plik, 'bariery2.txt');
       5: Assign(plik, 'bariery2.txt');
       6: Assign(plik, 'bariery3.txt');
       7: Assign(plik, 'bariery3.txt');
       8: Assign(plik, 'bariery4.txt');
       9: Assign(plik, 'bariery4.txt');
       end;

       Reset(plik);

       bariera := 0;
       while not eof(plik) do
       begin
            ReadLN(plik,doplikow);
            x := 0;
            y := 0;
            r := 0;

            {teraz ze stringa doplikow, wyciagniemy odpowiednie dane}
            case doplikow[1] of
            '0':;
            '1':  x := x + 100;
            '2':  x := x + 200;
            '3':  x := x + 300;
            '4':  x := x + 400;
            '5':  x := x + 500;
            '6':  x := x + 600;
            '7':  x := x + 700;
            '8':  x := x + 800;
            '9':  x := x + 900;
            end;

            case doplikow[2] of
            '0':;
            '1':  x := x + 10;
            '2':  x := x + 20;
            '3':  x := x + 30;
            '4':  x := x + 40;
            '5':  x := x + 50;
            '6':  x := x + 60;
            '7':  x := x + 70;
            '8':  x := x + 80;
            '9':  x := x + 90;
            end;

            case doplikow[3] of
            '0':;
            '1':  x := x + 1;
            '2':  x := x + 2;
            '3':  x := x + 3;
            '4':  x := x + 4;
            '5':  x := x + 5;
            '6':  x := x + 6;
            '7':  x := x + 7;
            '8':  x := x + 8;
            '9':  x := x + 9;
            end;

            case doplikow[5] of
            '0':;
            '1':  y := y + 100;
            '2':  y := y + 200;
            '3':  y := y + 300;
            '4':  y := y + 400;
            '5':  y := y + 500;
            '6':  y := y + 600;
            '7':  y := y + 700;
            '8':  y := y + 800;
            '9':  y := y + 900;
            end;

            case doplikow[6] of
            '0':;
            '1':  y := y + 10;
            '2':  y := y + 20;
            '3':  y := y + 30;
            '4':  y := y + 40;
            '5':  y := y + 50;
            '6':  y := y + 60;
            '7':  y := y + 70;
            '8':  y := y + 80;
            '9':  y := y + 90;
            end;

            case doplikow[7] of
            '0':;
            '1':  y := y + 1;
            '2':  y := y + 2;
            '3':  y := y + 3;
            '4':  y := y + 4;
            '5':  y := y + 5;
            '6':  y := y + 6;
            '7':  y := y + 7;
            '8':  y := y + 8;
            '9':  y := y + 9;
            end;

            case doplikow[9] of
            '0': r := 0;
            '1': r := 1;
            '2': r := 2;
            '3': r := 3;
            end;


            bariery[bariera].polozenieX := x;
            bariery[bariera].polozenieY := y;
            bariery[bariera].rodzaj := r;
            bariery[bariera].stan := 1;

            inc(bariera);

       end;

       Close(plik);
   end;

end;

procedure MalpyStrzelaja;     {tworzy pociski malp, pod specjalnymi warunkami 'AI'}
var liczniklosowosci : integer;
var losowamalpa : integer;
var brakbarier : integer;
var iterator : integer;
var przewidywanepolozenie : integer;
Begin

  randomize;
  liczniklosowosci := 5;

        repeat
              losowamalpa := random(ilemalp+50);
              dec(liczniklosowosci);

                   {jesli malpa zyje i na tym poziomie nie ma jeszcze pocisku malpy}
              if  ( (losowamalpa <= ilemalp) and (malpy[losowamalpa].zyje = 1) and (pociskimalp[malpy[losowamalpa].polozenieY] = 0) ) then
              begin
                   if (malpy[losowamalpa].rodzaj = 0) then
                   begin
                        pociskimalp[malpy[losowamalpa].polozenieY] := malpy[losowamalpa].polozenieX+16;
                        liczniklosowosci := 0;
                          {dzwiek rzutu bananem}
                        al_play_sample( grafika.dzwiek_malpa_rzut, 200, 127, 1000, 1=0 );
                   end
                   else
                   if (malpy[losowamalpa].rodzaj = 1) then  {to cos nei dziala jeszcze}
                   begin

                        for iterator := 0 to 100 do
                        begin

                            if ( (bariery[iterator].stan = 1) and (malpy[losowamalpa].polozenieX >= bariery[iterator].polozenieX) and (malpy[losowamalpa].polozenieX <= bariery[iterator].polozenieX + 20) ) then
                            begin
                                 brakbarier := 1;
                            end;

                        end;

                        if (brakbarier = 0) then
                        begin
                             pociskimalp[malpy[losowamalpa].polozenieY] := malpy[losowamalpa].polozenieX+16;
                             {dzwiek rzutu bananem}
                        al_play_sample( grafika.dzwiek_malpa_rzut, 200, 127, 1000, 1=0 );
                             liczniklosowosci := 0;
                        end;
                        brakbarier := 0;
                   end
                   else
                   if (malpy[losowamalpa].rodzaj = 2) then
                   begin
                       if (gracz1.rodzajbroni = 0) then
                       begin
                            {w tablicy pozycjegracza bedzie zapisana sekwencja ruchow gracza od ostatenigo strzalu
                            snajpera, strzeli ten snajper, ktory bedzie mial pewnosc, ze trafi w to miejsce
                            gdzie w poprzedniej sekwencji gracz byl, co on pamieta ze gracz tam byl}

                            przewidywanepolozenie := ((polozenie_karabinuY - malpy[losowamalpa].polozenieY) div 10);

                            if ((pozycjegracza[przewidywanepolozenie] <= malpy[losowamalpa].polozenieX) and (pozycjegracza[przewidywanepolozenie] + 30 >= malpy[losowamalpa].polozenieX) ) then
                            begin
                               pociskimalp[malpy[losowamalpa].polozenieY] := malpy[losowamalpa].polozenieX+16;
                               {dzwiek rzutu bananem}
                        al_play_sample( grafika.dzwiek_malpa_rzut, 200, 127, 1000, 1=0 );
                               liczniklosowosci := 0;
                            end;

                       end
                       else if (gracz1.rodzajbroni = 1) then
                       begin
                            if ( (gracz1.lasergotowy = 1) and (malpy[losowamalpa].polozenieX >= gracz1.polozenieX) and (malpy[losowamalpa].polozenieX <= gracz1.polozenieX + 30) ) then
                            begin
                               pociskimalp[malpy[losowamalpa].polozenieY] := malpy[losowamalpa].polozenieX+16;
                               {dzwiek rzutu bananem}
                        al_play_sample( grafika.dzwiek_malpa_rzut, 200, 127, 1000, 1=0 );
                               liczniklosowosci := 0;
                            end;
                       end;
                   end;
              end;

        until (liczniklosowosci = 0);

        if (malpy[ilemalp - 1].rodzaj = 3) then  {chyba tu blad}
        begin
             if (ilezyje = 1) then
             begin
                   {skoro i tak boss stoi w miejscu, moze lepiej to po prostu recznie?}
                if ( bossprzerwa > 10 ) then
                begin
                   {dzwiek rzutu bananem}
                        al_play_sample( grafika.dzwiek_malpa_rzut, 200, 127, 1000, 1=0 );
                   pociskimalp[malpy[ilemalp].polozenieY] := malpy[ilemalp].polozenieX+10;
                   pociskimalp[malpy[ilemalp].polozenieY+10] := malpy[ilemalp].polozenieX+30;
                   pociskimalp[malpy[ilemalp].polozenieY+20] := malpy[ilemalp].polozenieX+50;
                   pociskimalp[malpy[ilemalp].polozenieY+30] := malpy[ilemalp].polozenieX+70;
                   pociskimalp[malpy[ilemalp].polozenieY+40] := malpy[ilemalp].polozenieX+50;
                   pociskimalp[malpy[ilemalp].polozenieY+50] := malpy[ilemalp].polozenieX+30;
                   pociskimalp[malpy[ilemalp].polozenieY+50] := malpy[ilemalp].polozenieX+10;

                   bossprzerwa := bossprzerwa - 5;
                end
                else
                begin
                    inc(bossprzerwa);
                end;
             end;
        end;
end;

procedure Kolizje;                        {wszystkie mozliwe kolizje}
var wysokosc : integer;
var ktoramalpa : integer;
var iterator : integer;
begin

     if (gracz1.rodzajbroni = 0) then
     begin

          for ktoramalpa := 0 to ilemalp do
          begin
          wysokosc := 470;

                repeat
                      if ( (malpy[ktoramalpa].rodzaj <> 3) and  (wysokosc <= (malpy[ktoramalpa].polozenieY + 40)) and (wysokosc >= (malpy[ktoramalpa].polozenieY))) then
                      begin
                      if ( (gracz1.pociski[wysokosc] <= (malpy[ktoramalpa].polozenieX + 40)) and (gracz1.pociski[wysokosc] >= malpy[ktoramalpa].polozenieX) and (malpy[ktoramalpa].zyje = 1)) then
                          begin
                              bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                              malpy[ktoramalpa].zyje := 0;
                              dec(ilezyje);
                              gracz1.pociski[wysokosc] := 0;
                              gracz1.punkty := gracz1.punkty + 1;
                              if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                              {jesli jeszce nie ma, to stworzy bonus}
                                 {dzwiek umeirajacej malpy?}
                              al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                              if (bonus.CzasOgnia > 0) then
                              begin
                                  {dodatkowo zabija malpe zaraz na gorze, na dole, po bokach
                                  jesli zyja oczywiscie}
                                  {dzwiek ognia}
                                  {narazie zrobimy tylko malpe poprzedzajaca i nastena
                                 , bo nie wiem jak beda poustawiane, ale w przyszlosci
                                 wiadomo, ze bedzie to dzialalo tylko na malpy stykajace sie bezposrednio}
                                 if ( (malpy[ktoramalpa+1].zyje = 1 ) and (malpy[ktoramalpa+1].polozenieY = malpy[ktoramalpa].polozenieY) and (malpy[ktoramalpa+1].polozenieX = malpy[ktoramalpa].polozenieX+60) ) then
                                 begin
                                      malpy[ktoramalpa+1].zyje := 0;
                                      dec(ilezyje);
                                      gracz1.pociski[wysokosc] := 0;
                                      gracz1.punkty := gracz1.punkty + 1;
                                      if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                      al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                 {jesli jeszce nie ma, to stworzy bonus}
                                 end;
                                   if ( (malpy[ktoramalpa-1].zyje = 1 ) and (malpy[ktoramalpa-1].polozenieY = malpy[ktoramalpa].polozenieY) and (malpy[ktoramalpa-1].polozenieX = malpy[ktoramalpa].polozenieX-60) ) then
                                   begin
                                        malpy[ktoramalpa-1].zyje := 0;
                                        dec(ilezyje);
                                        gracz1.pociski[wysokosc] := 0;
                                        gracz1.punkty := gracz1.punkty + 1;
                                        if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                        al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                   {jesli jeszce nie ma, to stworzy bonus}
                                   end;
                                   if ( (malpy[ktoramalpa+10].zyje = 1)  and (malpy[ktoramalpa+10].polozenieY = malpy[ktoramalpa].polozenieY+60) and (malpy[ktoramalpa+10].polozenieX = malpy[ktoramalpa].polozenieX) ) then
                                   begin
                                        malpy[ktoramalpa+10].zyje := 0;
                                        dec(ilezyje);
                                        gracz1.pociski[wysokosc] := 0;
                                        gracz1.punkty := gracz1.punkty + 1;
                                        if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                        al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                   {jesli jeszce nie ma, to stworzy bonus}
                                   end;
                                   if ( (malpy[ktoramalpa-10].zyje = 1)  and (malpy[ktoramalpa-10].polozenieY = malpy[ktoramalpa].polozenieY-60) and (malpy[ktoramalpa-10].polozenieX = malpy[ktoramalpa].polozenieX) ) then
                                   begin
                                        malpy[ktoramalpa-10].zyje := 0;
                                        dec(ilezyje);
                                        gracz1.pociski[wysokosc] := 0;
                                        gracz1.punkty := gracz1.punkty + 1;
                                        if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                        al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                   {jesli jeszce nie ma, to stworzy bonus}
                                   end;
                              end;
                          end;
                      end
                      else if ((malpy[ktoramalpa].rodzaj = 3) and  (wysokosc <= (malpy[ktoramalpa].polozenieY + 80)) and (wysokosc >= (malpy[ktoramalpa].polozenieY)) and (malpy[ktoramalpa].zyje = 1) ) then
                      begin
                      {tu jak boss}
                          if ( (gracz1.pociski[wysokosc] <= (malpy[ktoramalpa].polozenieX + 80)) and (gracz1.pociski[wysokosc] >= malpy[ktoramalpa].polozenieX) and (malpy[ktoramalpa].zyje = 1)) then
                              begin
                                  if (ilezyje = 1) then
                                  begin
                                       if ( zyciebossa = 1 ) then
                                       begin
                                       bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                       malpy[ktoramalpa].zyje := 0;
                                       dec(ilezyje);
                                       gracz1.pociski[wysokosc] := 0;
                                       gracz1.punkty := gracz1.punkty + 10;
                                           {dzwiek umeirajacej malpy + muzyczka zwyciestwa i animacja zakonczenie}
                                       al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                       end
                                       else
                                       begin
                                       bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                       gracz1.pociski[wysokosc] := 0;
                                       gracz1.punkty := gracz1.punkty + 1;
                                       {dzwiek obrazen malpy}
                                         al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                       if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                       end;
                                       dec(zyciebossa);
                                  end
                                  else
                                  begin
                                       bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                       gracz1.pociski[wysokosc] := 0;
                                         {smiech malpy}
                                       al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                  end;
                              end;
                      end;


                      wysokosc := wysokosc - 10;
                until wysokosc = 10;
           end;
     end
     else if (gracz1.rodzajbroni = 1) then
     begin
          if (gracz1.lasergotowy = 2) then
          begin
               {zabija malpy}
               for ktoramalpa := ilemalp downto 0 do
               begin
                    if (malpy[ktoramalpa].zyje = 1) then
                    begin
                         if ( ( malpy[ktoramalpa].rodzaj <> 3) and (malpy[ktoramalpa].polozenieX <= (gracz1.polozenieX + 17)) and (malpy[ktoramalpa].polozenieX + 40 >= (gracz1.polozenieX + 17)) ) then
                         begin
                              bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                              malpy[ktoramalpa].zyje := 0;
                              dec(ilezyje);
                              gracz1.punkty := gracz1.punkty + 1;
                              if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                              {jesli jeszce nie ma, to stworzy bonus}
                                {dzwiek umeirajacej malpy?}
                              al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                         end
                         else  if ( (malpy[ktoramalpa].polozenieX <= (gracz1.polozenieX + 17)) and (malpy[ktoramalpa].polozenieX + 80 >= (gracz1.polozenieX + 17)) {and (malpy[ktoramalpa].zyje = 1)} ) then
                         begin
                             if ( ilezyje = 1 ) then
                             begin
                              bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                              malpy[ktoramalpa].zyje := 0;
                              dec(ilezyje);
                              gracz1.punkty := gracz1.punkty + 10;
                              zyciebossa := 0;
                              {dzwiek umeirajacej malpy + muzyczka zwyciestwa i animacja podlecenia do przodu potem}
                              al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                             end
                             else
                             begin
                                  bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                  gracz1.pociski[wysokosc] := 0;
                                    {smiech malpy}
                                  al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                             end;

                         end;
                    end;
               end;
               {niszczy ich pociski na swojej drodze}
               wysokosc := 470;
               repeat

                     if ( (pociskimalp[wysokosc]-6 <= (gracz1.polozenieX + 15)) and (pociskimalp[wysokosc]+6 >= (gracz1.polozenieX + 15)) ) then
                     begin
                          pociskimalp[wysokosc] := 0;
                     end;

                   wysokosc := wysokosc - 10;
               until wysokosc = 10;
               {oraz bariery...}
               wysokosc := 340;
               repeat
                   for ktoramalpa := 0 to 100 do
                   begin
                        if ( (bariery[ktoramalpa].stan = 1) and  (gracz1.polozenieX + 15 <=  bariery[ktoramalpa].polozenieX + 20 ) and (gracz1.polozenieX + 15 >= bariery[ktoramalpa].polozenieX) ) then
                        begin
                             bariery[ktoramalpa].stan := 0;
                        end;
                   end;
                     wysokosc := wysokosc + 20;
               until wysokosc = 380;
          end;
     end;

      wysokosc := 420;

           repeat
               if ( (bonus.CzasTarczy <> 0) and ( (pociskimalp[wysokosc - 10] >= ( gracz1.polozenieX)) and (pociskimalp[wysokosc - 10] <= ( gracz1.polozenieX + 30) )) ) then {To jest z bonusa}
               begin
                  pociskimalp[wysokosc - 10] := 0; {z Bonusa, efekt tarczy}
               end;
               if ( (pociskimalp[wysokosc] >= ( gracz1.polozenieX)) and (pociskimalp[wysokosc] <= ( gracz1.polozenieX + 30) ) ) then
               begin
                       gracz1.zycia := gracz1.zycia - 1;
                       pociskimalp[wysokosc] := 0;
                       {dzwiek obrazen naszych}
                       al_play_sample( grafika.dzwiek_malpa_slap, 200, 127, 1000, 1=0 );
               end;
               wysokosc := wysokosc + 10;
           until wysokosc = 470;

      {zbieranie bonusa}
      wysokosc := 420;
      repeat
            if ( (bonus.stan <> 0) and (bonus.polozenieY = wysokosc) and (bonus.polozenieX <= gracz1.polozenieX + 30) and (bonus.polozenieX >= gracz1.polozenieX) )  then
            begin
                   bonus.stan := 0;
                   Efektybonusow(1);
            end;
            wysokosc := wysokosc + 10;
      until wysokosc = 470;

      {strzelanie do bonusa drugiego rodzaju}
     if (bonus.drugi_stan = 1) then
     begin
          if (gracz1.rodzajbroni = 0) then
          begin

               if   ((bonus.drugi_polozenieX <= gracz1.pociski[20]) and (bonus.drugi_polozenieX + 40 >= gracz1.pociski[20]) ) then
               begin
                    bonus.drugi_stan := 0;
                    Efektybonusow(1);
                    gracz1.pociski[20] := 0;
                    gracz1.punkty := gracz1.punkty + 10;
               end
               else if ((bonus.drugi_polozenieX <= gracz1.pociski[10]) and (bonus.drugi_polozenieX + 40 >= gracz1.pociski[10]) ) then
               begin
                    bonus.drugi_stan := 0;
                    Efektybonusow(1);
                    gracz1.pociski[20] := 0;
                    gracz1.punkty := gracz1.punkty + 10;
               end;

          end
          else if (gracz1.rodzajbroni = 1) then
          begin
               if (gracz1.lasergotowy = 2) then
               begin


                    if ( ( bonus.drugi_polozenieX <= (gracz1.polozenieX + 17)) and (bonus.drugi_polozenieX + 40 >= (gracz1.polozenieX + 17)) ) then
                    begin
                         bonus.drugi_stan := 0;
                         Efektybonusow(1);
                         gracz1.punkty := gracz1.punkty + 10;
                    end;
               end;
          end;
     end;
      {bonus w barierze}


      wysokosc := 340;
      repeat
          for ktoramalpa := 0 to 100 do
          begin
               if ( (bonus.stan <> 0) and (bariery[ktoramalpa].stan = 1) and (bonus.polozenieY = wysokosc) and (bonus.polozenieX <=  bariery[ktoramalpa].polozenieX + 20 ) and (bonus.polozenieX >= bariery[ktoramalpa].polozenieX) ) then
               begin
                    bonus.stan := 0;
                    bariery[ktoramalpa].stan := 0;
               end;
          end;
            wysokosc := wysokosc + 20;
      until wysokosc = 380;
      {kolicja 2 pociskow}
      wysokosc := 470;
      repeat
            if ( (pociskimalp[wysokosc]-6 <= gracz1.pociski[wysokosc]) and (pociskimalp[wysokosc]+6 >= gracz1.pociski[wysokosc]) ) then
            begin
                 pociskimalp[wysokosc] := 0;
                 gracz1.pociski[wysokosc] := 0;
            end;

            wysokosc := wysokosc - 10;
      until wysokosc = 10;
      {nasz pocisk w barierze}
      wysokosc := 340;
      repeat
          for ktoramalpa := 100 downto 0 do
          begin
               if ( (bariery[ktoramalpa].stan = 1) and (gracz1.pociski[wysokosc] <=  bariery[ktoramalpa].polozenieX + 20 ) and (gracz1.pociski[wysokosc] >= bariery[ktoramalpa].polozenieX) ) then
               begin
                    gracz1.pociski[wysokosc] := 0;
                    bariery[ktoramalpa].stan := 0;
               end;
          end;
            wysokosc := wysokosc + 20;
      until wysokosc = 380;
      {pocisk malp w barierze}
      wysokosc := 340;
      repeat
          for ktoramalpa := 0 to 100 do
          begin
               if ( (bariery[ktoramalpa].stan = 1) and (pociskimalp[wysokosc] <=  bariery[ktoramalpa].polozenieX + 20 ) and (pociskimalp[wysokosc] >= bariery[ktoramalpa].polozenieX) ) then
               begin
                    pociskimalp[wysokosc] := 0;
                    bariery[ktoramalpa].stan := 0;
               end;
          end;
            wysokosc := wysokosc + 20;
      until wysokosc = 380;
      {malpa w barierze}
      for ktoramalpa := 0 to ilemalp do
      begin
      wysokosc := 340;
               repeat
                     for iterator := 0 to 100 do
                     begin
                     if ( (malpy[ktoramalpa].zyje = 1) and (bariery[iterator].stan = 1) and (malpy[ktoramalpa].polozenieY + 40 = wysokosc) and (malpy[ktoramalpa].polozenieX <=  bariery[iterator].polozenieX + 20 ) and (malpy[ktoramalpa].polozenieX + 40 >= bariery[iterator].polozenieX) ) then
                        begin
                             bariery[iterator].stan := 0;
                             przeskokmalpy := 1;
                        end;
                     end;
               wysokosc := wysokosc + 20;
               until wysokosc = 380;

       end;

      {wszystko fajnie, ale teraz kolizje jesli jest 2 graczy... makabra xd}
if ( ilegraczy = 2) then
begin

    if (gracz2.rodzajbroni = 0) then
    begin

         for ktoramalpa := 0 to ilemalp do
         begin
         wysokosc := 470;

               repeat
                     if ( (malpy[ktoramalpa].rodzaj <> 3) and  (wysokosc <= (malpy[ktoramalpa].polozenieY + 40)) and (wysokosc >= (malpy[ktoramalpa].polozenieY))) then
                     begin
                     if ( (gracz2.pociski[wysokosc] <= (malpy[ktoramalpa].polozenieX + 40)) and (gracz2.pociski[wysokosc] >= malpy[ktoramalpa].polozenieX) and (malpy[ktoramalpa].zyje = 1)) then
                         begin
                             bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                             malpy[ktoramalpa].zyje := 0;
                             dec(ilezyje);
                             gracz2.pociski[wysokosc] := 0;
                             gracz1.punkty := gracz1.punkty + 1;   {nie rozdzielamy pkt}
                             if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                             {jesli jeszce nie ma, to stworzy bonus}
                               {dzwiek umeirajacej malpy?}
                             al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                             if (bonus.CzasOgnia > 0) then
                             begin
                                 {dodatkowo zabija malpe zaraz na gorze, na dole, po bokach
                                 jesli zyja oczywiscie}
                                 {dzwiek ognia}
                                 {narazie zrobimy tylko malpe poprzedzajaca i nastena
                                , bo nie wiem jak beda poustawiane, ale w przyszlosci
                                wiadomo, ze bedzie to dzialalo tylko na malpy stykajace sie bezposrednio}
                                if ( (malpy[ktoramalpa+1].zyje = 1 ) and (malpy[ktoramalpa+1].polozenieY = malpy[ktoramalpa].polozenieY) and (malpy[ktoramalpa+1].polozenieX = malpy[ktoramalpa].polozenieX+60) ) then
                                begin
                                     malpy[ktoramalpa+1].zyje := 0;
                                     dec(ilezyje);
                                     gracz2.pociski[wysokosc] := 0;
                                     gracz1.punkty := gracz1.punkty + 1; {nie sa rozdzielane!}
                                     if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                {jesli jeszce nie ma, to stworzy bonus}
                                al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                end;
                                  if ( (malpy[ktoramalpa-1].zyje = 1 ) and (malpy[ktoramalpa-1].polozenieY = malpy[ktoramalpa].polozenieY) and (malpy[ktoramalpa-1].polozenieX = malpy[ktoramalpa].polozenieX-60) ) then
                                  begin
                                       malpy[ktoramalpa-1].zyje := 0;
                                       dec(ilezyje);
                                       gracz2.pociski[wysokosc] := 0;
                                       gracz1.punkty := gracz1.punkty + 1;
                                       if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                  {jesli jeszce nie ma, to stworzy bonus}
                                  al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                  end;
                                  if ( (malpy[ktoramalpa+10].zyje = 1)  and (malpy[ktoramalpa+10].polozenieY = malpy[ktoramalpa].polozenieY+60) and (malpy[ktoramalpa+10].polozenieX = malpy[ktoramalpa].polozenieX) ) then
                                  begin
                                       malpy[ktoramalpa+10].zyje := 0;
                                       dec(ilezyje);
                                       gracz2.pociski[wysokosc] := 0;
                                       gracz1.punkty := gracz1.punkty + 1;
                                       if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                  {jesli jeszce nie ma, to stworzy bonus}
                                  al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                  end;
                                  if ( (malpy[ktoramalpa-10].zyje = 1)  and (malpy[ktoramalpa-10].polozenieY = malpy[ktoramalpa].polozenieY-60) and (malpy[ktoramalpa-10].polozenieX = malpy[ktoramalpa].polozenieX) ) then
                                  begin
                                       malpy[ktoramalpa-10].zyje := 0;
                                       dec(ilezyje);
                                       gracz2.pociski[wysokosc] := 0;
                                       gracz1.punkty := gracz1.punkty + 1;
                                       if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                  {jesli jeszce nie ma, to stworzy bonus}
                                  al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                  end;
                             end;
                         end;
                     end
                     else if ((malpy[ktoramalpa].rodzaj = 3) and  (wysokosc <= (malpy[ktoramalpa].polozenieY + 80)) and (wysokosc >= (malpy[ktoramalpa].polozenieY)) and (malpy[ktoramalpa].zyje = 1) ) then
                     begin
                     {tu jak boss}
                         if ( (gracz2.pociski[wysokosc] <= (malpy[ktoramalpa].polozenieX + 80)) and (gracz2.pociski[wysokosc] >= malpy[ktoramalpa].polozenieX) and (malpy[ktoramalpa].zyje = 1)) then
                             begin
                                 if (ilezyje = 1) then
                                 begin
                                      if ( zyciebossa = 1 ) then
                                      begin
                                      bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                      malpy[ktoramalpa].zyje := 0;
                                      dec(ilezyje);
                                      gracz2.pociski[wysokosc] := 0;
                                      gracz1.punkty := gracz1.punkty + 10;
                                        {dzwiek umeirajacej malpy + muzyczka zwyciestwa i animacja zakonczenie}
                                      al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                      end
                                      else
                                      begin
                                      bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                      gracz2.pociski[wysokosc] := 0;
                                      gracz1.punkty := gracz1.punkty + 1;
                                      {dzwiek obrazen malpy}
                                      al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                      if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                                      end;
                                      dec(zyciebossa);
                                 end
                                 else
                                 begin
                                      bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                      gracz2.pociski[wysokosc] := 0;
                                      {smiech malpy}
                                      al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                                 end;
                             end;
                     end;


                     wysokosc := wysokosc - 10;
               until wysokosc = 10;
          end;
    end
    else if (gracz2.rodzajbroni = 1) then
    begin
         if (gracz2.lasergotowy = 2) then
         begin
              {zabija malpy}
              for ktoramalpa := ilemalp downto 0 do
              begin
                   if (malpy[ktoramalpa].zyje = 1) then
                   begin
                        if ( ( malpy[ktoramalpa].rodzaj <> 3) and (malpy[ktoramalpa].polozenieX <= (gracz2.polozenieX + 17)) and (malpy[ktoramalpa].polozenieX + 40 >= (gracz2.polozenieX + 17)) ) then
                        begin
                             bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                             malpy[ktoramalpa].zyje := 0;
                             dec(ilezyje);
                             gracz1.punkty := gracz1.punkty + 1;
                             if (bonus.stan = 0) then Stworzbonus(ktoramalpa);
                             {jesli jeszce nie ma, to stworzy bonus}
                               {dzwiek umeirajacej malpy?}
                             al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                        end
                        else  if ( (malpy[ktoramalpa].polozenieX <= (gracz2.polozenieX + 17)) and (malpy[ktoramalpa].polozenieX + 80 >= (gracz2.polozenieX + 17)) {and (malpy[ktoramalpa].zyje = 1)} ) then
                        begin
                            if ( ilezyje = 1 ) then
                            begin
                             bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                             malpy[ktoramalpa].zyje := 0;
                             dec(ilezyje);
                             gracz1.punkty := gracz1.punkty + 10;
                             zyciebossa := 0;
                               {dzwiek umeirajacej malpy + muzyczka zwyciestwa i animacja podlecenia do przodu potem}
                             al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                            end
                            else
                            begin
                                 bonus.Mroz := 0; {bonus zwiazany z zamrozeniem}
                                 gracz1.pociski[wysokosc] := 0;
                                   {smiech malpy}
                                 al_play_sample( grafika.dzwiek_malpa_dead, 200, 127, 1000, 1=0 );
                            end;

                        end;
                   end;
              end;
              {niszczy ich pociski na swojej drodze}
              wysokosc := 470;
              repeat

                    if ( (pociskimalp[wysokosc]-6 <= (gracz2.polozenieX + 15)) and (pociskimalp[wysokosc]+6 >= (gracz2.polozenieX + 15)) ) then
                    begin
                         pociskimalp[wysokosc] := 0;
                    end;

                  wysokosc := wysokosc - 10;
              until wysokosc = 10;
              {oraz bariery...}
              wysokosc := 340;
              repeat
                  for ktoramalpa := 0 to 100 do
                  begin
                       if ( (bariery[ktoramalpa].stan = 1) and  (gracz2.polozenieX + 15 <=  bariery[ktoramalpa].polozenieX + 20 ) and (gracz2.polozenieX + 15 >= bariery[ktoramalpa].polozenieX) ) then
                       begin
                            bariery[ktoramalpa].stan := 0;
                       end;
                  end;
                    wysokosc := wysokosc + 20;
              until wysokosc = 380;
         end;
    end;

     wysokosc := 420;

          repeat
              if ( (bonus.CzasTarczy <> 0) and ( (pociskimalp[wysokosc - 10] >= ( gracz2.polozenieX)) and (pociskimalp[wysokosc - 10] <= ( gracz2.polozenieX + 30) )) ) then {To jest z bonusa}
              begin
                 pociskimalp[wysokosc - 10] := 0; {z Bonusa, efekt tarczy}
              end;
              if ( (pociskimalp[wysokosc] >= ( gracz2.polozenieX)) and (pociskimalp[wysokosc] <= ( gracz2.polozenieX + 30) ) ) then
              begin
                      gracz1.zycia := gracz1.zycia - 1; {nie rozdzialemy!}
                      {dzwiek obrazen naszych}
                       al_play_sample( grafika.dzwiek_malpa_slap, 200, 127, 1000, 1=0 );
                      pociskimalp[wysokosc] := 0;
              end;
              wysokosc := wysokosc + 10;
          until wysokosc = 470;

          {zbieranie bonusa}
          wysokosc := 420;
          repeat
                if ( (bonus.stan <> 0) and (bonus.polozenieY = wysokosc) and (bonus.polozenieX <= gracz2.polozenieX + 30) and (bonus.polozenieX >= gracz2.polozenieX) )  then
                begin
                  bonus.stan := 0;
                  Efektybonusow(2);
                end;
                wysokosc := wysokosc + 10;
          until wysokosc = 470;

          {strzelanie w bonusa drugiego rodzaju}
          if (bonus.drugi_stan = 1) then
          begin
                    if (gracz2.rodzajbroni = 0) then
                    begin

                              if   ((bonus.drugi_polozenieX <= gracz2.pociski[20]) and (bonus.drugi_polozenieX + 40 >= gracz2.pociski[20]) ) then
                              begin
                                   bonus.drugi_stan := 0;
                                   Efektybonusow(2);
                                   gracz2.pociski[20] := 0;
                                   gracz1.punkty := gracz1.punkty + 10;
                              end
                              else if ((bonus.drugi_polozenieX <= gracz2.pociski[10]) and (bonus.drugi_polozenieX + 40 >= gracz2.pociski[10]) ) then
                              begin
                                   bonus.drugi_stan := 0;
                                   Efektybonusow(2);
                                   gracz2.pociski[20] := 0;
                                   gracz1.punkty := gracz1.punkty + 10;
                              end;

                    end
                    else if (gracz2.rodzajbroni = 1) then
                    begin
                         if (gracz2.lasergotowy = 2) then
                         begin


                              if ( ( bonus.drugi_polozenieX <= (gracz2.polozenieX + 17) ) and (bonus.drugi_polozenieX + 40 >= (gracz2.polozenieX + 17)))  then
                              begin
                                   bonus.drugi_stan := 0;
                                   Efektybonusow(2);
                                   gracz1.punkty := gracz1.punkty + 10;
                              end;
                         end;
                    end;
          end;

          {kolicja 2 pociskow}
          wysokosc := 470;
          repeat
                if ( (pociskimalp[wysokosc]-6 <= gracz2.pociski[wysokosc]) and (pociskimalp[wysokosc]+6 >= gracz2.pociski[wysokosc]) ) then
                begin
                     pociskimalp[wysokosc] := 0;
                     gracz2.pociski[wysokosc] := 0;
                end;

                wysokosc := wysokosc - 10;
          until wysokosc = 10;
          {nasz pocisk w barierze}
          wysokosc := 340;
          repeat
              for ktoramalpa := 100 downto 0 do
              begin
                   if ( (bariery[ktoramalpa].stan = 1) and (gracz2.pociski[wysokosc] <=  bariery[ktoramalpa].polozenieX + 20 ) and (gracz2.pociski[wysokosc] >= bariery[ktoramalpa].polozenieX) ) then
                   begin
                        gracz2.pociski[wysokosc] := 0;
                        bariery[ktoramalpa].stan := 0;
                   end;
              end;
                wysokosc := wysokosc + 20;
          until wysokosc = 380;
    end;


end;

procedure Przesunmalpy (var ktoranajwieksza : integer; var ktoranajmniejsza : integer);   {ruch malp}
var wdolibok : integer;
var tylkowbok : integer;

var najmniejsze : integer;
var najwieksze : integer;
var iteracjamalp : integer;
Begin

{ustala skrajne}
  najmniejsze := 600;
  najwieksze := -1;

  for iteracjamalp := ilemalp downto 1 do
  begin

      if ( (malpy[iteracjamalp].zyje = 1) and (malpy[iteracjamalp].rodzaj <> 3) ) then
      begin
          if (malpy[iteracjamalp].polozenieX <= najmniejsze) then
          begin
              najmniejsze := malpy[iteracjamalp].polozenieX;
              ktoranajmniejsza := iteracjamalp;
          end;
          if (malpy[iteracjamalp].polozenieX >= najwieksze) then
          begin
              najwieksze := malpy[iteracjamalp].polozenieX;
              ktoranajwieksza := iteracjamalp;
          end;
      end;

  end;

  {i przesuwa w odpowiedni sposob}

     if ((ktoranajmniejsza < 0) or (ktoranajmniejsza > 100)) then ktoranajmniejsza := 0;
     if ((ktoranajwieksza < 0) or (ktoranajwieksza > 100)) then ktoranajwieksza := 0;

      if (malpy[ktoranajmniejsza].polozenieX = 10) then
      begin
          stronaruchu := 0;
          for wdolibok := 0 to ilemalp do
            begin
                 if ( (malpy[wdolibok].zyje = 1) and (malpy[wdolibok].rodzaj <> 3) ) then
                 begin
                      malpy[wdolibok].polozenieY := malpy[wdolibok].polozenieY + 10;
                      malpy[wdolibok].polozenieX := malpy[wdolibok].polozenieX + 10;
                 end;

            end;
      end
      else  if (malpy[ktoranajwieksza].polozenieX = 600) then   {teraz to juz nie wiem co z tym....}
      begin
         stronaruchu := 1;
         for wdolibok := 0 to ilemalp do
           begin
                if ( (malpy[wdolibok].zyje = 1) and (malpy[wdolibok].rodzaj <> 3) ) then
                begin
                     malpy[wdolibok].polozenieY := malpy[wdolibok].polozenieY + 10;
                     malpy[wdolibok].polozenieX := malpy[wdolibok].polozenieX - 10;
                end;

           end;
      end
      else
      begin
             for tylkowbok := 0 to ilemalp do
             begin
                  if ( (malpy[tylkowbok].zyje = 1) and (malpy[tylkowbok].rodzaj <> 3) ) then
                  begin

                       if (stronaruchu = 0) then
                       begin
                              malpy[tylkowbok].polozenieX := malpy[tylkowbok].polozenieX + 10;
                       end
                       else
                       begin
                              malpy[tylkowbok].polozenieX := malpy[tylkowbok].polozenieX - 10;
                       end;
                  end
                  else if (malpy[wdolibok].rodzaj <> 3) then {dlaczego dalej przesuwa bossa?}
                  begin
                       malpy[tylkowbok].polozenieX := 280;
                       malpy[tylkowbok].polozenieY := 20;
                  end;
             end;
      end;




end;

procedure Wynik;                  {sprawdza warunki zwyciestwa}
var iteratormalp : integer;
begin


      {warunki zakonczenia pojedynczego poziomu}
  if (gracz1.zycia = 0) then
  begin
       endOflev := 1;
  end
  else
  if (ilezyje = 0) then
  begin
       endOflev := 2;
  end;

  for iteratormalp := ilemalp downto 0 do
  begin
       if ( malpy[iteratormalp].polozenieY > 430 ) then
       begin
            endOflev := 1;
       end;
  end;



end;

procedure Init;                   {laduje warunki poczatkowe poziomu}
var bariera : integer;
var x : integer;
var y : integer;
var r : integer;
Begin

  al_blit( grafika.tlo, al_screen, 0, 0, 0, 0, 640, 480 );
  al_textout_ex(al_screen,al_font,'Czekaj.......', 50,450, al_makecol(255,255,255), -1);


  {grafika.gracz := al_create_bitmap(240,60); }
  grafika.gracz := al_load_bmp('gracz.bmp',dobitmap);
  {grafika.bonus := al_create_bitmap(20,20);}
  grafika.bonus := al_load_bmp('bonus.bmp',dobitmap);
  {grafika.pocisk := al_create_bitmap(50,30);}
  grafika.pocisk := al_load_bmp('pocisk.bmp',dobitmap);
  {grafika.malpa := al_create_bitmap(360,130);}
  grafika.malpa := al_load_bmp('malpa.bmp',dobitmap);
  {grafika.bariery := al_create_bitmap(20,20);}
  grafika.bariery := al_load_bmp('bariera.bmp',dobitmap);


  if ( ilegraczy = 2 ) then
  begin
       gracz1.polozenieX := 400;
       gracz2.polozenieX := 200;
  end
  else
  begin
       gracz1.polozenieX := 300;
  end;
  opoznieniemalp := 9;
  przeskokmalpy := 1;
  czestoscwystrzlu := 5;
  przeskokwystrzalu := 1;
  opoznieniepocisku := 1;
  przeskokpocisku := 2;

  case poziom of
  1: Assign(plik, 'poziom1.txt');
  2: Assign(plik, 'poziom2.txt');
  3: Assign(plik, 'poziom3.txt');
  4: Assign(plik, 'poziom4.txt');
  5: Assign(plik, 'poziom5.txt');
  6: Assign(plik, 'poziom6.txt');
  7: Assign(plik, 'poziom7.txt');
  8: Assign(plik, 'poziom8.txt');
  9: Assign(plik, 'poziom9boss.txt');
  end;

  Reset(plik);

  ilemalp := 1;
  while not eof(plik) do
  begin
       ReadLN(plik,doplikow);
       x := 0;
       y := 0;
       r := 0;

       {teraz ze stringa doplikow, wyciagniemy odpowiednie dane}
       case doplikow[1] of
       '0':;
       '1':  x := x + 100;
       '2':  x := x + 200;
       '3':  x := x + 300;
       '4':  x := x + 400;
       '5':  x := x + 500;
       '6':  x := x + 600;
       '7':  x := x + 700;
       '8':  x := x + 800;
       '9':  x := x + 900;
       end;

       case doplikow[2] of
       '0':;
       '1':  x := x + 10;
       '2':  x := x + 20;
       '3':  x := x + 30;
       '4':  x := x + 40;
       '5':  x := x + 50;
       '6':  x := x + 60;
       '7':  x := x + 70;
       '8':  x := x + 80;
       '9':  x := x + 90;
       end;

       case doplikow[3] of
       '0':;
       '1':  x := x + 1;
       '2':  x := x + 2;
       '3':  x := x + 3;
       '4':  x := x + 4;
       '5':  x := x + 5;
       '6':  x := x + 6;
       '7':  x := x + 7;
       '8':  x := x + 8;
       '9':  x := x + 9;
       end;

       case doplikow[5] of
       '0':;
       '1':  y := y + 100;
       '2':  y := y + 200;
       '3':  y := y + 300;
       '4':  y := y + 400;
       '5':  y := y + 500;
       '6':  y := y + 600;
       '7':  y := y + 700;
       '8':  y := y + 800;
       '9':  y := y + 900;
       end;

       case doplikow[6] of
       '0':;
       '1':  y := y + 10;
       '2':  y := y + 20;
       '3':  y := y + 30;
       '4':  y := y + 40;
       '5':  y := y + 50;
       '6':  y := y + 60;
       '7':  y := y + 70;
       '8':  y := y + 80;
       '9':  y := y + 90;
       end;

       case doplikow[7] of
       '0':;
       '1':  y := y + 1;
       '2':  y := y + 2;
       '3':  y := y + 3;
       '4':  y := y + 4;
       '5':  y := y + 5;
       '6':  y := y + 6;
       '7':  y := y + 7;
       '8':  y := y + 8;
       '9':  y := y + 9;
       end;

       case doplikow[9] of
       '0': r := 0;
       '1': r := 1;
       '2': r := 2;
       '3': r := 3;
       end;


       malpy[ilemalp].polozenieX := x;
       malpy[ilemalp].polozenieY := y;
       malpy[ilemalp].rodzaj := r;
       malpy[ilemalp].zyje := 1;

       inc(ilemalp);
  end;

  Close(plik);

  ilezyje := ilemalp - 1;

  {laduje z plikow bariery nasze}
  case poziom of
  1: Assign(plik, 'bariery1.txt');
  2: Assign(plik, 'bariery1.txt');
  3: Assign(plik, 'bariery1.txt');
  4: Assign(plik, 'bariery2.txt');
  5: Assign(plik, 'bariery2.txt');
  6: Assign(plik, 'bariery3.txt');
  7: Assign(plik, 'bariery3.txt');
  8: Assign(plik, 'bariery4.txt');
  9: Assign(plik, 'bariery4.txt');
  end;

  Reset(plik);

  bariera := 0;
  while not eof(plik) do
  begin
       ReadLN(plik,doplikow);
       x := 0;
       y := 0;
       r := 0;

       {teraz ze stringa doplikow, wyciagniemy odpowiednie dane}
       case doplikow[1] of
       '0':;
       '1':  x := x + 100;
       '2':  x := x + 200;
       '3':  x := x + 300;
       '4':  x := x + 400;
       '5':  x := x + 500;
       '6':  x := x + 600;
       '7':  x := x + 700;
       '8':  x := x + 800;
       '9':  x := x + 900;
       end;

       case doplikow[2] of
       '0':;
       '1':  x := x + 10;
       '2':  x := x + 20;
       '3':  x := x + 30;
       '4':  x := x + 40;
       '5':  x := x + 50;
       '6':  x := x + 60;
       '7':  x := x + 70;
       '8':  x := x + 80;
       '9':  x := x + 90;
       end;

       case doplikow[3] of
       '0':;
       '1':  x := x + 1;
       '2':  x := x + 2;
       '3':  x := x + 3;
       '4':  x := x + 4;
       '5':  x := x + 5;
       '6':  x := x + 6;
       '7':  x := x + 7;
       '8':  x := x + 8;
       '9':  x := x + 9;
       end;

       case doplikow[5] of
       '0':;
       '1':  y := y + 100;
       '2':  y := y + 200;
       '3':  y := y + 300;
       '4':  y := y + 400;
       '5':  y := y + 500;
       '6':  y := y + 600;
       '7':  y := y + 700;
       '8':  y := y + 800;
       '9':  y := y + 900;
       end;

       case doplikow[6] of
       '0':;
       '1':  y := y + 10;
       '2':  y := y + 20;
       '3':  y := y + 30;
       '4':  y := y + 40;
       '5':  y := y + 50;
       '6':  y := y + 60;
       '7':  y := y + 70;
       '8':  y := y + 80;
       '9':  y := y + 90;
       end;

       case doplikow[7] of
       '0':;
       '1':  y := y + 1;
       '2':  y := y + 2;
       '3':  y := y + 3;
       '4':  y := y + 4;
       '5':  y := y + 5;
       '6':  y := y + 6;
       '7':  y := y + 7;
       '8':  y := y + 8;
       '9':  y := y + 9;
       end;

       case doplikow[9] of
       '0': r := 0;
       '1': r := 1;
       '2': r := 2;
       '3': r := 3;
       end;


       bariery[bariera].polozenieX := x;
       bariery[bariera].polozenieY := y;
       bariery[bariera].rodzaj := r;
       bariery[bariera].stan := 1;

       inc(bariera);

  end;

  Close(plik);

  {w tym momencie zaczyna juz sobie grac muzyczka z tla}
  al_rest(1500);
  al_clear_to_color( al_screen, al_makecol( 0, 0, 0 ) );

end;

procedure Input;                       {interakcja graczy}
Begin

  if( al_key[AL_KEY_ESC]) then
  begin
      endOfgame := 1; endOflev := 1;
  end;

  if (al_key[AL_KEY_LEFT]) then     {poruszanie sie gracza1}
  begin
       if ((gracz1.polozenieX > 10) and (gracz1.lasergotowy = 0)) then
       begin
            gracz1.polozenieX := gracz1.polozenieX - 10;
            pozycjegracza[0] := gracz1.polozenieX;
       end;
  end;

  if (al_key[AL_KEY_RIGHT]) then
  begin
       if ((gracz1.polozenieX < 600) and (gracz1.lasergotowy = 0)) then
       begin
          if (ilegraczy = 1) then
          begin
               gracz1.polozenieX := gracz1.polozenieX + 10;
               pozycjegracza[0] := gracz1.polozenieX;
          end
          else if (gracz2.polozenieX <> gracz1.polozenieX + 30) then
          begin
               gracz1.polozenieX := gracz1.polozenieX + 10;
               pozycjegracza[0] := gracz1.polozenieX;
          end;
       end;
  end;

  if (al_key[AL_KEY_UP]) then         {strzelanie gracz 1, gracz drugi ma wszystko analogicznie}
  begin
       if (gracz1.rodzajbroni = 0) then
       begin
            if ( (gracz1.pociski[430] = 0) and (gracz1.pociski[420] = 0) and (gracz1.pociski[410] = 0) and (gracz1.pociski[400] = 0) and (gracz1.pociski[390] = 0) and (gracz1.pociski[380] = 0)and (gracz1.pociski[370] = 0)and (gracz1.pociski[360] = 0)and (gracz1.pociski[350] = 0) ) then
            begin
            gracz1.pociski[440] := (gracz1.polozenieX+15);
            {dzwiek strzalu}
            al_play_sample( grafika.dzwiek_shot, 200, 127, 1000, 1=0 );

            end;
       end
       else if ( (gracz1.rodzajbroni = 1) and (gracz1.lasergotowy = 0) ) then
       begin
            gracz1.lasergotowy := 1;
            gracz1.opoznienielasera := 50;
       end;
  end;

  if (al_key[AL_KEY_ENTER]) then    {wysylanie torpedy}
  begin
       if ((gracz1.polozenieX < 600) and (gracz1.lasergotowy = 0)) then
       begin
            if (bonus.torpedy > 0) then
            begin
               dec(bonus.torpedy); bonus.CzasTorpedy := 10;
            end;
       end;
  end;

  {drugi gracz}
  if ( ilegraczy = 2 ) then
  begin
       if (al_key[AL_KEY_A]) then     {poruszanie sie gracza2}
       begin
            if ((gracz2.polozenieX > 10) and (gracz2.lasergotowy = 0) and (gracz2.polozenieX <> gracz1.polozenieX + 30) ) then
            begin
                 gracz2.polozenieX := gracz2.polozenieX - 10;
                 pozycjegracza[0] := gracz2.polozenieX;
            end;
       end;

       if (al_key[AL_KEY_D]) then
       begin
            if ((gracz2.polozenieX < 600) and (gracz2.lasergotowy = 0)) then
            begin
               gracz2.polozenieX := gracz2.polozenieX + 10;
               pozycjegracza[0] := gracz2.polozenieX;
            end;
       end;

       if (al_key[AL_KEY_W]) then         {strzelanie gracz 2}
       begin
            if (gracz2.rodzajbroni = 0) then
            begin
                 if ( (gracz2.pociski[430] = 0) and (gracz2.pociski[420] = 0) and (gracz2.pociski[410] = 0) and (gracz2.pociski[400] = 0) and (gracz2.pociski[390] = 0) and (gracz2.pociski[380] = 0)and (gracz2.pociski[370] = 0)and (gracz2.pociski[360] = 0)and (gracz2.pociski[350] = 0) ) then
                 begin
                 gracz2.pociski[440] := (gracz2.polozenieX+15);
                 {dzwiek strzalu}
                 al_play_sample( grafika.dzwiek_shot, 200, 127, 1000, 1=0 );

                 end;
            end
            else if ( (gracz2.rodzajbroni = 1) and (gracz2.lasergotowy = 0) ) then
            begin
                 gracz2.lasergotowy := 1;
                 gracz2.opoznienielasera := 50;
            end;
       end;
  end;

end;

procedure Modyfication;                {w tej procedurze znajdują się procedury odpowiedzialne za kazda zmiane stanu gry}
var ktoranajmniejsza : integer;
var ktoranajwieksza : integer;
var wysokosc : integer;
var iterator : integer;
Begin

     Wynik;

     if (bonus.czaskomunikatu <> 0) then
     begin
        dec(bonus.czaskomunikatu);
     end;

     if (bonus.CzasTarczy <> 0) then
     begin
        dec(bonus.CzasTarczy);
     end;

     if (bonus.CzasOgnia <> 0) then
     begin
        dec(bonus.CzasOgnia);
     end;

     if (bonus.CzasTorpedy = 10) then
     begin
        dec(bonus.CzasTorpedy);
        wysokosc := 10;
        repeat
              pociskimalp[wysokosc]:= 0;
              wysokosc := wysokosc + 10;
        until wysokosc = 470;

     end
     else if (bonus.CzasTorpedy > 0) then
     begin
        dec(bonus.CzasTorpedy);
     end;


     inc(przeskokpocisku);
     if (przeskokpocisku >= opoznieniepocisku) then
     begin
          Pociskprzeciwnika;
          przeskokpocisku := 0;
     end;

     inc(przeskokwystrzalu);
     if ( (przeskokwystrzalu > czestoscwystrzlu) and (bonus.Mroz = 0) ) then
     begin
          MalpyStrzelaja;
          przeskokwystrzalu := 0;
     end;

     Pociskgracza;

     Przesunbonus;

     {Powyzej procedury odpowiedzialne za przesuwanie pociskow i bonuse}

     Kolizje;  {chyba jasne prawda? kopalnia bledow i baaaardzo duzo tego...}

     inc(przeskokmalpy);
     if ( (przeskokmalpy > opoznieniemalp) and (bonus.Mroz = 0) ) then
     begin           {przesuwa przeciwnikow}
          Przesunmalpy(ktoranajwieksza,ktoranajmniejsza);
          przeskokmalpy := 0;
     end;

     {pracuje z tablica naszych pozycji zeszlych}
     for iterator := 44 downto 0 do
     begin
          pozycjegracza[iterator + 1] := pozycjegracza[iterator];
     end;

     {aktywacja 2 bonusa}                                        {warunki tego bonusa jeszcze pozmieniaj trochu}
     if ( (bonus.drugi_stan = 0) and ((gracz1.punkty - gracz1.zycia = 13) or (gracz1.punkty - gracz1.zycia = 37) or (gracz1.punkty - gracz1.zycia = 53) or (gracz1.punkty - gracz1.zycia = 84)  ) ) then
     begin
          bonus.drugi_stan := 1;
          bonus.drugi_polozenieX := 10;
          bonus.drugi_polozenieY := 10;
     end;

     if ( (bonus.drugi_stan = 1) and (bonus.drugi_polozenieX = 620) ) then
     begin
          bonus.drugi_stan := 0;
     end;

       {do animacji poruszania sie malp}
       if ( grafika.klatka_malp = 39) then
       begin
            grafika.klatka_malp := 0;
       end
       else if (bonus.Mroz <> 1) then
       begin
            inc(grafika.klatka_malp);
       end;

end;

procedure Drawing;                                  {w tej procedurze nastepuje rysowanie + kilka dzwiekow}
var ktoramalpa : integer;
var wysokosc : integer;
var punktowychar : char;
var zyciowychar : char;
var torpedowychar : char;
var poziomowychar : char;
var iterator : integer;
Begin

  al_clear_to_color( grafika.bufor, al_makecol( 0, 0, 0 ) );


  {rysowanie wystrzelanych torped}
  wysokosc := 470;
  if (bonus.CzasTorpedy > 0) then
  begin
     al_blit( grafika.pocisk, grafika.bufor, 21,0, 280,200, 30, 30);
     al_blit( grafika.pocisk, grafika.bufor, 21,0, 470,130, 30, 30);
     al_blit( grafika.pocisk, grafika.bufor, 21,0, 170,360, 30, 30);
     al_blit( grafika.pocisk, grafika.bufor, 21,0, 70,210, 30, 30);
     al_blit( grafika.pocisk, grafika.bufor, 21,0, 560,210, 30, 30);
     al_blit( grafika.pocisk, grafika.bufor, 21,0, 390,120, 30, 30);
     al_blit( grafika.pocisk, grafika.bufor, 21,0, 130,60, 30, 30);

     {dzwiek torpedy}
     al_play_sample( grafika.dzwiek_torpeda, 200, 127, 1000, 1=0 );
  end;

  {ponizej jest rysowanie strzalow gracza}
  wysokosc := 470;
  if (gracz1.rodzajbroni = 0) then
  begin
       repeat
             if (gracz1.pociski[wysokosc] <> 0) then
             begin
                al_blit( grafika.pocisk, grafika.bufor, 9,0, gracz1.pociski[wysokosc],wysokosc, 4, 4);
             end;

             wysokosc := wysokosc - 10;
       until wysokosc = 10;
  end
  else if (gracz1.rodzajbroni = 1)  then
  begin
       wysokosc := 400;
       if (gracz1.lasergotowy = 2) then
       begin
            {dzwiek lasera gracza 1}
            al_play_sample( grafika.dzwiek_laser1, 200, 127, 1000, 1=0 );

            repeat
                al_blit( grafika.pocisk, grafika.bufor, 13,0, gracz1.polozenieX + 15,wysokosc, 8, 10);

                  wysokosc := wysokosc - 10;
            until wysokosc = 10;
       end
       else if (gracz1.lasergotowy = 1) then
       begin
            al_blit( grafika.gracz, grafika.bufor, 120,0, gracz1.polozenieX,polozenie_karabinuY, 30, 50);
       end
       else if (gracz1.lasergotowy = 0) then
       begin
            al_blit( grafika.gracz, grafika.bufor, 60,0, gracz1.polozenieX,polozenie_karabinuY, 30, 50);
       end;
  end;
  {i 2 tez!}
  if (ilegraczy = 2) then
  begin
       wysokosc := 430;
  if (gracz2.rodzajbroni = 0) then
  begin
       repeat
             if (gracz2.pociski[wysokosc] <> 0) then
             begin
                al_blit( grafika.pocisk, grafika.bufor, 9,0, gracz2.pociski[wysokosc],wysokosc, 4, 4);
             end;

             wysokosc := wysokosc - 10;
       until wysokosc = 10;
  end
  else if (gracz2.rodzajbroni = 1)  then
  begin
       wysokosc := 400;
       if (gracz2.lasergotowy = 2) then
       begin
            {dzwiek lasera gracza 1}
            al_play_sample( grafika.dzwiek_laser2, 200, 127, 1000, 1=0 );

            repeat
                al_blit( grafika.pocisk, grafika.bufor, 13,0, gracz2.polozenieX + 15,wysokosc, 8, 10);

                  wysokosc := wysokosc - 10;
            until wysokosc = 10;
       end
       else if (gracz2.lasergotowy = 1) then
       begin
          al_blit( grafika.gracz, grafika.bufor, 150,0, gracz2.polozenieX,polozenie_karabinuY, 30, 50);
       end
       else if (gracz2.lasergotowy = 0) then
       begin
          al_blit( grafika.gracz, grafika.bufor, 90,0, gracz2.polozenieX,polozenie_karabinuY, 30, 50);
       end;
  end;
  end;

  {ponizej rysowanie strzalow malp}
  wysokosc := 470;
  repeat
      if (pociskimalp[wysokosc]<>0) then
       begin
          al_blit( grafika.pocisk, grafika.bufor, 0,0, pociskimalp[wysokosc],wysokosc-12, 8, 20);
       end;

      wysokosc := wysokosc - 10;
  until wysokosc = 10;

  {rysowanie bonusa}
  if (bonus.stan <> 0) then
  begin
       al_blit( grafika.bonus, grafika.bufor, 0,0, bonus.polozenieX,bonus.polozenieY, 20, 20);
  end;

 {rysowanie przeciwnikow}
 for ktoramalpa := 0 to ilemalp do
  begin

     if (malpy[ktoramalpa].zyje = 1) then
       begin

            if (malpy[ktoramalpa].rodzaj = 3) then    {boss}
            begin

                 if (grafika.klatka_malp < 10) then
                 begin
                      al_blit( grafika.malpa, grafika.bufor, 0,41, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 80, 80);
                 end
                 else if (grafika.klatka_malp < 20) then
                 begin
                      al_blit( grafika.malpa, grafika.bufor, 120,41, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 80, 80);
                 end
                 else if (grafika.klatka_malp < 30) then
                 begin
                  al_blit( grafika.malpa, grafika.bufor, 240,41, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 80, 80);
                 end
                 else if (grafika.klatka_malp < 40) then
                 begin
                      al_blit( grafika.malpa, grafika.bufor, 120,41, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 80, 80);
                 end;


                if ( ilezyje > 1 ) then
                begin

                    al_blit( grafika.malpa, grafika.bufor, 0,121, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY + 90, 80, 10);
                end;
                if ( zyciebossa > 0 ) then
                begin
                       al_textout_ex(grafika.bufor,al_font,chr(zyciebossa+48), malpy[ktoramalpa].polozenieX + 20, malpy[ktoramalpa].polozenieY - 15, al_makecol(255,255,255), -1);
                end;

            end
            else if (malpy[ktoramalpa].rodzaj = 2) then
            begin

                if (grafika.klatka_malp < 10) then
                begin
                     al_blit( grafika.malpa, grafika.bufor, 80,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end
                else if (grafika.klatka_malp < 20) then
                begin
                     al_blit( grafika.malpa, grafika.bufor, 200,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end
                else if (grafika.klatka_malp < 30) then
                begin
                 al_blit( grafika.malpa, grafika.bufor, 320,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end
                else if (grafika.klatka_malp < 40) then
                begin
                     al_blit( grafika.malpa, grafika.bufor, 200,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end;

            end
            else if (malpy[ktoramalpa].rodzaj = 1) then
            begin

                if (grafika.klatka_malp < 10) then
                begin
                     al_blit( grafika.malpa, grafika.bufor, 40, 0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end
                else if (grafika.klatka_malp < 20) then
                begin
                     al_blit( grafika.malpa, grafika.bufor, 160, 0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end
                else if (grafika.klatka_malp < 30) then
                begin
                 al_blit( grafika.malpa, grafika.bufor, 280, 0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end
                else if (grafika.klatka_malp < 40) then
                begin
                     al_blit( grafika.malpa, grafika.bufor, 160, 0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
                end;

            end
            else
            begin

               if (grafika.klatka_malp < 10) then
               begin
                    al_blit( grafika.malpa, grafika.bufor, 0,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end
               else if (grafika.klatka_malp < 20) then
               begin
                    al_blit( grafika.malpa, grafika.bufor, 120,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end
               else if (grafika.klatka_malp < 30) then
               begin
                al_blit( grafika.malpa, grafika.bufor, 240,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end
               else if (grafika.klatka_malp < 40) then
               begin
                    al_blit( grafika.malpa, grafika.bufor, 120,0, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end;

            end;

       end;
  end;

  {pokazuje ze malpy zamrozone}
  if (bonus.Mroz = 1) then
  begin
     for ktoramalpa := 0 to ilemalp do
      begin
           if ( (malpy[ktoramalpa].zyje = 1) and (malpy[ktoramalpa].rodzaj <> 3 {na bosa trzebaby w foramcie png}) ) then
           begin

               if (grafika.klatka_malp < 10) then
               begin
                    al_blit( grafika.malpa, grafika.bufor, 80,40, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end
               else if (grafika.klatka_malp < 20) then
               begin
                    al_blit( grafika.malpa, grafika.bufor, 200,40, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end
               else if (grafika.klatka_malp < 30) then
               begin
                al_blit( grafika.malpa, grafika.bufor, 320,40, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end
               else if (grafika.klatka_malp < 40) then
               begin
                    al_blit( grafika.malpa, grafika.bufor, 200,40, malpy[ktoramalpa].polozenieX,malpy[ktoramalpa].polozenieY, 40, 40);
               end;

           end;
      end;
  end;

 {rysowanie gracza, wraz z efektami bonusow}

  {

  tutaj prototyp animacji poruszania sie gracza, osobno jest potrzebny dla 2

  if (al_key[AL_KEY_LEFT]) then {leci w lewo}
  begin

  end
  else if (al_key[AL_KEY_RIGHT]) then  {leci w prawo}
  begin

  end
  else    {jak jestesmy w miejscu}
  begin

  end;

  }

  if (gracz1.rodzajbroni = 0 ) then
  begin
       al_blit( grafika.gracz, grafika.bufor, 0,0, gracz1.polozenieX,polozenie_karabinuY, 30, 50);
  end;

  if (bonus.CzasTarczy > 0) then
  begin
       al_blit( grafika.gracz, grafika.bufor, 0,50, gracz1.polozenieX,polozenie_karabinuY, 30, 50);
  end;
  if (bonus.CzasOgnia > 0) then
  begin
       al_blit( grafika.gracz, grafika.bufor, 180,0, gracz1.polozenieX,polozenie_karabinuY, 30, 50);
  end;

  {i 2 tez!}
  if (ilegraczy = 2) then
  begin
         if (gracz2.rodzajbroni = 0 ) then
         begin
              al_blit( grafika.gracz, grafika.bufor, 30,0, gracz2.polozenieX,polozenie_karabinuY, 30, 50);
         end;

         if (bonus.CzasTarczy > 0) then
         begin
              al_blit( grafika.gracz, grafika.bufor, 0,50, gracz2.polozenieX,polozenie_karabinuY, 30, 50);
         end;
         if (bonus.CzasOgnia > 0) then
         begin
              al_blit( grafika.gracz, grafika.bufor, 210,0, gracz2.polozenieX,polozenie_karabinuY, 30, 50);
         end;
  end;

  {rysowanie barier}
  for ktoramalpa := 0 to 100 do
  begin
        if (bariery[ktoramalpa].stan = 1) then
        begin

            al_blit( grafika.bariery, grafika.bufor, 0,0, bariery[ktoramalpa].polozenieX,bariery[ktoramalpa].polozenieY, 20, 20);

        end;
  end;
  {rysowanie drugiego rodzaju bonusa}
  if ( bonus.drugi_stan = 1 ) then
  begin

       if (grafika.klatka_malp < 10) then
                 begin
                      al_blit( grafika.malpa, grafika.bufor, 80,80, bonus.drugi_polozenieX,bonus.drugi_polozenieY, 30, 20);
                 end
                 else if (grafika.klatka_malp < 20) then
                 begin
                      al_blit( grafika.malpa, grafika.bufor, 200,80, bonus.drugi_polozenieX,bonus.drugi_polozenieY, 30, 20);
                 end
                 else if (grafika.klatka_malp < 30) then
                 begin
                  al_blit( grafika.malpa, grafika.bufor, 320,80, bonus.drugi_polozenieX,bonus.drugi_polozenieY, 30, 20);
                 end
                 else if (grafika.klatka_malp < 40) then
                 begin
                      al_blit( grafika.malpa, grafika.bufor, 200,80, bonus.drugi_polozenieX,bonus.drugi_polozenieY, 30, 20);
                 end;

       {tutaj tez takie dzwieki odtawrza, ze leci spodek, myk myk!!!}
  end;



  {rysowanie naglych elementow interfejsu}
  if (bonus.czaskomunikatu > 0) then
  begin
       case bonus.komunikat of
       1: al_textout_ex(grafika.bufor,al_font,'LIFE UP + 1!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       2: al_textout_ex(grafika.bufor,al_font,'Zlapales Torpede!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       3: al_textout_ex(grafika.bufor,al_font,'Zmieniles Bron!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       4: al_textout_ex(grafika.bufor,al_font,'Zmiana Kierunku!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       5: al_textout_ex(grafika.bufor,al_font,'Przyspieszyly!!!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       6: al_textout_ex(grafika.bufor,al_font,'Spowolnily!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       7: al_textout_ex(grafika.bufor,al_font,'Tarcza!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       8: al_textout_ex(grafika.bufor,al_font,'Mrozem ich!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       9: al_textout_ex(grafika.bufor,al_font,'Ale Upal!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       10: al_textout_ex(grafika.bufor,al_font,'Chron Twarz!', ScreenWidth div 2, ScreenHeight - 20, al_makecol(255,255,255), -1);
       end;
  end;

  {rysowanie stalych elementow interfejsu}
 al_textout_ex(grafika.bufor,al_font,'Punkty', 20,410, al_makecol(255,255,255), -1);
 if (gracz1.punkty > 99 ) then
 begin
    punktowychar := chr(gracz1.punkty div 100 + 48);
    al_textout_ex(grafika.bufor,al_font,punktowychar, 20,420, al_makecol(255,255,255), -1);
    punktowychar := chr(((gracz1.punkty div 10) mod 10) + 48);
    al_textout_ex(grafika.bufor,al_font,punktowychar, 30,420, al_makecol(255,255,255), -1);
    punktowychar := chr(gracz1.punkty mod 10 + 48);
    al_textout_ex(grafika.bufor,al_font,punktowychar, 40,420, al_makecol(255,255,255), -1);
 end
 else if (gracz1.punkty > 9) then
 begin
      punktowychar := chr(gracz1.punkty div 10 + 48);
      al_textout_ex(grafika.bufor,al_font,punktowychar, 20,420, al_makecol(255,255,255), -1);
      punktowychar := chr(gracz1.punkty mod 10 + 48);
      al_textout_ex(grafika.bufor,al_font,punktowychar, 30,420, al_makecol(255,255,255), -1);
 end
 else
 begin
       punktowychar := chr(gracz1.punkty + 48);
       al_textout_ex(grafika.bufor,al_font,punktowychar, 20,420, al_makecol(255,255,255), -1);
 end;

 al_textout_ex(grafika.bufor,al_font,'Zycia', 580,410, al_makecol(255,255,255), -1);
 if (gracz1.zycia > 9) then
 begin
      zyciowychar := chr(gracz1.zycia div 10 + 48);
      al_textout_ex(grafika.bufor,al_font,zyciowychar, 580,420, al_makecol(255,255,255), -1);
      zyciowychar := chr(gracz1.zycia mod 10 + 48);
      al_textout_ex(grafika.bufor,al_font,zyciowychar, 590,420, al_makecol(255,255,255), -1);
 end
 else
 begin
       zyciowychar := chr(gracz1.zycia + 48);
       al_textout_ex(grafika.bufor,al_font,zyciowychar, 580,420, al_makecol(255,255,255), -1);
 end;

 al_textout_ex(grafika.bufor,al_font,'Torpedy', 20,440, al_makecol(255,255,255), -1);
 if (bonus.torpedy > 9) then
 begin
      torpedowychar := chr(bonus.torpedy div 10 + 48);
      al_textout_ex(grafika.bufor,al_font,torpedowychar, 20,450, al_makecol(255,255,255), -1);
      torpedowychar := chr(bonus.torpedy mod 10 + 48);
      al_textout_ex(grafika.bufor,al_font,torpedowychar, 30,450, al_makecol(255,255,255), -1);
 end
 else
 begin
       torpedowychar := chr(bonus.torpedy + 48);
       al_textout_ex(grafika.bufor,al_font,torpedowychar, 20,450, al_makecol(255,255,255), -1);
 end;

  al_textout_ex(grafika.bufor,al_font,'Poziom', 580,440, al_makecol(255,255,255), -1);
  if (poziom > 9) then
 begin
      poziomowychar := chr(poziom div 10 + 48);
      al_textout_ex(grafika.bufor,al_font,poziomowychar, 580,450, al_makecol(255,255,255), -1);
      poziomowychar := chr(poziom mod 10 + 48);
      al_textout_ex(grafika.bufor,al_font,poziomowychar, 590,450, al_makecol(255,255,255), -1);
 end
 else
 begin
       poziomowychar := chr(poziom + 48);
       al_textout_ex(grafika.bufor,al_font,poziomowychar, 580,450, al_makecol(255,255,255), -1);
 end;



  al_blit( grafika.bufor, al_screen, 0, 0, 0, 0, 640, 480 );
end;

procedure Result;                                 {podsumowanie rozgrywki}
var punktowychar : char;
var zyciowychar : char;
var iterator : integer;
begin

  al_blit( grafika.tlo, grafika.bufor, 0, 0, 0, 0, 0, 0 );

   al_clear_to_color( al_screen, al_makecol( 0, 0, 0 ) );
   al_clear_to_color( grafika.bufor, al_makecol( 0, 0, 0 ) );

  {zerowanie malp i barier, dla penwosci }

  for iterator := 0 to 100 do
  begin
       bariery[iterator].stan := 0;
       malpy[iterator].zyje := 0;
  end;

   ilemalp := 0;
   ilezyje := 0;
   gracz1.lasergotowy := 0;
   gracz2.lasergotowy := 0;
   bonus.drugi_stan := 0;
   bonus.stan := 0;


 if (endOfgame = 1) then
   begin
                  {dzwiek przegranej}
            al_play_sample( grafika.dzwiek_losegame, 200, 127, 1000, 1=0 );


       al_textout_ex(grafika.bufor,al_font,'Przegrales!!!', 250,200, al_makecol(255,255,255), -1);
       al_textout_ex(grafika.bufor,al_font,'Uzbierales marne: ', 250,210, al_makecol(255,255,255), -1);

        if (gracz1.punkty > 99) then
              begin
                  punktowychar := chr(gracz1.punkty div 100 + 48);
                  al_textout_ex(grafika.bufor,al_font,punktowychar, 410,210, al_makecol(255,255,255), -1);
                  doplikow := punktowychar;
                  punktowychar := chr(((gracz1.punkty div 10) mod 10)+48);
                  al_textout_ex(grafika.bufor,al_font,punktowychar, 420,210, al_makecol(255,255,255), -1);
                  doplikow := doplikow + punktowychar;
                  punktowychar := chr(gracz1.punkty mod 10 + 48);
                  al_textout_ex(grafika.bufor,al_font,punktowychar, 430,210, al_makecol(255,255,255), -1);
                  doplikow := doplikow + punktowychar;
                  al_textout_ex(grafika.bufor,al_font,'puntky', 450,210, al_makecol(255,255,255), -1);
              end
              else if (gracz1.punkty > 9) then
              begin
                  punktowychar := chr(gracz1.punkty div 10 + 48);
                  al_textout_ex(grafika.bufor,al_font,punktowychar, 420,210, al_makecol(255,255,255), -1);
                  doplikow := punktowychar;
                  punktowychar := chr(gracz1.punkty mod 10 + 48);
                  al_textout_ex(grafika.bufor,al_font,punktowychar, 430,210, al_makecol(255,255,255), -1);
                  doplikow := doplikow + punktowychar;
                  al_textout_ex(grafika.bufor,al_font,'punkty', 450,210, al_makecol(255,255,255), -1);
              end
              else
              begin
                  punktowychar := chr(gracz1.punkty + 48);
                  al_textout_ex(grafika.bufor,al_font,punktowychar, 420,210, al_makecol(255,255,255), -1);
                  doplikow := punktowychar;
                  al_textout_ex(grafika.bufor,al_font,'punkty', 450,210, al_makecol(255,255,255), -1);
              end;
   end
 else if (endOfgame = 2) then
   begin

       {dzwiek wygranej}
       al_play_sample( grafika.dzwiek_wingame, 200, 127, 1000, 1=0 );

      al_textout_ex(grafika.bufor,al_font,' Wygrales!!!', 250,200, al_makecol(255,255,255), -1);
      al_textout_ex(grafika.bufor,al_font,'Uzbierales cenne: ', 250,210, al_makecol(255,255,255), -1);

      if (gracz1.punkty > 99) then
            begin
                punktowychar := chr(gracz1.punkty div 100 + 48);
                al_textout_ex(grafika.bufor,al_font,punktowychar, 410,210, al_makecol(255,255,255), -1);
                doplikow := punktowychar;
                punktowychar := chr(((gracz1.punkty div 10) mod 10)+48);
                al_textout_ex(grafika.bufor,al_font,punktowychar, 420,210, al_makecol(255,255,255), -1);
                doplikow := doplikow + punktowychar;
                punktowychar := chr(gracz1.punkty mod 10 + 48);
                al_textout_ex(grafika.bufor,al_font,punktowychar, 430,210, al_makecol(255,255,255), -1);
                doplikow := doplikow + punktowychar;
                al_textout_ex(grafika.bufor,al_font,'puntky', 450,210, al_makecol(255,255,255), -1);
            end
            else if (gracz1.punkty > 9) then
            begin
                punktowychar := chr(gracz1.punkty div 10 + 48);
                al_textout_ex(grafika.bufor,al_font,punktowychar, 420,210, al_makecol(255,255,255), -1);
                doplikow := punktowychar;
                punktowychar := chr(gracz1.punkty mod 10 + 48);
                al_textout_ex(grafika.bufor,al_font,punktowychar, 430,210, al_makecol(255,255,255), -1);
                doplikow := doplikow + punktowychar;
                al_textout_ex(grafika.bufor,al_font,'punkty', 450,210, al_makecol(255,255,255), -1);
            end
            else
            begin
                punktowychar := chr(gracz1.punkty + 48);
                al_textout_ex(grafika.bufor,al_font,punktowychar, 420,210, al_makecol(255,255,255), -1);
                doplikow := punktowychar;
                al_textout_ex(grafika.bufor,al_font,'punkty', 450,210, al_makecol(255,255,255), -1);
            end;
      if (gracz1.zycia > 9) then
      begin
         al_textout_ex(grafika.bufor,al_font,'Zachowujac przy tym: ', 240,230, al_makecol(255,255,255), -1);
         zyciowychar := chr(gracz1.zycia div 10 + 48);
         al_textout_ex(grafika.bufor,al_font,zyciowychar, 440,230, al_makecol(255,255,255), -1);
         zyciowychar := chr(gracz1.zycia mod 10 + 48);
         al_textout_ex(grafika.bufor,al_font,zyciowychar, 450,230, al_makecol(255,255,255), -1);
         al_textout_ex(grafika.bufor,al_font,'zyc', 470,230, al_makecol(255,255,255), -1);
      end
      else
      begin
           al_textout_ex(grafika.bufor,al_font,'Zachowujac przy tym: ', 240,230, al_makecol(255,255,255), -1);
           zyciowychar := chr(gracz1.zycia mod 10 + 48);
           al_textout_ex(grafika.bufor,al_font,zyciowychar, 450,230, al_makecol(255,255,255), -1);
           al_textout_ex(grafika.bufor,al_font,'zyc', 470,230, al_makecol(255,255,255), -1);
      end;

   end;



   al_blit( grafika.bufor, al_screen, 0, 0, 0, 0, 640, 480 );

   al_rest(4000);
   al_readkey();
   al_clear_to_color( al_screen, al_makecol( 0, 0, 0 ) );
   al_clear_to_color( grafika.bufor, al_makecol( 0, 0, 0 ) );



end;

procedure Najlepsi;                  {uaktualnia liste najlepszych graczy}
var wybor : integer;
var klawisz : char;
var iterator : integer;
var ppkt : integer;
var ktoryprzesunac : integer;
var iterator2 : integer;
var wypis : string;
begin

        ktoryprzesunac := 0;
        {zapisujemy do najlepszych}
        Assign(plik,'najlepsi.txt');
        Reset(plik);
        ReadLN(plik,doplikow);
        for iterator := 1 to 10 do
        begin

             ppkt := 0;
             if ( doplikow[iterator*6-2] <> '0' ) then
             begin

                case doplikow[iterator*6-2] of
                '1':  ppkt := ppkt + 100;
                '2':  ppkt := ppkt + 200;
                '3':  ppkt := ppkt + 300;
                '4':  ppkt := ppkt + 400;
                '5':  ppkt := ppkt + 500;
                '6':  ppkt := ppkt + 600;
                '7':  ppkt := ppkt + 700;
                '8':  ppkt := ppkt + 800;
                '9':  ppkt := ppkt + 900;
                end;

             end;
             if (doplikow[iterator*6-1] <> '0') then
             begin

                case doplikow[iterator*6-1] of
                '1':  ppkt := ppkt + 10;
                '2':  ppkt := ppkt + 20;
                '3':  ppkt := ppkt + 30;
                '4':  ppkt := ppkt + 40;
                '5':  ppkt := ppkt + 50;
                '6':  ppkt := ppkt + 60;
                '7':  ppkt := ppkt + 70;
                '8':  ppkt := ppkt + 80;
                '9':  ppkt := ppkt + 90;
                end;

             end;

             case doplikow[iterator*6] of
             '1':  ppkt := ppkt + 1;
             '2':  ppkt := ppkt + 2;
             '3':  ppkt := ppkt + 3;
             '4':  ppkt := ppkt + 4;
             '5':  ppkt := ppkt + 5;
             '6':  ppkt := ppkt + 6;
             '7':  ppkt := ppkt + 7;
             '8':  ppkt := ppkt + 8;
             '9':  ppkt := ppkt + 9;
             end;



             if (ppkt < gracz1.punkty) then
             begin
                  ktoryprzesunac := iterator;
                  break;
                  {w zmiennej ktoramalpa jest indeks, od ktorego goscia na liscie
                  mamy wiecevj pkt... i nawet dziala!!!}
             end;

        end;

        Close(plik);
        { a teraz przesuniemy co trzeba i dopiszemy do trzeba!
        w zmiennej ktoryprzesunac, wiesz od ktorego miejsca cza przesunac!}

        if (ktoryprzesunac <> 0) then
        begin
              Assign(plik,'najlepsi.txt');
              Reset(plik);
              ReadLN(plik,doplikow);

              for iterator := 10 downto ktoryprzesunac do
              begin

                   if (iterator = ktoryprzesunac) then
                   begin
                        doplikow[iterator*6] := chr((gracz1.punkty mod 10)+48);
                        doplikow[iterator*6-1] := chr(((gracz1.punkty div 10) mod 10)+48);
                        doplikow[iterator*6-2] := chr((gracz1.punkty div 100)+48);
                        doplikow[iterator*6-3] := gracz1.pseudonim[3];
                        doplikow[iterator*6-4] := gracz1.pseudonim[2];
                        doplikow[iterator*6-5] := gracz1.pseudonim[1];
                   end
                   else
                   begin
                        doplikow[iterator*6] := doplikow[(iterator-1)*6];
                        doplikow[iterator*6-1] := doplikow[(iterator-1)*6-1];
                        doplikow[iterator*6-2] := doplikow[(iterator-1)*6-2];
                        doplikow[iterator*6-3] := doplikow[(iterator-1)*6-3];
                        doplikow[iterator*6-4] := doplikow[(iterator-1)*6-4];
                        doplikow[iterator*6-5] := doplikow[(iterator-1)*6-5];
                   end;

              end;
              Close(plik);
              Assign(plik,'najlepsi.txt');
              Rewrite(plik);
              Writeln(plik,doplikow);
              Close(plik);
        end;

end;

function Menu: integer;           {dzialanie w menu}
var wybor : integer;
var anim : integer;
var klawisz : char;
var trudnosc : integer;
var pseudo : string;
begin

 {inicjujemy kilka zmiennych potrzebnych przed nowa gra}
 poziom := 1;
 trudnosc := 0;
 gracz1.punkty := 0;
 gracz1.zycia := 5;
 zyciebossa := 5;
 endOfGame := 0;
 endOfGame := 0;

   {czyscimy bonusy z poprzednich rozzgrywek i bron}
   gracz1.rodzajbroni := 0;
   gracz2.rodzajbroni := 0;
      bonus.stan := 0;
    bonus.komunikat := 0;
    bonus.czaskomunikatu := 0;;
    bonus.torpedy := 0;
    bonus.CzasTorpedy := 0;
    bonus.CzasTarczy := 0;
    bonus.CzasOgnia := 0;
    bonus.Mroz := 0;
    bonus.drugi_stan := 0;

  al_blit( grafika.bufor, al_screen, 0, 0, 0, 0, 640, 480 );
  al_clear_to_color( grafika.bufor, al_makecol( 0, 0, 0 ) );

 {menu wraz z grafika}

 wybor := 1;
 anim := 4;

 repeat                {napisy statyczne}
       al_blit( grafika.tlo, grafika.bufor, 640,480, 0, 0, 640, 480);
                       {obsluga klawiatury}
       if (al_key[AL_KEY_UP]) then dec(wybor);
       if (al_key[AL_KEY_DOWN]) then inc(wybor);
       if (wybor = 0) then wybor := 4;
       if (wybor = 5) then wybor := 1;

       {wyswietlanie animacji krecacego sie banana}


            case anim of
            1:al_blit( grafika.tlo, grafika.bufor, 1280,30, 130, 205 + wybor*50, 40, 30);
            2:al_blit( grafika.tlo, grafika.bufor, 1280,60, 130, 205 + wybor*50, 40, 30);
            3:al_blit( grafika.tlo, grafika.bufor, 1280,90, 130, 205 + wybor*50, 40, 30);
            4:al_blit( grafika.tlo, grafika.bufor, 1280,0, 130, 205 + wybor*50, 40, 30);
            5:al_blit( grafika.tlo, grafika.bufor, 1280,120, 130, 205 + wybor*50, 40, 30);
            6:al_blit( grafika.tlo, grafika.bufor, 1280,150, 130, 205 + wybor*50, 40, 30);
            7:al_blit( grafika.tlo, grafika.bufor, 1280,180, 130, 205 + wybor*50, 40, 30);
            end;

            if (anim = 7) then
            begin
                anim := 1;
            end
            else
            begin
                inc(anim);
            end;

       al_rest(110);                {podwojne buforowanie}
       al_blit( grafika.bufor, al_screen, 0, 0, 0, 0, 640, 480 );
 until al_key[AL_KEY_ENTER];

        case wybor of      {dzialanie poszczegolnych sekcji}
       1: begin  end; {nowa gra}
       2: begin  end; {wyswietl najlepszych}
       3: begin  end; {opcje}
       4: begin  al_stop_sample( grafika.dzwiek_music ); end; {wyjscie}
       end;

 al_clear_to_color( grafika.bufor, al_makecol( 0, 0, 0 ) );
 al_blit( grafika.bufor, al_screen, 0, 0, 0, 0, 640, 480 );

 Menu := wybor;

 {wychodzac z menu albo zaczynamy zupelnie nowa rozgrywke albo wychodzimy z gry}

end;

procedure NajlepsiWyswietl;            {jesli gracz zarzada, ukazuje liste najlepszychc z pliku}
var iterator : integer;
var iterator2 : integer;
var wypis : string;
begin
   {wyswietlamy jesli ktos zechce, na tle malpki}

        al_blit( grafika.tlo, al_screen, 0, 0, 0, 0, 640, 480 );

        al_rest(300);
        Assign(plik,'najlepsi.txt');
        Reset(plik);
        ReadLN(plik,doplikow);

        for iterator := 1 to 10 do
        begin
             wypis := '';
             for iterator2 := 1 to 6 do
             begin
                  wypis := wypis+doplikow[iterator2+(iterator*6-6)];
             end;
             al_textout_ex(al_screen,al_font,chr(iterator+47)+'. '+wypis, 160,20+(iterator*10), al_makecol(255,255,255), -1);

             al_textout_ex(al_screen,al_font,'Esc - Powrot', 50,450, al_makecol(255,255,255), -1);

        end;

        Close(plik);

        while (1=1) do
        begin
             if (al_key[AL_KEY_ENTER]) then begin break end
             else if (al_key[AL_KEY_ESC]) then begin break end;
        end;

        {powrot oczywiscie znowu do menu}

end;

procedure Opcje;              {mozliwosc ustawienia psudonimu i ilosci graczy}
var wybor : integer;
begin


       {wyswietlamy jesli ktos zechce, na tle malpki}

       wybor := 1;

        repeat
           al_blit( grafika.tlo, grafika.bufor, 0, 0, 0, 0, 640, 480 );

             al_rest(150);

              if (wybor = 1) then
              begin
                   al_textout_ex(grafika.bufor,al_font,'Ilosc Graczy', 140,50, al_makecol(255,255,255), -1);

                   case ilegraczy of
                   1: al_textout_ex(grafika.bufor,al_font,' - 1', 220,50, al_makecol(255,255,255), -1);
                   2: al_textout_ex(grafika.bufor,al_font,' - 2', 220,50, al_makecol(255,255,255), -1);
                   end;
              end
              else
              begin
                  al_textout_ex(grafika.bufor,al_font,'Ilosc Graczy', 160,50, al_makecol(255,255,255), -1);

                  case ilegraczy of
                  1: al_textout_ex(grafika.bufor,al_font,' - 1', 240,50, al_makecol(255,255,255), -1);
                  2: al_textout_ex(grafika.bufor,al_font,' - 2', 240,50, al_makecol(255,255,255), -1);
                  end;
              end;
                           {
              al_textout_ex(grafika.bufor,al_font,'Poziom Trudnosci', 170,90, al_makecol(255,255,255), -1);
              case trudnosc of
              1: al_textout_ex(grafika.bufor,al_font,' - 1', 260,90, al_makecol(255,255,255), -1);
              2: al_textout_ex(grafika.bufor,al_font,' - 2', 260,90, al_makecol(255,255,255), -1);
              end;                     }

              if (wybor = 2) then
              begin
                                                       {domyslny pla}
                  al_textout_ex(grafika.bufor,al_font,'Pseudonim - '+gracz1.pseudonim[1]+gracz1.pseudonim[2]+gracz1.pseudonim[3], 140,70, al_makecol(255,255,255), -1);
              end
              else
              begin

                  al_textout_ex(grafika.bufor,al_font,'Pseudonim - '+gracz1.pseudonim[1]+gracz1.pseudonim[2]+gracz1.pseudonim[3], 160,70, al_makecol(255,255,255), -1);
              end;


              al_textout_ex(grafika.bufor,al_font,'Esc - Powrot', 50,450, al_makecol(255,255,255), -1);

              {obsluga klawy}

              if (al_key[AL_KEY_UP]) then dec(wybor);
              if (al_key[AL_KEY_DOWN]) then inc(wybor);
              if (wybor = 0) then wybor := 2;
              if (wybor = 3) then wybor := 1;

              if ( (wybor = 1) and (al_key[AL_KEY_ENTER]) ) then
              begin                            {ustaw ilu graczy}
                   if (ilegraczy = 1) then
                   begin
                       ilegraczy := 2;
                   end
                   else
                   begin
                       ilegraczy := 1;
                   end;
              end;

              if ( (wybor = 2) and (al_key[AL_KEY_ENTER]) ) then
              begin                     {ustal nowy pseudonim}
                  gracz1.pseudonim[1] := '0';
                   while gracz1.pseudonim[1] = '0' do
                   begin

                       if (al_keypressed) then
                       begin

                       if (al_key[AL_KEY_1]) then begin gracz1.pseudonim[1] := '1'; end else
                       if (al_key[AL_KEY_2]) then begin gracz1.pseudonim[1] := '2'; end else
                       if (al_key[AL_KEY_3]) then begin gracz1.pseudonim[1] := '3'; end else
                       if (al_key[AL_KEY_4]) then begin gracz1.pseudonim[1] := '4'; end else
                       if (al_key[AL_KEY_5]) then begin gracz1.pseudonim[1] := '5'; end else
                       if (al_key[AL_KEY_6]) then begin gracz1.pseudonim[1] := '6'; end else
                       if (al_key[AL_KEY_7]) then begin gracz1.pseudonim[1] := '7'; end else
                       if (al_key[AL_KEY_8]) then begin gracz1.pseudonim[1] := '8'; end else
                       if (al_key[AL_KEY_9]) then begin gracz1.pseudonim[1] := '9'; end else
                       if (al_key[AL_KEY_0]) then begin gracz1.pseudonim[1] := '0'; end else
                       if (al_key[AL_KEY_q]) then begin gracz1.pseudonim[1] := 'q'; end else
                       if (al_key[AL_KEY_w]) then begin gracz1.pseudonim[1] := 'w'; end else
                       if (al_key[AL_KEY_e]) then begin gracz1.pseudonim[1] := 'e'; end else
                       if (al_key[AL_KEY_r]) then begin gracz1.pseudonim[1] := 'r'; end else
                       if (al_key[AL_KEY_t]) then begin gracz1.pseudonim[1] := 't'; end else
                       if (al_key[AL_KEY_y]) then begin gracz1.pseudonim[1] := 'y'; end else
                       if (al_key[AL_KEY_u]) then begin gracz1.pseudonim[1] := 'u'; end else
                       if (al_key[AL_KEY_i]) then begin gracz1.pseudonim[1] := 'i'; end else
                       if (al_key[AL_KEY_o]) then begin gracz1.pseudonim[1] := 'o'; end else
                       if (al_key[AL_KEY_p]) then begin gracz1.pseudonim[1] := 'p'; end else
                       if (al_key[AL_KEY_a]) then begin gracz1.pseudonim[1] := 'a'; end else
                       if (al_key[AL_KEY_s]) then begin gracz1.pseudonim[1] := 's'; end else
                       if (al_key[AL_KEY_d]) then begin gracz1.pseudonim[1] := 'd'; end else
                       if (al_key[AL_KEY_f]) then begin gracz1.pseudonim[1] := 'f'; end else
                       if (al_key[AL_KEY_g]) then begin gracz1.pseudonim[1] := 'g'; end else
                       if (al_key[AL_KEY_h]) then begin gracz1.pseudonim[1] := 'h'; end else
                       if (al_key[AL_KEY_j]) then begin gracz1.pseudonim[1] := 'j'; end else
                       if (al_key[AL_KEY_k]) then begin gracz1.pseudonim[1] := 'k'; end else
                       if (al_key[AL_KEY_l]) then begin gracz1.pseudonim[1] := 'l'; end else
                       if (al_key[AL_KEY_z]) then begin gracz1.pseudonim[1] := 'z'; end else
                       if (al_key[AL_KEY_x]) then begin gracz1.pseudonim[1] := 'x'; end else
                       if (al_key[AL_KEY_c]) then begin gracz1.pseudonim[1] := 'c'; end else
                       if (al_key[AL_KEY_v]) then begin gracz1.pseudonim[1] := 'v'; end else
                       if (al_key[AL_KEY_b]) then begin gracz1.pseudonim[1] := 'b'; end else
                       if (al_key[AL_KEY_n]) then begin gracz1.pseudonim[1] := 'n'; end else
                       if (al_key[AL_KEY_m]) then begin gracz1.pseudonim[1] := 'm'; end else
                       begin gracz1.pseudonim[1] := '0'; end;
                       al_rest(150);

                       end;

                   end;
                   gracz1.pseudonim[2] := '0';
                    while gracz1.pseudonim[2] = '0' do
                    begin

                        if (al_keypressed) then
                        begin

                        if (al_key[AL_KEY_1]) then begin gracz1.pseudonim[2] := '1'; end else
                        if (al_key[AL_KEY_2]) then begin gracz1.pseudonim[2] := '2'; end else
                        if (al_key[AL_KEY_3]) then begin gracz1.pseudonim[2] := '3'; end else
                        if (al_key[AL_KEY_4]) then begin gracz1.pseudonim[2] := '4'; end else
                        if (al_key[AL_KEY_5]) then begin gracz1.pseudonim[2] := '5'; end else
                        if (al_key[AL_KEY_6]) then begin gracz1.pseudonim[2] := '6'; end else
                        if (al_key[AL_KEY_7]) then begin gracz1.pseudonim[2] := '7'; end else
                        if (al_key[AL_KEY_8]) then begin gracz1.pseudonim[2] := '8'; end else
                        if (al_key[AL_KEY_9]) then begin gracz1.pseudonim[2] := '9'; end else
                        if (al_key[AL_KEY_0]) then begin gracz1.pseudonim[2] := '0'; end else
                        if (al_key[AL_KEY_q]) then begin gracz1.pseudonim[2] := 'q'; end else
                        if (al_key[AL_KEY_w]) then begin gracz1.pseudonim[2] := 'w'; end else
                        if (al_key[AL_KEY_e]) then begin gracz1.pseudonim[2] := 'e'; end else
                        if (al_key[AL_KEY_r]) then begin gracz1.pseudonim[2] := 'r'; end else
                        if (al_key[AL_KEY_t]) then begin gracz1.pseudonim[2] := 't'; end else
                        if (al_key[AL_KEY_y]) then begin gracz1.pseudonim[2] := 'y'; end else
                        if (al_key[AL_KEY_u]) then begin gracz1.pseudonim[2] := 'u'; end else
                        if (al_key[AL_KEY_i]) then begin gracz1.pseudonim[2] := 'i'; end else
                        if (al_key[AL_KEY_o]) then begin gracz1.pseudonim[2] := 'o'; end else
                        if (al_key[AL_KEY_p]) then begin gracz1.pseudonim[2] := 'p'; end else
                        if (al_key[AL_KEY_a]) then begin gracz1.pseudonim[2] := 'a'; end else
                        if (al_key[AL_KEY_s]) then begin gracz1.pseudonim[2] := 's'; end else
                        if (al_key[AL_KEY_d]) then begin gracz1.pseudonim[2] := 'd'; end else
                        if (al_key[AL_KEY_f]) then begin gracz1.pseudonim[2] := 'f'; end else
                        if (al_key[AL_KEY_g]) then begin gracz1.pseudonim[2] := 'g'; end else
                        if (al_key[AL_KEY_h]) then begin gracz1.pseudonim[2] := 'h'; end else
                        if (al_key[AL_KEY_j]) then begin gracz1.pseudonim[2] := 'j'; end else
                        if (al_key[AL_KEY_k]) then begin gracz1.pseudonim[2] := 'k'; end else
                        if (al_key[AL_KEY_l]) then begin gracz1.pseudonim[2] := 'l'; end else
                        if (al_key[AL_KEY_z]) then begin gracz1.pseudonim[2] := 'z'; end else
                        if (al_key[AL_KEY_x]) then begin gracz1.pseudonim[2] := 'x'; end else
                        if (al_key[AL_KEY_c]) then begin gracz1.pseudonim[2] := 'c'; end else
                        if (al_key[AL_KEY_v]) then begin gracz1.pseudonim[2] := 'v'; end else
                        if (al_key[AL_KEY_b]) then begin gracz1.pseudonim[2] := 'b'; end else
                        if (al_key[AL_KEY_n]) then begin gracz1.pseudonim[2] := 'n'; end else
                        if (al_key[AL_KEY_m]) then begin gracz1.pseudonim[2] := 'm'; end else
                        begin gracz1.pseudonim[2] := '0'; end;
                        al_rest(150);

                        end;
                    end;
                    gracz1.pseudonim[3] := '0';
                     while gracz1.pseudonim[3] = '0' do
                     begin
                         if (al_keypressed) then
                         begin

                         if (al_key[AL_KEY_1]) then begin gracz1.pseudonim[3] := '1'; end else
                         if (al_key[AL_KEY_2]) then begin gracz1.pseudonim[3] := '2'; end else
                         if (al_key[AL_KEY_3]) then begin gracz1.pseudonim[3] := '3'; end else
                         if (al_key[AL_KEY_4]) then begin gracz1.pseudonim[3] := '4'; end else
                         if (al_key[AL_KEY_5]) then begin gracz1.pseudonim[3] := '5'; end else
                         if (al_key[AL_KEY_6]) then begin gracz1.pseudonim[3] := '6'; end else
                         if (al_key[AL_KEY_7]) then begin gracz1.pseudonim[3] := '7'; end else
                         if (al_key[AL_KEY_8]) then begin gracz1.pseudonim[3] := '8'; end else
                         if (al_key[AL_KEY_9]) then begin gracz1.pseudonim[3] := '9'; end else
                         if (al_key[AL_KEY_0]) then begin gracz1.pseudonim[3] := '0'; end else
                         if (al_key[AL_KEY_q]) then begin gracz1.pseudonim[3] := 'q'; end else
                         if (al_key[AL_KEY_w]) then begin gracz1.pseudonim[3] := 'w'; end else
                         if (al_key[AL_KEY_e]) then begin gracz1.pseudonim[3] := 'e'; end else
                         if (al_key[AL_KEY_r]) then begin gracz1.pseudonim[3] := 'r'; end else
                         if (al_key[AL_KEY_t]) then begin gracz1.pseudonim[3] := 't'; end else
                         if (al_key[AL_KEY_y]) then begin gracz1.pseudonim[3] := 'y'; end else
                         if (al_key[AL_KEY_u]) then begin gracz1.pseudonim[3] := 'u'; end else
                         if (al_key[AL_KEY_i]) then begin gracz1.pseudonim[3] := 'i'; end else
                         if (al_key[AL_KEY_o]) then begin gracz1.pseudonim[3] := 'o'; end else
                         if (al_key[AL_KEY_p]) then begin gracz1.pseudonim[3] := 'p'; end else
                         if (al_key[AL_KEY_a]) then begin gracz1.pseudonim[3] := 'a'; end else
                         if (al_key[AL_KEY_s]) then begin gracz1.pseudonim[3] := 's'; end else
                         if (al_key[AL_KEY_d]) then begin gracz1.pseudonim[3] := 'd'; end else
                         if (al_key[AL_KEY_f]) then begin gracz1.pseudonim[3] := 'f'; end else
                         if (al_key[AL_KEY_g]) then begin gracz1.pseudonim[3] := 'g'; end else
                         if (al_key[AL_KEY_h]) then begin gracz1.pseudonim[3] := 'h'; end else
                         if (al_key[AL_KEY_j]) then begin gracz1.pseudonim[3] := 'j'; end else
                         if (al_key[AL_KEY_k]) then begin gracz1.pseudonim[3] := 'k'; end else
                         if (al_key[AL_KEY_l]) then begin gracz1.pseudonim[3] := 'l'; end else
                         if (al_key[AL_KEY_z]) then begin gracz1.pseudonim[3] := 'z'; end else
                         if (al_key[AL_KEY_x]) then begin gracz1.pseudonim[3] := 'x'; end else
                         if (al_key[AL_KEY_c]) then begin gracz1.pseudonim[3] := 'c'; end else
                         if (al_key[AL_KEY_v]) then begin gracz1.pseudonim[3] := 'v'; end else
                         if (al_key[AL_KEY_b]) then begin gracz1.pseudonim[3] := 'b'; end else
                         if (al_key[AL_KEY_n]) then begin gracz1.pseudonim[3] := 'n'; end else
                         if (al_key[AL_KEY_m]) then begin gracz1.pseudonim[3] := 'm'; end else
                         begin gracz1.pseudonim[3] := '0'; end;
                         al_rest(150);

                         end;
                     end;
              end;

          al_blit( grafika.bufor, al_screen, 0, 0, 0, 0, 640, 480 );
        until al_key[AL_KEY_ESC];


     {po ustawieniu opcji, wracamy do menu}
end;

procedure PoPoziomie;             {czyli co dzieje sie po kazdym poziomie}
var iterator : integer;
begin

     iterator := 470; {czysci z pociskow}
      repeat
            pociskimalp[iterator] := 0;
            gracz1.pociski[iterator] := 0;
            gracz2.pociski[iterator] := 0;
            iterator := iterator - 10;
      until iterator = 10;
     bonus.stan := 0;

     if ( zyciebossa = 0 ) then
     begin
        endOfgame := 2;
        endOflev := 2;
     end;

     if (endOflev = 1) then endOfgame := 1;

     inc(poziom);
     {ilemalp := 10 + 2*poziom;}
     endOflev := 0;

end;

Begin
endOfgame := 0;
koniec := 0;
ilegraczy := 1;
gracz1.pseudonim := 'pla';  {zeby nie bylo!, znaczy bylo!}

  inicjalizacja;

 {ekran powitalny}
  {grafika.bufor := al_create_bitmap( 640, 480 );}
  al_clear_to_color( grafika.bufor, al_makecol( 0, 0, 0 ) );
  {grafika.tlo := al_create_bitmap( 1320, 960 ); }
  grafika.tlo := al_load_bmp('tlo.bmp',dobitmap);
  al_blit( grafika.tlo, al_screen, 0, 480, 0, 0, 640, 480 );

  al_play_sample( grafika.dzwiek_shot, 200, 127, 1000, 1=0 );
  al_rest(500);
  al_play_sample( grafika.dzwiek_yee, 200, 127, 1000, 1=0 );


  al_rest(4000);


 {rozpoczyna sie wlasciwa petla gry}

while(koniec=0) do {raczej prawdziwy!}
begin

      {muzyczka sie zaczyna}
      al_play_sample( grafika.dzwiek_music, 200, 127, 1000, 1=1 );

      al_blit( grafika.tlo, al_screen, 0, 0, 0, 0, 640, 480 );
      al_rest(3000);

      al_blit( grafika.tlo, al_screen, 640, 0, 0, 0, 640, 480 );
      al_readkey();
    while (1=1) do  {Nasze Meniu}
    begin
        case Menu of
        1:break;
        2:NajlepsiWyswietl;
        3:Opcje;
        4:begin koniec := 1; break; end;
        end;
    end;
          {zaczyna sie gra wlasciwa, podzielona na poziomy}
    while ((endOfgame = 0) and (koniec = 0)) do
    begin

          al_stop_sample( grafika.dzwiek_music );
          al_play_sample( grafika.dzwiek_music2, 200, 127, 1000, 1=1 );

          Init; {wprowadza dane do planszy, bierze je z plikow}

          while (endOflev = 0)  do
          begin


               czaszrownowazenia := 0;

               if (czaszrownowazenia < 30) then
               begin
                    GetTime(h1,m1,s1,sek100);

                    Input; {pobiera interakcje gracza}

                    Modyfication;

                    GetTime(h2,m2,s2,sek200);

                    if (sek200 > sek100) then
                    begin
                         czaszrownowazenia := (sek200-sek100) ;
                    end
                    else
                    begin
                         czaszrownowazenia := (sek100-sek200) ;
                    end;
               end;

          Drawing;
          al_rest(40-czaszrownowazenia);
          end;

          Popoziomie;
          al_stop_sample( grafika.dzwiek_music2 );
          al_rest(100);
    end;

    Result;
    Najlepsi; {te dwie sa zawsze na koncu gry}

end;

{struktura - 10 malp w pojedynczym rzedzie
 maks 3 rzedy barier, a najnizej polozony jest gracz}

{bitmapy, ktore uzywalismy i sample}
  al_destroy_bitmap(grafika.gracz);
  al_destroy_bitmap(grafika.malpa);
  al_destroy_bitmap(grafika.bariery);
  al_destroy_bitmap(grafika.bonus);
  al_destroy_bitmap(grafika.pocisk);
  al_destroy_bitmap(grafika.tlo);
  al_destroy_bitmap(grafika.bufor);
  al_destroy_sample( grafika.dzwiek_malpa_dead );
  al_destroy_sample( grafika.dzwiek_malpa_rzut );
  al_destroy_sample( grafika.dzwiek_malpa_slap );
  al_destroy_sample( grafika.dzwiek_laser1 );
  al_destroy_sample( grafika.dzwiek_laser2 );
  al_destroy_sample( grafika.dzwiek_losegame );
  al_destroy_sample( grafika.dzwiek_shot );
  al_destroy_sample( grafika.dzwiek_wingame );
  al_destroy_sample( grafika.dzwiek_yee );
  al_destroy_sample( grafika.dzwiek_torpeda );
  al_destroy_sample( grafika.dzwiek_music );
  al_destroy_sample( grafika.dzwiek_music2 );
 al_exit;

End.

