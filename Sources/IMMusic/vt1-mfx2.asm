
	device zxspectrum128
	org $c000


;vortex tracker ii v1.0 pt3 player for zx spectrum
;(c)2004,2007 s.v.bulba <vorobey@mail.khstu.ru>
;http://bulba.untergrund.net (http://bulba.at.kz)

;mfx edition by intense
;warning: uses shadow registers hl',de',bc' for stack output!
;uncomment the 'ld hl,0x2758' line if used alongside basic

;release number
release equ "7"

;features
;--------
;-can be compiled at any address (i.e. no need rounding org
; address).
;-variables (vars) can be located at any address (not only after
;code block).
;-init subroutine detects module version and rightly generates
; both note and volume tables outside of code block (in vars).
;-two portamento (spc. command 3xxx) algorithms (depending of
; module version).
;-new 1.xx and 2.xx special command behaviour (only for pt v3.7
; and higher).
;-any tempo value are accepted (including tempo=1 and tempo=2).
;-fully compatible with ay_emul pt3 player codes.
;-see also notes at the end of this source code.

;limitations
;-----------
;-can run in ram only (self-modified code is used).

;warning!!! play subroutine can crash if no module are loaded
;into ram or init subroutine was not called before.

;call mute or init one more time to mute sound after stopping
;playing
start:

;test codes (commented)
	call musicplay
	ei
_lp	halt
	call musicplay+5
	xor a
	in a,(0xfe)
	cpl
	and 15
	jr z,_lp
	jr musicplay+8
	ret 
tona	equ 0
tonb	equ 2
tonc	equ 4
noise	equ 6
mixer	equ 7
ampla	equ 8
amplb	equ 9
amplc	equ 10
env	equ 11
envtp	equ 13

;entry and other points
;start initialization
;start+3 initialization with module address in hl
;start+5 play one quark
;start+8 mute
;start+10 setup and status flags
;start+11 pointer to current position value in pt3 module;
;after init (start+11) points to postion0-1 (optimization)



musicplay
	ld hl,mdladdr
	jr init
	jp play
	jr mute
setup	db 0 ;set bit0 to 1, if you want to play without looping
	     ;bit7 is set each time, when loop point is passed
	     ;(hikaru) set bit 1 before calling start+5 to push the ay register data
	     ;         for the current frame into the stack.
	     ;         note that bit 1 resets automatically at exit
crpsptr	dw 0

;identifier
	db "=vtii pt3 player r.",release,"="

checklp	ld hl,setup
	set 7,(hl)
	bit 0,(hl)
	ret z
	pop hl
	ld hl,delycnt
	inc (hl)
	ld hl,chana+chp_ntskcn
	inc (hl)
mute	xor a
	ld h,a
	ld l,a
	ld (ayregs+ampla),a
	ld (ayregs+amplb),hl
	jp rout_a0

init
;hl - addressofmodule

	ld (modaddr),hl
	ld (mdaddr2),hl
	push hl
	ld de,100
	add hl,de
	ld a,(hl)
	ld (delay),a
	push hl
	pop ix
	add hl,de
	ld (crpsptr),hl
	ld e,(ix+102-100)
	add hl,de
	inc hl
	ld (lposptr),hl
	pop de
	ld l,(ix+103-100)
	ld h,(ix+104-100)
	add hl,de
	ld (patsptr),hl
	ld hl,169
	add hl,de
	ld (ornptrs),hl
	ld hl,105
	add hl,de
	ld (samptrs),hl
	ld hl,setup
	res 7,(hl)

;note table data depacker
	ld de,t_pack
	ld bc,t1_+(2*49)-1
tp_0	ld a,(de)
	inc de
	cp 15*2
	jr nc,tp_1
	ld h,a
	ld a,(de)
	ld l,a
	inc de
	jr tp_2
tp_1	push de
	ld d,0
	ld e,a
	add hl,de
	add hl,de
	pop de
tp_2	ld a,h
	ld (bc),a
	dec bc
	ld a,l
	ld (bc),a
	dec bc
	sub 0xf0 ;#f8*2
	jr nz,tp_0

	ld hl,vars
	ld (hl),a
	ld de,vars+1
	ld bc,var0end-vars-1
	ldir
	inc a
	ld (delycnt),a
	ld hl,0xf001 ;h - chp_volume, l - chp_ntskcn
	ld (chana+chp_ntskcn),hl
	ld (chanb+chp_ntskcn),hl
	ld (chanc+chp_ntskcn),hl

	ld hl,emptysamorn
	ld (adinpta),hl ;ptr to zero
	ld (chana+chp_ornptr),hl ;ornament 0 is "0,1,0"
	ld (chanb+chp_ornptr),hl ;in all versions from
	ld (chanc+chp_ornptr),hl ;3.xx to 3.6x and vtii

	ld (chana+chp_samptr),hl ;s1 there is no default
	ld (chanb+chp_samptr),hl ;s2 sample in pt3, so, you
	ld (chanc+chp_samptr),hl ;s3 can comment s1,2,3; see
				    ;also emptysamorn comment

	ld a,(ix+13-100) ;extract version number
	sub 0x30
	jr c,l20
	cp 10
	jr c,l21
l20	ld a,6
l21	ld (version),a
	push af
	cp 4
	ld a,(ix+99-100) ;tone table number
	rla
	and 7

;notetablecreator (c) ivan roshin
;a - notetablenumber*2+versionfornotetable
;(xx1b - 3.xx..3.4r, xx0b - 3.4x..3.6x..vtii1.0)

	ld hl,nt_data
	push de
	ld d,b
	add a,a
	ld e,a
	add hl,de
	ld e,(hl)
	inc hl
	srl e
	sbc a,a
	and 0xa7 ;#00 (nop) or #a7 (and a)
	ld (l3),a
	ex de,hl
	pop bc ;bc=t1_
	add hl,bc

	ld a,(de)
	add a,t_ & 0x00ff
	ld c,a
	adc a,t_/256
	sub c
	ld b,a
	push bc
	ld de,nt_
	push de

	ld b,12
l1	push bc
	ld c,(hl)
	inc hl
	push hl
	ld b,(hl)

	push de
	ex de,hl
	ld de,23
	ld ixh,8

l2	srl b
	rr c
l3	db 0x19	;and a or nop
	ld a,c
	adc a,d	;=adc 0
	ld (hl),a
	inc hl
	ld a,b
	adc a,d
	ld (hl),a
	add hl,de
	dec ixh
	jr nz,l2

	pop de
	inc de
	inc de
	pop hl
	inc hl
	pop bc
	djnz l1

	pop hl
	pop de

	ld a,e
	cp tcold_1 & 0x00ff
	jr nz,corr_1
	ld a,0xfd
	ld (nt_+0x2e),a

corr_1	ld a,(de)
	and a
	jr z,tc_exit
	rra
	push af
	add a,a
	ld c,a
	add hl,bc
	pop af
	jr nc,corr_2
	dec (hl)
	dec (hl)
corr_2	inc (hl)
	and a
	sbc hl,bc
	inc de
	jr corr_1

tc_exit

	pop af

;voltablecreator (c) ivan roshin
;a - versionforvolumetable (0..4 - 3.xx..3.4x;
			   ;5.. - 3.5x..3.6x..vtii1.0)

	cp 5
	ld hl,0x11
	ld d,h
	ld e,h
	ld a,0x17
	jr nc,m1
	dec l
	ld e,l
	xor a
m1      ld (m2),a

	ld ix,vt_+16
	ld c,0x10

initv2  push hl

	add hl,de
	ex de,hl
	sbc hl,hl

initv1  ld a,l
m2      db 0x7d
	ld a,h
	adc a,0
	ld (ix),a
	inc ix
	add hl,de
	inc c
	ld a,c
	and 15
	jr nz,initv1

	pop hl
	ld a,e
	cp 0x77
	jr nz,m3
	inc e
m3      ld a,c
	and a
	jr nz,initv2

	jp rout_a0

;pattern decoder
pd_orsm	ld (ix-12+chp_env_en),0
	call setorn
	ld a,(bc)
	inc bc
	rrca

pd_sam	add a,a
pd_sam_	ld e,a
	ld d,0
samptrs equ $+1
	ld hl,0x2121
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
modaddr equ $+1
	ld hl,0x2121
	add hl,de
	ld (ix-12+chp_samptr),l
	ld (ix-12+chp_samptr+1),h
	jr pd_loop

pd_vol	rlca
	rlca
	rlca
	rlca
	ld (ix-12+chp_volume),a
	jr pd_lp2

pd_eoff	ld (ix-12+chp_env_en),a
	ld (ix-12+chp_psinor),a
	jr pd_lp2

pd_sore	dec a
	jr nz,pd_env
	ld a,(bc)
	inc bc
	ld (ix-12+chp_nntskp),a
	jr pd_lp2

pd_env	call setenv
	jr pd_lp2

pd_orn	call setorn
	jr pd_loop

pd_esam	ld (ix-12+chp_env_en),a
	ld (ix-12+chp_psinor),a
	call nz,setenv
	ld a,(bc)
	inc bc
	jr pd_sam_

ptdecod ld a,(ix-12+chp_note)
	ld (prnote+1),a
	ld l,(ix-12+chp_crtnsl)
	ld h,(ix-12+chp_crtnsl+1)
	ld (prslide+1),hl

pd_loop	ld de,0x2010
pd_lp2	ld a,(bc)
	inc bc
	add a,e
	jr c,pd_orsm
	add a,d
	jr z,pd_fin
	jr c,pd_sam
	add a,e
	jr z,pd_rel
	jr c,pd_vol
	add a,e
	jr z,pd_eoff
	jr c,pd_sore
	add a,96
	jr c,pd_note
	add a,e
	jr c,pd_orn
	add a,d
	jr c,pd_nois
	add a,e
	jr c,pd_esam
	add a,a
	ld e,a
	ld hl,spccoms-0x20e0 ;+#ff20-#2000
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	push de
	jr pd_loop

pd_nois	ld (ns_base),a
	jr pd_lp2

pd_rel	res 0,(ix-12+chp_flags)
	jr pd_res

pd_note	ld (ix-12+chp_note),a
	set 0,(ix-12+chp_flags)
	xor a

pd_res	ld (pdsp_+1),sp
	ld sp,ix
	ld h,a
	ld l,a
	push hl
	push hl
	push hl
	push hl
	push hl
	push hl
pdsp_	ld sp,0x3131

pd_fin	ld a,(ix-12+chp_nntskp)
	ld (ix-12+chp_ntskcn),a
	ret

c_portm res 2,(ix-12+chp_flags)
	ld a,(bc)
	inc bc
;skip precalculated tone delta (because
;cannot be right after pt3 compilation)
	inc bc
	inc bc
	ld (ix-12+chp_tnsldl),a
	ld (ix-12+chp_tslcnt),a
	ld de,nt_
	ld a,(ix-12+chp_note)
	ld (ix-12+chp_sltont),a
	add a,a
	ld l,a
	ld h,0
	add hl,de
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	push hl
prnote	ld a,0x3e
	ld (ix-12+chp_note),a
	add a,a
	ld l,a
	ld h,0
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	pop hl
	sbc hl,de
	ld (ix-12+chp_tndelt),l
	ld (ix-12+chp_tndelt+1),h
	ld e,(ix-12+chp_crtnsl)
	ld d,(ix-12+chp_crtnsl+1)
version equ $+1
	ld a,0x3e
	cp 6
	jr c,oldprtm ;old 3xxx for pt v3.5-
prslide	ld de,0x1111
	ld (ix-12+chp_crtnsl),e
	ld (ix-12+chp_crtnsl+1),d
oldprtm	ld a,(bc) ;signed tone step
	inc bc
	ex af,af'
	ld a,(bc)
	inc bc
	and a
	jr z,nosig
	ex de,hl
nosig	sbc hl,de
	jp p,set_stp
	cpl
	ex af,af'
	neg
	ex af,af'
set_stp	ld (ix-12+chp_tslstp+1),a
	ex af,af'
	ld (ix-12+chp_tslstp),a
	ld (ix-12+chp_conoff),0
	ret

c_gliss	set 2,(ix-12+chp_flags)
	ld a,(bc)
	inc bc
	ld (ix-12+chp_tnsldl),a
	and a
	jr nz,gl36
	ld a,(version) ;alco pt3.7+
	cp 7
	sbc a,a
	inc a
gl36	ld (ix-12+chp_tslcnt),a
	ld a,(bc)
	inc bc
	ex af,af'
	ld a,(bc)
	inc bc
	jr set_stp

c_smpos	ld a,(bc)
	inc bc
	ld (ix-12+chp_psinsm),a
	ret

c_orpos	ld a,(bc)
	inc bc
	ld (ix-12+chp_psinor),a
	ret

c_vibrt	ld a,(bc)
	inc bc
	ld (ix-12+chp_onoffd),a
	ld (ix-12+chp_conoff),a
	ld a,(bc)
	inc bc
	ld (ix-12+chp_offond),a
	xor a
	ld (ix-12+chp_tslcnt),a
	ld (ix-12+chp_crtnsl),a
	ld (ix-12+chp_crtnsl+1),a
	ret

c_engls	ld a,(bc)
	inc bc
	ld (env_del),a
	ld (curedel),a
	ld a,(bc)
	inc bc
	ld l,a
	ld a,(bc)
	inc bc
	ld h,a
	ld (esldadd),hl
	ret

c_delay	ld a,(bc)
	inc bc
	ld (delay),a
	ret

setenv	ld (ix-12+chp_env_en),e
	ld (ayregs+envtp),a
	ld a,(bc)
	inc bc
	ld h,a
	ld a,(bc)
	inc bc
	ld l,a
	ld (envbase),hl
	xor a
	ld (ix-12+chp_psinor),a
	ld (curedel),a
	ld h,a
	ld l,a
	ld (curesld),hl
c_nop	ret

setorn	add a,a
	ld e,a
	ld d,0
	ld (ix-12+chp_psinor),d
ornptrs	equ $+1
	ld hl,0x2121
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
mdaddr2	equ $+1
	ld hl,0x2121
	add hl,de
	ld (ix-12+chp_ornptr),l
	ld (ix-12+chp_ornptr+1),h
	ret

;all 16 addresses to protect from broken pt3 modules
spccoms dw c_nop
	dw c_gliss
	dw c_portm
	dw c_smpos
	dw c_orpos
	dw c_vibrt
	dw c_nop
	dw c_nop
	dw c_engls
	dw c_delay
	dw c_nop
	dw c_nop
	dw c_nop
	dw c_nop
	dw c_nop
	dw c_nop

chregs	xor a
	ld (ampl),a
	bit 0,(ix+chp_flags)
	push hl
	jp z,ch_exit
	ld (csp_+1),sp
	ld l,(ix+chp_ornptr)
	ld h,(ix+chp_ornptr+1)
	ld sp,hl
	pop de
	ld h,a
	ld a,(ix+chp_psinor)
	ld l,a
	add hl,sp
	inc a
	cp d
	jr c,ch_orps
	ld a,e
ch_orps	ld (ix+chp_psinor),a
	ld a,(ix+chp_note)
	add a,(hl)
	jp p,ch_ntp
	xor a
ch_ntp	cp 96
	jr c,ch_nok
	ld a,95
ch_nok	add a,a
	ex af,af'
	ld l,(ix+chp_samptr)
	ld h,(ix+chp_samptr+1)
	ld sp,hl
	pop de
	ld h,0
	ld a,(ix+chp_psinsm)
	ld b,a
	add a,a
	add a,a
	ld l,a
	add hl,sp
	ld sp,hl
	ld a,b
	inc a
	cp d
	jr c,ch_smps
	ld a,e
ch_smps	ld (ix+chp_psinsm),a
	pop bc
	pop hl
	ld e,(ix+chp_tnacc)
	ld d,(ix+chp_tnacc+1)
	add hl,de
	bit 6,b
	jr z,ch_noac
	ld (ix+chp_tnacc),l
	ld (ix+chp_tnacc+1),h
ch_noac ex de,hl
	ex af,af'
	ld l,a
	ld h,0
	ld sp,nt_
	add hl,sp
	ld sp,hl
	pop hl
	add hl,de
	ld e,(ix+chp_crtnsl)
	ld d,(ix+chp_crtnsl+1)
	add hl,de
csp_	ld sp,0x3131
	ex (sp),hl
	xor a
	or (ix+chp_tslcnt)
	jr z,ch_amp
	dec (ix+chp_tslcnt)
	jr nz,ch_amp
	ld a,(ix+chp_tnsldl)
	ld (ix+chp_tslcnt),a
	ld l,(ix+chp_tslstp)
	ld h,(ix+chp_tslstp+1)
	ld a,h
	add hl,de
	ld (ix+chp_crtnsl),l
	ld (ix+chp_crtnsl+1),h
	bit 2,(ix+chp_flags)
	jr nz,ch_amp
	ld e,(ix+chp_tndelt)
	ld d,(ix+chp_tndelt+1)
	and a
	jr z,ch_stpp
	ex de,hl
ch_stpp sbc hl,de
	jp m,ch_amp
	ld a,(ix+chp_sltont)
	ld (ix+chp_note),a
	xor a
	ld (ix+chp_tslcnt),a
	ld (ix+chp_crtnsl),a
	ld (ix+chp_crtnsl+1),a
ch_amp	ld a,(ix+chp_cramsl)
	bit 7,c
	jr z,ch_noam
	bit 6,c
	jr z,ch_amin
	cp 15
	jr z,ch_noam
	inc a
	jr ch_svam
ch_amin	cp -15
	jr z,ch_noam
	dec a
ch_svam	ld (ix+chp_cramsl),a
ch_noam	ld l,a
	ld a,b
	and 15
	add a,l
	jp p,ch_apos
	xor a
ch_apos	cp 16
	jr c,ch_vol
	ld a,15
ch_vol	or (ix+chp_volume)
	ld l,a
	ld h,0
	ld de,vt_
	add hl,de
	ld a,(hl)
ch_env	bit 0,c
	jr nz,ch_noen
	or (ix+chp_env_en)
ch_noen	ld (ampl),a
	bit 7,b
	ld a,c
	jr z,no_ensl
	rla
	rla
	sra a
	sra a
	sra a
	add a,(ix+chp_crensl) ;see comment below
	bit 5,b
	jr z,no_enac
	ld (ix+chp_crensl),a
no_enac	ld hl,addtoen
	add a,(hl) ;bug in pt3 - need word here.
		   ;fix it in next version?
	ld (hl),a
	jr ch_mix
no_ensl rra
	add a,(ix+chp_crnssl)
	ld (addtons),a
	bit 5,b
	jr z,ch_mix
	ld (ix+chp_crnssl),a
ch_mix	ld a,b
	rra
	and 0x48
ch_exit	ld hl,ayregs+mixer
	or (hl)
	rrca
	ld (hl),a
	pop hl
	xor a
	or (ix+chp_conoff)
	ret z
	dec (ix+chp_conoff)
	ret nz
	xor (ix+chp_flags)
	ld (ix+chp_flags),a
	rra
	ld a,(ix+chp_onoffd)
	jr c,ch_ondl
	ld a,(ix+chp_offond)
ch_ondl	ld (ix+chp_conoff),a
	ret

play    xor a
	ld (addtoen),a
	ld (ayregs+mixer),a
	dec a
	ld (ayregs+envtp),a
	ld hl,delycnt
	dec (hl)
	jr nz,pl2
	ld hl,chana+chp_ntskcn
	dec (hl)
	jr nz,pl1b
adinpta	equ $+1
	ld bc,0x0101
	ld a,(bc)
	and a
	jr nz,pl1a
	ld d,a
	ld (ns_base),a
	ld hl,(crpsptr)
	inc hl
	ld a,(hl)
	inc a
	jr nz,plnlp
	call checklp
lposptr	equ $+1
	ld hl,0x2121
	ld a,(hl)
	inc a
plnlp	ld (crpsptr),hl
	dec a
	add a,a
	ld e,a
	rl d
patsptr	equ $+1
	ld hl,0x2121
	add hl,de
	ld de,(modaddr)
	ld (psp_+1),sp
	ld sp,hl
	pop hl
	add hl,de
	ld b,h
	ld c,l
	pop hl
	add hl,de
	ld (adinptb),hl
	pop hl
	add hl,de
	ld (adinptc),hl
psp_	ld sp,0x3131
pl1a	ld ix,chana+12
	call ptdecod
	ld (adinpta),bc

pl1b	ld hl,chanb+chp_ntskcn
	dec (hl)
	jr nz,pl1c
	ld ix,chanb+12
adinptb	equ $+1
	ld bc,0x0101
	call ptdecod
	ld (adinptb),bc

pl1c	ld hl,chanc+chp_ntskcn
	dec (hl)
	jr nz,pl1d
	ld ix,chanc+12
adinptc	equ $+1
	ld bc,0x0101
	call ptdecod
	ld (adinptc),bc

delay	equ $+1
pl1d	ld a,0x3e
	ld (delycnt),a

pl2	ld ix,chana
	ld hl,(ayregs+tona)
	call chregs
	ld (ayregs+tona),hl
	ld a,(ampl)
	ld (ayregs+ampla),a
	ld ix,chanb
	ld hl,(ayregs+tonb)
	call chregs
	ld (ayregs+tonb),hl
	ld a,(ampl)
	ld (ayregs+amplb),a
	ld ix,chanc
	ld hl,(ayregs+tonc)
	call chregs
;	ld a,(ampl) ;ampl = ayregs+amplc
;	ld (ayregs+amplc),a
	ld (ayregs+tonc),hl

	ld hl,(ns_base_addtons)
	ld a,h
	add a,l
	ld (ayregs+noise),a

addtoen equ $+1
	ld a,0x3e
	ld e,a
	add a,a
	sbc a,a
	ld d,a
	ld hl,(envbase)
	add hl,de
	ld de,(curesld)
	add hl,de
	ld (ayregs+env),hl

	xor a
	ld hl,curedel
	or (hl)
	jr z,rout_a0
	dec (hl)
	jr nz,rout
env_del	equ $+1
	ld a,0x3e
	ld (hl),a
esldadd	equ $+1
	ld hl,0x2121
	add hl,de
	ld (curesld),hl

rout	xor a
rout_a0 ld hl,setup
	bit 1,(hl)
	jr nz,rstk
	ld de,0xffbf
	ld bc,0xfffd
	ld hl,ayregs
lout	out (c),a
	ld b,e
	outi
	ld b,d
	inc a
	cp 13
	jr nz,lout
	out (c),a
	ld a,(hl)
	and a
	ret m
	ld b,e
	out (c),a
	ret
rstk
	res 1,(hl)
	ld (rstksp_+1),sp
	ld sp,ayregs
	pop bc
	pop de
	pop hl
	pop af
	exx
	pop bc
	pop de
	pop hl
rstksp_
	ld sp,0
	ex (sp),hl
	push de
	push bc
	exx
	push af
	push hl
	push de
	push bc
	;ld hl,0x2758
	exx
	jp (hl)



nt_data	db (t_new_0-t1_)*2
	db tcnew_0-t_
	db (t_old_0-t1_)*2+1
	db tcold_0-t_
	db (t_new_1-t1_)*2+1
	db tcnew_1-t_
	db (t_old_1-t1_)*2+1
	db tcold_1-t_
	db (t_new_2-t1_)*2
	db tcnew_2-t_
	db (t_old_2-t1_)*2
	db tcold_2-t_
	db (t_new_3-t1_)*2
	db tcnew_3-t_
	db (t_old_3-t1_)*2
	db tcold_3-t_

t_

tcold_0	db 0x00+1,0x04+1,0x08+1,0x0a+1,0x0c+1,0x0e+1,0x12+1,0x14+1
	db 0x18+1,0x24+1,0x3c+1,0
tcold_1	db 0x5c+1,0
tcold_2	db 0x30+1,0x36+1,0x4c+1,0x52+1,0x5e+1,0x70+1,0x82,0x8c,0x9c
	db 0x9e,0xa0,0xa6,0xa8,0xaa,0xac,0xae,0xae,0
tcnew_3	db 0x56+1
tcold_3	db 0x1e+1,0x22+1,0x24+1,0x28+1,0x2c+1,0x2e+1,0x32+1,0xbe+1,0
tcnew_0	db 0x1c+1,0x20+1,0x22+1,0x26+1,0x2a+1,0x2c+1,0x30+1,0x54+1
	db 0xbc+1,0xbe+1,0
tcnew_1 equ tcold_1
tcnew_2	db 0x1a+1,0x20+1,0x24+1,0x28+1,0x2a+1,0x3a+1,0x4c+1,0x5e+1
	db 0xba+1,0xbc+1,0xbe+1,0

emptysamorn equ $-1
	db 1,0,0x90 ;delete #90 if you don't need default sample

;first 12 values of tone tables (packed)

t_pack	db 0x06ec*2/256,0xd8 ;#06ec*2
	db 0x0755-0x06ec
	db 0x07c5-0x0755
	db 0x083b-0x07c5
	db 0x08b8-0x083b
	db 0x093d-0x08b8
	db 0x09ca-0x093d
	db 0x0a5f-0x09ca
	db 0x0afc-0x0a5f
	db 0x0ba4-0x0afc
	db 0x0c55-0x0ba4
	db 0x0d10-0x0c55
	db 0x066d*2/256,0xda ;#066d*2
	db 0x06cf-0x066d
	db 0x0737-0x06cf
	db 0x07a4-0x0737
	db 0x0819-0x07a4
	db 0x0894-0x0819
	db 0x0917-0x0894
	db 0x09a1-0x0917
	db 0x0a33-0x09a1
	db 0x0acf-0x0a33
	db 0x0b73-0x0acf
	db 0x0c22-0x0b73
	db 0x0cda-0x0c22
	db 0x0704*2/256,0x08 ;#0704*2
	db 0x076e-0x0704
	db 0x07e0-0x076e
	db 0x0858-0x07e0
	db 0x08d6-0x0858
	db 0x095c-0x08d6
	db 0x09ec-0x095c
	db 0x0a82-0x09ec
	db 0x0b22-0x0a82
	db 0x0bcc-0x0b22
	db 0x0c80-0x0bcc
	db 0x0d3e-0x0c80
	db 0x07e0*2/256,0xc0 ;#07e0*2
	db 0x0858-0x07e0
	db 0x08e0-0x0858
	db 0x0960-0x08e0
	db 0x09f0-0x0960
	db 0x0a88-0x09f0
	db 0x0b28-0x0a88
	db 0x0bd8-0x0b28
	db 0x0c80-0x0bd8
	db 0x0d60-0x0c80
	db 0x0e10-0x0d60
	db 0x0ef8-0x0e10

;vars from here can be stripped
;you can move vars to any other address

vars

;channelsvars
	;struct	chp
;reset group
chp_psinor	equ 0
chp_psinsm	equ 1
chp_cramsl	equ 2
chp_crnssl	equ 3
chp_crensl	equ 4
chp_tslcnt	equ 5
chp_crtnsl	equ 6 ;dw
chp_tnacc	equ 8 ;dw
chp_conoff	equ 10
;reset group

chp_onoffd	equ 11

;ix for ptdecod here (+12)
chp_offond	equ 12
chp_ornptr	equ 13 ;dw
chp_samptr	equ 15 ;dw
chp_nntskp	equ 17
chp_note	equ 18
chp_sltont	equ 19
chp_env_en	equ 20
chp_flags	equ 21
 ;enabled - 0,simplegliss - 2
chp_tnsldl	equ 22
chp_tslstp	equ 23 ;dw
chp_tndelt	equ 25 ;dw
chp_ntskcn	equ 27
chp_volume	equ 28

chp	equ chp_volume+1

chana	ds chp
chanb	ds chp
chanc	ds chp

;globalvars
delycnt	db 0
curesld	dw 0
curedel	db 0
ns_base_addtons
ns_base	db 0
addtons	db 0

ayregs

vt_	ds 256 ;createdvolumetableaddress

envbase	equ vt_+14

t1_	equ vt_+16 ;tone tables data depacked here

t_old_1	equ t1_
t_old_2	equ t_old_1+24
t_old_3	equ t_old_2+24
t_old_0	equ t_old_3+2
t_new_0	equ t_old_0
t_new_1	equ t_old_1
t_new_2	equ t_new_0+24
t_new_3	equ t_old_3

nt_	ds 192 ;creatednotetableaddress

;local var
ampl	equ ayregs+amplc

var0end	equ vt_+16 ;init zeroes from vars to var0end-1

varsend equ $

mdladdr equ $

;release 0 steps:
;11.sep.2004 - note tables creator
;12.sep.2004 - volume tables creator; init subroutine
;13.sep.2004 - play counters, position counters
;14.sep.2004 - patterns decoder subroutine
;15.sep.2004 - resting (no code)
;16.sep.2004 - chregs subroutine; global debugging; 1st stable
;version was born
;17.sep.2004 - debugging and optimization. first release!
;release 1 steps:
;20.sep.2004 - local vars moved to code (selfmodified code
;smaller and faster)
;22.sep.2004 - added mute sound entry at start+8; position
;pointer moved to start+11; added setup and status byte at
;start+10 noloop mode and loop passed flags added
;release 2 steps:
;28.sep.2004 - optimization: code around chregs's volume and
;vibrato faster now; zeroing pd_res through stack; ton and ampl
;moved from channel vars to global ones; first position selector
;removed from init; optimization for packers(ivan roshin method)
;release 3 steps:
;2.oct.2004 - optimization in init and pd_loop (thanks to ivan
;roshin)
;4.oct.2004 - load delay from (hl) in init (2 bytes shorter)
;5.oct.2004 - optimization in pd_loop (->pd_lp2)
;7.oct.2004 - swaping some commands for better packing
;release 4 steps:
;9.oct.2004 - optimization around ld hl,spccoms (thanks to ivan
;roshin); in ptdecod swapped bc and de to optimize c_portm;
;removed sam and orn len and loop channel vars; chregs totally
;optimized
;release 5 steps:
;11.oct.2004 - pd_orsm and c_portm optimized; ivan roshin's
;volume tables creator algorithm (51 bytes shorter than mine)
;12.oct.2004 - ivan roshin's note tables creator algorithm (74
;bytes shorter than mine)
;release 6 steps:
;14.oct.2004 - loop and next position calculations moved to init
;15.oct.2004 - adinpt moved to code
;19.oct.2004 - env_del moved to code
;20.oct.2004 - version push and pop (1 byte shorter, thanks to
;ivan roshin)
;22.oct.2004 - env_en moved from flags' bit to byte (shorter and
;faster code)
;25.oct.2004 - setenv optimized
;29.oct.2004 - optimized around addtoen (sbc a,a, thanks to ivan
;roshin)
;3.nov.2004 - note tables data was compressed; with depacker it
;is 9 bytes shorter than uncompressed (thanks to ivan roshin)
;4.nov.2004 - default sample and ornament both are fixed now
;and placed into code block (6 bytes shorter)
;7.nov.2004 - ld a,(ns_base):ld l,a changed to ld hl,(ns_base)
;(thanks to dima bystrov)
;9.nov.2004 - ns_base and addtons are merged to ns_base_addtons;
;ld a,255 changed to dec a (at start of play); added rout_a0
;12.nov.2004 - ntskcn&volume are merged (8 bytes smaller init);
;ld bc,t1_ changed to push de...pop bc in note table creator
;19.dec.2004 - nt_data reorganized (6 bytes shorter, thanks to
;ivan roshin); c_portm and c_gliss are merged via set_stp (48
;tacts slower, but 8 bytes smaller, thanks to ivan roshin)
;release 7 steps:
;29.apr.2007 - sjasm adaptation; new 1.xx and 2.xx
;interpretation for pt 3.7+.
;7.sep.2017 - modified by hikaru/intense: generalized asm syntax
;for improved compatibility, added stack output (see setup byte)

;tests in immation tester v1.0 by andy man/pos (thanks to
;himik's zxz for help):
;module name/author	min tacts	max tacts	average
;spleen/nik-o		1720		9256		5500
;chuta/miguel		1720		9496		5500
;zhara/macros		4536		8744		5500

;size:
;code block #676 bytes
;variables #21d bytes (can be stripped)
;size in ram #676+#21d=#893 (2195) bytes

;notes:
;pro tracker 3.4r can not be detected by header, so pt3.4r tone
;tables really used only for modules of 3.3 and older versions.

music:
	incbin "grace3.pt3"

end
	savebin "vortex.bin",start,end-start
	savesna "vortex.sna",start
	savetap "vortex.tap",start
