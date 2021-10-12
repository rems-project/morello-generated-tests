.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x84, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x84
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0xf6, 0x7f, 0x5f, 0xc8, 0xed, 0xb3, 0xe9, 0xe2, 0xdf, 0xab, 0x35, 0x79, 0xf4, 0xef, 0xe9, 0x62
	.byte 0xa1, 0x47, 0xc4, 0x38, 0x3d, 0x41, 0xcd, 0xe2, 0x72, 0x10, 0xc5, 0xc2, 0xd0, 0x9b, 0xe9, 0x02
	.byte 0x1d, 0x54, 0x67, 0xe2, 0xfd, 0x75, 0x57, 0x82, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data8:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x827
	/* C15 */
	.octa 0x1004
	/* C29 */
	.octa 0x80000000000704870000000000401040
	/* C30 */
	.octa 0x4000000000030007000000000000020c
final_cap_values:
	/* C0 */
	.octa 0x800
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0x827
	/* C15 */
	.octa 0x1004
	/* C16 */
	.octa 0x4000000000030007ffffffffff59a20c
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000704870000000000401084
	/* C30 */
	.octa 0x4000000000030007000000000000020c
initial_SP_EL3_value:
	.octa 0x80100000400109620000000000001420
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000403e080500ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001150
	.dword 0x0000000000001160
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc85f7ff6 // ldxr:aarch64/instrs/memory/exclusive/single Rt:22 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xe2e9b3ed // ASTUR-V.RI-D Rt:13 Rn:31 op2:00 imm9:010011011 V:1 op1:11 11100010:11100010
	.inst 0x7935abdf // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:30 imm12:110101101010 opc:00 111001:111001 size:01
	.inst 0x62e9eff4 // LDP-C.RIBW-C Ct:20 Rn:31 Ct2:11011 imm7:1010011 L:1 011000101:011000101
	.inst 0x38c447a1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:29 01:01 imm9:001000100 0:0 opc:11 111000:111000 size:00
	.inst 0xe2cd413d // ASTUR-R.RI-64 Rt:29 Rn:9 op2:00 imm9:011010100 V:0 op1:11 11100010:11100010
	.inst 0xc2c51072 // CVTD-R.C-C Rd:18 Cn:3 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x02e99bd0 // SUB-C.CIS-C Cd:16 Cn:30 imm12:101001100110 sh:1 A:1 00000010:00000010
	.inst 0xe267541d // ALDUR-V.RI-H Rt:29 Rn:0 op2:01 imm9:001110101 V:1 op1:01 11100010:11100010
	.inst 0x825775fd // ASTRB-R.RI-B Rt:29 Rn:15 op:01 imm9:101110111 L:0 1000001001:1000001001
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400543 // ldr c3, [x10, #1]
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2400d4f // ldr c15, [x10, #3]
	.inst 0xc240115d // ldr c29, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ea // ldr c10, [c7, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010ea // ldr c10, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x7, #0xf
	and x10, x10, x7
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400147 // ldr c7, [x10, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400547 // ldr c7, [x10, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400d47 // ldr c7, [x10, #3]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401147 // ldr c7, [x10, #4]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401547 // ldr c7, [x10, #5]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401947 // ldr c7, [x10, #6]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2401d47 // ldr c7, [x10, #7]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2402147 // ldr c7, [x10, #8]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402547 // ldr c7, [x10, #9]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402947 // ldr c7, [x10, #10]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402d47 // ldr c7, [x10, #11]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x7, v13.d[0]
	cmp x10, x7
	b.ne comparison_fail
	ldr x10, =0x0
	mov x7, v13.d[1]
	cmp x10, x7
	b.ne comparison_fail
	ldr x10, =0x0
	mov x7, v29.d[0]
	cmp x10, x7
	b.ne comparison_fail
	ldr x10, =0x0
	mov x7, v29.d[1]
	cmp x10, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000107a
	ldr x1, =check_data0
	ldr x2, =0x0000107c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001108
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001150
	ldr x1, =check_data2
	ldr x2, =0x00001170
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001420
	ldr x1, =check_data3
	ldr x2, =0x00001428
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001980
	ldr x1, =check_data4
	ldr x2, =0x00001981
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001cc0
	ldr x1, =check_data5
	ldr x2, =0x00001cc8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ce0
	ldr x1, =check_data6
	ldr x2, =0x00001ce2
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00401040
	ldr x1, =check_data8
	ldr x2, =0x00401041
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
