.section data0, #alloc, #write
	.zero 2528
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1552
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x01, 0x5a, 0x05, 0xe2, 0xd9, 0x44, 0x22, 0x4b, 0xc1, 0x33, 0xc0, 0xc2, 0x1e, 0x08, 0x10, 0x1b
	.byte 0x1e, 0x28, 0xf3, 0xc2, 0xae, 0x01, 0xc6, 0xc2, 0x40, 0x23, 0x69, 0x82, 0x1a, 0xaf, 0xbc, 0x52
	.byte 0x6a, 0x4f, 0x4a, 0x3c, 0x9f, 0xf0, 0x0e, 0x34
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C13 */
	.octa 0x800300070000000000000000
	/* C16 */
	.octa 0x800000000207820e00000000004105ab
	/* C26 */
	.octa 0x800000000000c00000000000000010c0
	/* C27 */
	.octa 0x440000
	/* C30 */
	.octa 0x4000000000000007ffffe000
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C1 */
	.octa 0x0
	/* C13 */
	.octa 0x800300070000000000000000
	/* C16 */
	.octa 0x800000000207820e00000000004105ab
	/* C26 */
	.octa 0xe5780000
	/* C27 */
	.octa 0x4400a4
	/* C30 */
	.octa 0x9900000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000f400b0000000000500001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000019e0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2055a01 // ALDURSB-R.RI-64 Rt:1 Rn:16 op2:10 imm9:001010101 V:0 op1:00 11100010:11100010
	.inst 0x4b2244d9 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:25 Rn:6 imm3:001 option:010 Rm:2 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c033c1 // GCLEN-R.C-C Rd:1 Cn:30 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x1b10081e // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:0 Ra:2 o0:0 Rm:16 0011011000:0011011000 sf:0
	.inst 0xc2f3281e // ORRFLGS-C.CI-C Cd:30 Cn:0 0:0 01:01 imm8:10011001 11000010111:11000010111
	.inst 0xc2c601ae // SCBNDS-C.CR-C Cd:14 Cn:13 000:000 opc:00 0:0 Rm:6 11000010110:11000010110
	.inst 0x82692340 // ALDR-C.RI-C Ct:0 Rn:26 op:00 imm9:010010010 L:1 1000001001:1000001001
	.inst 0x52bcaf1a // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:26 imm16:1110010101111000 hw:01 100101:100101 opc:10 sf:0
	.inst 0x3c4a4f6a // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:10 Rn:27 11:11 imm9:010100100 0:0 opc:01 111100:111100 size:00
	.inst 0x340ef09f // cbz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:0000111011110000100 op:0 011010:011010 sf:0
	.zero 67032
	.inst 0x000000c2
	.zero 55344
	.inst 0xc2c21260
	.zero 139884
	.inst 0x000000c2
	.zero 786264
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc240048d // ldr c13, [x4, #1]
	.inst 0xc2400890 // ldr c16, [x4, #2]
	.inst 0xc2400c9a // ldr c26, [x4, #3]
	.inst 0xc240109b // ldr c27, [x4, #4]
	.inst 0xc240149e // ldr c30, [x4, #5]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603264 // ldr c4, [c19, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x82601264 // ldr c4, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400093 // ldr c19, [x4, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400493 // ldr c19, [x4, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400893 // ldr c19, [x4, #2]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2400c93 // ldr c19, [x4, #3]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401093 // ldr c19, [x4, #4]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2401493 // ldr c19, [x4, #5]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2401893 // ldr c19, [x4, #6]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0xc2
	mov x19, v10.d[0]
	cmp x4, x19
	b.ne comparison_fail
	ldr x4, =0x0
	mov x19, v10.d[1]
	cmp x4, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000019e0
	ldr x1, =check_data0
	ldr x2, =0x000019f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00410600
	ldr x1, =check_data2
	ldr x2, =0x00410601
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0041de34
	ldr x1, =check_data3
	ldr x2, =0x0041de38
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004400a4
	ldr x1, =check_data4
	ldr x2, =0x004400a5
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
