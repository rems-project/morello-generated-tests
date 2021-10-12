.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf0, 0xc0, 0x40, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xa2, 0x33, 0xc2, 0xc2, 0x17, 0x93, 0xc5, 0xc2, 0x09, 0x00, 0xc0, 0xda, 0x40, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0x9c, 0xa2, 0xde, 0xc2, 0x1d, 0xfc, 0x3f, 0x42, 0xc1, 0x87, 0xdd, 0xc2, 0xbd, 0x79, 0xbe, 0xb8
	.byte 0x20, 0xc0, 0xba, 0x29, 0xdd, 0x7f, 0xd7, 0x02, 0xc2, 0x33, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000500400840000000000001000
	/* C1 */
	.octa 0x2004
	/* C13 */
	.octa 0xffffffffff001000
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x2000000000
	/* C29 */
	.octa 0x2000800000010007000000000040c0f0
final_cap_values:
	/* C0 */
	.octa 0x40000000500400840000000000001000
	/* C1 */
	.octa 0x1fd8
	/* C9 */
	.octa 0x8000000000000
	/* C13 */
	.octa 0xffffffffff001000
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0xc0000000300100050000002000000000
	/* C24 */
	.octa 0x2000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x3bc0800000010007ffffffffffe21004
	/* C30 */
	.octa 0x2000800000010007000000000040c10c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x3bc08000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000300100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c233a2 // BLRS-C-C 00010:00010 Cn:29 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c59317 // CVTD-C.R-C Cd:23 Rn:24 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xdac00009 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:9 Rn:0 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2c21140
	.zero 49376
	.inst 0xc2dea29c // CLRPERM-C.CR-C Cd:28 Cn:20 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0x423ffc1d // ASTLR-R.R-32 Rt:29 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2dd87c1 // CHKSS-_.CC-C 00001:00001 Cn:30 001:001 opc:00 1:1 Cm:29 11000010110:11000010110
	.inst 0xb8be79bd // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:13 10:10 S:1 option:011 Rm:30 1:1 opc:10 111000:111000 size:10
	.inst 0x29bac020 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:1 Rt2:10000 imm7:1110101 L:0 1010011:1010011 opc:00
	.inst 0x02d77fdd // SUB-C.CIS-C Cd:29 Cn:30 imm12:010111011111 sh:1 A:1 00000010:00000010
	.inst 0xc2c233c2 // BLRS-C-C 00010:00010 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.zero 999156
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2401374 // ldr c20, [x27, #4]
	.inst 0xc2401778 // ldr c24, [x27, #5]
	.inst 0xc2401b7d // ldr c29, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260315b // ldr c27, [c10, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260115b // ldr c27, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x10, #0xf
	and x27, x27, x10
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036a // ldr c10, [x27, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240076a // ldr c10, [x27, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b6a // ldr c10, [x27, #2]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2400f6a // ldr c10, [x27, #3]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240136a // ldr c10, [x27, #4]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc240176a // ldr c10, [x27, #5]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2401b6a // ldr c10, [x27, #6]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2401f6a // ldr c10, [x27, #7]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc240236a // ldr c10, [x27, #8]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc240276a // ldr c10, [x27, #9]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402b6a // ldr c10, [x27, #10]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd8
	ldr x1, =check_data2
	ldr x2, =0x00001fe0
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
	ldr x0, =0x0040c0f0
	ldr x1, =check_data4
	ldr x2, =0x0040c10c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
