.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0xf0
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x01, 0x7d, 0x5f, 0x42, 0xdb, 0x7f, 0x9f, 0xc8, 0x7b, 0x52, 0xdf, 0x6d, 0x5f, 0xaf, 0x41, 0xb8
	.byte 0x47, 0x7c, 0x00, 0x22, 0x21, 0x29, 0xd1, 0x1a, 0xc2, 0xff, 0x1b, 0x22, 0xc2, 0xab, 0x11, 0x38
	.byte 0xe2, 0xd7, 0x01, 0x7c, 0x4b, 0x77, 0xe1, 0x82, 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4c000000200020000000000000400ff0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1ee0
	/* C9 */
	.octa 0x0
	/* C17 */
	.octa 0x8
	/* C19 */
	.octa 0x80000000000740070000000000403e80
	/* C26 */
	.octa 0x80000000000100050000000000000fee
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x4c0000002001400500000000000011c0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4c000000200020000000000000400ff0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1ee0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x8
	/* C19 */
	.octa 0x80000000000740070000000000404070
	/* C26 */
	.octa 0x80000000000100050000000000001008
	/* C27 */
	.octa 0x1
	/* C30 */
	.octa 0x4c0000002001400500000000000011c0
initial_SP_EL3_value:
	.octa 0x40000000000700070000000000001400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200004000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ee0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425f7d01 // ALDAR-C.R-C Ct:1 Rn:8 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc89f7fdb // stllr:aarch64/instrs/memory/ordered Rt:27 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x6ddf527b // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:27 Rn:19 Rt2:10100 imm7:0111110 L:1 1011011:1011011 opc:01
	.inst 0xb841af5f // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:26 11:11 imm9:000011010 0:0 opc:01 111000:111000 size:10
	.inst 0x22007c47 // STXR-R.CR-C Ct:7 Rn:2 (1)(1)(1)(1)(1):11111 0:0 Rs:0 0:0 L:0 001000100:001000100
	.inst 0x1ad12921 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:9 op2:10 0010:0010 Rm:17 0011010110:0011010110 sf:0
	.inst 0x221bffc2 // STLXR-R.CR-C Ct:2 Rn:30 (1)(1)(1)(1)(1):11111 1:1 Rs:27 0:0 L:0 001000100:001000100
	.inst 0x3811abc2 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:100011010 0:0 opc:00 111000:111000 size:00
	.inst 0x7c01d7e2 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:31 01:01 imm9:000011101 0:0 opc:00 111100:111100 size:01
	.inst 0x82e1774b // ALDR-R.RRB-64 Rt:11 Rn:26 opc:01 S:1 option:011 Rm:1 1:1 L:1 100000101:100000101
	.inst 0xc2c21140
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
	ldr x24, =initial_cap_values
	.inst 0xc2400302 // ldr c2, [x24, #0]
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f09 // ldr c9, [x24, #3]
	.inst 0xc2401311 // ldr c17, [x24, #4]
	.inst 0xc2401713 // ldr c19, [x24, #5]
	.inst 0xc2401b1a // ldr c26, [x24, #6]
	.inst 0xc2401f1b // ldr c27, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103f
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603158 // ldr c24, [c10, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601158 // ldr c24, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030a // ldr c10, [x24, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240070a // ldr c10, [x24, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc240170a // ldr c10, [x24, #5]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2401b0a // ldr c10, [x24, #6]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc2401f0a // ldr c10, [x24, #7]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240230a // ldr c10, [x24, #8]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240270a // ldr c10, [x24, #9]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402b0a // ldr c10, [x24, #10]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc2402f0a // ldr c10, [x24, #11]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x10, v2.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v2.d[1]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v20.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v20.d[1]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v27.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v27.d[1]
	cmp x24, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010da
	ldr x1, =check_data1
	ldr x2, =0x000010db
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011c0
	ldr x1, =check_data2
	ldr x2, =0x000011d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001402
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ee0
	ldr x1, =check_data4
	ldr x2, =0x00001ef0
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
	ldr x0, =0x00400ff0
	ldr x1, =check_data6
	ldr x2, =0x00401000
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00404070
	ldr x1, =check_data7
	ldr x2, =0x00404080
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
