.section data0, #alloc, #write
	.zero 704
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3360
	.byte 0xa0, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xff, 0xff, 0xff, 0x1f
.data
check_data2:
	.byte 0xa0, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x62, 0x02, 0x01, 0xfa, 0xde, 0xa7, 0x92, 0xb9, 0xc2, 0x4b, 0x40, 0xeb, 0x80, 0x71, 0xc0, 0xc2
	.byte 0xe2, 0xbf, 0x06, 0xb4
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x03, 0x0c, 0x50, 0xe2, 0xe0, 0xa7, 0xce, 0xe2, 0x04, 0x65, 0x74, 0x69, 0x03, 0xac, 0x6a, 0x82
	.byte 0x00, 0xf8, 0xc7, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7ffffffc0000
	/* C8 */
	.octa 0x8000000000010005000000000000107c
	/* C12 */
	.octa 0x30007ff800000004040fc
	/* C30 */
	.octa 0x80000000000100050000000000000020
final_cap_values:
	/* C0 */
	.octa 0x5b901aa00000000000001aa0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1aa0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x8000000000010005000000000000107c
	/* C12 */
	.octa 0x30007ff800000004040fc
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x1fffffff
initial_SP_EL3_value:
	.octa 0x1f06
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xfa010262 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:19 000000:000000 Rm:1 11010000:11010000 S:1 op:1 sf:1
	.inst 0xb992a7de // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:010010101001 opc:10 111001:111001 size:10
	.inst 0xeb404bc2 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:30 imm6:010010 Rm:0 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0xc2c07180 // GCOFF-R.C-C Rd:0 Cn:12 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xb406bfe2 // cbz:aarch64/instrs/branch/conditional/compare Rt:2 imm19:0000011010111111111 op:0 011010:011010 sf:1
	.zero 55288
	.inst 0xe2500c03 // ALDURSH-R.RI-32 Rt:3 Rn:0 op2:11 imm9:100000000 V:0 op1:01 11100010:11100010
	.inst 0xe2cea7e0 // ALDUR-R.RI-64 Rt:0 Rn:31 op2:01 imm9:011101010 V:0 op1:11 11100010:11100010
	.inst 0x69746504 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:4 Rn:8 Rt2:11001 imm7:1101000 L:1 1010010:1010010 opc:01
	.inst 0x826aac03 // ALDR-R.RI-64 Rt:3 Rn:0 op:11 imm9:010101010 L:1 1000001001:1000001001
	.inst 0xc2c7f800 // SCBNDS-C.CI-S Cd:0 Cn:0 1110:1110 S:1 imm6:001111 11000010110:11000010110
	.inst 0xc2c210a0
	.zero 993244
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c8 // ldr c8, [x6, #1]
	.inst 0xc24008cc // ldr c12, [x6, #2]
	.inst 0xc2400cde // ldr c30, [x6, #3]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851037
	msr SCTLR_EL3, x6
	ldr x6, =0x0
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a6 // ldr c6, [c5, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826010a6 // ldr c6, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x5, #0xf
	and x6, x6, x5
	cmp x6, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c5 // ldr c5, [x6, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc24008c5 // ldr c5, [x6, #2]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2400cc5 // ldr c5, [x6, #3]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc24014c5 // ldr c5, [x6, #5]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc24018c5 // ldr c5, [x6, #6]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2401cc5 // ldr c5, [x6, #7]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012c4
	ldr x1, =check_data1
	ldr x2, =0x000012c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403ffc
	ldr x1, =check_data4
	ldr x2, =0x00403ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040d80c
	ldr x1, =check_data5
	ldr x2, =0x0040d824
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
