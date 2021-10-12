.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x2b, 0xf0, 0xc0, 0xc2, 0x7e, 0x0f, 0xd5, 0x1a, 0x3d, 0xa1, 0xe8, 0xc2, 0x40, 0x7c, 0x9f, 0x48
	.byte 0x47, 0x64, 0x5f, 0xfc, 0x5e, 0x24, 0x4d, 0x92, 0x02, 0xa3, 0xdf, 0xc2, 0x2b, 0xa4, 0x76, 0xe2
	.byte 0xfe, 0x0f, 0x53, 0xe2, 0x51, 0x48, 0x2e, 0xf2, 0x40, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400192
	/* C2 */
	.octa 0xc00000000000a0080000000000001ff0
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x2000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400192
	/* C2 */
	.octa 0x2000000
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x2000000
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x2000000
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x400400
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000d03000000f0000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f02b // GCTYPE-R.C-C Rd:11 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x1ad50f7e // sdiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:27 o1:1 00001:00001 Rm:21 0011010110:0011010110 sf:0
	.inst 0xc2e8a13d // BICFLGS-C.CI-C Cd:29 Cn:9 0:0 00:00 imm8:01000101 11000010111:11000010111
	.inst 0x489f7c40 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xfc5f6447 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:7 Rn:2 01:01 imm9:111110110 0:0 opc:01 111100:111100 size:11
	.inst 0x924d245e // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:2 imms:001001 immr:001101 N:1 100100:100100 opc:00 sf:1
	.inst 0xc2dfa302 // CLRPERM-C.CR-C Cd:2 Cn:24 000:000 1:1 10:10 Rm:31 11000010110:11000010110
	.inst 0xe276a42b // ALDUR-V.RI-H Rt:11 Rn:1 op2:01 imm9:101101010 V:1 op1:01 11100010:11100010
	.inst 0xe2530ffe // ALDURSH-R.RI-32 Rt:30 Rn:31 op2:11 imm9:100110000 V:0 op1:01 11100010:11100010
	.inst 0xf22e4851 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:17 Rn:2 imms:010010 immr:101110 N:0 100100:100100 opc:11 sf:1
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f89 // ldr c9, [x28, #3]
	.inst 0xc2401395 // ldr c21, [x28, #4]
	.inst 0xc2401798 // ldr c24, [x28, #5]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_csp_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260325c // ldr c28, [c18, #3]
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	.inst 0x8260125c // ldr c28, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x18, #0xf
	and x28, x28, x18
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400392 // ldr c18, [x28, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400792 // ldr c18, [x28, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400b92 // ldr c18, [x28, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400f92 // ldr c18, [x28, #3]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401392 // ldr c18, [x28, #4]
	.inst 0xc2d2a561 // chkeq c11, c18
	b.ne comparison_fail
	.inst 0xc2401792 // ldr c18, [x28, #5]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2401b92 // ldr c18, [x28, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401f92 // ldr c18, [x28, #7]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc2402392 // ldr c18, [x28, #8]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402792 // ldr c18, [x28, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x18, v7.d[0]
	cmp x28, x18
	b.ne comparison_fail
	ldr x28, =0x0
	mov x18, v7.d[1]
	cmp x28, x18
	b.ne comparison_fail
	ldr x28, =0x0
	mov x18, v11.d[0]
	cmp x28, x18
	b.ne comparison_fail
	ldr x28, =0x0
	mov x18, v11.d[1]
	cmp x28, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff8
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004000fc
	ldr x1, =check_data2
	ldr x2, =0x004000fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400330
	ldr x1, =check_data3
	ldr x2, =0x00400332
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
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
