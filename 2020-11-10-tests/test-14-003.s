.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0xc2, 0x7f, 0x1f, 0x42, 0x41, 0x10, 0xc2, 0xc2, 0x1f, 0x30, 0x24, 0x78, 0x3c, 0x48, 0x20, 0x0b
	.byte 0xff, 0x72, 0x76, 0x78, 0x7e, 0xff, 0x13, 0xc8, 0xde, 0xc8, 0x54, 0xe2, 0xf5, 0x52, 0x51, 0x38
	.byte 0xe0, 0xab, 0xcf, 0xc2, 0xfe, 0xe7, 0xe0, 0xe2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000200100050000000000001000
	/* C2 */
	.octa 0x800000000000000000000000
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x400100
	/* C22 */
	.octa 0x8000
	/* C23 */
	.octa 0xc0000000000600030000000000001400
	/* C27 */
	.octa 0x40000000180700070000000000001b30
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C2 */
	.octa 0x800000000000000000000000
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x400100
	/* C19 */
	.octa 0x1
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x8000
	/* C23 */
	.octa 0xc0000000000600030000000000001400
	/* C27 */
	.octa 0x40000000180700070000000000001b30
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1fca
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000103000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x421f7fc2 // ASTLR-C.R-C Ct:2 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xc2c21041 // CHKSLD-C-C 00001:00001 Cn:2 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x7824301f // ldseth:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:0 00:00 opc:011 0:0 Rs:4 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x0b20483c // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:28 Rn:1 imm3:010 option:010 Rm:0 01011001:01011001 S:0 op:0 sf:0
	.inst 0x787672ff // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:111 o3:0 Rs:22 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc813ff7e // stlxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:27 Rt2:11111 o0:1 Rs:19 0:0 L:0 0010000:0010000 size:11
	.inst 0xe254c8de // ALDURSH-R.RI-64 Rt:30 Rn:6 op2:10 imm9:101001100 V:0 op1:01 11100010:11100010
	.inst 0x385152f5 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:21 Rn:23 00:00 imm9:100010101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2cfabe0 // EORFLGS-C.CR-C Cd:0 Cn:31 1010:1010 opc:10 Rm:15 11000010110:11000010110
	.inst 0xe2e0e7fe // ALDUR-V.RI-D Rt:30 Rn:31 op2:01 imm9:000001110 V:1 op1:11 11100010:11100010
	.inst 0xc2c21120
	.zero 1048532
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f46 // ldr c6, [x26, #3]
	.inst 0xc2401356 // ldr c22, [x26, #4]
	.inst 0xc2401757 // ldr c23, [x26, #5]
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851037
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313a // ldr c26, [c9, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260113a // ldr c26, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x9, #0xf
	and x26, x26, x9
	cmp x26, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400349 // ldr c9, [x26, #0]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400749 // ldr c9, [x26, #1]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401749 // ldr c9, [x26, #5]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2401b49 // ldr c9, [x26, #6]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2401f49 // ldr c9, [x26, #7]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402349 // ldr c9, [x26, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x9, v30.d[0]
	cmp x26, x9
	b.ne comparison_fail
	ldr x26, =0x0
	mov x9, v30.d[1]
	cmp x26, x9
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
	ldr x0, =0x00001315
	ldr x1, =check_data1
	ldr x2, =0x00001316
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001400
	ldr x1, =check_data2
	ldr x2, =0x00001402
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001b30
	ldr x1, =check_data3
	ldr x2, =0x00001b38
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fd8
	ldr x1, =check_data4
	ldr x2, =0x00001fe0
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
	ldr x0, =0x0040004c
	ldr x1, =check_data6
	ldr x2, =0x0040004e
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
