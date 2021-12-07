!to "bas-vanity.prg", cbm

!source "globals.asm"
!source "macros.asm"

* = $2001

!zone basic_load {
	; Cannot use the standard basic upstart macro because must do a bload
	; in order to retain xemu compatibility.
	!byte $0C,$20,$0A,$00,$97,$20,$30,$2C,$36,$35,$00,$2D,$20,$14,$00,$FE
	!byte $11,$20,$22,$41,$55,$44,$49,$4F,$31,$2E,$52,$41,$57,$22,$2C,$50
	!byte $31,$33,$34,$32,$31,$37,$37,$32,$38,$2C,$52,$00,$4E,$20,$1E,$00
	!byte $FE,$11,$20,$22,$41,$55,$44,$49,$4F,$32,$2E,$52,$41,$57,$22,$2C
	!byte $50,$31,$33,$34,$32,$38,$33,$32,$36,$34,$2C,$52,$00,$6F,$20,$28
	!byte $00,$FE,$11,$20,$22,$41,$55,$44,$49,$4F,$33,$2E,$52,$41,$57,$22
	!byte $2C,$50,$31,$33,$34,$33,$34,$38,$38,$30,$30,$2C,$52,$00,$92,$20
	!byte $32,$00,$FE,$11,$20,$22,$54,$49,$4C,$45,$4D,$41,$50,$2E,$43,$48
	!byte $52,$53,$22,$2C,$50,$31,$33,$34,$34,$31,$34,$33,$33,$36,$2C,$52
	!byte $00,$B5,$20,$3C,$00,$FE,$11,$20,$22,$54,$49,$4C,$45,$4D,$41,$50
	!byte $2E,$43,$4C,$55,$54,$22,$2C,$50,$31,$33,$34,$34,$37,$39,$38,$37
	!byte $32,$2C,$52,$00,$BE,$20,$46,$00,$FE,$02,$20,$30,$00,$C9,$20,$50
	!byte $00,$9E,$20,$38,$33,$39,$35,$00,$00,$00
}

!zone main {
main:
	sei
	+Enable40mhz
	+MapIO
	+ToggleNTSC $0
	+SetAdvancedGraphicsModes $0, $0, $0, $0, $0, $1, $1, $1
	+Set40ColumnMode
	
	; remap all interrupts (Is this necessary if I never cli?  Like, for the 
	; nmi maybe?)
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
	
	; disable ram write protection in pages 2 + 3
	+DisableRamProtection
	
	; load charset
	+RunDMAJob load_charset
	+SetCharacterGeneratorData $50000
	
	; load palette
	+RunDMAJob load_palette
	;+SetColorRAM $4000
	
	+SetScreenMemory $8000
	
	; load pcm file
	+RunDMAJob load_audio_1
	+RunDMAJob load_audio_2
	+RunDMAJob load_audio_3	

	lda #$01
	sta $d020
	sta $d021
	
	lda #$00
	sta ch_0_cur_addr
	sta ch_0_cur_addr + 1
	sta ch_2_cur_addr
	sta ch_2_cur_addr + 1
	
	sta ch_0_t_addr
	sta ch_0_t_addr + 1
	sta ch_2_t_addr
	sta ch_2_t_addr + 1
	
	; @gardners:
	; so 44K1 = ( 44100 x 2^24 ) / ( 40.5 x 10^6 )
	; = 18269
	; = $00475D, assuming I got it right.
	sta ch_0_freq + 2
	sta ch_2_freq + 2

	lda #<$23ae				; 22050
	sta ch_0_freq
	sta ch_2_freq
	lda #>$23ae
	sta ch_0_freq + 1
	sta ch_2_freq + 1
	
	lda #$ff
	sta ch_0_volume
	sta ch_2_volume
	
	jmp audio_next
	
	; basic raster timed loop
	
.rasterloop:
-	lda ch_0_control
	and #%00001000
	bne audio_next
	
	lda #$80
	cmp $d012
	bne -
	
	; Theoretically, do stuff here
	
	jmp .rasterloop
	
audio_next:
	inc audio_block
	
	lda audio_block
	cmp #$05
	bpl +
	
	sta ch_0_cur_addr + 2
	sta ch_2_cur_addr + 2
	
	lda #%10100010
	sta ch_0_control
	sta ch_2_control
	
+	jmp .rasterloop
}

; I think this may need to do more than JUST rti.
empty_irq:
	rti

load_audio_1:
	+DMAAtticCopyJob $8000000, $20000, $0000, $0, $0
load_audio_2:
	+DMAAtticCopyJob $8010000, $30000, $0000, $0, $0
load_audio_3:
	+DMAAtticCopyJob $8020000, $40000, $0000, $0, $0
load_charset:
	+DMAAtticCopyJob $8030000, $50000, $EF00, $0, $0
load_palette:
	+DMAAtticCopyJob $8040000, $0D100, $0300, $0, $0

audio_block:
	!byte $01
