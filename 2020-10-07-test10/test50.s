.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0x01, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0xc1, 0xba, 0x00, 0x7a, 0x00, 0x00, 0x00, 0x80, 0x40, 0x01, 0x00, 0x00
	.zero 16
.data
check_data1:
	.byte 0x9f
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x0c, 0x48, 0x56, 0x3a, 0xe6, 0xc4, 0x1b, 0xea, 0x41, 0x14, 0xec, 0xe2, 0x23, 0x54, 0x44, 0x62
	.byte 0xc2, 0x73, 0x06, 0xe2, 0x0e, 0x30, 0xc1, 0xc2, 0x02, 0xd8, 0xa6, 0x82, 0xc1, 0x03, 0x1f, 0xfa
	.byte 0x5e, 0x7c, 0x4f, 0x9b, 0xc0, 0x03, 0xc1, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x90000000600400000000000000000f80
	/* C2 */
	.octa 0x109f
	/* C7 */
	.octa 0x5f71ffffffffffff
	/* C27 */
	.octa 0x5047
	/* C30 */
	.octa 0x1061
final_cap_values:
	/* C1 */
	.octa 0x1060
	/* C2 */
	.octa 0x109f
	/* C3 */
	.octa 0x140800000000000000000000000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x5f71ffffffffffff
	/* C14 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x5047
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000600c0000000000000003001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3a56480c // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1100 0:0 Rn:0 10:10 cond:0100 imm5:10110 111010010:111010010 op:0 sf:0
	.inst 0xea1bc4e6 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:6 Rn:7 imm6:110001 Rm:27 N:0 shift:00 01010:01010 opc:11 sf:1
	.inst 0xe2ec1441 // ALDUR-V.RI-D Rt:1 Rn:2 op2:01 imm9:011000001 V:1 op1:11 11100010:11100010
	.inst 0x62445423 // LDNP-C.RIB-C Ct:3 Rn:1 Ct2:10101 imm7:0001000 L:1 011000100:011000100
	.inst 0xe20673c2 // ASTURB-R.RI-32 Rt:2 Rn:30 op2:00 imm9:001100111 V:0 op1:00 11100010:11100010
	.inst 0xc2c1300e // GCFLGS-R.C-C Rd:14 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x82a6d802 // ASTR-V.RRB-D Rt:2 Rn:0 opc:10 S:1 option:110 Rm:6 1:1 L:0 100000101:100000101
	.inst 0xfa1f03c1 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:30 000000:000000 Rm:31 11010000:11010000 S:1 op:1 sf:1
	.inst 0x9b4f7c5e // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:2 Ra:11111 0:0 Rm:15 10:10 U:0 10011011:10011011
	.inst 0xc2c103c0 // SCBNDS-C.CR-C Cd:0 Cn:30 000:000 opc:00 0:0 Rm:1 11000010110:11000010110
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d47 // ldr c7, [x10, #3]
	.inst 0xc240115b // ldr c27, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q2, =0x7a00bac100000000
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850032
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032ea // ldr c10, [c23, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826012ea // ldr c10, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x23, #0xf
	and x10, x10, x23
	cmp x10, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400157 // ldr c23, [x10, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400557 // ldr c23, [x10, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400957 // ldr c23, [x10, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400d57 // ldr c23, [x10, #3]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2401557 // ldr c23, [x10, #5]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401957 // ldr c23, [x10, #6]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401d57 // ldr c23, [x10, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x23, v1.d[0]
	cmp x10, x23
	b.ne comparison_fail
	ldr x10, =0x0
	mov x23, v1.d[1]
	cmp x10, x23
	b.ne comparison_fail
	ldr x10, =0x7a00bac100000000
	mov x23, v2.d[0]
	cmp x10, x23
	b.ne comparison_fail
	ldr x10, =0x0
	mov x23, v2.d[1]
	cmp x10, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c8
	ldr x1, =check_data1
	ldr x2, =0x000010c9
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001160
	ldr x1, =check_data2
	ldr x2, =0x00001168
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
