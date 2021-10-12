.section data0, #alloc, #write
	.zero 80
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4000
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x21, 0x08, 0xc0, 0xda, 0x3e, 0xa1, 0x44, 0xf8, 0xff, 0x6f, 0x10, 0xf2, 0xea, 0x43, 0x82, 0x82
	.byte 0xe2, 0x7f, 0xdf, 0xc8, 0x9f, 0xbd, 0x1e, 0xa2, 0x09, 0x00, 0x31, 0x37, 0x01, 0xf2, 0x9e, 0x82
	.byte 0x24, 0x90, 0xc1, 0xc2, 0xa0, 0x48, 0x36, 0xe2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x10cc
	/* C9 */
	.octa 0x80000000204100050000000000001006
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000000100070000000000001250
	/* C16 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x10cc
	/* C9 */
	.octa 0x80000000204100050000000000001006
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000000100070000000000001100
	/* C16 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x800000004001000a0000000000001008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4000000054010c0200ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00821 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf844a13e // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:9 00:00 imm9:001001010 0:0 opc:01 111000:111000 size:11
	.inst 0xf2106fff // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:31 imms:011011 immr:010000 N:0 100100:100100 opc:11 sf:1
	.inst 0x828243ea // ASTRB-R.RRB-B Rt:10 Rn:31 opc:00 S:0 option:010 Rm:2 0:0 L:0 100000101:100000101
	.inst 0xc8df7fe2 // ldlar:aarch64/instrs/memory/ordered Rt:2 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xa21ebd9f // STR-C.RIBW-C Ct:31 Rn:12 11:11 imm9:111101011 0:0 opc:00 10100010:10100010
	.inst 0x37310009 // tbnz:aarch64/instrs/branch/conditional/test Rt:9 imm14:00100000000000 b40:00110 op:1 011011:011011 b5:0
	.inst 0x829ef201 // ASTRB-R.RRB-B Rt:1 Rn:16 opc:00 S:1 option:111 Rm:30 0:0 L:0 100000101:100000101
	.inst 0xc2c19024 // CLRTAG-C.C-C Cd:4 Cn:1 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xe23648a0 // ASTUR-V.RI-Q Rt:0 Rn:5 op2:10 imm9:101100100 V:1 op1:00 11100010:11100010
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a45 // ldr c5, [x18, #2]
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc240124a // ldr c10, [x18, #4]
	.inst 0xc240164c // ldr c12, [x18, #5]
	.inst 0xc2401a50 // ldr c16, [x18, #6]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q0, =0x40020000
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b2 // ldr c18, [c21, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826012b2 // ldr c18, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x21, #0xf
	and x18, x18, x21
	cmp x18, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400255 // ldr c21, [x18, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400655 // ldr c21, [x18, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400a55 // ldr c21, [x18, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400e55 // ldr c21, [x18, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401255 // ldr c21, [x18, #4]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401655 // ldr c21, [x18, #5]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401a55 // ldr c21, [x18, #6]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401e55 // ldr c21, [x18, #7]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402255 // ldr c21, [x18, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x40020000
	mov x21, v0.d[0]
	cmp x18, x21
	b.ne comparison_fail
	ldr x18, =0x0
	mov x21, v0.d[1]
	cmp x18, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001010
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001040
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001050
	ldr x1, =check_data3
	ldr x2, =0x00001058
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001100
	ldr x1, =check_data4
	ldr x2, =0x00001110
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
