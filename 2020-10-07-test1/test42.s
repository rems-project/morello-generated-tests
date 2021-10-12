.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xa2, 0x7d, 0x7f, 0x42, 0x82, 0xc0, 0x1e, 0xe2, 0x8a, 0xc4, 0x69, 0x79, 0x01, 0xfc, 0xdf, 0x08
	.byte 0xa3, 0xa0, 0xe6, 0xc2, 0xa6, 0x5d, 0xaf, 0xd0, 0xef, 0xfb, 0xbb, 0x39, 0xf2, 0x0c, 0xe5, 0xb0
	.byte 0xec, 0xd7, 0xdb, 0x78, 0xc2, 0xe7, 0xd6, 0xe2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffffe
	/* C4 */
	.octa 0x80000000000100050000000000000020
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0xebc
	/* C30 */
	.octa 0x102
final_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffffe
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x3fff800000000000000000000000
	/* C4 */
	.octa 0x80000000000100050000000000000020
	/* C5 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x2000800050000000000000005efb6000
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x7da2
	/* C13 */
	.octa 0xebc
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x2000800050000000ffffffffca59d000
	/* C30 */
	.octa 0x102
initial_SP_EL3_value:
	.octa 0x800000000f078f0f0000000000400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000105708060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427f7da2 // ALDARB-R.R-B Rt:2 Rn:13 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xe21ec082 // ASTURB-R.RI-32 Rt:2 Rn:4 op2:00 imm9:111101100 V:0 op1:00 11100010:11100010
	.inst 0x7969c48a // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:10 Rn:4 imm12:101001110001 opc:01 111001:111001 size:01
	.inst 0x08dffc01 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2e6a0a3 // BICFLGS-C.CI-C Cd:3 Cn:5 0:0 00:00 imm8:00110101 11000010111:11000010111
	.inst 0xd0af5da6 // ADRP-C.IP-C Rd:6 immhi:010111101011101101 P:1 10000:10000 immlo:10 op:1
	.inst 0x39bbfbef // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:15 Rn:31 imm12:111011111110 opc:10 111001:111001 size:00
	.inst 0xb0e50cf2 // ADRP-C.I-C Rd:18 immhi:110010100001100111 P:1 10000:10000 immlo:01 op:1
	.inst 0x78dbd7ec // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:12 Rn:31 01:01 imm9:110111101 0:0 opc:11 111000:111000 size:01
	.inst 0xe2d6e7c2 // ALDUR-R.RI-64 Rt:2 Rn:30 op2:01 imm9:101101110 V:0 op1:11 11100010:11100010
	.inst 0xc2c21120
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a4 // ldr c4, [x29, #1]
	.inst 0xc2400ba5 // ldr c5, [x29, #2]
	.inst 0xc2400fad // ldr c13, [x29, #3]
	.inst 0xc24013be // ldr c30, [x29, #4]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850038
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313d // ldr c29, [c9, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260113d // ldr c29, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a9 // ldr c9, [x29, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24007a9 // ldr c9, [x29, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400ba9 // ldr c9, [x29, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400fa9 // ldr c9, [x29, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc24013a9 // ldr c9, [x29, #4]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc24017a9 // ldr c9, [x29, #5]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2401ba9 // ldr c9, [x29, #6]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401fa9 // ldr c9, [x29, #7]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc24023a9 // ldr c9, [x29, #8]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc24027a9 // ldr c9, [x29, #9]
	.inst 0xc2c9a5a1 // chkeq c13, c9
	b.ne comparison_fail
	.inst 0xc2402ba9 // ldr c9, [x29, #10]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2402fa9 // ldr c9, [x29, #11]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24033a9 // ldr c9, [x29, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000100c
	ldr x1, =check_data0
	ldr x2, =0x0000100d
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001502
	ldr x1, =check_data2
	ldr x2, =0x00001504
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ebc
	ldr x1, =check_data3
	ldr x2, =0x00001ebd
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
	ldr x0, =0x00400efe
	ldr x1, =check_data5
	ldr x2, =0x00400eff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
