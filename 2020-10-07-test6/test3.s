.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x27, 0x13, 0xc0, 0xda, 0x5c, 0x7d, 0x9f, 0xc8, 0xec, 0x45, 0x52, 0xfc, 0xe1, 0x4b, 0xc0, 0x82
	.byte 0x53, 0xdc, 0x17, 0xb9, 0x23, 0x7a, 0x94, 0xe2, 0xc1, 0x33, 0xc2, 0xc2, 0x42, 0x28, 0xa4, 0x9b
	.byte 0x20, 0x0b, 0xc0, 0xda, 0xe1, 0x87, 0xc2, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x448000
	/* C2 */
	.octa 0xfffffffffffff428
	/* C10 */
	.octa 0xc00
	/* C15 */
	.octa 0x1938
	/* C17 */
	.octa 0x800000000447800500000000004210b9
	/* C19 */
	.octa 0x62000000
	/* C28 */
	.octa 0xfee0fd0000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0xc00
	/* C15 */
	.octa 0x185c
	/* C17 */
	.octa 0x800000000447800500000000004210b9
	/* C19 */
	.octa 0x62000000
	/* C28 */
	.octa 0xfee0fd0000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000180060000000000040004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000704070000000000001403
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac01327 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:7 Rn:25 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc89f7d5c // stllr:aarch64/instrs/memory/ordered Rt:28 Rn:10 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xfc5245ec // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:12 Rn:15 01:01 imm9:100100100 0:0 opc:01 111100:111100 size:11
	.inst 0x82c04be1 // ALDRSH-R.RRB-32 Rt:1 Rn:31 opc:10 S:0 option:010 Rm:0 0:0 L:1 100000101:100000101
	.inst 0xb917dc53 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:19 Rn:2 imm12:010111110111 opc:00 111001:111001 size:10
	.inst 0xe2947a23 // ALDURSW-R.RI-64 Rt:3 Rn:17 op2:10 imm9:101000111 V:0 op1:10 11100010:11100010
	.inst 0xc2c233c1 // CHKTGD-C-C 00001:00001 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x9ba42842 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:2 Ra:10 o0:0 Rm:4 01:01 U:1 10011011:10011011
	.inst 0xdac00b20 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:25 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c287e1 // CHKSS-_.CC-C 00001:00001 Cn:31 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc240098a // ldr c10, [x12, #2]
	.inst 0xc2400d8f // ldr c15, [x12, #3]
	.inst 0xc2401191 // ldr c17, [x12, #4]
	.inst 0xc2401593 // ldr c19, [x12, #5]
	.inst 0xc240199c // ldr c28, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032ec // ldr c12, [c23, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826012ec // ldr c12, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x23, #0xf
	and x12, x12, x23
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400197 // ldr c23, [x12, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400597 // ldr c23, [x12, #1]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400997 // ldr c23, [x12, #2]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2400d97 // ldr c23, [x12, #3]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401197 // ldr c23, [x12, #4]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401597 // ldr c23, [x12, #5]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2401997 // ldr c23, [x12, #6]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2401d97 // ldr c23, [x12, #7]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x23, v12.d[0]
	cmp x12, x23
	b.ne comparison_fail
	ldr x12, =0x0
	mov x23, v12.d[1]
	cmp x12, x23
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
	ldr x0, =0x00001d38
	ldr x1, =check_data1
	ldr x2, =0x00001d40
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
	ldr x0, =0x00421000
	ldr x1, =check_data3
	ldr x2, =0x00421004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00488004
	ldr x1, =check_data4
	ldr x2, =0x00488006
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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

	.balign 128
vector_table:
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
