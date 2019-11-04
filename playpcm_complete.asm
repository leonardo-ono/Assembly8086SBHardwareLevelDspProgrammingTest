; Sound Blaster
; Hardware level DSP programming
; Play a PCM sound using 'Direct Mode'
; Written by Leonardo Ono (ono.leo@gmail.com)
;
; Target OS: DOS
;
; use: nasm playpc~1.asm -o playpc~1.obj -f obj
;      tlink playpc~1.obj, playpc~1.exe
;
; 11/03/2019 - fixed to work in both DOSBox and real
;              machine with real SB16 sound card.
;
; References:
; SB16 card jumpers - https://stason.org/TULARC/pc/sound-cards-multimedia/CREATIVE-LABS-INC-Sound-card-SOUNDBLASTER-16-VALUE-6.html
; http://archive.gamedev.net/archive/reference/articles/article443.html see "02x0Ch     DSP - Write Data or Command"

	bits 16

segment code

	..start: ; entry point

			; setup stack
			mov ax, stack
			mov ss, ax
			mov sp, stack_top
			
			; setup data segments
			mov ax, data
			mov ds, ax
			mov ax, sound_seg
			mov es, ax
	
			call far start_fast_clock
	
			call far sb_reset
			cmp ax, 1
			jz sb_reset_ok
	
	sb_reset_error:
			mov ah, 9h
			mov dx, msg_sb_reset_error
			int 21h
			jmp exit_process
	
	sb_reset_ok:
			mov ah, 9h
			mov dx, msg_sb_reset_ok
			int 21h
	
	sb_turn_on_speaker:
			mov bl, 0d1h
			call far sb_write_dsp

			mov dword [last_time], 0
		
	start_playing:
			mov ah, 9h
			mov dx, msg_start_playing
			int 21h
		
		.next_sample:
			mov bl, 10h
			call far sb_write_dsp
	
		.wait:
			call far get_current_time
			cmp eax, [last_time]
			jbe .wait
			mov [last_time], eax

			mov bx, [es:voc_index]
			mov bl, [es:voc + bx] ;  [sound]
			call far sb_write_dsp

			mov ah, 1
			int 16h
			jnz stop_playing
		
			;inc byte [sound]
			inc word [es:voc_index]
			cmp word [es:voc_index], 51529
			jb .next_sample;
		
			; restart voc_index
			mov word [es:voc_index], 0
		
			jmp .next_sample

	stop_playing:
	
		.clear_keyboard_buffer:
			mov ah, 0
			int 16h
			
		.print_msg_top_playing:	
			mov ah, 9h
			mov dx, msg_stop_playing
			int 21h
		
	sb_turn_off_speaker:
			mov bl, 0d3h
			call far sb_write_dsp
	
	exit_process:
			; return to DOS
			mov ah, 4ch
			int 21h
		
			
segment sb

	sb_reset:
			mov dx, 226h
			mov al, 1
			out dx, al
			
			mov cx, 50
		.wait_a_little:
			nop
			loop .wait_a_little
	
			mov dx, 226h
			mov al, 0
			out dx, al
		
			mov cx, 0
		.check_read_data_available:
			mov dx, 22eh
			in al, dx
			or al, al
			jns .next_try
			
		.read_data:
			mov dx, 22ah
			in al, dx
			cmp al, 0aah
			jnz .error
		.ok:
			mov ax,1
			jmp .end
		.next_try:
			loop .check_read_data_available
		.error:
			mov ax, 0
		.end:	
			retf

	; bl = send byte data
	sb_write_dsp:
			mov dx, 22ch
		.busy:
			in al, dx
			test al, 10000000b
			jnz .busy
			mov al, bl
			out dx, al
			retf
		
segment timer
   ; count = 1193180 / sampling_rate
	; sampling_rate = 4000 cycles per second
	; count = 1193180 / 4000 = 298 (in decimal) = 12a (in hex) 
	start_fast_clock:
			cli
			mov al, 36h
			out 43h, al
			mov al, 2ah ; low 2ah
			out 40h, al
			mov al, 1h ; high 01h
			out 40h, al
			sti
			retf

	; eax = get current time
	get_current_time:
			push es
			mov ax, 0
			mov es, ax
			mov eax, [es:46ch]
			pop es
			retf
			
segment data
	msg_sb_reset_ok db "sb reset success.", 13, 10, "$"
	msg_sb_reset_error db "error reset sb !", 13, 10, "$"
	msg_start_playing db "start playing PCM 4k 8bits mono ...", 13, 10, "$"
	msg_stop_playing db "stop playing ...", 13, 10, "$"
	sound db 0

segment sound_seg
	last_time dd 0
	voc_index dw 0
	voc:
			incbin "kingsv.wav" ; 51529 bytes (file size)
	
segment stack stack
			resb 1024
	stack_top:

