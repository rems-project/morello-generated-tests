.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 2224
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1824
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xdf, 0x93, 0xc0, 0xc2, 0x49, 0x6c, 0xe2, 0x82, 0x21, 0x18, 0xb7, 0x39, 0x28, 0x10, 0xc5, 0xc2
	.byte 0xae, 0xa8, 0xc2, 0xc2, 0x9e, 0xe7, 0xa2, 0x9b, 0xfb, 0x47, 0xa0, 0xc2, 0xfe, 0x23, 0xdf, 0x9a
	.byte 0xbe, 0xcf, 0xca, 0xe2, 0x1e, 0x64, 0xca, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4004804400ffffffffff6001
	/* C1 */
	.octa 0x80000000000100050000000000001238
	/* C2 */
	.octa 0xc60
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x1
	/* C29 */
	.octa 0xf54
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x4004804400ffffffffff6001
	/* C1 */
	.octa 0xffffffffffffffc2
	/* C2 */
	.octa 0xc60
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1
	/* C14 */
	.octa 0x3fff800000000000000000000000
	/* C27 */
	.octa 0x58007008000006080c002
	/* C29 */
	.octa 0xf54
	/* C30 */
	.octa 0x400480440000000000000001
initial_SP_EL3_value:
	.octa 0x58007007ffffe60820000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x9010000000820006000000000001e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c093df // GCTAG-R.C-C Rd:31 Cn:30 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x82e26c49 // ALDR-V.RRB-S Rt:9 Rn:2 opc:11 S:0 option:011 Rm:2 1:1 L:1 100000101:100000101
	.inst 0x39b71821 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:110111000110 opc:10 111001:111001 size:00
	.inst 0xc2c51028 // CVTD-R.C-C Rd:8 Cn:1 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c2a8ae // EORFLGS-C.CR-C Cd:14 Cn:5 1010:1010 opc:10 Rm:2 11000010110:11000010110
	.inst 0x9ba2e79e // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:28 Ra:25 o0:1 Rm:2 01:01 U:1 10011011:10011011
	.inst 0xc2a047fb // ADD-C.CRI-C Cd:27 Cn:31 imm3:001 option:010 Rm:0 11000010101:11000010101
	.inst 0x9adf23fe // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:31 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xe2cacfbe // ALDUR-C.RI-C Ct:30 Rn:29 op2:11 imm9:010101100 V:0 op1:11 11100010:11100010
	.inst 0xc2ca641e // CPYVALUE-C.C-C Cd:30 Cn:0 001:001 opc:11 0:0 Cm:10 11000010110:11000010110
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b02 // ldr c2, [x24, #2]
	.inst 0xc2400f05 // ldr c5, [x24, #3]
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc240171d // ldr c29, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603358 // ldr c24, [c26, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601358 // ldr c24, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x26, #0xf
	and x24, x24, x26
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031a // ldr c26, [x24, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240071a // ldr c26, [x24, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400b1a // ldr c26, [x24, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400f1a // ldr c26, [x24, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240131a // ldr c26, [x24, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240171a // ldr c26, [x24, #5]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc240231a // ldr c26, [x24, #8]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240271a // ldr c26, [x24, #9]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0xc2c2c2c2
	mov x26, v9.d[0]
	cmp x24, x26
	b.ne comparison_fail
	ldr x24, =0x0
	mov x26, v9.d[1]
	cmp x24, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000018c0
	ldr x1, =check_data1
	ldr x2, =0x000018c4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
