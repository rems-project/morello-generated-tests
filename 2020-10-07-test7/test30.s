.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x40
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3e, 0x40, 0xc9, 0xc2, 0x81, 0x1c, 0x13, 0x79, 0x9f, 0xc8, 0x93, 0xb9, 0xdb, 0xe6, 0x9a, 0x39
	.byte 0x62, 0xe8, 0xbc, 0x22, 0xc1, 0x41, 0x4a, 0xb7
.data
check_data5:
	.byte 0x3f, 0x63, 0xda, 0xc2, 0x41, 0x33, 0xc2, 0xc2, 0x56, 0x78, 0x37, 0x9b, 0x4d, 0xd0, 0xf0, 0xe2
	.byte 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x10000020000000000
	/* C2 */
	.octa 0x400000000007000f00000000000010f3
	/* C3 */
	.octa 0x800
	/* C4 */
	.octa 0x30
	/* C22 */
	.octa 0xfe0
	/* C25 */
	.octa 0x800400204020000000000000004
	/* C26 */
	.octa 0x100000000000080000000000002
final_cap_values:
	/* C1 */
	.octa 0x10000020000000000
	/* C2 */
	.octa 0x400000000007000f00000000000010f3
	/* C3 */
	.octa 0x790
	/* C4 */
	.octa 0x30
	/* C25 */
	.octa 0x800400204020000000000000004
	/* C26 */
	.octa 0x100000000000080000000000002
	/* C27 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000008700830000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c9403e // SCVALUE-C.CR-C Cd:30 Cn:1 000:000 opc:10 0:0 Rm:9 11000010110:11000010110
	.inst 0x79131c81 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:4 imm12:010011000111 opc:00 111001:111001 size:01
	.inst 0xb993c89f // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:4 imm12:010011110010 opc:10 111001:111001 size:10
	.inst 0x399ae6db // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:22 imm12:011010111001 opc:10 111001:111001 size:00
	.inst 0x22bce862 // STP-CC.RIAW-C Ct:2 Rn:3 Ct2:11010 imm7:1111001 L:0 001000101:001000101
	.inst 0xb74a41c1 // tbnz:aarch64/instrs/branch/conditional/test Rt:1 imm14:01001000001110 b40:01001 op:1 011011:011011 b5:1
	.zero 18484
	.inst 0xc2da633f // SCOFF-C.CR-C Cd:31 Cn:25 000:000 opc:11 0:0 Rm:26 11000010110:11000010110
	.inst 0xc2c23341 // CHKTGD-C-C 00001:00001 Cn:26 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x9b377856 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:22 Rn:2 Ra:30 o0:0 Rm:23 01:01 U:0 10011011:10011011
	.inst 0xe2f0d04d // ASTUR-V.RI-D Rt:13 Rn:2 op2:00 imm9:100001101 V:1 op1:11 11100010:11100010
	.inst 0xc2c21220
	.zero 1030048
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400cc4 // ldr c4, [x6, #3]
	.inst 0xc24010d6 // ldr c22, [x6, #4]
	.inst 0xc24014d9 // ldr c25, [x6, #5]
	.inst 0xc24018da // ldr c26, [x6, #6]
	/* Vector registers */
	mrs x6, cptr_el3
	bfc x6, #10, #1
	msr cptr_el3, x6
	isb
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603226 // ldr c6, [c17, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601226 // ldr c6, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x17, #0xf
	and x6, x6, x17
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d1 // ldr c17, [x6, #0]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24004d1 // ldr c17, [x6, #1]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc24008d1 // ldr c17, [x6, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400cd1 // ldr c17, [x6, #3]
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	.inst 0xc24010d1 // ldr c17, [x6, #4]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc24014d1 // ldr c17, [x6, #5]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc24018d1 // ldr c17, [x6, #6]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0x0
	mov x17, v13.d[0]
	cmp x6, x17
	b.ne comparison_fail
	ldr x6, =0x0
	mov x17, v13.d[1]
	cmp x6, x17
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
	ldr x0, =0x000011be
	ldr x1, =check_data1
	ldr x2, =0x000011c0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001bf8
	ldr x1, =check_data2
	ldr x2, =0x00001bfc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e99
	ldr x1, =check_data3
	ldr x2, =0x00001e9a
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040484c
	ldr x1, =check_data5
	ldr x2, =0x00404860
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
