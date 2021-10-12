.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xf6, 0x63, 0xd4, 0x38, 0xe5, 0x7f, 0x1f, 0x42, 0x5e, 0x6c, 0x56, 0xb8, 0x20, 0x00, 0x5f, 0xd6
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xa0, 0xfd, 0xdf, 0x48, 0x7f, 0x5c, 0x7e, 0xca, 0xc1, 0x72, 0xc6, 0xc2, 0x11, 0x70, 0x84, 0x5a
	.byte 0x9f, 0x49, 0xc0, 0xc2, 0xa0, 0xa9, 0xfe, 0xc2, 0x60, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x410000
	/* C2 */
	.octa 0x80000000200000000000000000448002
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x800000000007000f0000000000402000
final_cap_values:
	/* C0 */
	.octa 0x800000000007000ff500000000402000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000200000000000000000447f68
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x800000000007000f0000000000402000
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000080100000000000001100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000007000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38d463f6 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:22 Rn:31 00:00 imm9:101000110 0:0 opc:11 111000:111000 size:00
	.inst 0x421f7fe5 // ASTLR-C.R-C Ct:5 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0xb8566c5e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:2 11:11 imm9:101100110 0:0 opc:01 111000:111000 size:10
	.inst 0xd65f0020 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 65520
	.inst 0x48dffda0 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:13 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xca7e5c7f // eon:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:3 imm6:010111 Rm:30 N:1 shift:01 01010:01010 opc:10 sf:1
	.inst 0xc2c672c1 // CLRPERM-C.CI-C Cd:1 Cn:22 100:100 perm:011 1100001011000110:1100001011000110
	.inst 0x5a847011 // csinv:aarch64/instrs/integer/conditional/select Rd:17 Rn:0 o2:0 0:0 cond:0111 Rm:4 011010100:011010100 op:1 sf:0
	.inst 0xc2c0499f // UNSEAL-C.CC-C Cd:31 Cn:12 0010:0010 opc:01 Cm:0 11000010110:11000010110
	.inst 0xc2fea9a0 // ORRFLGS-C.CI-C Cd:0 Cn:13 0:0 01:01 imm8:11110101 11000010111:11000010111
	.inst 0xc2c21160
	.zero 983012
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc240110d // ldr c13, [x8, #4]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850032
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603168 // ldr c8, [c11, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601168 // ldr c8, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x11, #0x1
	and x8, x8, x11
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010b // ldr c11, [x8, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240050b // ldr c11, [x8, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240090b // ldr c11, [x8, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400d0b // ldr c11, [x8, #3]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc240110b // ldr c11, [x8, #4]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240150b // ldr c11, [x8, #5]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240190b // ldr c11, [x8, #6]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2401d0b // ldr c11, [x8, #7]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc240210b // ldr c11, [x8, #8]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001046
	ldr x1, =check_data0
	ldr x2, =0x00001047
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402000
	ldr x1, =check_data3
	ldr x2, =0x00402002
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00410000
	ldr x1, =check_data4
	ldr x2, =0x0041001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00447f68
	ldr x1, =check_data5
	ldr x2, =0x00447f6c
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
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
