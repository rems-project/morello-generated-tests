.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xed, 0xaa, 0x59, 0x82, 0x40, 0x50, 0xc2, 0xc2
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0x49, 0xb7, 0xd6, 0x28, 0x44, 0xbc, 0xe2, 0x42, 0xc8, 0x2a, 0xc7, 0x9a, 0x41, 0x28, 0xde, 0xc2
	.byte 0x1a, 0xfc, 0xdf, 0x88, 0xa6, 0x90, 0xc6, 0xc2, 0x4e, 0x78, 0x7e, 0x38, 0x11, 0x60, 0xf1, 0x82
	.byte 0x80, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001000
	/* C2 */
	.octa 0x20008000d002000500000000004a0800
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x4feff8
	/* C23 */
	.octa 0xe80
	/* C26 */
	.octa 0x1ff4
	/* C30 */
	.octa 0x5f7fe
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001000
	/* C1 */
	.octa 0x20008000d002000500000000004a0800
	/* C2 */
	.octa 0x20008000d002000500000000004a0800
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0xe80
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x5f7fe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8259aaed // ASTR-R.RI-32 Rt:13 Rn:23 op:10 imm9:110011010 L:0 1000001001:1000001001
	.inst 0xc2c25040 // RET-C-C 00000:00000 Cn:2 100:100 opc:10 11000010110000100:11000010110000100
	.zero 657400
	.inst 0x28d6b749 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:9 Rn:26 Rt2:01101 imm7:0101101 L:1 1010001:1010001 opc:00
	.inst 0x42e2bc44 // LDP-C.RIB-C Ct:4 Rn:2 Ct2:01111 imm7:1000101 L:1 010000101:010000101
	.inst 0x9ac72ac8 // asrv:aarch64/instrs/integer/shift/variable Rd:8 Rn:22 op2:10 0010:0010 Rm:7 0011010110:0011010110 sf:1
	.inst 0xc2de2841 // BICFLGS-C.CR-C Cd:1 Cn:2 1010:1010 opc:00 Rm:30 11000010110:11000010110
	.inst 0x88dffc1a // ldar:aarch64/instrs/memory/ordered Rt:26 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c690a6 // CLRPERM-C.CI-C Cd:6 Cn:5 100:100 perm:100 1100001011000110:1100001011000110
	.inst 0x387e784e // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:14 Rn:2 10:10 S:1 option:011 Rm:30 1:1 opc:01 111000:111000 size:00
	.inst 0x82f16011 // ALDR-R.RRB-32 Rt:17 Rn:0 opc:00 S:0 option:011 Rm:17 1:1 L:1 100000101:100000101
	.inst 0xc2c21280
	.zero 391132
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2400e0d // ldr c13, [x16, #3]
	.inst 0xc2401211 // ldr c17, [x16, #4]
	.inst 0xc2401617 // ldr c23, [x16, #5]
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2401e1e // ldr c30, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x0
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603290 // ldr c16, [c20, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601290 // ldr c16, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400214 // ldr c20, [x16, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400614 // ldr c20, [x16, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a14 // ldr c20, [x16, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400e14 // ldr c20, [x16, #3]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2401614 // ldr c20, [x16, #5]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401a14 // ldr c20, [x16, #6]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401e14 // ldr c20, [x16, #7]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2402214 // ldr c20, [x16, #8]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2402614 // ldr c20, [x16, #9]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2402a14 // ldr c20, [x16, #10]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2402e14 // ldr c20, [x16, #11]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2403214 // ldr c20, [x16, #12]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2403614 // ldr c20, [x16, #13]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x000014e8
	ldr x1, =check_data1
	ldr x2, =0x000014ec
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff4
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004a0450
	ldr x1, =check_data4
	ldr x2, =0x004a0470
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004a0800
	ldr x1, =check_data5
	ldr x2, =0x004a0824
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff8
	ldr x1, =check_data6
	ldr x2, =0x004ffffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffe
	ldr x1, =check_data7
	ldr x2, =0x004fffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
