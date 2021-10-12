.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x87, 0xeb, 0xd0, 0xc2, 0x5a, 0x2d, 0x4d, 0xe2, 0x21, 0x44, 0xf3, 0xe2, 0xdf, 0xcb, 0x77, 0xf9
	.byte 0x9c, 0xf5, 0x46, 0x78, 0xd6, 0x6f, 0xe4, 0x42, 0x22, 0xc8, 0xe0, 0x78, 0x60, 0xd1, 0xc3, 0xf2
	.byte 0x02, 0x1d, 0x5a, 0xe2, 0x61, 0x8a, 0x71, 0x82, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data1:
	.byte 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2
.data
check_data2:
	.byte 0xe2, 0xe2
.data
check_data3:
	.byte 0xe2, 0xe2
.data
check_data4:
	.byte 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2
	.byte 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2
.data
check_data5:
	.byte 0xe2, 0xe2, 0xe2, 0xe2
.data
check_data6:
	.byte 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2
.data
check_data7:
	.byte 0xe2, 0xe2
.data
check_data8:
	.byte 0xe2, 0xe2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x7fbfc
	/* C1 */
	.octa 0x800000002007c1a60000000000400404
	/* C8 */
	.octa 0x800000004802d001000000000040083f
	/* C10 */
	.octa 0x8000000000d7209f0000000000401ffc
	/* C12 */
	.octa 0x440000
	/* C19 */
	.octa 0x80000000000100050000000000403b98
	/* C30 */
	.octa 0x404000
final_cap_values:
	/* C0 */
	.octa 0x1e8b0007fbfc
	/* C1 */
	.octa 0xe2e2e2e2
	/* C2 */
	.octa 0xffffe2e2
	/* C8 */
	.octa 0x800000004802d001000000000040083f
	/* C10 */
	.octa 0x8000000000d7209f0000000000401ffc
	/* C12 */
	.octa 0x44006f
	/* C19 */
	.octa 0x80000000000100050000000000403b98
	/* C22 */
	.octa 0xe2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2
	/* C26 */
	.octa 0xffffe2e2
	/* C27 */
	.octa 0xe2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2
	/* C28 */
	.octa 0xe2e2
	/* C30 */
	.octa 0x404000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x901000001f0e0000000000000f800001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d0eb87 // CTHI-C.CR-C Cd:7 Cn:28 1010:1010 opc:11 Rm:16 11000010110:11000010110
	.inst 0xe24d2d5a // ALDURSH-R.RI-32 Rt:26 Rn:10 op2:11 imm9:011010010 V:0 op1:01 11100010:11100010
	.inst 0xe2f34421 // ALDUR-V.RI-D Rt:1 Rn:1 op2:01 imm9:100110100 V:1 op1:11 11100010:11100010
	.inst 0xf977cbdf // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:30 imm12:110111110010 opc:01 111001:111001 size:11
	.inst 0x7846f59c // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:28 Rn:12 01:01 imm9:001101111 0:0 opc:01 111000:111000 size:01
	.inst 0x42e46fd6 // LDP-C.RIB-C Ct:22 Rn:30 Ct2:11011 imm7:1001000 L:1 010000101:010000101
	.inst 0x78e0c822 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:1 10:10 S:0 option:110 Rm:0 1:1 opc:11 111000:111000 size:01
	.inst 0xf2c3d160 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0001111010001011 hw:10 100101:100101 opc:11 sf:1
	.inst 0xe25a1d02 // ALDURSH-R.RI-32 Rt:2 Rn:8 op2:11 imm9:110100001 V:0 op1:01 11100010:11100010
	.inst 0x82718a61 // ALDR-R.RI-32 Rt:1 Rn:19 op:10 imm9:100011000 L:1 1000001001:1000001001
	.inst 0xc2c213a0
	.zero 780
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.zero 1184
	.inst 0x0000e2e2
	.zero 6376
	.inst 0xe2e20000
	.zero 7088
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.zero 856
	.inst 0xe2e2e2e2
	.zero 28564
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.zero 217192
	.inst 0x0000e2e2
	.zero 262140
	.inst 0x0000e2e2
	.zero 524284
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
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc240130c // ldr c12, [x24, #4]
	.inst 0xc2401713 // ldr c19, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b8 // ldr c24, [c29, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826013b8 // ldr c24, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031d // ldr c29, [x24, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240071d // ldr c29, [x24, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400b1d // ldr c29, [x24, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400f1d // ldr c29, [x24, #3]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc240131d // ldr c29, [x24, #4]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc240171d // ldr c29, [x24, #5]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc2401b1d // ldr c29, [x24, #6]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc2401f1d // ldr c29, [x24, #7]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc240231d // ldr c29, [x24, #8]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc240271d // ldr c29, [x24, #9]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	.inst 0xc2402b1d // ldr c29, [x24, #10]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc2402f1d // ldr c29, [x24, #11]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0xe2e2e2e2e2e2e2e2
	mov x29, v1.d[0]
	cmp x24, x29
	b.ne comparison_fail
	ldr x24, =0x0
	mov x29, v1.d[1]
	cmp x24, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400338
	ldr x1, =check_data1
	ldr x2, =0x00400340
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004007e0
	ldr x1, =check_data2
	ldr x2, =0x004007e2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004020ce
	ldr x1, =check_data3
	ldr x2, =0x004020d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403c80
	ldr x1, =check_data4
	ldr x2, =0x00403ca0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403ff8
	ldr x1, =check_data5
	ldr x2, =0x00403ffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040af90
	ldr x1, =check_data6
	ldr x2, =0x0040af98
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00440000
	ldr x1, =check_data7
	ldr x2, =0x00440002
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00480000
	ldr x1, =check_data8
	ldr x2, =0x00480002
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
