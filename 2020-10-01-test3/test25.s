.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x42, 0x0f
.data
check_data5:
	.byte 0x30, 0x2c, 0x01, 0xbc, 0x4a, 0x80, 0x2c, 0xfd, 0x28, 0xa8, 0x55, 0x78, 0xff, 0xa3, 0x67, 0xf9
	.byte 0x22, 0xe4, 0x5b, 0xa2, 0x20, 0x78, 0x64, 0xa2, 0xc2, 0x6a, 0x7f, 0x78, 0x5c, 0xc8, 0x0e, 0x38
	.byte 0xc3, 0x2f, 0xee, 0x22, 0x00, 0x7c, 0xdf, 0x48, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data6:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x10ee
	/* C2 */
	.octa 0xffffffffffffc100
	/* C4 */
	.octa 0x3fff2
	/* C22 */
	.octa 0x1a02
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xce0
	/* C2 */
	.octa 0x1000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x3fff2
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x100800000000000000000000000
	/* C22 */
	.octa 0x1a02
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xdc0
initial_csp_value:
	.octa 0x3fc000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000016000700ffffffffffffe0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xbc012c30 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:16 Rn:1 11:11 imm9:000010010 0:0 opc:00 111100:111100 size:10
	.inst 0xfd2c804a // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:10 Rn:2 imm12:101100100000 opc:00 111101:111101 size:11
	.inst 0x7855a828 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:8 Rn:1 10:10 imm9:101011010 0:0 opc:01 111000:111000 size:01
	.inst 0xf967a3ff // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:100111101000 opc:01 111001:111001 size:11
	.inst 0xa25be422 // LDR-C.RIAW-C Ct:2 Rn:1 01:01 imm9:110111110 0:0 opc:01 10100010:10100010
	.inst 0xa2647820 // LDR-C.RRB-C Ct:0 Rn:1 10:10 S:1 option:011 Rm:4 1:1 opc:01 10100010:10100010
	.inst 0x787f6ac2 // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:22 10:10 S:0 option:011 Rm:31 1:1 opc:01 111000:111000 size:01
	.inst 0x380ec85c // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:28 Rn:2 10:10 imm9:011101100 0:0 opc:00 111000:111000 size:00
	.inst 0x22ee2fc3 // LDP-CC.RIAW-C Ct:3 Rn:30 Ct2:01011 imm7:1011100 L:1 001000101:001000101
	.inst 0x48df7c00 // ldlarh:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c210a0
	.zero 3028
	.inst 0x00001000
	.zero 1045500
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a64 // ldr c4, [x19, #2]
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc240127c // ldr c28, [x19, #4]
	.inst 0xc240167e // ldr c30, [x19, #5]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q10, =0xf42000010000000
	ldr q16, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_csp_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085003a
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b3 // ldr c19, [c5, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x826010b3 // ldr c19, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400265 // ldr c5, [x19, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2401265 // ldr c5, [x19, #4]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401665 // ldr c5, [x19, #5]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401a65 // ldr c5, [x19, #6]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401e65 // ldr c5, [x19, #7]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402265 // ldr c5, [x19, #8]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2402665 // ldr c5, [x19, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0xf42000010000000
	mov x5, v10.d[0]
	cmp x19, x5
	b.ne comparison_fail
	ldr x19, =0x0
	mov x5, v10.d[1]
	cmp x19, x5
	b.ne comparison_fail
	ldr x19, =0x0
	mov x5, v16.d[0]
	cmp x19, x5
	b.ne comparison_fail
	ldr x19, =0x0
	mov x5, v16.d[1]
	cmp x19, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000105a
	ldr x1, =check_data1
	ldr x2, =0x0000105c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010ec
	ldr x1, =check_data2
	ldr x2, =0x000010ed
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001100
	ldr x1, =check_data3
	ldr x2, =0x00001110
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001a00
	ldr x1, =check_data4
	ldr x2, =0x00001a08
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
	ldr x0, =0x00400c00
	ldr x1, =check_data6
	ldr x2, =0x00400c10
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400f40
	ldr x1, =check_data7
	ldr x2, =0x00400f48
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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
