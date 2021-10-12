.section data0, #alloc, #write
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 64
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 128
	.byte 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3168
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 496
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data6:
	.byte 0xfe, 0xcb, 0x5b, 0xe2, 0x14, 0xe8, 0xb8, 0xb8, 0xff, 0x07, 0x44, 0xe2, 0xda, 0x7c, 0xc1, 0x9b
	.byte 0x3e, 0x30, 0xc1, 0xc2, 0x22, 0x7c, 0xdf, 0xc8, 0xe7, 0xdb, 0x53, 0x38, 0x34, 0x89, 0xc0, 0xc2
	.byte 0x93, 0x7f, 0xdf, 0x88, 0x22, 0xd1, 0xc5, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x100000000000000001e08
	/* C1 */
	.octa 0x1000
	/* C9 */
	.octa 0x101006600ffffffffffe005
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x1038
final_cap_values:
	/* C0 */
	.octa 0x100000000000000001e08
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x800000004004003900ffffffffffe005
	/* C7 */
	.octa 0xc2
	/* C9 */
	.octa 0x101006600ffffffffffe005
	/* C19 */
	.octa 0xc2c2c2c2
	/* C20 */
	.octa 0x101006600ffffffffffe005
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x1038
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000500050000000000001150
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004004003900ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe25bcbfe // ALDURSH-R.RI-64 Rt:30 Rn:31 op2:10 imm9:110111100 V:0 op1:01 11100010:11100010
	.inst 0xb8b8e814 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:20 Rn:0 10:10 S:0 option:111 Rm:24 1:1 opc:10 111000:111000 size:10
	.inst 0xe24407ff // ALDURH-R.RI-32 Rt:31 Rn:31 op2:01 imm9:001000000 V:0 op1:01 11100010:11100010
	.inst 0x9bc17cda // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:26 Rn:6 Ra:11111 0:0 Rm:1 10:10 U:1 10011011:10011011
	.inst 0xc2c1303e // GCFLGS-R.C-C Rd:30 Cn:1 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc8df7c22 // ldlar:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x3853dbe7 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:7 Rn:31 10:10 imm9:100111101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c08934 // CHKSSU-C.CC-C Cd:20 Cn:9 0010:0010 opc:10 Cm:0 11000010110:11000010110
	.inst 0x88df7f93 // ldlar:aarch64/instrs/memory/ordered Rt:19 Rn:28 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c5d122 // CVTDZ-C.R-C Cd:2 Rn:9 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2400d58 // ldr c24, [x10, #3]
	.inst 0xc240115c // ldr c28, [x10, #4]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085003a
	msr SCTLR_EL3, x10
	ldr x10, =0x0
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260318a // ldr c10, [c12, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260118a // ldr c10, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x12, #0xf
	and x10, x10, x12
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014c // ldr c12, [x10, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240054c // ldr c12, [x10, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240094c // ldr c12, [x10, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240114c // ldr c12, [x10, #4]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240154c // ldr c12, [x10, #5]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc240194c // ldr c12, [x10, #6]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc2401d4c // ldr c12, [x10, #7]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc240214c // ldr c12, [x10, #8]
	.inst 0xc2cca781 // chkeq c28, c12
	b.ne comparison_fail
	.inst 0xc240254c // ldr c12, [x10, #9]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001038
	ldr x1, =check_data1
	ldr x2, =0x0000103c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000108d
	ldr x1, =check_data2
	ldr x2, =0x0000108e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000110c
	ldr x1, =check_data3
	ldr x2, =0x0000110e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001190
	ldr x1, =check_data4
	ldr x2, =0x00001192
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e08
	ldr x1, =check_data5
	ldr x2, =0x00001e0c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
