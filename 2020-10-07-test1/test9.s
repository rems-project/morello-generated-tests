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
	.zero 4
.data
check_data3:
	.byte 0xdf, 0x2b, 0x02, 0xa2, 0x0f, 0x7c, 0x41, 0x9b, 0xff, 0xa7, 0x5f, 0xf8, 0x0c, 0xdc, 0x0d, 0x3c
	.byte 0x5f, 0x00, 0x21, 0x9b, 0x61, 0x19, 0xe0, 0xc2, 0x2d, 0x88, 0x82, 0xb9, 0x3f, 0xc4, 0xf7, 0x28
	.byte 0x42, 0x60, 0x6c, 0xa8, 0x0a, 0xfc, 0x9f, 0x48, 0x00, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf83
	/* C2 */
	.octa 0x400408
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x700920820000000000000001
	/* C30 */
	.octa 0xe20
final_cap_values:
	/* C0 */
	.octa 0x1060
	/* C1 */
	.octa 0x101c
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x700920820000000000000001
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0xe20
initial_SP_EL3_value:
	.octa 0x400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500900000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000001fb000700ffe00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2022bdf // STTR-C.RIB-C Ct:31 Rn:30 10:10 imm9:000100010 0:0 opc:00 10100010:10100010
	.inst 0x9b417c0f // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:15 Rn:0 Ra:11111 0:0 Rm:1 10:10 U:0 10011011:10011011
	.inst 0xf85fa7ff // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:31 01:01 imm9:111111010 0:0 opc:01 111000:111000 size:11
	.inst 0x3c0ddc0c // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:12 Rn:0 11:11 imm9:011011101 0:0 opc:00 111100:111100 size:00
	.inst 0x9b21005f // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:2 Ra:0 o0:0 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xc2e01961 // CVT-C.CR-C Cd:1 Cn:11 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0xb982882d // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:13 Rn:1 imm12:000010100010 opc:10 111001:111001 size:10
	.inst 0x28f7c43f // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:1 Rt2:10001 imm7:1101111 L:1 1010001:1010001 opc:00
	.inst 0xa86c6042 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:2 Rn:2 Rt2:11000 imm7:1011000 L:1 1010000:1010000 opc:10
	.inst 0x489ffc0a // stlrh:aarch64/instrs/memory/ordered Rt:10 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c21100
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a2 // ldr c2, [x5, #1]
	.inst 0xc24008aa // ldr c10, [x5, #2]
	.inst 0xc2400cab // ldr c11, [x5, #3]
	.inst 0xc24010be // ldr c30, [x5, #4]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q12, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850038
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603105 // ldr c5, [c8, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601105 // ldr c5, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000a8 // ldr c8, [x5, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24008a8 // ldr c8, [x5, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400ca8 // ldr c8, [x5, #3]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc24010a8 // ldr c8, [x5, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc24014a8 // ldr c8, [x5, #5]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc24018a8 // ldr c8, [x5, #6]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2401ca8 // ldr c8, [x5, #7]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc24020a8 // ldr c8, [x5, #8]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x8, v12.d[0]
	cmp x5, x8
	b.ne comparison_fail
	ldr x5, =0x0
	mov x8, v12.d[1]
	cmp x5, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001050
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001068
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012e8
	ldr x1, =check_data2
	ldr x2, =0x000012ec
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004002c8
	ldr x1, =check_data4
	ldr x2, =0x004002d8
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
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
