!to "bas-vanity.prg", cbm

!source "globals.asm"
!source "macros.asm"

	+BasicUpstart65

!zone main {
	sei
	+Enable40mhz
	+MapIO
	
	; initial test will just have a short sample that it can play once, before 
	; getting into memory management.
	lda #<samplestart
	sta ch_0_cur_addr
	lda #>samplestart
	sta ch_0_cur_addr + 1
	lda #00
	sta ch_0_cur_addr + 2
	
	lda #<sampleend
	sta ch_0_t_addr
	lda #>sampleend
	sta ch_0_t_addr + 1
	
	; @gardners:
	; so 44K1 = 44100 x 2^24 / 40.5 x 10^6
	; = 18269
	; = $00475D, assuming I got it right.
	lda #<$475d
	sta ch_0_freq
	lda #>$475d
	sta ch_0_freq + 1
	lda #$00
	sta ch_0_freq + 2
	
	lda #$ff
	sta ch_0_volume
	
	lda #%10100011
	sta ch_0_control
	
	; load wav file into attic memory
	; https://discord.com/channels/719326990221574164/782757495180361778/906427547347202108
	; set volume and such
	
	; play sample
	
	; basic raster timed loop
	
.rasterloop:
-	lda #$80
	cmp $d012
	bne -
	
	; Theoretically, do stuff here
	
	jmp .rasterloop
}

samplestart:
!bin "../test1.raw"
sampleend:
!set samplelength = sampleend - samplestart
