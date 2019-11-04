; Play PCM sound through Sound Blaster using Direct Mode
; Written by Leonardo Ono (ono.leo@gmail.com)
;
; This is a fixed version of the original code (playpcm.asm)
; of https://youtu.be/cQwG7DiqK80 video
;
; 11/03/2019 the original code works fine in DOSBox, however i 
;            finally could buy a real Sound Blaster 16 
;            and this code didn't work in this real
;            sound card. So this is the fixed version 
;            that now works in both DOSBox and real
;            machine :)

; Note: although this code apparently works this way, it's always a 
;       good idea at the beginning to reset the SB and
;       turn on the speakers.
;
; References:
; SB16 card jumpers - https://stason.org/TULARC/pc/sound-cards-multimedia/CREATIVE-LABS-INC-Sound-card-SOUNDBLASTER-16-VALUE-6.html
; http://archive.gamedev.net/archive/reference/articles/article443.html see "02x0Ch     DSP - Write Data or Command"

	bits 16
	org 100h

section .text

	start:

			; print 'A' in the screen
			mov ah, 0eh
			mov al, 'A'
			int 10h

		.loop:

			; send DSP Command 10h
			mov bl, 10h
			call sb_write_dsp

			; send byte audio sample
			mov si, [sound_index]
			mov bl, [sound_data + si]
			call sb_write_dsp	

			mov cx, 10000 ; <-- change this value according to the speed of your computer
		.delay:
			nop
			loop .delay

			inc word [sound_index]
			cmp word [sound_index], 51529
			jb .loop

			; return to DOS
			mov ah, 4ch
			int 21h
	
	sb_write_dsp:
			mov dx, 22ch
		.busy:
			in al, dx
			test al, 10000000b
			jnz .busy
			mov al, bl
			out dx, al
			ret

section .data

	sound_index dw 0

	sound_data:
			incbin "kingsv.wav" ; 51.529 bytes






