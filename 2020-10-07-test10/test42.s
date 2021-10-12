.section data0, #alloc, #write
	.zero 4080
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xe2, 0x93, 0xc5, 0xc2, 0xfa, 0x16, 0xb5, 0xe2, 0xf0, 0x68, 0x8a, 0xab, 0x00, 0x50, 0xc2, 0xc2
	.byte 0x66, 0x51, 0x9c, 0xb9, 0xff, 0x13, 0xc0, 0xc2, 0x8e, 0x2e, 0xdd, 0x9a, 0xc2, 0x32, 0xc2, 0xc2
	.byte 0xfc, 0xcb, 0x63, 0x38, 0xd1, 0x33, 0x81, 0xf8, 0x60, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000200140050000000000400011
	/* C3 */
	.octa 0x4ffffd
	/* C11 */
	.octa 0x800000000001000500000000000003a0
	/* C22 */
	.octa 0x20008000d00100090000000000400021
	/* C23 */
	.octa 0x8000000000010005000000000049000f
	/* C29 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x20008000200140050000000000400011
	/* C2 */
	.octa 0x100026007ff60000000000000
	/* C3 */
	.octa 0x4ffffd
	/* C6 */
	.octa 0xffffffffc2c2c2c2
	/* C11 */
	.octa 0x800000000001000500000000000003a0
	/* C22 */
	.octa 0x20008000d00100090000000000400021
	/* C23 */
	.octa 0x8000000000010005000000000049000f
	/* C28 */
	.octa 0xc2
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x20008000200140050000000000400021
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000900050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x10002600700240001d0000020
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c593e2 // CVTD-C.R-C Cd:2 Rn:31 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xe2b516fa // ALDUR-V.RI-S Rt:26 Rn:23 op2:01 imm9:101010001 V:1 op1:10 11100010:11100010
	.inst 0xab8a68f0 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:16 Rn:7 imm6:011010 Rm:10 0:0 shift:10 01011:01011 S:1 op:0 sf:1
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0xb99c5166 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:11 imm12:011100010100 opc:10 111001:111001 size:10
	.inst 0xc2c013ff // GCBASE-R.C-C Rd:31 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9add2e8e // rorv:aarch64/instrs/integer/shift/variable Rd:14 Rn:20 op2:11 0010:0010 Rm:29 0011010110:0011010110 sf:1
	.inst 0xc2c232c2 // BLRS-C-C 00010:00010 Cn:22 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x3863cbfc // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:28 Rn:31 10:10 S:0 option:110 Rm:3 1:1 opc:01 111000:111000 size:00
	.inst 0xf88133d1 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:30 00:00 imm9:000010011 0:0 opc:10 111000:111000 size:11
	.inst 0xc2c21260
	.zero 589620
	.inst 0xc2c2c2c2
	.zero 458904
	.inst 0x00c20000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2400b2b // ldr c11, [x25, #2]
	.inst 0xc2400f36 // ldr c22, [x25, #3]
	.inst 0xc2401337 // ldr c23, [x25, #4]
	.inst 0xc240173d // ldr c29, [x25, #5]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850032
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603279 // ldr c25, [c19, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601279 // ldr c25, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400333 // ldr c19, [x25, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400733 // ldr c19, [x25, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400b33 // ldr c19, [x25, #2]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400f33 // ldr c19, [x25, #3]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2401333 // ldr c19, [x25, #4]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2401733 // ldr c19, [x25, #5]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2401b33 // ldr c19, [x25, #6]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2401f33 // ldr c19, [x25, #7]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2402333 // ldr c19, [x25, #8]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402733 // ldr c19, [x25, #9]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0xc2c2c2c2
	mov x19, v26.d[0]
	cmp x25, x19
	b.ne comparison_fail
	ldr x25, =0x0
	mov x19, v26.d[1]
	cmp x25, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff4
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
	ldr x0, =0x0048ff60
	ldr x1, =check_data2
	ldr x2, =0x0048ff64
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
