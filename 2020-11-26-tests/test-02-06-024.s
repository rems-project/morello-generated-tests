.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xe0, 0x51, 0xc2, 0xc2
.data
check_data5:
	.byte 0xdd, 0xf7, 0x24, 0x51, 0x2d, 0x30, 0xc0, 0xc2, 0xf8, 0xc4, 0x81, 0x38, 0xc0, 0x17, 0x03, 0x78
	.byte 0xbf, 0x2d, 0xc1, 0x9a, 0x3d, 0xe4, 0x92, 0xe2, 0x5e, 0x37, 0x72, 0xbd, 0x29, 0x88, 0x85, 0xb9
	.byte 0x85, 0x7f, 0x3f, 0x42, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 4
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000400000010000000000000c00
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x800000004001c00200000000004ffffe
	/* C15 */
	.octa 0x20008000800000000000000000400015
	/* C26 */
	.octa 0x800000000007800700000000004085d0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000600070000000000001002
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000400000010000000000000c00
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x800000004001c002000000000050001a
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x3fff
	/* C15 */
	.octa 0x20008000800000000000000000400015
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000007800700000000004085d0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000600070000000000001033
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004004c00c0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004000140200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c251e0 // RET-C-C 00000:00000 Cn:15 100:100 opc:10 11000010110000100:11000010110000100
	.zero 16
	.inst 0x5124f7dd // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:29 Rn:30 imm12:100100111101 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2c0302d // GCLEN-R.C-C Rd:13 Cn:1 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x3881c4f8 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:7 01:01 imm9:000011100 0:0 opc:10 111000:111000 size:00
	.inst 0x780317c0 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:30 01:01 imm9:000110001 0:0 opc:00 111000:111000 size:01
	.inst 0x9ac12dbf // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:13 op2:11 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0xe292e43d // ALDUR-R.RI-32 Rt:29 Rn:1 op2:01 imm9:100101110 V:0 op1:10 11100010:11100010
	.inst 0xbd72375e // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:30 Rn:26 imm12:110010001101 opc:01 111101:111101 size:10
	.inst 0xb9858829 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:9 Rn:1 imm12:000101100010 opc:10 111001:111001 size:10
	.inst 0x423f7f85 // ASTLRB-R.R-B Rt:5 Rn:28 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c211c0
	.zero 1048516
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc240167a // ldr c26, [x19, #5]
	.inst 0xc2401a7c // ldr c28, [x19, #6]
	.inst 0xc2401e7e // ldr c30, [x19, #7]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031d3 // ldr c19, [c14, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011d3 // ldr c19, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026e // ldr c14, [x19, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240066e // ldr c14, [x19, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400a6e // ldr c14, [x19, #2]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc2400e6e // ldr c14, [x19, #3]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240126e // ldr c14, [x19, #4]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc240166e // ldr c14, [x19, #5]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc2401a6e // ldr c14, [x19, #6]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc2401e6e // ldr c14, [x19, #7]
	.inst 0xc2cea701 // chkeq c24, c14
	b.ne comparison_fail
	.inst 0xc240226e // ldr c14, [x19, #8]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc240266e // ldr c14, [x19, #9]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2402a6e // ldr c14, [x19, #10]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2402e6e // ldr c14, [x19, #11]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x14, v30.d[0]
	cmp x19, x14
	b.ne comparison_fail
	ldr x19, =0x0
	mov x14, v30.d[1]
	cmp x19, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001188
	ldr x1, =check_data1
	ldr x2, =0x0000118c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001402
	ldr x1, =check_data2
	ldr x2, =0x00001403
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f30
	ldr x1, =check_data3
	ldr x2, =0x00001f34
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400014
	ldr x1, =check_data5
	ldr x2, =0x0040003c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040b804
	ldr x1, =check_data6
	ldr x2, =0x0040b808
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
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
