; Play PCM sound through Sound Blaster using Direct Mode
; Written by Leonardo Ono (ono.leo@gmail.com)
;
; This is the original code of https://youtu.be/cQwG7DiqK80 video
;
; 11/03/2019 this code works fine in DOSBox, however i 
;            finally could buy a real Sound Blaster 16 
;            and this code didn't work in this real
;            sound card. I'll leave this code unchanged 
;            and i added a fixed version as playpcm2.asm
;            that now works in both DOSBox and real
;            machine :) 
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
			mov dx, 22ch
			mov al, 10h
			out dx, al

			; send byte audio sample
			mov si, [sound_index]
			mov al, [sound_data + si]
			out dx, al

			mov cx, 10000
		.delay:
			nop
			loop .delay

			inc word [sound_index]
			cmp word [sound_index], 51529
			jb .loop

			; return to DOS
			mov ah, 4ch
			int 21h

section .data

	sound_index dw 0

	sound_data:
			incbin "kingsv.wav" ; 51.529 bytes






