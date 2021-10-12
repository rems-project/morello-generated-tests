.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x14, 0x0c, 0xc5, 0x9a, 0xff, 0x6e, 0x94, 0xe2, 0x43, 0x02, 0xdb, 0xe2, 0xd6, 0xd0, 0xc1, 0xc2
	.byte 0x15, 0x15, 0x9f, 0x4a, 0x61, 0x12, 0xc2, 0xc2, 0xff, 0x8f, 0x35, 0x31, 0xe2, 0xb6, 0x16, 0x8b
	.byte 0x44, 0x10, 0xc7, 0xc2, 0x41, 0x84, 0xdf, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C18 */
	.octa 0x90c
	/* C19 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x1d6
final_cap_values:
	/* C2 */
	.octa 0x1d6
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x1d6
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C18 */
	.octa 0x90c
	/* C19 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x1d6
initial_SP_EL3_value:
	.octa 0x70000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000442200000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004002108400ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac50c14 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:20 Rn:0 o1:1 00001:00001 Rm:5 0011010110:0011010110 sf:1
	.inst 0xe2946eff // ASTUR-C.RI-C Ct:31 Rn:23 op2:11 imm9:101000110 V:0 op1:10 11100010:11100010
	.inst 0xe2db0243 // ASTUR-R.RI-64 Rt:3 Rn:18 op2:00 imm9:110110000 V:0 op1:11 11100010:11100010
	.inst 0xc2c1d0d6 // CPY-C.C-C Cd:22 Cn:6 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x4a9f1515 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:21 Rn:8 imm6:000101 Rm:31 N:0 shift:10 01010:01010 opc:10 sf:0
	.inst 0xc2c21261 // CHKSLD-C-C 00001:00001 Cn:19 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x31358fff // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:31 imm12:110101100011 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x8b16b6e2 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:23 imm6:101101 Rm:22 0:0 shift:00 01011:01011 S:0 op:0 sf:1
	.inst 0xc2c71044 // RRLEN-R.R-C Rd:4 Rn:2 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xc2df8441 // CHKSS-_.CC-C 00001:00001 Cn:2 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400223 // ldr c3, [x17, #0]
	.inst 0xc2400625 // ldr c5, [x17, #1]
	.inst 0xc2400a26 // ldr c6, [x17, #2]
	.inst 0xc2400e32 // ldr c18, [x17, #3]
	.inst 0xc2401233 // ldr c19, [x17, #4]
	.inst 0xc2401637 // ldr c23, [x17, #5]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603131 // ldr c17, [c9, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601131 // ldr c17, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x9, #0xf
	and x17, x17, x9
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400229 // ldr c9, [x17, #0]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400629 // ldr c9, [x17, #1]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400a29 // ldr c9, [x17, #2]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2400e29 // ldr c9, [x17, #3]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401229 // ldr c9, [x17, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401629 // ldr c9, [x17, #5]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401a29 // ldr c9, [x17, #6]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401e29 // ldr c9, [x17, #7]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402229 // ldr c9, [x17, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402629 // ldr c9, [x17, #9]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011a0
	ldr x1, =check_data0
	ldr x2, =0x000011b0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001940
	ldr x1, =check_data1
	ldr x2, =0x00001948
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
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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
