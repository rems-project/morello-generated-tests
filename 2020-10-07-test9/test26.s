.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0x60, 0xf4
.data
check_data3:
	.byte 0xe6, 0x67, 0x51, 0x78, 0x46, 0xf0, 0xc5, 0xc2, 0x3e, 0xf0, 0x9b, 0xb9, 0x1e, 0xd4, 0xd1, 0xac
	.byte 0x9f, 0x31, 0xc5, 0xc2, 0x01, 0x30, 0xc2, 0xc2, 0x01, 0x74, 0x06, 0x78, 0xc1, 0xa7, 0xcc, 0xc2
	.byte 0xe5, 0xba, 0x82, 0xd8, 0xd7, 0x8e, 0xf4, 0xd2, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001dc0
	/* C1 */
	.octa 0x8000000000010005fffffffffffff460
	/* C2 */
	.octa 0x100000000000000
	/* C12 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000002057
	/* C1 */
	.octa 0x8000000000010005fffffffffffff460
	/* C2 */
	.octa 0x100000000000000
	/* C6 */
	.octa 0x20008000200000080100000000000000
	/* C12 */
	.octa 0x1
	/* C23 */
	.octa 0xa476000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000001000700000000004582f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x785167e6 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:31 01:01 imm9:100010110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c5f046 // CVTPZ-C.R-C Cd:6 Rn:2 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xb99bf03e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:011011111100 opc:10 111001:111001 size:10
	.inst 0xacd1d41e // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:30 Rn:0 Rt2:10101 imm7:0100011 L:1 1011001:1011001 opc:10
	.inst 0xc2c5319f // CVTP-R.C-C Rd:31 Cn:12 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x78067401 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:0 01:01 imm9:001100111 0:0 opc:00 111000:111000 size:01
	.inst 0xc2cca7c1 // CHKEQ-_.CC-C 00001:00001 Cn:30 001:001 opc:01 1:1 Cm:12 11000010110:11000010110
	.inst 0xd882bae5 // prfm_lit:aarch64/instrs/memory/literal/general Rt:5 imm19:1000001010111010111 011000:011000 opc:11
	.inst 0xd2f48ed7 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:23 imm16:1010010001110110 hw:11 100101:100101 opc:10 sf:1
	.inst 0xc2c21200
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
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a2 // ldr c2, [x5, #2]
	.inst 0xc2400cac // ldr c12, [x5, #3]
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
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601205 // ldr c5, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x16, #0xf
	and x5, x5, x16
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b0 // ldr c16, [x5, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24004b0 // ldr c16, [x5, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24008b0 // ldr c16, [x5, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400cb0 // ldr c16, [x5, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc24010b0 // ldr c16, [x5, #4]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24014b0 // ldr c16, [x5, #5]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc24018b0 // ldr c16, [x5, #6]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x16, v21.d[0]
	cmp x5, x16
	b.ne comparison_fail
	ldr x5, =0x0
	mov x16, v21.d[1]
	cmp x5, x16
	b.ne comparison_fail
	ldr x5, =0x0
	mov x16, v30.d[0]
	cmp x5, x16
	b.ne comparison_fail
	ldr x5, =0x0
	mov x16, v30.d[1]
	cmp x5, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001050
	ldr x1, =check_data0
	ldr x2, =0x00001054
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001dc0
	ldr x1, =check_data1
	ldr x2, =0x00001de0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff2
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
	ldr x0, =0x004582f0
	ldr x1, =check_data4
	ldr x2, =0x004582f2
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
