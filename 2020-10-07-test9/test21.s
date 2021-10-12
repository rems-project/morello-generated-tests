.section data0, #alloc, #write
	.zero 880
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 3200
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0x9e, 0xfa, 0x66, 0x79, 0xc2, 0xad, 0xcc, 0xb0, 0x20, 0xd0, 0xc5, 0xc2, 0xa2, 0x36, 0x5f, 0xab
	.byte 0xde, 0x53, 0xc6, 0xc2, 0xc1, 0x33, 0xc0, 0xc2, 0x40, 0xf8, 0xb2, 0xd8, 0x52, 0x10, 0xc0, 0x5a
	.byte 0xe0, 0x23, 0x79, 0x82, 0x44, 0x08, 0xc0, 0xda, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc05da100000011
	/* C20 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C1 */
	.octa 0xffffffffffffffff
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0xc2c2
initial_SP_EL3_value:
	.octa 0x801000000001000500000000003fe800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000000000000c04ddcfff1e011
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7966fa9e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:20 imm12:100110111110 opc:01 111001:111001 size:01
	.inst 0xb0ccadc2 // ADRP-C.I-C Rd:2 immhi:100110010101101110 P:1 10000:10000 immlo:01 op:1
	.inst 0xc2c5d020 // CVTDZ-C.R-C Cd:0 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xab5f36a2 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:21 imm6:001101 Rm:31 0:0 shift:01 01011:01011 S:1 op:0 sf:1
	.inst 0xc2c653de // CLRPERM-C.CI-C Cd:30 Cn:30 100:100 perm:010 1100001011000110:1100001011000110
	.inst 0xc2c033c1 // GCLEN-R.C-C Rd:1 Cn:30 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xd8b2f840 // prfm_lit:aarch64/instrs/memory/literal/general Rt:0 imm19:1011001011111000010 011000:011000 opc:11
	.inst 0x5ac01052 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:18 Rn:2 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x827923e0 // ALDR-C.RI-C Ct:0 Rn:31 op:00 imm9:110010010 L:1 1000001001:1000001001
	.inst 0xdac00844 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:4 Rn:2 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c211a0
	.zero 244
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1048272
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	ldr x0, =initial_tag_locations
	mov x1, #1
tag_init_loop:
	ldr x2, [x0], #8
	cbz x2, tag_init_end
	.inst 0xc2400043 // ldr c3, [x2, #0]
	.inst 0xc2c18063 // sctag c3, c3, c1
	.inst 0xc2000043 // str c3, [x2, #0]
	b tag_init_loop
tag_init_end:
	/* Write general purpose registers */
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005d4 // ldr c20, [x14, #1]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085003a
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ae // ldr c14, [c13, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826011ae // ldr c14, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x13, #0x3
	and x14, x14, x13
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cd // ldr c13, [x14, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24005cd // ldr c13, [x14, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24009cd // ldr c13, [x14, #2]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000137c
	ldr x1, =check_data0
	ldr x2, =0x0000137e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400120
	ldr x1, =check_data2
	ldr x2, =0x00400130
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	ldr x0, =fail_message
write_tube:
	ldr x1, =trickbox
write_tube_loop:
	ldrb w2, [x0], #1
	strb w2, [x1]
	b write_tube_loop
ok_message:
	.ascii "OK\n\004"
fail_message:
	.ascii "FAILED\n\004"

	.balign 128
vector_table:
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
	.balign 128
	b comparison_fail
