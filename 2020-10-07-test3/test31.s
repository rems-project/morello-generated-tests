.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xa1, 0xea, 0x3e, 0x38, 0x9e, 0x49, 0xc1, 0xc2, 0x54, 0x7c, 0x3f, 0x42, 0xe1, 0x6b, 0x90, 0xeb
	.byte 0x52, 0x40, 0x25, 0xe2, 0x20, 0xd0, 0xc0, 0xc2, 0x20, 0xfd, 0x9f, 0x08, 0x01, 0x59, 0xff, 0x38
	.byte 0x21, 0x10, 0xc2, 0xc2, 0x4e, 0x28, 0xd7, 0x9a, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x10000000007000f0000000000000000
	/* C2 */
	.octa 0x1080
	/* C8 */
	.octa 0x80000000000700070000000000403000
	/* C9 */
	.octa 0x40000000000700270000000000001000
	/* C12 */
	.octa 0x800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x40000000540204120000000000000004
	/* C30 */
	.octa 0x13be
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1080
	/* C8 */
	.octa 0x80000000000700070000000000403000
	/* C9 */
	.octa 0x40000000000700270000000000001000
	/* C12 */
	.octa 0x800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x40000000540204120000000000000004
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000200100050006800000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x383eeaa1 // strb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:21 10:10 S:0 option:111 Rm:30 1:1 opc:00 111000:111000 size:00
	.inst 0xc2c1499e // UNSEAL-C.CC-C Cd:30 Cn:12 0010:0010 opc:01 Cm:1 11000010110:11000010110
	.inst 0x423f7c54 // ASTLRB-R.R-B Rt:20 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xeb906be1 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:31 imm6:011010 Rm:16 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xe2254052 // ASTUR-V.RI-B Rt:18 Rn:2 op2:00 imm9:001010100 V:1 op1:00 11100010:11100010
	.inst 0xc2c0d020 // GCPERM-R.C-C Rd:0 Cn:1 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x089ffd20 // stlrb:aarch64/instrs/memory/ordered Rt:0 Rn:9 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x38ff5901 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:8 10:10 S:1 option:010 Rm:31 1:1 opc:11 111000:111000 size:00
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x9ad7284e // asrv:aarch64/instrs/integer/shift/variable Rd:14 Rn:2 op2:10 0010:0010 Rm:23 0011010110:0011010110 sf:1
	.inst 0xc2c21160
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
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400948 // ldr c8, [x10, #2]
	.inst 0xc2400d49 // ldr c9, [x10, #3]
	.inst 0xc240114c // ldr c12, [x10, #4]
	.inst 0xc2401554 // ldr c20, [x10, #5]
	.inst 0xc2401955 // ldr c21, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q18, =0x0
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316a // ldr c10, [c11, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260116a // ldr c10, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x10, x10, x11
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014b // ldr c11, [x10, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240054b // ldr c11, [x10, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240094b // ldr c11, [x10, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240114b // ldr c11, [x10, #4]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc240154b // ldr c11, [x10, #5]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240194b // ldr c11, [x10, #6]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2401d4b // ldr c11, [x10, #7]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240214b // ldr c11, [x10, #8]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x11, v18.d[0]
	cmp x10, x11
	b.ne comparison_fail
	ldr x10, =0x0
	mov x11, v18.d[1]
	cmp x10, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001081
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d4
	ldr x1, =check_data2
	ldr x2, =0x000010d5
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013c2
	ldr x1, =check_data3
	ldr x2, =0x000013c3
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
	ldr x0, =0x00403000
	ldr x1, =check_data5
	ldr x2, =0x00403001
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
