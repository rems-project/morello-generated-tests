.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x5f, 0x19, 0xd3, 0xc2, 0x62, 0xbb, 0xef, 0xca, 0xc2, 0xd7, 0x75, 0x69, 0x05, 0xb0, 0xc0, 0xc2
	.byte 0x28, 0x08, 0xd2, 0x29, 0x3f, 0x70, 0xc9, 0x62, 0x81, 0x33, 0xc2, 0xc2, 0xc2, 0xcf, 0x93, 0xa8
	.byte 0x15, 0xd8, 0x7f, 0xb8, 0x1f, 0xa8, 0x25, 0x02, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20000000000000001dc8
	/* C1 */
	.octa 0xfe0
	/* C10 */
	.octa 0x2000000100030000000000000000
	/* C19 */
	.octa 0x0
	/* C30 */
	.octa 0x1508
final_cap_values:
	/* C0 */
	.octa 0x20000000000000001dc8
	/* C1 */
	.octa 0x1190
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x2000000100030000000000000000
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1640
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000610070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd010000045d107ca0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001190
	.dword 0x00000000000011a0
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d3195f // ALIGND-C.CI-C Cd:31 Cn:10 0110:0110 U:0 imm6:100110 11000010110:11000010110
	.inst 0xcaefbb62 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:27 imm6:101110 Rm:15 N:1 shift:11 01010:01010 opc:10 sf:1
	.inst 0x6975d7c2 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:2 Rn:30 Rt2:10101 imm7:1101011 L:1 1010010:1010010 opc:01
	.inst 0xc2c0b005 // GCSEAL-R.C-C Rd:5 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x29d20828 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:8 Rn:1 Rt2:00010 imm7:0100100 L:1 1010011:1010011 opc:00
	.inst 0x62c9703f // LDP-C.RIBW-C Ct:31 Rn:1 Ct2:11100 imm7:0010010 L:1 011000101:011000101
	.inst 0xc2c23381 // CHKTGD-C-C 00001:00001 Cn:28 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xa893cfc2 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:30 Rt2:10011 imm7:0100111 L:0 1010001:1010001 opc:10
	.inst 0xb87fd815 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:21 Rn:0 10:10 S:1 option:110 Rm:31 1:1 opc:01 111000:111000 size:10
	.inst 0x0225a81f // ADD-C.CIS-C Cd:31 Cn:0 imm12:100101101010 sh:0 A:0 00000010:00000010
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009aa // ldr c10, [x13, #2]
	.inst 0xc2400db3 // ldr c19, [x13, #3]
	.inst 0xc24011be // ldr c30, [x13, #4]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324d // ldr c13, [c18, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260124d // ldr c13, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x18, #0xf
	and x13, x13, x18
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b2 // ldr c18, [x13, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24005b2 // ldr c18, [x13, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24009b2 // ldr c18, [x13, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400db2 // ldr c18, [x13, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc24011b2 // ldr c18, [x13, #4]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc24015b2 // ldr c18, [x13, #5]
	.inst 0xc2d2a541 // chkeq c10, c18
	b.ne comparison_fail
	.inst 0xc24019b2 // ldr c18, [x13, #6]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2401db2 // ldr c18, [x13, #7]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc24021b2 // ldr c18, [x13, #8]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc24025b2 // ldr c18, [x13, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001078
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001190
	ldr x1, =check_data1
	ldr x2, =0x000011b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014b4
	ldr x1, =check_data2
	ldr x2, =0x000014bc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001508
	ldr x1, =check_data3
	ldr x2, =0x00001518
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001dc8
	ldr x1, =check_data4
	ldr x2, =0x00001dcc
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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
