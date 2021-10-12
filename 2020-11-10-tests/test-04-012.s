.section data0, #alloc, #write
	.zero 2048
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x04, 0xa6, 0x53, 0xb8, 0xe2, 0xb3, 0xc0, 0xc2, 0x03, 0xe4, 0x95, 0x6d, 0xbf, 0x20, 0x6a, 0x78
	.byte 0xfe, 0x5b, 0x5c, 0x79, 0x1d, 0x08, 0xa1, 0xaa, 0x35, 0x4a, 0x78, 0xf8, 0x61, 0x0f, 0xc0, 0xda
	.byte 0xe0, 0x78, 0x57, 0xe2, 0x81, 0xfb, 0x17, 0x38, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf40
	/* C5 */
	.octa 0x1800
	/* C7 */
	.octa 0x80000000600100050000000000001109
	/* C10 */
	.octa 0x80
	/* C16 */
	.octa 0x416b60
	/* C17 */
	.octa 0x10f8
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x2000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x1800
	/* C7 */
	.octa 0x80000000600100050000000000001109
	/* C10 */
	.octa 0x80
	/* C16 */
	.octa 0x416a9a
	/* C17 */
	.octa 0x10f8
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x2000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x11d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb853a604 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:4 Rn:16 01:01 imm9:100111010 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c0b3e2 // GCSEAL-R.C-C Rd:2 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x6d95e403 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:3 Rn:0 Rt2:11001 imm7:0101011 L:0 1011011:1011011 opc:01
	.inst 0x786a20bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:010 o3:0 Rs:10 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x795c5bfe // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:31 imm12:011100010110 opc:01 111001:111001 size:01
	.inst 0xaaa1081d // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:0 imm6:000010 Rm:1 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xf8784a35 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:21 Rn:17 10:10 S:0 option:010 Rm:24 1:1 opc:01 111000:111000 size:11
	.inst 0xdac00f61 // rev:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:27 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xe25778e0 // ALDURSH-R.RI-64 Rt:0 Rn:7 op2:10 imm9:101110111 V:0 op1:01 11100010:11100010
	.inst 0x3817fb81 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:28 10:10 imm9:101111111 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c211a0
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400585 // ldr c5, [x12, #1]
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2400d8a // ldr c10, [x12, #3]
	.inst 0xc2401190 // ldr c16, [x12, #4]
	.inst 0xc2401591 // ldr c17, [x12, #5]
	.inst 0xc2401998 // ldr c24, [x12, #6]
	.inst 0xc2401d9b // ldr c27, [x12, #7]
	.inst 0xc240219c // ldr c28, [x12, #8]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q3, =0x0
	ldr q25, =0x10000000000000
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x3085103d
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ac // ldr c12, [c13, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826011ac // ldr c12, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018d // ldr c13, [x12, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240058d // ldr c13, [x12, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240098d // ldr c13, [x12, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc240118d // ldr c13, [x12, #4]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240158d // ldr c13, [x12, #5]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240198d // ldr c13, [x12, #6]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc2401d8d // ldr c13, [x12, #7]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc240218d // ldr c13, [x12, #8]
	.inst 0xc2cda621 // chkeq c17, c13
	b.ne comparison_fail
	.inst 0xc240258d // ldr c13, [x12, #9]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240298d // ldr c13, [x12, #10]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc2402d8d // ldr c13, [x12, #11]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc240318d // ldr c13, [x12, #12]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc240358d // ldr c13, [x12, #13]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x13, v3.d[0]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x0
	mov x13, v3.d[1]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x10000000000000
	mov x13, v25.d[0]
	cmp x12, x13
	b.ne comparison_fail
	ldr x12, =0x0
	mov x13, v25.d[1]
	cmp x12, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001082
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001098
	ldr x1, =check_data1
	ldr x2, =0x000010a8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f8
	ldr x1, =check_data2
	ldr x2, =0x00001100
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001802
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f7f
	ldr x1, =check_data4
	ldr x2, =0x00001f80
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
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
	ldr x0, =0x00416b60
	ldr x1, =check_data7
	ldr x2, =0x00416b64
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
