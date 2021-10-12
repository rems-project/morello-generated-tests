.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x42, 0x00, 0x11, 0x00, 0x00, 0x0b, 0x00, 0x00, 0x40, 0x40, 0x13, 0x00, 0x00
	.zero 16
.data
check_data4:
	.byte 0xce, 0xee, 0x9c, 0x34, 0x1e, 0x00, 0x12, 0x1a, 0x00, 0x26, 0xc5, 0xc2, 0xdf, 0x7b, 0x7f, 0xf8
	.byte 0x79, 0x20, 0x93, 0xb8, 0xd0, 0x0b, 0xc2, 0x6a, 0x42, 0x0a, 0x4d, 0xe2, 0x7f, 0x0c, 0x0d, 0x39
	.byte 0xd7, 0xfc, 0x82, 0x22, 0x0b, 0xff, 0x7f, 0x42, 0x40, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffc000d2
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1036
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1470
	/* C14 */
	.octa 0xffffffff
	/* C16 */
	.octa 0x80000060003000000000e00c801
	/* C18 */
	.octa 0x800000000005000e0000000000400f2e
	/* C23 */
	.octa 0x13404000000b0000110042000000
	/* C24 */
	.octa 0x800000005000000000000000004003fc
final_cap_values:
	/* C0 */
	.octa 0x80000060003ffffffffffffffff
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1036
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x14c0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0xffffffff
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x800000000005000e0000000000400f2e
	/* C23 */
	.octa 0x13404000000b0000110042000000
	/* C24 */
	.octa 0x800000005000000000000000004003fc
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000f0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x349ceece // cbz:aarch64/instrs/branch/conditional/compare Rt:14 imm19:1001110011101110110 op:0 011010:011010 sf:0
	.inst 0x1a12001e // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:0 000000:000000 Rm:18 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c52600 // CPYTYPE-C.C-C Cd:0 Cn:16 001:001 opc:01 0:0 Cm:5 11000010110:11000010110
	.inst 0xf87f7bdf // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:31 Rn:30 10:10 S:1 option:011 Rm:31 1:1 opc:01 111000:111000 size:11
	.inst 0xb8932079 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:3 00:00 imm9:100110010 0:0 opc:10 111000:111000 size:10
	.inst 0x6ac20bd0 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:16 Rn:30 imm6:000010 Rm:2 N:0 shift:11 01010:01010 opc:11 sf:0
	.inst 0xe24d0a42 // ALDURSH-R.RI-64 Rt:2 Rn:18 op2:10 imm9:011010000 V:0 op1:01 11100010:11100010
	.inst 0x390d0c7f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:3 imm12:001101000011 opc:00 111001:111001 size:00
	.inst 0x2282fcd7 // STP-CC.RIAW-C Ct:23 Rn:6 Ct2:11111 imm7:0000101 L:0 001000101:001000101
	.inst 0x427fff0b // ALDAR-R.R-32 Rt:11 Rn:24 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c21340
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b63 // ldr c3, [x27, #2]
	.inst 0xc2400f65 // ldr c5, [x27, #3]
	.inst 0xc2401366 // ldr c6, [x27, #4]
	.inst 0xc240176e // ldr c14, [x27, #5]
	.inst 0xc2401b70 // ldr c16, [x27, #6]
	.inst 0xc2401f72 // ldr c18, [x27, #7]
	.inst 0xc2402377 // ldr c23, [x27, #8]
	.inst 0xc2402778 // ldr c24, [x27, #9]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260335b // ldr c27, [c26, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260135b // ldr c27, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x26, #0xf
	and x27, x27, x26
	cmp x27, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240037a // ldr c26, [x27, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240077a // ldr c26, [x27, #1]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400b7a // ldr c26, [x27, #2]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc2400f7a // ldr c26, [x27, #3]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240137a // ldr c26, [x27, #4]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc240177a // ldr c26, [x27, #5]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc2401b7a // ldr c26, [x27, #6]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc2401f7a // ldr c26, [x27, #7]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240237a // ldr c26, [x27, #8]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240277a // ldr c26, [x27, #9]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc2402b7a // ldr c26, [x27, #10]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc2402f7a // ldr c26, [x27, #11]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc240337a // ldr c26, [x27, #12]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001768
	ldr x1, =check_data0
	ldr x2, =0x0000176c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001808
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b79
	ldr x1, =check_data2
	ldr x2, =0x00001b7a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c70
	ldr x1, =check_data3
	ldr x2, =0x00001c90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004003fc
	ldr x1, =check_data5
	ldr x2, =0x00400400
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400ffe
	ldr x1, =check_data6
	ldr x2, =0x00401000
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
