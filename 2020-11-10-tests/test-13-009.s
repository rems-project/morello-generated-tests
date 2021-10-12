.section data0, #alloc, #write
	.byte 0x11, 0x8c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x11, 0x8c
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xd2, 0x6b, 0x31, 0x78, 0x53, 0x30, 0xc7, 0xc2, 0xda, 0xff, 0x5f, 0x08, 0x3a, 0xf8, 0x61, 0xa2
	.byte 0x1f, 0x52, 0x3e, 0x78, 0x51, 0xb0, 0xc5, 0xc2, 0x42, 0xb8, 0xd1, 0x78, 0xc2, 0xf3, 0xfb, 0x82
	.byte 0xe2, 0xff, 0x7f, 0x42, 0xcd, 0x17, 0xec, 0x79, 0x80, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 16
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x3f1e0
	/* C2 */
	.octa 0x2001
	/* C16 */
	.octa 0x1000
	/* C17 */
	.octa 0xffffffffffc015ac
	/* C18 */
	.octa 0x0
	/* C27 */
	.octa 0x3fd7a
	/* C30 */
	.octa 0x80000000000100050000000000400a10
final_cap_values:
	/* C1 */
	.octa 0x3f1e0
	/* C2 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x1000
	/* C17 */
	.octa 0x200080001006000f0000000000002001
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x3fd7a
	/* C30 */
	.octa 0x80000000000100050000000000400a10
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004ffff8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78316bd2 // strh_reg:aarch64/instrs/memory/single/general/register Rt:18 Rn:30 10:10 S:0 option:011 Rm:17 1:1 opc:00 111000:111000 size:01
	.inst 0xc2c73053 // RRMASK-R.R-C Rd:19 Rn:2 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x085fffda // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:26 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xa261f83a // LDR-C.RRB-C Ct:26 Rn:1 10:10 S:1 option:111 Rm:1 1:1 opc:01 10100010:10100010
	.inst 0x783e521f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c5b051 // CVTP-C.R-C Cd:17 Rn:2 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x78d1b842 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:2 10:10 imm9:100011011 0:0 opc:11 111000:111000 size:01
	.inst 0x82fbf3c2 // ALDR-R.RRB-32 Rt:2 Rn:30 opc:00 S:1 option:111 Rm:27 1:1 L:1 100000101:100000101
	.inst 0x427fffe2 // ALDAR-R.R-32 Rt:2 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x79ec17cd // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:13 Rn:30 imm12:101100000101 opc:11 111001:111001 size:01
	.inst 0xc2c21080
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
	ldr x3, =initial_cap_values
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400870 // ldr c16, [x3, #2]
	.inst 0xc2400c71 // ldr c17, [x3, #3]
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc240147b // ldr c27, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603083 // ldr c3, [c4, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601083 // ldr c3, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401064 // ldr c4, [x3, #4]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401464 // ldr c4, [x3, #5]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401864 // ldr c4, [x3, #6]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401c64 // ldr c4, [x3, #7]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402064 // ldr c4, [x3, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402464 // ldr c4, [x3, #9]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x00001f1c
	ldr x1, =check_data1
	ldr x2, =0x00001f1e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fbc
	ldr x1, =check_data2
	ldr x2, =0x00001fbe
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
	ldr x0, =0x00400a10
	ldr x1, =check_data4
	ldr x2, =0x00400a11
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040201a
	ldr x1, =check_data5
	ldr x2, =0x0040201c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00430fe0
	ldr x1, =check_data6
	ldr x2, =0x00430ff0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffff8
	ldr x1, =check_data7
	ldr x2, =0x004ffffc
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
