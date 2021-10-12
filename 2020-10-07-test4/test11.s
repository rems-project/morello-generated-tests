.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe0, 0x40, 0x7b, 0xe2, 0x01, 0x84, 0xdf, 0xc2, 0x41, 0xac, 0x51, 0xc2, 0xa2, 0xff, 0xdf, 0x48
	.byte 0xc1, 0xe6, 0xa0, 0x62, 0x12, 0x00, 0x00, 0xda, 0x3e, 0xb9, 0xab, 0x8a, 0x08, 0x94, 0xc0, 0xd8
	.byte 0x5f, 0x9b, 0xff, 0xc2, 0xe7, 0x3b, 0x40, 0xb8, 0x00, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40028000000000000000e001
	/* C2 */
	.octa 0x900000000003000700000000003fe050
	/* C7 */
	.octa 0x2000
	/* C22 */
	.octa 0x4c000000080705370000000000002010
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000005a000100000000000016ec
final_cap_values:
	/* C0 */
	.octa 0x40028000000000000000e001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C18 */
	.octa 0xffffffffffffffff
	/* C22 */
	.octa 0x4c000000080705370000000000001c20
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000005a000100000000000016ec
initial_SP_EL3_value:
	.octa 0x80000000000000000000000000000ffd
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000484000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000209180060080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe27b40e0 // ASTUR-V.RI-H Rt:0 Rn:7 op2:00 imm9:110110100 V:1 op1:01 11100010:11100010
	.inst 0xc2df8401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0xc251ac41 // LDR-C.RIB-C Ct:1 Rn:2 imm12:010001101011 L:1 110000100:110000100
	.inst 0x48dfffa2 // ldarh:aarch64/instrs/memory/ordered Rt:2 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x62a0e6c1 // STP-C.RIBW-C Ct:1 Rn:22 Ct2:11001 imm7:1000001 L:0 011000101:011000101
	.inst 0xda000012 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:18 Rn:0 000000:000000 Rm:0 11010000:11010000 S:0 op:1 sf:1
	.inst 0x8aabb93e // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:9 imm6:101110 Rm:11 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0xd8c09408 // prfm_lit:aarch64/instrs/memory/literal/general Rt:8 imm19:1100000010010100000 011000:011000 opc:11
	.inst 0xc2ff9b5f // SUBS-R.CC-C Rd:31 Cn:26 100110:100110 Cm:31 11000010111:11000010111
	.inst 0xb8403be7 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:7 Rn:31 10:10 imm9:000000011 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c21300
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
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400cb6 // ldr c22, [x5, #3]
	.inst 0xc24010b9 // ldr c25, [x5, #4]
	.inst 0xc24014ba // ldr c26, [x5, #5]
	.inst 0xc24018bd // ldr c29, [x5, #6]
	/* Vector registers */
	mrs x5, cptr_el3
	bfc x5, #10, #1
	msr cptr_el3, x5
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850032
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603305 // ldr c5, [c24, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601305 // ldr c5, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	mov x24, #0xf
	and x5, x5, x24
	cmp x5, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b8 // ldr c24, [x5, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24004b8 // ldr c24, [x5, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24008b8 // ldr c24, [x5, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400cb8 // ldr c24, [x5, #3]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24010b8 // ldr c24, [x5, #4]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24014b8 // ldr c24, [x5, #5]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc24018b8 // ldr c24, [x5, #6]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2401cb8 // ldr c24, [x5, #7]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc24020b8 // ldr c24, [x5, #8]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x24, v0.d[0]
	cmp x5, x24
	b.ne comparison_fail
	ldr x5, =0x0
	mov x24, v0.d[1]
	cmp x5, x24
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
	ldr x0, =0x000016ec
	ldr x1, =check_data1
	ldr x2, =0x000016ee
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c20
	ldr x1, =check_data2
	ldr x2, =0x00001c40
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb4
	ldr x1, =check_data3
	ldr x2, =0x00001fb6
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402700
	ldr x1, =check_data5
	ldr x2, =0x00402710
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
