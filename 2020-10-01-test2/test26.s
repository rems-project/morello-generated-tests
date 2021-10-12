.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x35, 0xac, 0x81, 0xb8, 0xc0, 0x7f, 0x59, 0x9b, 0x00, 0x04, 0xc0, 0x5a, 0x22, 0xda, 0xcd, 0xc2
	.byte 0x04, 0xd0, 0xc0, 0xc2, 0x60, 0x1a, 0xc0, 0xc2, 0x26, 0xe8, 0x3f, 0x78, 0xec, 0x7f, 0xdf, 0x48
	.byte 0xfc, 0x93, 0x85, 0xac, 0xbf, 0x15, 0x0c, 0xe2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000700070000000000001006
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C17 */
	.octa 0x410201020000000017ffe000
	/* C19 */
	.octa 0x4001080100000007ffffe001
final_cap_values:
	/* C0 */
	.octa 0x4001080100000007ffffe001
	/* C1 */
	.octa 0xc0000000000700070000000000001020
	/* C2 */
	.octa 0x410201020000000018000000
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x1000
	/* C17 */
	.octa 0x410201020000000017ffe000
	/* C19 */
	.octa 0x4001080100000007ffffe001
	/* C21 */
	.octa 0x0
initial_csp_value:
	.octa 0xc0000000000100070000000000001010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000700cf00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb881ac35 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:21 Rn:1 11:11 imm9:000011010 0:0 opc:10 111000:111000 size:10
	.inst 0x9b597fc0 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:30 Ra:11111 0:0 Rm:25 10:10 U:0 10011011:10011011
	.inst 0x5ac00400 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:0 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2cdda22 // ALIGNU-C.CI-C Cd:2 Cn:17 0110:0110 U:1 imm6:011011 11000010110:11000010110
	.inst 0xc2c0d004 // GCPERM-R.C-C Rd:4 Cn:0 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c01a60 // ALIGND-C.CI-C Cd:0 Cn:19 0110:0110 U:0 imm6:000000 11000010110:11000010110
	.inst 0x783fe826 // strh_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:1 10:10 S:0 option:111 Rm:31 1:1 opc:00 111000:111000 size:01
	.inst 0x48df7fec // ldlarh:aarch64/instrs/memory/ordered Rt:12 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xac8593fc // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:28 Rn:31 Rt2:00100 imm7:0001011 L:0 1011001:1011001 opc:10
	.inst 0xe20c15bf // ALDURB-R.RI-32 Rt:31 Rn:13 op2:01 imm9:011000001 V:0 op1:00 11100010:11100010
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x20, cptr_el3
	orr x20, x20, #0x200
	msr cptr_el3, x20
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc2400686 // ldr c6, [x20, #1]
	.inst 0xc2400a8d // ldr c13, [x20, #2]
	.inst 0xc2400e91 // ldr c17, [x20, #3]
	.inst 0xc2401293 // ldr c19, [x20, #4]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q4, =0x0
	ldr q28, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_csp_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f4 // ldr c20, [c23, #3]
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	.inst 0x826012f4 // ldr c20, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400297 // ldr c23, [x20, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400697 // ldr c23, [x20, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a97 // ldr c23, [x20, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e97 // ldr c23, [x20, #3]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401297 // ldr c23, [x20, #4]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401697 // ldr c23, [x20, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401a97 // ldr c23, [x20, #6]
	.inst 0xc2d7a5a1 // chkeq c13, c23
	b.ne comparison_fail
	.inst 0xc2401e97 // ldr c23, [x20, #7]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2402297 // ldr c23, [x20, #8]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402697 // ldr c23, [x20, #9]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x23, v4.d[0]
	cmp x20, x23
	b.ne comparison_fail
	ldr x20, =0x0
	mov x23, v4.d[1]
	cmp x20, x23
	b.ne comparison_fail
	ldr x20, =0x0
	mov x23, v28.d[0]
	cmp x20, x23
	b.ne comparison_fail
	ldr x20, =0x0
	mov x23, v28.d[1]
	cmp x20, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c1
	ldr x1, =check_data1
	ldr x2, =0x000010c2
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr ddc_el3, c20
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
