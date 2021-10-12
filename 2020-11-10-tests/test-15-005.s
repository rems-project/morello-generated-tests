.section data0, #alloc, #write
	.zero 512
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xe1, 0x10, 0xc2, 0xc2, 0x22, 0xd4, 0xe2, 0xc2, 0x40, 0x32, 0xc2, 0xc2
.data
check_data3:
	.byte 0x22, 0x47, 0x8a, 0x2a, 0x80, 0x5a, 0xc0, 0xc2, 0x1f, 0x72, 0x60, 0xb8, 0xfe, 0x7f, 0x0b, 0x22
	.byte 0x41, 0x20, 0xc1, 0xc2, 0xfa, 0x13, 0xc0, 0xda, 0x41, 0x48, 0xc0, 0xc2, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4000000000400002000000000100
	/* C7 */
	.octa 0x0
	/* C16 */
	.octa 0x1204
	/* C18 */
	.octa 0x20008000000100070000000000400800
	/* C20 */
	.octa 0xc0020001000000004000e000
final_cap_values:
	/* C0 */
	.octa 0xc0020001000000004000e000
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x1
	/* C16 */
	.octa 0x1204
	/* C18 */
	.octa 0x20008000000100070000000000400800
	/* C20 */
	.octa 0xc0020001000000004000e000
	/* C26 */
	.octa 0x40
	/* C30 */
	.octa 0x2000800080030002000000000040000d
initial_SP_EL3_value:
	.octa 0x1200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300020000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000005802000000fffffffffff780
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c210e1 // CHKSLD-C-C 00001:00001 Cn:7 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2e2d422 // ASTR-C.RRB-C Ct:2 Rn:1 1:1 L:0 S:1 option:110 Rm:2 11000010111:11000010111
	.inst 0xc2c23240 // BLR-C-C 00000:00000 Cn:18 100:100 opc:01 11000010110000100:11000010110000100
	.zero 2036
	.inst 0x2a8a4722 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:25 imm6:010001 Rm:10 N:0 shift:10 01010:01010 opc:01 sf:0
	.inst 0xc2c05a80 // ALIGNU-C.CI-C Cd:0 Cn:20 0110:0110 U:1 imm6:000000 11000010110:11000010110
	.inst 0xb860721f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:111 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x220b7ffe // STXR-R.CR-C Ct:30 Rn:31 (1)(1)(1)(1)(1):11111 0:0 Rs:11 0:0 L:0 001000100:001000100
	.inst 0xc2c12041 // SCBNDSE-C.CR-C Cd:1 Cn:2 000:000 opc:01 0:0 Rm:1 11000010110:11000010110
	.inst 0xdac013fa // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:26 Rn:31 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c04841 // UNSEAL-C.CC-C Cd:1 Cn:2 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0xc2c21300
	.zero 1046496
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dd0 // ldr c16, [x14, #3]
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc24015d4 // ldr c20, [x14, #5]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085103d
	msr SCTLR_EL3, x14
	ldr x14, =0x84
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330e // ldr c14, [c24, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260130e // ldr c14, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x24, #0xf
	and x14, x14, x24
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d8 // ldr c24, [x14, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005d8 // ldr c24, [x14, #1]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24009d8 // ldr c24, [x14, #2]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2400dd8 // ldr c24, [x14, #3]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24015d8 // ldr c24, [x14, #5]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2401dd8 // ldr c24, [x14, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001210
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400800
	ldr x1, =check_data3
	ldr x2, =0x00400820
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
