.section data0, #alloc, #write
	.zero 32
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 4048
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xe3, 0x83, 0xdf, 0xc2, 0x4c, 0xac, 0x44, 0xa2, 0x40, 0x98, 0xe2, 0xc2, 0x41, 0x50, 0xc1, 0xc2
	.byte 0xe1, 0xff, 0xdf, 0x88, 0x28, 0x60, 0x5e, 0x3a, 0x3f, 0x80, 0xd2, 0xc2, 0xfe, 0x9b, 0xeb, 0xc2
	.byte 0x5f, 0xfe, 0x7d, 0x91, 0x3b, 0x50, 0xc1, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000100070000000000000b80
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc2c2c2c2
	/* C2 */
	.octa 0x80000000000100070000000000001020
	/* C3 */
	.octa 0x800000000001000500000000004ffff8
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C18 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x3
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004ffff8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df83e3 // SCTAG-C.CR-C Cd:3 Cn:31 000:000 0:0 10:10 Rm:31 11000010110:11000010110
	.inst 0xa244ac4c // LDR-C.RIBW-C Ct:12 Rn:2 11:11 imm9:001001010 0:0 opc:01 10100010:10100010
	.inst 0xc2e29840 // SUBS-R.CC-C Rd:0 Cn:2 100110:100110 Cm:2 11000010111:11000010111
	.inst 0xc2c15041 // CFHI-R.C-C Rd:1 Cn:2 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x88dfffe1 // ldar:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x3a5e6028 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1000 0:0 Rn:1 00:00 cond:0110 Rm:30 111010010:111010010 op:0 sf:0
	.inst 0xc2d2803f // SCTAG-C.CR-C Cd:31 Cn:1 000:000 0:0 10:10 Rm:18 11000010110:11000010110
	.inst 0xc2eb9bfe // SUBS-R.CC-C Rd:30 Cn:31 100110:100110 Cm:11 11000010111:11000010111
	.inst 0x917dfe5f // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:18 imm12:111101111111 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xc2c1503b // CFHI-R.C-C Rd:27 Cn:1 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c21080
	.zero 1048524
	.inst 0xc2c2c2c2
	.zero 4
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400302 // ldr c2, [x24, #0]
	.inst 0xc240070b // ldr c11, [x24, #1]
	.inst 0xc2400b12 // ldr c18, [x24, #2]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601098 // ldr c24, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x4, #0xf
	and x24, x24, x4
	cmp x24, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400304 // ldr c4, [x24, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400704 // ldr c4, [x24, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2401304 // ldr c4, [x24, #4]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401704 // ldr c4, [x24, #5]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2401b04 // ldr c4, [x24, #6]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2401f04 // ldr c4, [x24, #7]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402304 // ldr c4, [x24, #8]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001030
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
	ldr x0, =0x004ffff8
	ldr x1, =check_data2
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
