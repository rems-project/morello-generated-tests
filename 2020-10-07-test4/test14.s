.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x91, 0x07, 0x67, 0xe2, 0x0c, 0x80, 0x07, 0xb8, 0xb6, 0x5c, 0x15, 0xa9, 0x6e, 0x03, 0x78, 0x82
	.byte 0x1e, 0x1c, 0xd2, 0xc2, 0x5f, 0x71, 0x9a, 0x5a, 0x80, 0xf4, 0x07, 0xe2, 0x7f, 0x84, 0x2f, 0xd0
	.byte 0xc0, 0x33, 0xc2, 0xc2
.data
check_data6:
	.byte 0xde, 0x11, 0xc0, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400000040000000000001d88
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x40000000400000b100000000000010c8
	/* C12 */
	.octa 0x0
	/* C18 */
	.octa 0x20008000d00200400000000000400080
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x360
	/* C28 */
	.octa 0xfa0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C4 */
	.octa 0x1000
	/* C5 */
	.octa 0x40000000400000b100000000000010c8
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x20008000d00200400000000000400080
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x360
	/* C28 */
	.octa 0xfa0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x900000000003000700ffffffa2000200
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001b60
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2670791 // ALDUR-V.RI-H Rt:17 Rn:28 op2:01 imm9:001110000 V:1 op1:01 11100010:11100010
	.inst 0xb807800c // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:12 Rn:0 00:00 imm9:001111000 0:0 opc:00 111000:111000 size:10
	.inst 0xa9155cb6 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:22 Rn:5 Rt2:10111 imm7:0101010 L:0 1010010:1010010 opc:10
	.inst 0x8278036e // ALDR-C.RI-C Ct:14 Rn:27 op:00 imm9:110000000 L:1 1000001001:1000001001
	.inst 0xc2d21c1e // CSEL-C.CI-C Cd:30 Cn:0 11:11 cond:0001 Cm:18 11000010110:11000010110
	.inst 0x5a9a715f // csinv:aarch64/instrs/integer/conditional/select Rd:31 Rn:10 o2:0 0:0 cond:0111 Rm:26 011010100:011010100 op:1 sf:0
	.inst 0xe207f480 // ALDURB-R.RI-32 Rt:0 Rn:4 op2:01 imm9:001111111 V:0 op1:00 11100010:11100010
	.inst 0xd02f847f // ADRDP-C.ID-C Rd:31 immhi:010111110000100011 P:0 10000:10000 immlo:10 op:1
	.inst 0xc2c233c0 // BLR-C-C 00000:00000 Cn:30 100:100 opc:01 11000010110000100:11000010110000100
	.zero 92
	.inst 0xc2c011de // GCBASE-R.C-C Rd:30 Cn:14 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xc2c21060
	.zero 1048440
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x1, cptr_el3
	orr x1, x1, #0x200
	msr cptr_el3, x1
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
	ldr x1, =initial_cap_values
	.inst 0xc2400020 // ldr c0, [x1, #0]
	.inst 0xc2400424 // ldr c4, [x1, #1]
	.inst 0xc2400825 // ldr c5, [x1, #2]
	.inst 0xc2400c2c // ldr c12, [x1, #3]
	.inst 0xc2401032 // ldr c18, [x1, #4]
	.inst 0xc2401436 // ldr c22, [x1, #5]
	.inst 0xc2401837 // ldr c23, [x1, #6]
	.inst 0xc2401c3b // ldr c27, [x1, #7]
	.inst 0xc240203c // ldr c28, [x1, #8]
	/* Set up flags and system registers */
	mov x1, #0x40000000
	msr nzcv, x1
	ldr x1, =0x200
	msr CPTR_EL3, x1
	ldr x1, =0x30850030
	msr SCTLR_EL3, x1
	ldr x1, =0x80
	msr S3_6_C1_C2_2, x1 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603061 // ldr c1, [c3, #3]
	.inst 0xc28b4121 // msr DDC_EL3, c1
	isb
	.inst 0x82601061 // ldr c1, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21020 // br c1
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
	isb
	/* Check processor flags */
	mrs x1, nzcv
	ubfx x1, x1, #28, #4
	mov x3, #0x5
	and x1, x1, x3
	cmp x1, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x1, =final_cap_values
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400423 // ldr c3, [x1, #1]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc2400823 // ldr c3, [x1, #2]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2400c23 // ldr c3, [x1, #3]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2401023 // ldr c3, [x1, #4]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401423 // ldr c3, [x1, #5]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401823 // ldr c3, [x1, #6]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401c23 // ldr c3, [x1, #7]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402023 // ldr c3, [x1, #8]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2402423 // ldr c3, [x1, #9]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402823 // ldr c3, [x1, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x1, =0x0
	mov x3, v17.d[0]
	cmp x1, x3
	b.ne comparison_fail
	ldr x1, =0x0
	mov x3, v17.d[1]
	cmp x1, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000107f
	ldr x1, =check_data1
	ldr x2, =0x00001080
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001218
	ldr x1, =check_data2
	ldr x2, =0x00001228
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001b60
	ldr x1, =check_data3
	ldr x2, =0x00001b70
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e00
	ldr x1, =check_data4
	ldr x2, =0x00001e04
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400024
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x00400088
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2df4021 // scvalue c1, c1, x31
	.inst 0xc28b4121 // msr DDC_EL3, c1
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
