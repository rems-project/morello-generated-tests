.section data0, #alloc, #write
	.byte 0x01, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0xc1, 0x27, 0xc1, 0xc2, 0x1d, 0xf0, 0xc6, 0xc2, 0xe1, 0x53, 0xeb, 0x78, 0xfe, 0xe7, 0x5b, 0xa2
	.byte 0xa0, 0x23, 0x2e, 0xb8, 0xf0, 0x23, 0x01, 0x02, 0x41, 0xc8, 0x71, 0xa2, 0xdf, 0x03, 0x24, 0x38
	.byte 0xc1, 0x87, 0xd6, 0xc2, 0x3e, 0x9c, 0x91, 0xb8, 0x20, 0x13, 0xc2, 0xc2
.data
check_data2:
	.byte 0x03, 0x01, 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x2000800000000000000000000000
	/* C2 */
	.octa 0x43ff20
	/* C4 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C14 */
	.octa 0x1000
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x100040000000000000000
	/* C30 */
	.octa 0x1002740060000000000008000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x46001c
	/* C2 */
	.octa 0x43ff20
	/* C4 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C14 */
	.octa 0x1000
	/* C16 */
	.octa 0xc28
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x100040000000000000000
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c127c1 // CPYTYPE-C.C-C Cd:1 Cn:30 001:001 opc:01 0:0 Cm:1 11000010110:11000010110
	.inst 0xc2c6f01d // CLRPERM-C.CI-C Cd:29 Cn:0 100:100 perm:111 1100001011000110:1100001011000110
	.inst 0x78eb53e1 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:31 00:00 opc:101 0:0 Rs:11 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xa25be7fe // LDR-C.RIAW-C Ct:30 Rn:31 01:01 imm9:110111110 0:0 opc:01 10100010:10100010
	.inst 0xb82e23a0 // ldeor:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:29 00:00 opc:010 0:0 Rs:14 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x020123f0 // 0x020123f0
	.inst 0xa271c841 // LDR-C.RRB-C Ct:1 Rn:2 10:10 S:0 option:110 Rm:17 1:1 opc:01 10100010:10100010
	.inst 0x382403df // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:4 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2d687c1 // CHKSS-_.CC-C 00001:00001 Cn:30 001:001 opc:00 1:1 Cm:22 11000010110:11000010110
	.inst 0xb8919c3e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:1 11:11 imm9:100011001 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21320
	.zero 261876
	.inst 0x00460103
	.zero 786652
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400ce4 // ldr c4, [x7, #3]
	.inst 0xc24010eb // ldr c11, [x7, #4]
	.inst 0xc24014ee // ldr c14, [x7, #5]
	.inst 0xc24018f1 // ldr c17, [x7, #6]
	.inst 0xc2401cf6 // ldr c22, [x7, #7]
	.inst 0xc24020fe // ldr c30, [x7, #8]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851037
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603327 // ldr c7, [c25, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601327 // ldr c7, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x25, #0xf
	and x7, x7, x25
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f9 // ldr c25, [x7, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004f9 // ldr c25, [x7, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24008f9 // ldr c25, [x7, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400cf9 // ldr c25, [x7, #3]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24010f9 // ldr c25, [x7, #4]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc24014f9 // ldr c25, [x7, #5]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc24018f9 // ldr c25, [x7, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401cf9 // ldr c25, [x7, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc24020f9 // ldr c25, [x7, #8]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc24024f9 // ldr c25, [x7, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24028f9 // ldr c25, [x7, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
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
	ldr x0, =0x0043ff20
	ldr x1, =check_data2
	ldr x2, =0x0043ff30
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0046001c
	ldr x1, =check_data3
	ldr x2, =0x00460020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
