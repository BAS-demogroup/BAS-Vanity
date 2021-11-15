!to "bas-vanity.prg", cbm

!source "globals.asm"
!source "macros.asm"

	+BasicUpstart65

!zone main {
	sei
	+Enable40mhz
	+MapIO
	
	; remap all interrupts (Is this necessary if I never cli?)
	lda #<empty_irq
	sta $0314
	sta $0316
	sta $0318
	sta $fffa
	sta $fffc
	sta $fffe
	lda #>empty_irq
	sta $0315
	sta $0316
	sta $0319
	sta $fffb
	sta $fffd
	sta $ffff
	
	; remap color ram
	; disable ram write protection in pages 2 + 3
	+DisableRamProtection
	
	; load pcm file
	ldx #$0f
	lda #$a0
-	sta fastload_filename, x
	dex
	bpl -
	
	ldx #$ff
-	inx
	cpx #$10
	beq +
	lda audio, x
	beq +
	sta fastload_filename, x
	bne -
	
+	inx
	stx fastload_filename_len
	
	lda #$00
	sta fastload_address + 0
	sta fastload_address + 1
	sta fastload_address + 3
	lda #$02
	sta fastload_address + 2
	
-	jsr fastload_irq
	lda fastload_request
	bne -
	
debug_here:
	lda #$01
	sta fastload_request
	
-	jsr fastload_irq
	lda fastload_request
	bmi +
	bne -
	beq ++
	
+
	lda #$02
	sta $d020
	sta $d021
	brk

++
	lda #$01
	sta $d020
	sta $d021
	
	; https://discord.com/channels/719326990221574164/782757495180361778/906427547347202108
	; set volume and panning
	
	; play sample
	lda #$00
	sta ch_0_cur_addr
	sta ch_0_cur_addr + 1
	lda #$02
	sta ch_0_cur_addr + 2
	
	lda #$ff
	sta ch_0_t_addr
	sta ch_0_t_addr + 1
	
	; @gardners:
	; so 44K1 = ( 44100 x 2^24 ) / ( 40.5 x 10^6 )
	; = 18269
	; = $00475D, assuming I got it right.
	lda #<$23ae				; 22050
	sta ch_0_freq
	lda #>$23ae
	sta ch_0_freq + 1
	lda #$00
	sta ch_0_freq + 2
	
	lda #$ff
	sta ch_0_volume
	
	lda #%10000010
	sta ch_0_control
	
	; basic raster timed loop
	
.rasterloop:
-	lda #$80
	cmp $d012
	bne -
	
	; Theoretically, do stuff here
	
	jmp .rasterloop
}

; I think this may need to do more than JUST rti.
empty_irq:
	rti

!src "fastload.asm"

audio:
!pet "audio.raw"
!byte $00

!set audio_len = * - audio
