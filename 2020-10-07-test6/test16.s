.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 12
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xc2, 0x17, 0x35, 0x2d, 0x5e, 0xa0, 0xde, 0xc2, 0x03, 0x84, 0xa1, 0x9b, 0xdf, 0x7c, 0x3f, 0x42
	.byte 0xe1, 0x13, 0xc7, 0xc2, 0x81, 0x07, 0x05, 0xf8, 0x1f, 0xec, 0x84, 0xb8, 0x5e, 0xb4, 0xad, 0xe2
	.byte 0x3b, 0x09, 0x18, 0x1b, 0x4c, 0x29, 0xde, 0xc2, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000008100070000000000000fc2
	/* C2 */
	.octa 0x100000000000000000000001125
	/* C6 */
	.octa 0x1030
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x400000002001000500000000000017c0
	/* C30 */
	.octa 0x400000004002001e0000000000001060
final_cap_values:
	/* C0 */
	.octa 0x80000000008100070000000000001010
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x100000000000000000000001125
	/* C6 */
	.octa 0x1030
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x3fff800000000000000000000000
	/* C28 */
	.octa 0x40000000200100050000000000001810
	/* C30 */
	.octa 0x100000000000000000000001125
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000200700060000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2d3517c2 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:2 Rn:30 Rt2:00101 imm7:1101010 L:0 1011010:1011010 opc:00
	.inst 0xc2dea05e // CLRPERM-C.CR-C Cd:30 Cn:2 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0x9ba18403 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:3 Rn:0 Ra:1 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0x423f7cdf // ASTLRB-R.R-B Rt:31 Rn:6 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c713e1 // RRLEN-R.R-C Rd:1 Rn:31 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xf8050781 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:28 01:01 imm9:001010000 0:0 opc:00 111000:111000 size:11
	.inst 0xb884ec1f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:0 11:11 imm9:001001110 0:0 opc:10 111000:111000 size:10
	.inst 0xe2adb45e // ALDUR-V.RI-S Rt:30 Rn:2 op2:01 imm9:011011011 V:1 op1:10 11100010:11100010
	.inst 0x1b18093b // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:27 Rn:9 Ra:2 o0:0 Rm:24 0011011000:0011011000 sf:0
	.inst 0xc2de294c // BICFLGS-C.CR-C Cd:12 Cn:10 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0xc2c21160
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
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac6 // ldr c6, [x22, #2]
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc24012dc // ldr c28, [x22, #4]
	.inst 0xc24016de // ldr c30, [x22, #5]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q2, =0x0
	ldr q5, =0x0
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
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603176 // ldr c22, [c11, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601176 // ldr c22, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002cb // ldr c11, [x22, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24006cb // ldr c11, [x22, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400acb // ldr c11, [x22, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400ecb // ldr c11, [x22, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc24012cb // ldr c11, [x22, #4]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc24016cb // ldr c11, [x22, #5]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc2401acb // ldr c11, [x22, #6]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc2401ecb // ldr c11, [x22, #7]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x11, v2.d[0]
	cmp x22, x11
	b.ne comparison_fail
	ldr x22, =0x0
	mov x11, v2.d[1]
	cmp x22, x11
	b.ne comparison_fail
	ldr x22, =0x0
	mov x11, v5.d[0]
	cmp x22, x11
	b.ne comparison_fail
	ldr x22, =0x0
	mov x11, v5.d[1]
	cmp x22, x11
	b.ne comparison_fail
	ldr x22, =0x0
	mov x11, v30.d[0]
	cmp x22, x11
	b.ne comparison_fail
	ldr x22, =0x0
	mov x11, v30.d[1]
	cmp x22, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001031
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001204
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017c0
	ldr x1, =check_data3
	ldr x2, =0x000017c8
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
