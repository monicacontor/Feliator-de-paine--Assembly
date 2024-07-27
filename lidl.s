.org 1800h
AML_CONTOR:
	.db 000H
IP_PASS_UTIL:
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
IP_BUFFER_AFISARE:
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
	.db 000h	; " "
VP_PASS_STATUS:
	.DB 1
	
.org 3000h
;~Introducere~


Introducere:
	ld c,01h ;  se incarca in registre o valoare pentru ca feliatorul sa poata sa verifice daca are paine si daca poate sa inceapa felierea 
	ld d,01h ; 
	jp z, selectare_meniu

selectare_meniu:
    ld ix, selectare_meniu_afisare
	call IP_SCAN
    cp 018h ; Tasta T ne duce in meniul utilizator
    jp z, Meniu
	cp 00AH ;Tasta A ne duce in meniul administrator pentru introducere parola
	jp z, AML_ENTRY
    jr selectare_meniu
		
		
optiuni_administrator:
	ld ix , meniu_admin
	call scan 
	cp 1Fh   ; Tasta F5 activeaza optiunile de feliere
	jp z, selectare_meniu
	cp 1Eh   ;Tasta F6 dezactiveaza optiunile de feliere
	jp z,feliere_dezactivata
	jp optiuni_administrator

meniu_admin:
	.db 000h ;
	.db 0AFh ;"6"
	.db 00Fh ;"F"
	.db 000h ;
	.db 0AEh ;"5"
	.db 00Fh ;"F"
	
;~Administrator parola~

AML_ENTRY:
	ld HL, AML_CONTOR 
	ld (HL), 000H ; Init
	ld ix, AML_BUFFER_IMPLEMENTARE

AML_AFISARE_PASS:
	call AML_SCAN
	cp AML_TASTA_GO 
	jp nz, selectare_meniu
	jp IP_ENTRY

AML_BUFFER_IMPLEMENTARE:
	.db 000H ; " "
	.db	0AEH ; "S"
	.db	0AEH ; "S"
	.db	03FH ; "A"
	.db	01FH ; "P"
	.db	000H ; " "
	
	
IP_ENTRY:
	; Init variabile RAM
	ld b, 6
	ld hl, IP_PASS_UTIL
IP_LOOP:
	ld (hl), 000h
	inc hl
	djnz IP_LOOP
	ld b, 6
	ld hl, IP_BUFFER_AFISARE
IP_LOOP1:
	ld (hl), 000h
	inc hl
	djnz IP_LOOP1
	ld c, 6
	ld ix, IP_BUFFER_AFISARE
IP_AFISARE:
	call IP_SCAN
	ld hl, IP_BUFFER_AFISARE
	ld b, 0
	sbc hl, bc
	ld (hl), a
	ld hl, IP_BUFFER_AFISARE
	ld b, 0
	dec c
	add hl, bc
	ld (hl), 002h
	ld a, c
	cp 0
	jr nz, IP_AFISARE
	
IP_CALL_SCAN:
	call IP_SCAN
	cp IP_TASTA_GO
	jr nz, IP_CALL_SCAN
	jp VP_ENTRY
VP_ENTRY:
	ld hl, VP_PASS_STATUS
	ld (hl), 1
	ld c, 00H		;Reg C used as a counter.

VP_LOOP_VERIFPASS:
	ld hl, VP_PASS_STATIC
	ld b,00H
	add hl, bc
	ld a,(hl)
	
	ld hl, IP_PASS_UTIL
	ld b,00H
	add hl, bc
	ld b,(hl)
	cp b
	jp nz, VP_PASS_INCORECTA
	inc c
	ld a, 06H
	cp c
	jp nz, VP_LOOP_VERIFPASS


VP_PASS_CORECTA:
	ld hl, VP_PASS_STATUS
	ld (hl), 00H
	jp optiuni_administrator ;Parola corecta ne duce in  meniul administrator
	
VP_PASS_INCORECTA:
	ld hl, VP_PASS_STATUS
	ld ix, eroare
	call scan
	jp selectare_meniu ;Parola gresita, afiseaza mesajul "Err"
	
eroare:
	.db 000h ;
	.db 000h ;
	.db 000h ;
	.db 003h ;"r"
	.db 003H ;"r"
	.db 08Fh ;"E"

	
VP_PASS_STATIC:
	.DB 002h ;"2"
	.DB 002h ;"2"
	.DB 002h ;"2"
	.DB 002h ;"2"
	.DB 002h ;"2"
	.DB 002h ;"2"

;~Meniu input~

utilizator_actfel:
	ld d,01h 				; feliere activata
	jp z, optiuni_feliere

Meniu:
	ld e,c
	cp 18h 						;tasta T ne duce la confirmare feliere
	jp z, confirmare_feliere
	cp 0Ah						;tasta A ne duce in meniul administrator
	jp z, optiuni_feliere
	jp Meniu
	
selectare_meniu_afisare:
	.db 000h ;
	.db 000h ; 
	.db 000h ;
	.db 085H ;"l"
	.db 08Fh ;"e"
	.db 0AEh ;"S"
	
	
confirmare_feliere:
	ld ix, confirmare_afisfel 
	call scan
	cp 0Fh
	jp z, utilizator_actfel		; confirmare feliere prin apasarea tastei  F
	

confirmare_afisfel:
	.db 00Fh ;"F"
	.db 000h ;
	.db 000h ;
	.db 085H ;"L"
	.db 08Fh ;"E"
	.db 00Fh ;"F"
	
	
optiuni_feliere:
		ld ix, afisare_optiuni
		call scan
		cp 001h				
		jp z, Feliere10  ; 3 optiuni feliere: tasta 1,2,3
		cp 002h
		jp z, Feliere12
		cp 003h
		jp z, Feliere14
afisare_optiuni:
	.db 026H ;"4"
    .db 005H ;"1"
	.db 09BH ;"2"
    .db 005H ;"1"
	.db 0BDH ;"0"
	.db 005H ;"1"		

SOUND:
	call TONE
	jp optiuni_feliere
	
		
Feliere10:
		ld c, 010h
		call TONE
		ld ix,optiune10
		call scan
		jp Feliere10
optiune10:
    .db 000H
    .db 000H
    .db 0BDH ;"0"
    .db 005H ;"1"
    .db 000H
    .db 000H

Feliere12:
		ld c, 010h
		call TONE
		ld ix,optiune12
		call scan 
		jp Feliere12
optiune12:
    .db 000H
    .db 000H
    .db 09BH ;"2"
    .db 005H ;"1"
    .db 000H
    .db 000H

Feliere14:
		ld c, 010h
		call TONE
		ld ix, optiune14
		call scan 
		jp Feliere14
optiune14:
    .db 000H
    .db 000H
    .db 026H ;"4"
    .db 005H ;"1"
    .db 000H
    .db 000H

	
feliere_dezactivata:
	ld ix, afisare_feliere_dezactivata
	call scan
	ld c,02h
	jp selectare_meniu
	
	
afisare_feliere_dezactivata:
	.db 000h ;
	.db 000h ;
	.db 000h ;
	.db 000h ;
	.db 000h ;
	.db 002h ;"-"
	
	

	
AML_SCAN   .equ 05FEH ; define
AML_TASTA_GO	.equ 012H
IP_SCAN   .equ 05FEH
IP_TASTA_GO	.equ 012H
TONE 	.equ 05E4H
scan	.equ 05FEH



.end
    rst 38h
