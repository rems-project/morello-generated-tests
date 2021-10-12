.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0xe0, 0xc1, 0x00, 0xe0, 0x00, 0x00, 0xe5, 0xa1, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xf4
.data
check_data5:
	.byte 0x21, 0xc3, 0xb5, 0xe2, 0xde, 0x47, 0x46, 0x79, 0x01, 0x10, 0x82, 0x5a, 0x1e, 0xf8, 0xa2, 0xaa
	.byte 0x21, 0x23, 0x1f, 0x38, 0x3f, 0xfc, 0x7f, 0x42, 0xd0, 0xa8, 0x31, 0xe2, 0xe1, 0xf4, 0x41, 0x38
	.byte 0xa0, 0x93, 0x9e, 0x02, 0xcd, 0x75, 0x4f, 0x38, 0x40, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xffffe00b
	/* C6 */
	.octa 0x2026
	/* C7 */
	.octa 0x800000002001000500000000004ffffe
	/* C14 */
	.octa 0x800000004001c002000000000040dffe
	/* C25 */
	.octa 0x4000000060010fb90000000000002008
	/* C29 */
	.octa 0x800120050000000000000000
	/* C30 */
	.octa 0x80000000600400060000000000001000
final_cap_values:
	/* C0 */
	.octa 0x80012005fffffffffffff85c
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffe00b
	/* C6 */
	.octa 0x2026
	/* C7 */
	.octa 0x8000000020010005000000000050001d
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x800000004001c002000000000040e0f5
	/* C25 */
	.octa 0x4000000060010fb90000000000002008
	/* C29 */
	.octa 0x800120050000000000000000
	/* C30 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000807000000fffffffffff920
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b5c321 // ASTUR-V.RI-S Rt:1 Rn:25 op2:00 imm9:101011100 V:1 op1:10 11100010:11100010
	.inst 0x794647de // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:000110010001 opc:01 111001:111001 size:01
	.inst 0x5a821001 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:0 o2:0 0:0 cond:0001 Rm:2 011010100:011010100 op:1 sf:0
	.inst 0xaaa2f81e // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:0 imm6:111110 Rm:2 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0x381f2321 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:25 00:00 imm9:111110010 0:0 opc:00 111000:111000 size:00
	.inst 0x427ffc3f // ALDAR-R.R-32 Rt:31 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xe231a8d0 // ASTUR-V.RI-Q Rt:16 Rn:6 op2:10 imm9:100011010 V:1 op1:00 11100010:11100010
	.inst 0x3841f4e1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:7 01:01 imm9:000011111 0:0 opc:01 111000:111000 size:00
	.inst 0x029e93a0 // SUB-C.CIS-C Cd:0 Cn:29 imm12:011110100100 sh:0 A:1 00000010:00000010
	.inst 0x384f75cd // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:13 Rn:14 01:01 imm9:011110111 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400162 // ldr c2, [x11, #0]
	.inst 0xc2400566 // ldr c6, [x11, #1]
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2400d6e // ldr c14, [x11, #3]
	.inst 0xc2401179 // ldr c25, [x11, #4]
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q1, =0x0
	ldr q16, =0xa1e50000e000c1e000008000000000
	/* Set up flags and system registers */
	mov x11, #0x40000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260324b // ldr c11, [c18, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260124b // ldr c11, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x18, #0x4
	and x11, x11, x18
	cmp x11, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400172 // ldr c18, [x11, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400572 // ldr c18, [x11, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400972 // ldr c18, [x11, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400d72 // ldr c18, [x11, #3]
	.inst 0xc2d2a4c1 // chkeq c6, c18
	b.ne comparison_fail
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2401572 // ldr c18, [x11, #5]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2401972 // ldr c18, [x11, #6]
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	.inst 0xc2401d72 // ldr c18, [x11, #7]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2402172 // ldr c18, [x11, #8]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402572 // ldr c18, [x11, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x18, v1.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0x0
	mov x18, v1.d[1]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0xe000008000000000
	mov x18, v16.d[0]
	cmp x11, x18
	b.ne comparison_fail
	ldr x11, =0xa1e50000e000c1
	mov x18, v16.d[1]
	cmp x11, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001322
	ldr x1, =check_data0
	ldr x2, =0x00001324
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f40
	ldr x1, =check_data1
	ldr x2, =0x00001f50
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f64
	ldr x1, =check_data2
	ldr x2, =0x00001f68
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff4
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffa
	ldr x1, =check_data4
	ldr x2, =0x00001ffb
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
	ldr x0, =0x0040dffe
	ldr x1, =check_data6
	ldr x2, =0x0040dfff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffe
	ldr x1, =check_data7
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
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
