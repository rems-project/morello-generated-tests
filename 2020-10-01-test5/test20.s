.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x80, 0x09, 0xc1, 0x1a, 0xa2, 0xf2, 0xc0, 0xc2, 0x10, 0x34, 0x1a, 0xfc, 0xa0, 0x69, 0x7e, 0xa2
	.byte 0x1f, 0xe7, 0x41, 0x78, 0xdf, 0xa8, 0xef, 0xc2, 0xf7, 0x05, 0xc2, 0xc2, 0xaa, 0x46, 0x4b, 0x34
	.byte 0xa1, 0x17, 0x40, 0xb8, 0x3e, 0x92, 0x55, 0xb8, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0xffffffff
	/* C13 */
	.octa 0x10
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x1003
	/* C24 */
	.octa 0xc00
	/* C29 */
	.octa 0x7f8
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0xffffffff
	/* C13 */
	.octa 0x10
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x1003
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0xc1e
	/* C29 */
	.octa 0x7f9
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000107002000fffffffffff0f0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1ac10980 // udiv:aarch64/instrs/integer/arithmetic/div Rd:0 Rn:12 o1:0 00001:00001 Rm:1 0011010110:0011010110 sf:0
	.inst 0xc2c0f2a2 // GCTYPE-R.C-C Rd:2 Cn:21 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xfc1a3410 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:16 Rn:0 01:01 imm9:110100011 0:0 opc:00 111100:111100 size:11
	.inst 0xa27e69a0 // LDR-C.RRB-C Ct:0 Rn:13 10:10 S:0 option:011 Rm:30 1:1 opc:01 10100010:10100010
	.inst 0x7841e71f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:24 01:01 imm9:000011110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2efa8df // ORRFLGS-C.CI-C Cd:31 Cn:6 0:0 01:01 imm8:01111101 11000010111:11000010111
	.inst 0xc2c205f7 // BUILD-C.C-C Cd:23 Cn:15 001:001 opc:00 0:0 Cm:2 11000010110:11000010110
	.inst 0x344b46aa // cbz:aarch64/instrs/branch/conditional/compare Rt:10 imm19:0100101101000110101 op:0 011010:011010 sf:0
	.inst 0xb84017a1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:29 01:01 imm9:000000001 0:0 opc:01 111000:111000 size:10
	.inst 0xb855923e // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:17 00:00 imm9:101011001 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c21360
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400526 // ldr c6, [x9, #1]
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2400d2d // ldr c13, [x9, #3]
	.inst 0xc240112f // ldr c15, [x9, #4]
	.inst 0xc2401531 // ldr c17, [x9, #5]
	.inst 0xc2401938 // ldr c24, [x9, #6]
	.inst 0xc2401d3d // ldr c29, [x9, #7]
	.inst 0xc240213e // ldr c30, [x9, #8]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q16, =0x1000000000
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603369 // ldr c9, [c27, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x82601369 // ldr c9, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013b // ldr c27, [x9, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240053b // ldr c27, [x9, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240093b // ldr c27, [x9, #2]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc2400d3b // ldr c27, [x9, #3]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc240113b // ldr c27, [x9, #4]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240153b // ldr c27, [x9, #5]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc240193b // ldr c27, [x9, #6]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc2401d3b // ldr c27, [x9, #7]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240213b // ldr c27, [x9, #8]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240253b // ldr c27, [x9, #9]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240293b // ldr c27, [x9, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x1000000000
	mov x27, v16.d[0]
	cmp x9, x27
	b.ne comparison_fail
	ldr x9, =0x0
	mov x27, v16.d[1]
	cmp x9, x27
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x000017fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c02
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f5c
	ldr x1, =check_data4
	ldr x2, =0x00001f60
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
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
