.section data0, #alloc, #write
	.zero 1040
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3040
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xde, 0x67, 0xca, 0xc2, 0xca, 0x69, 0x5f, 0xe2, 0x21, 0xf0, 0x60, 0x91, 0xfb, 0xff, 0x7f, 0x42
	.byte 0xc0, 0xdb, 0x92, 0x82, 0x3f, 0xd2, 0x82, 0x1a, 0x3e, 0x22, 0x05, 0x82, 0x2b, 0x91, 0xc1, 0xc2
	.byte 0xbf, 0xbb, 0xc5, 0xc2, 0xdb, 0xc3, 0x44, 0xb3, 0x80, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x10
	/* C14 */
	.octa 0x40c946
	/* C18 */
	.octa 0xa02
	/* C29 */
	.octa 0x700060000000000000000
	/* C30 */
	.octa 0x300070080e00000000001
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffc2c2
	/* C10 */
	.octa 0xffffffffffffc2c2
	/* C14 */
	.octa 0x40c946
	/* C18 */
	.octa 0xa02
	/* C27 */
	.octa 0xc2c2c2c2c2c
	/* C29 */
	.octa 0x700060000000000000000
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
initial_SP_EL3_value:
	.octa 0x4ffff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0108000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ca67de // CPYVALUE-C.C-C Cd:30 Cn:30 001:001 opc:11 0:0 Cm:10 11000010110:11000010110
	.inst 0xe25f69ca // ALDURSH-R.RI-64 Rt:10 Rn:14 op2:10 imm9:111110110 V:0 op1:01 11100010:11100010
	.inst 0x9160f021 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:1 imm12:100000111100 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x427ffffb // ALDAR-R.R-32 Rt:27 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x8292dbc0 // ALDRSH-R.RRB-64 Rt:0 Rn:30 opc:10 S:1 option:110 Rm:18 0:0 L:0 100000101:100000101
	.inst 0x1a82d23f // csel:aarch64/instrs/integer/conditional/select Rd:31 Rn:17 o2:0 0:0 cond:1101 Rm:2 011010100:011010100 op:0 sf:0
	.inst 0x8205223e // LDR-C.I-C Ct:30 imm17:00010100100010001 1000001000:1000001000
	.inst 0xc2c1912b // CLRTAG-C.C-C Cd:11 Cn:9 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c5bbbf // SCBNDS-C.CI-C Cd:31 Cn:29 1110:1110 S:0 imm6:001011 11000010110:11000010110
	.inst 0xb344c3db // bfm:aarch64/instrs/integer/bitfield Rd:27 Rn:30 imms:110000 immr:000100 N:1 100110:100110 opc:01 sf:1
	.inst 0xc2c21080
	.zero 51472
	.inst 0x0000c2c2
	.zero 116704
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 880320
	.inst 0xc2c2c2c2
	.zero 12
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc240006a // ldr c10, [x3, #0]
	.inst 0xc240046e // ldr c14, [x3, #1]
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2400c7d // ldr c29, [x3, #3]
	.inst 0xc240107e // ldr c30, [x3, #4]
	/* Set up flags and system registers */
	mov x3, #0x40000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x3085003a
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603083 // ldr c3, [c4, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601083 // ldr c3, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x4, #0xd
	and x3, x3, x4
	cmp x3, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401064 // ldr c4, [x3, #4]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2401464 // ldr c4, [x3, #5]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2401864 // ldr c4, [x3, #6]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001414
	ldr x1, =check_data0
	ldr x2, =0x00001416
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
	ldr x0, =0x0040c93c
	ldr x1, =check_data2
	ldr x2, =0x0040c93e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00429120
	ldr x1, =check_data3
	ldr x2, =0x00429130
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff0
	ldr x1, =check_data4
	ldr x2, =0x004ffff4
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
