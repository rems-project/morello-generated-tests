.section data0, #alloc, #write
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xa1, 0x10, 0xc2, 0xc2, 0x80, 0x3f, 0x4f, 0xe2, 0x5f, 0xaf, 0xd2, 0xd2, 0xdc, 0x5b, 0xa7, 0xb9
	.byte 0x5e, 0x24, 0xdf, 0xe2, 0x5f, 0x13, 0x3d, 0x78, 0x43, 0x87, 0x6c, 0x51, 0xdf, 0x32, 0x21, 0x78
	.byte 0xe0, 0x33, 0x9c, 0xcb, 0x4c, 0x72, 0xbf, 0x38, 0x00, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x100e
	/* C5 */
	.octa 0x0
	/* C18 */
	.octa 0xc0000000000100050000000000001ffe
	/* C22 */
	.octa 0xc00000000001000500000000000012f0
	/* C26 */
	.octa 0xc0000000000100050000000000001000
	/* C28 */
	.octa 0xfd9
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000004d59a0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x100e
	/* C3 */
	.octa 0xff4e0000
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0xc0000000000100050000000000001ffe
	/* C22 */
	.octa 0xc00000000001000500000000000012f0
	/* C26 */
	.octa 0xc0000000000100050000000000001000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080400000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000400070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c210a1 // CHKSLD-C-C 00001:00001 Cn:5 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xe24f3f80 // ALDURSH-R.RI-32 Rt:0 Rn:28 op2:11 imm9:011110011 V:0 op1:01 11100010:11100010
	.inst 0xd2d2af5f // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:1001010101111010 hw:10 100101:100101 opc:10 sf:1
	.inst 0xb9a75bdc // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:30 imm12:100111010110 opc:10 111001:111001 size:10
	.inst 0xe2df245e // ALDUR-R.RI-64 Rt:30 Rn:2 op2:01 imm9:111110010 V:0 op1:11 11100010:11100010
	.inst 0x783d135f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:001 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x516c8743 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:3 Rn:26 imm12:101100100001 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x782132df // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xcb9c33e0 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:31 imm6:001100 Rm:28 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0x38bf724c // lduminb:aarch64/instrs/memory/atomicops/ld Rt:12 Rn:18 00:00 opc:111 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2c21300
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa5 // ldr c5, [x21, #2]
	.inst 0xc2400eb2 // ldr c18, [x21, #3]
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc24016ba // ldr c26, [x21, #5]
	.inst 0xc2401abc // ldr c28, [x21, #6]
	.inst 0xc2401ebd // ldr c29, [x21, #7]
	.inst 0xc24022be // ldr c30, [x21, #8]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603315 // ldr c21, [c24, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601315 // ldr c21, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x24, #0xf
	and x21, x21, x24
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b8 // ldr c24, [x21, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24006b8 // ldr c24, [x21, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400ab8 // ldr c24, [x21, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400eb8 // ldr c24, [x21, #3]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc24012b8 // ldr c24, [x21, #4]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc24016b8 // ldr c24, [x21, #5]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401ab8 // ldr c24, [x21, #6]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401eb8 // ldr c24, [x21, #7]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc24022b8 // ldr c24, [x21, #8]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc24026b8 // ldr c24, [x21, #9]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402ab8 // ldr c24, [x21, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402eb8 // ldr c24, [x21, #11]
	.inst 0xc2d8a7c1 // chkeq c30, c24
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
	ldr x0, =0x000010cc
	ldr x1, =check_data1
	ldr x2, =0x000010ce
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012f0
	ldr x1, =check_data2
	ldr x2, =0x000012f2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x004d80f8
	ldr x1, =check_data5
	ldr x2, =0x004d80fc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
