.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0xa8
.data
check_data2:
	.byte 0x00, 0x00, 0x82, 0x00
.data
check_data3:
	.byte 0x55, 0x08, 0x12, 0x71, 0x9e, 0x80, 0x41, 0xc2, 0x81, 0x73, 0xa5, 0xe2, 0x43, 0x36, 0x0f, 0xb8
	.byte 0x32, 0xec, 0x4a, 0xb8, 0x3e, 0xfc, 0xbd, 0x82, 0x82, 0xb8, 0x59, 0x58, 0xa1, 0xc3, 0xc2, 0xc2
	.byte 0xcd, 0xeb, 0xfb, 0xc2, 0xa2, 0xd0, 0xc0, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000406004f0000000000400916
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000700221060000000000402400
	/* C18 */
	.octa 0x40000000080140050000000000001000
	/* C28 */
	.octa 0xf71
	/* C29 */
	.octa 0x3ffffffffff0018f
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000700221060000000000402400
	/* C13 */
	.octa 0xdf00000000000000
	/* C18 */
	.octa 0x0
	/* C28 */
	.octa 0xf71
	/* C29 */
	.octa 0x3ffffffffff0018f
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080001001c0050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000007001500ffffffffffc2c0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x71120855 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:21 Rn:2 imm12:010010000010 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc241809e // LDR-C.RIB-C Ct:30 Rn:4 imm12:000001100000 L:1 110000100:110000100
	.inst 0xe2a57381 // ASTUR-V.RI-S Rt:1 Rn:28 op2:00 imm9:001010111 V:1 op1:10 11100010:11100010
	.inst 0xb80f3643 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:3 Rn:18 01:01 imm9:011110011 0:0 opc:00 111000:111000 size:10
	.inst 0xb84aec32 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:1 11:11 imm9:010101110 0:0 opc:01 111000:111000 size:10
	.inst 0x82bdfc3e // ASTR-V.RRB-S Rt:30 Rn:1 opc:11 S:1 option:111 Rm:29 1:1 L:0 100000101:100000101
	.inst 0x5859b882 // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:2 imm19:0101100110111000100 011000:011000 opc:01
	.inst 0xc2c2c3a1 // CVT-R.CC-C Rd:1 Cn:29 110000:110000 Cm:2 11000010110:11000010110
	.inst 0xc2fbebcd // ORRFLGS-C.CI-C Cd:13 Cn:30 0:0 01:01 imm8:11011111 11000010111:11000010111
	.inst 0xc2c0d0a2 // GCPERM-R.C-C Rd:2 Cn:5 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c3 // ldr c3, [x22, #1]
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2400ed2 // ldr c18, [x22, #3]
	.inst 0xc24012dc // ldr c28, [x22, #4]
	.inst 0xc24016dd // ldr c29, [x22, #5]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q1, =0xa8000000
	ldr q30, =0x820000
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850032
	msr SCTLR_EL3, x22
	ldr x22, =0x4
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f6 // ldr c22, [c23, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x826012f6 // ldr c22, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x23, #0xf
	and x22, x22, x23
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d7 // ldr c23, [x22, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc24006d7 // ldr c23, [x22, #1]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400ad7 // ldr c23, [x22, #2]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2400ed7 // ldr c23, [x22, #3]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc24016d7 // ldr c23, [x22, #5]
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2401ed7 // ldr c23, [x22, #7]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0xa8000000
	mov x23, v1.d[0]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v1.d[1]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x820000
	mov x23, v30.d[0]
	cmp x22, x23
	b.ne comparison_fail
	ldr x22, =0x0
	mov x23, v30.d[1]
	cmp x22, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001044
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
	ldr x0, =0x004009c4
	ldr x1, =check_data4
	ldr x2, =0x004009c8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402a00
	ldr x1, =check_data5
	ldr x2, =0x00402a10
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004b3728
	ldr x1, =check_data6
	ldr x2, =0x004b3730
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
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
