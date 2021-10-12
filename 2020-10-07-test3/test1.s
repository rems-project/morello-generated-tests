.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xe5, 0x83, 0xd1, 0xc2, 0xf9, 0xbb, 0xc8, 0x28, 0x51, 0xb1, 0x9e, 0x5a, 0x9e, 0x7d, 0x41, 0xa2
	.byte 0x05, 0xec, 0x88, 0xb8, 0x60, 0x9f, 0x41, 0xa2, 0x33, 0xc0, 0x1a, 0x78, 0xcf, 0x80, 0xdc, 0xc2
	.byte 0x1f, 0x68, 0xc1, 0xc2, 0x1f, 0x7c, 0x47, 0x9b, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1f22
	/* C1 */
	.octa 0x1208
	/* C12 */
	.octa 0x1008
	/* C17 */
	.octa 0x1
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0x1408
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1208
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x1178
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x1598
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xfdc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000100100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000400700480000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011c0
	.dword 0x00000000000015e0
	.dword final_cap_values + 0
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d183e5 // SCTAG-C.CR-C Cd:5 Cn:31 000:000 0:0 10:10 Rm:17 11000010110:11000010110
	.inst 0x28c8bbf9 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:25 Rn:31 Rt2:01110 imm7:0010001 L:1 1010001:1010001 opc:00
	.inst 0x5a9eb151 // csinv:aarch64/instrs/integer/conditional/select Rd:17 Rn:10 o2:0 0:0 cond:1011 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0xa2417d9e // LDR-C.RIBW-C Ct:30 Rn:12 11:11 imm9:000010111 0:0 opc:01 10100010:10100010
	.inst 0xb888ec05 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:5 Rn:0 11:11 imm9:010001110 0:0 opc:10 111000:111000 size:10
	.inst 0xa2419f60 // LDR-C.RIBW-C Ct:0 Rn:27 11:11 imm9:000011001 0:0 opc:01 10100010:10100010
	.inst 0x781ac033 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:19 Rn:1 00:00 imm9:110101100 0:0 opc:00 111000:111000 size:01
	.inst 0xc2dc80cf // SCTAG-C.CR-C Cd:15 Cn:6 000:000 0:0 10:10 Rm:28 11000010110:11000010110
	.inst 0xc2c1681f // ORRFLGS-C.CR-C Cd:31 Cn:0 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0x9b477c1f // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:0 Ra:11111 0:0 Rm:7 10:10 U:0 10011011:10011011
	.inst 0xc2c21160
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009ac // ldr c12, [x13, #2]
	.inst 0xc2400db1 // ldr c17, [x13, #3]
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc24015bb // ldr c27, [x13, #5]
	.inst 0xc24019bc // ldr c28, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316d // ldr c13, [c11, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260116d // ldr c13, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x11, #0x9
	and x13, x13, x11
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001ab // ldr c11, [x13, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24005ab // ldr c11, [x13, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24009ab // ldr c11, [x13, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400dab // ldr c11, [x13, #3]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc24011ab // ldr c11, [x13, #4]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc24015ab // ldr c11, [x13, #5]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc24019ab // ldr c11, [x13, #6]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc2401dab // ldr c11, [x13, #7]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc24021ab // ldr c11, [x13, #8]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc24025ab // ldr c11, [x13, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001024
	ldr x1, =check_data0
	ldr x2, =0x0000102c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011c0
	ldr x1, =check_data1
	ldr x2, =0x000011d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011fc
	ldr x1, =check_data2
	ldr x2, =0x000011fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000015e0
	ldr x1, =check_data3
	ldr x2, =0x000015f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff8
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
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
	.inst 0xc28b412d // msr DDC_EL3, c13
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
