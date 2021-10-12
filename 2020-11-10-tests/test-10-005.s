.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0xe1, 0x00, 0x00, 0xc2
.data
check_data1:
	.byte 0x0c, 0x74
.data
check_data2:
	.byte 0x4a, 0xc0, 0x5b, 0x29, 0xc0, 0xcc, 0xc1, 0xc2, 0xf9, 0x94, 0x46, 0xb9, 0xd9, 0x03, 0x1f, 0x7a
	.byte 0xde, 0xff, 0x08, 0xc8, 0x3d, 0x00, 0x07, 0x7a, 0xe2, 0xb3, 0x19, 0x79, 0xff, 0xff, 0x7f, 0x42
	.byte 0x3e, 0xf8, 0xb1, 0x82, 0xe1, 0x93, 0xc0, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000000000
	/* C2 */
	.octa 0x40740c
	/* C7 */
	.octa 0x403104
	/* C17 */
	.octa 0x200
	/* C30 */
	.octa 0x4ffff0
final_cap_values:
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x40740c
	/* C7 */
	.octa 0x403104
	/* C8 */
	.octa 0x1
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x200
	/* C30 */
	.octa 0x4ffff0
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000604070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x295bc04a // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:10 Rn:2 Rt2:10000 imm7:0110111 L:1 1010010:1010010 opc:00
	.inst 0xc2c1ccc0 // CSEL-C.CI-C Cd:0 Cn:6 11:11 cond:1100 Cm:1 11000010110:11000010110
	.inst 0xb94694f9 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:25 Rn:7 imm12:000110100101 opc:01 111001:111001 size:10
	.inst 0x7a1f03d9 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:25 Rn:30 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc808ffde // stlxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:30 Rt2:11111 o0:1 Rs:8 0:0 L:0 0010000:0010000 size:11
	.inst 0x7a07003d // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:1 000000:000000 Rm:7 11010000:11010000 S:1 op:1 sf:0
	.inst 0x7919b3e2 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:31 imm12:011001101100 opc:00 111001:111001 size:01
	.inst 0x427fffff // ALDAR-R.R-32 Rt:31 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x82b1f83e // ASTR-V.RRB-D Rt:30 Rn:1 opc:10 S:1 option:111 Rm:17 1:1 L:0 100000101:100000101
	.inst 0xc2c093e1 // GCTAG-R.C-C Rd:1 Cn:31 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c212a0
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2400db1 // ldr c17, [x13, #3]
	.inst 0xc24011be // ldr c30, [x13, #4]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q30, =0xc20000e100000000
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ad // ldr c13, [c21, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012ad // ldr c13, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x21, #0x4
	and x13, x13, x21
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b5 // ldr c21, [x13, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24005b5 // ldr c21, [x13, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc24009b5 // ldr c21, [x13, #2]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2400db5 // ldr c21, [x13, #3]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc24011b5 // ldr c21, [x13, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc24019b5 // ldr c21, [x13, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401db5 // ldr c21, [x13, #7]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0xc20000e100000000
	mov x21, v30.d[0]
	cmp x13, x21
	b.ne comparison_fail
	ldr x13, =0x0
	mov x21, v30.d[1]
	cmp x13, x21
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
	ldr x0, =0x00001cd8
	ldr x1, =check_data1
	ldr x2, =0x00001cda
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403798
	ldr x1, =check_data3
	ldr x2, =0x0040379c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004074e8
	ldr x1, =check_data4
	ldr x2, =0x004074f0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff0
	ldr x1, =check_data5
	ldr x2, =0x004ffff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
