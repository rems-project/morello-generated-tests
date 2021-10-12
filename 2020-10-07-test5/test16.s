.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xa1, 0x91, 0x1b, 0x54, 0x21, 0xa4, 0xc5, 0xc2, 0xbf, 0x33, 0xbd, 0x22, 0xfe, 0x7f, 0xd0, 0x9b
	.byte 0x5c, 0x94, 0x0f, 0x79, 0x00, 0xef, 0xfe, 0xc2, 0xc2, 0xe3, 0x85, 0xf9, 0xc6, 0x0f, 0xb7, 0xf9
	.byte 0xdc, 0x2b, 0xc4, 0x9a, 0xde, 0x45, 0xee, 0x82, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x85c
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x800000003ffb0007ffffffff80000d48
	/* C24 */
	.octa 0x90100000400100110000000000001010
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x85c
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x800000003ffb0007ffffffff80000d48
	/* C24 */
	.octa 0x90100000400100110000000000001010
	/* C29 */
	.octa 0xfa0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4c000000520100000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x541b91a1 // b_cond:aarch64/instrs/branch/conditional/cond cond:0001 0:0 imm19:0001101110010001101 01010100:01010100
	.inst 0xc2c5a421 // CHKEQ-_.CC-C 00001:00001 Cn:1 001:001 opc:01 1:1 Cm:5 11000010110:11000010110
	.inst 0x22bd33bf // STP-CC.RIAW-C Ct:31 Rn:29 Ct2:01100 imm7:1111010 L:0 001000101:001000101
	.inst 0x9bd07ffe // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:31 Ra:11111 0:0 Rm:16 10:10 U:1 10011011:10011011
	.inst 0x790f945c // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:2 imm12:001111100101 opc:00 111001:111001 size:01
	.inst 0xc2feef00 // ALDR-C.RRB-C Ct:0 Rn:24 1:1 L:1 S:0 option:111 Rm:30 11000010111:11000010111
	.inst 0xf985e3c2 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:30 imm12:000101111000 opc:10 111001:111001 size:11
	.inst 0xf9b70fc6 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:30 imm12:110111000011 opc:10 111001:111001 size:11
	.inst 0x9ac42bdc // asrv:aarch64/instrs/integer/shift/variable Rd:28 Rn:30 op2:10 0010:0010 Rm:4 0011010110:0011010110 sf:1
	.inst 0x82ee45de // ALDR-R.RRB-64 Rt:30 Rn:14 opc:01 S:0 option:010 Rm:14 1:1 L:1 100000101:100000101
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400865 // ldr c5, [x3, #2]
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc240106e // ldr c14, [x3, #4]
	.inst 0xc2401478 // ldr c24, [x3, #5]
	.inst 0xc240187c // ldr c28, [x3, #6]
	.inst 0xc2401c7d // ldr c29, [x3, #7]
	/* Set up flags and system registers */
	mov x3, #0x40000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e3 // ldr c3, [c7, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826010e3 // ldr c3, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x7, #0xf
	and x3, x3, x7
	cmp x3, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400067 // ldr c7, [x3, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc2401067 // ldr c7, [x3, #4]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401467 // ldr c7, [x3, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401867 // ldr c7, [x3, #6]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2401c67 // ldr c7, [x3, #7]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402067 // ldr c7, [x3, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001026
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a90
	ldr x1, =check_data2
	ldr x2, =0x00001a98
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
