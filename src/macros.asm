!macro BasicUpstart65 {
	* = $2001
	
	!byte $16,$20			;End of command marker (first byte after the 00 terminator)
	!byte $0a,$00			;10
	!byte $fe,$02,$30,$3a	;BANK 0:
	!byte $9e				;SYS
	!text "$202C"
	!byte $3a, $8f			;:REM
	!fill 21, $14
	!text "BAS", $00
	!byte $00,$00			;End of basic terminators
.start:
}

!macro MapIO {
	lda #0
	tax
	tay
	taz
	map
	eom

	lda #$37
	sta $00
	lda #$35
	sta $01
}

!macro Enable40mhz {
	lda #65
	sta $00
}

!macro RunDMAJob .JobPointer {
	lda #(.JobPointer >> 16)
	sta $D702
	sta $D704
	lda #>.JobPointer
	sta $D701
	lda #<.JobPointer
	sta $D705
}

!macro DMAFillJob .SourceByte, .Destination, .Length, .Chain {
	!byte $00
	!if (.Chain) {
		!byte $07
	} else {
		!byte $03
	}
	
	!word .Length
	!word .SourceByte
	!byte $00
	!word .Destination & $FFFF
	!byte ((.Destination >> 16) & $0F)
	
	!if (.Chain) {
		!word $0000
	}
}

!macro DMACopyJob .Source, .Destination, .Length, .Chain, .Backwards {
	!byte $00 //No more options
	!if(.Chain) {
		!byte $04 //Copy and chain
	} else {
		!byte $00 //Copy and last request
	}	
	
	!set .backByte = 0
	!if(.Backwards) {
		!set .backByte = $40
		!set .Source = .Source + .Length - 1
		!set .Destination = .Destination + .Length - 1
	}
	!word .Length //Size of Copy

	!word .Source & $ffff
	!byte (.Source >> 16) + .backByte

	!word .Destination & $ffff
	!byte ((.Destination >> 16) & $0f)  + .backByte
	!if(.Chain) {
		!word $0000
	}
}
