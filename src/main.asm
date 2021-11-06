!to "bas-vanity.prg", cbm

!source "macros.asm"

	+BasicUpstart65

!zone main {
	sei
	+Enable40mhz
	+MapIO
	
	; load wav file into attic memory
	; set volume and such
	; basic raster timed loop
}