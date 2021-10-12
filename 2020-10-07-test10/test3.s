.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xc4, 0xef
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x60, 0x26, 0x9e, 0x5a, 0xf9, 0x23, 0xe7, 0xc2, 0xf7, 0x83, 0x53, 0xa2, 0x1e, 0x90, 0x0a, 0x78
	.byte 0x5a, 0xea, 0xc0, 0xc2, 0xd6, 0xd3, 0xe7, 0xc2, 0x81, 0x63, 0x41, 0x3a, 0x3e, 0x24, 0x8d, 0xe2
	.byte 0xde, 0xc2, 0xc1, 0xc2, 0xc8, 0xbb, 0x13, 0x9b, 0x80, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000000417c0c70000000000400002
	/* C30 */
	.octa 0xffffefc4
final_cap_values:
	/* C0 */
	.octa 0x103c
	/* C1 */
	.octa 0x800000000417c0c70000000000400002
	/* C22 */
	.octa 0x3e000000ffffefc4
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x200b
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x200b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000004004001d0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001f60
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5a9e2660 // csneg:aarch64/instrs/integer/conditional/select Rd:0 Rn:19 o2:1 0:0 cond:0010 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0xc2e723f9 // BICFLGS-C.CI-C Cd:25 Cn:31 0:0 00:00 imm8:00111001 11000010111:11000010111
	.inst 0xa25383f7 // LDUR-C.RI-C Ct:23 Rn:31 00:00 imm9:100111000 0:0 opc:01 10100010:10100010
	.inst 0x780a901e // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:0 00:00 imm9:010101001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c0ea5a // CTHI-C.CR-C Cd:26 Cn:18 1010:1010 opc:11 Rm:0 11000010110:11000010110
	.inst 0xc2e7d3d6 // EORFLGS-C.CI-C Cd:22 Cn:30 0:0 10:10 imm8:00111110 11000010111:11000010111
	.inst 0x3a416381 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0001 0:0 Rn:28 00:00 cond:0110 Rm:1 111010010:111010010 op:0 sf:0
	.inst 0xe28d243e // ALDUR-R.RI-32 Rt:30 Rn:1 op2:01 imm9:011010010 V:0 op1:10 11100010:11100010
	.inst 0xc2c1c2de // CVT-R.CC-C Rd:30 Cn:22 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x9b13bbc8 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:8 Rn:30 Ra:14 o0:1 Rm:19 0011011000:0011011000 sf:1
	.inst 0xc2c21080
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc240053e // ldr c30, [x9, #1]
	/* Set up flags and system registers */
	mov x9, #0x10000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603089 // ldr c9, [c4, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601089 // ldr c9, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x4, #0xf
	and x9, x9, x4
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc2c4a6e1 // chkeq c23, c4
	b.ne comparison_fail
	.inst 0xc2401124 // ldr c4, [x9, #4]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2401524 // ldr c4, [x9, #5]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001102
	ldr x1, =check_data0
	ldr x2, =0x00001104
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f60
	ldr x1, =check_data1
	ldr x2, =0x00001f70
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
	ldr x0, =0x004000d4
	ldr x1, =check_data3
	ldr x2, =0x004000d8
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
