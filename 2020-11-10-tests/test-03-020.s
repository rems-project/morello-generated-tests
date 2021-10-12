.section data0, #alloc, #write
	.byte 0x41, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1872
	.byte 0x80, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 2192
.data
check_data0:
	.byte 0x41, 0x18
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x40, 0x00, 0x04
	.byte 0x80, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0xcb, 0x32, 0xfa, 0xc2, 0x8b, 0x27, 0xce, 0x1a, 0xd5, 0x3d, 0x4a, 0x58, 0x82, 0x11, 0xf0, 0x36
.data
check_data4:
	.byte 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.byte 0xbf, 0x41, 0x62, 0x78, 0xbf, 0x40, 0x79, 0x38, 0x47, 0x28, 0x73, 0x82, 0xc9, 0x0f, 0x17, 0xa2
	.byte 0x00, 0x9f, 0x59, 0xd1, 0xc2, 0x33, 0xc4, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x840
	/* C5 */
	.octa 0xc0000000500100040000000000001000
	/* C9 */
	.octa 0x4004000001000000000000000000100
	/* C13 */
	.octa 0xc0000000401110000000000000001000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0xd8100000000c00060000000000002050
final_cap_values:
	/* C2 */
	.octa 0x4004000001000000000000000000100
	/* C5 */
	.octa 0xc0000000500100040000000000001000
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x4004000001000000000000000000100
	/* C13 */
	.octa 0xc0000000401110000000000000001000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0xa0008000000300070000000000400255
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000001007003300fffffffffe2001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001760
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2fa32cb // EORFLGS-C.CI-C Cd:11 Cn:22 0:0 10:10 imm8:11010001 11000010111:11000010111
	.inst 0x1ace278b // lsrv:aarch64/instrs/integer/shift/variable Rd:11 Rn:28 op2:01 0010:0010 Rm:14 0011010110:0011010110 sf:0
	.inst 0x584a3dd5 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:21 imm19:0100101000111101110 011000:011000 opc:01
	.inst 0x36f01182 // tbz:aarch64/instrs/branch/conditional/test Rt:2 imm14:00000010001100 b40:11110 op:0 011011:011011 b5:0
	.zero 112
	.inst 0xc2c21180
	.zero 440
	.inst 0x786241bf // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:100 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x387940bf // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:100 o3:0 Rs:25 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x82732847 // ALDR-R.RI-32 Rt:7 Rn:2 op:10 imm9:100110010 L:1 1000001001:1000001001
	.inst 0xa2170fc9 // STR-C.RIBW-C Ct:9 Rn:30 11:11 imm9:101110000 0:0 opc:00 10100010:10100010
	.inst 0xd1599f00 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:24 imm12:011001100111 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xc2c433c2 // LDPBLR-C.C-C Ct:2 Cn:30 100:100 opc:01 11000010110001000:11000010110001000
	.zero 1047980
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x19, =initial_cap_values
	.inst 0xc2400262 // ldr c2, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2400e6d // ldr c13, [x19, #3]
	.inst 0xc2401276 // ldr c22, [x19, #4]
	.inst 0xc2401679 // ldr c25, [x19, #5]
	.inst 0xc2401a7e // ldr c30, [x19, #6]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603193 // ldr c19, [c12, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601193 // ldr c19, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026c // ldr c12, [x19, #0]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc240066c // ldr c12, [x19, #1]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400a6c // ldr c12, [x19, #2]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240166c // ldr c12, [x19, #5]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc2401a6c // ldr c12, [x19, #6]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc2401e6c // ldr c12, [x19, #7]
	.inst 0xc2cca721 // chkeq c25, c12
	b.ne comparison_fail
	.inst 0xc240226c // ldr c12, [x19, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001750
	ldr x1, =check_data2
	ldr x2, =0x00001770
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400080
	ldr x1, =check_data4
	ldr x2, =0x00400084
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040023c
	ldr x1, =check_data5
	ldr x2, =0x00400254
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004947c0
	ldr x1, =check_data6
	ldr x2, =0x004947c8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
