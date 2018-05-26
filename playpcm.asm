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






