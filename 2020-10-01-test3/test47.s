.section data0, #alloc, #write
	.zero 16
	.byte 0x05, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x05, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xa1, 0x11, 0xc4, 0xc2, 0xfe, 0xff, 0x7f, 0x42, 0x81, 0x8d, 0xc9, 0x3c, 0xfe, 0xbf, 0x97, 0xf9
	.byte 0x0e, 0x10, 0x61, 0xf9, 0xa1, 0x87, 0xda, 0xc2, 0xda, 0xeb, 0xcc, 0xc2, 0x00, 0x20, 0xc1, 0xc2
	.byte 0xfe, 0xca, 0x55, 0xe2, 0x01, 0x00, 0x0f, 0x3a, 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000003ffdd0
	/* C12 */
	.octa 0x800000001007900f00000000003fff68
	/* C13 */
	.octa 0x90000000400000010000000000001000
	/* C23 */
	.octa 0x208c
	/* C26 */
	.octa 0x180470080000401c80000
	/* C29 */
	.octa 0x400010000f80000000000
final_cap_values:
	/* C0 */
	.octa 0x800000007dd0fdd000000000003ffdd0
	/* C12 */
	.octa 0x800000001007900f0000000000400000
	/* C13 */
	.octa 0x90000000400000010000000000001000
	/* C14 */
	.octa 0x0
	/* C23 */
	.octa 0x208c
	/* C26 */
	.octa 0x4000000000000000000000
	/* C29 */
	.octa 0x400010000f80000000000
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x1ff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600400040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c411a1 // LDPBR-C.C-C Ct:1 Cn:13 100:100 opc:00 11000010110001000:11000010110001000
	.inst 0x427ffffe // ALDAR-R.R-32 Rt:30 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x3cc98d81 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:1 Rn:12 11:11 imm9:010011000 0:0 opc:11 111100:111100 size:00
	.inst 0xf997bffe // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:31 imm12:010111101111 opc:10 111001:111001 size:11
	.inst 0xf961100e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:0 imm12:100001000100 opc:01 111001:111001 size:11
	.inst 0xc2da87a1 // CHKSS-_.CC-C 00001:00001 Cn:29 001:001 opc:00 1:1 Cm:26 11000010110:11000010110
	.inst 0xc2ccebda // CTHI-C.CR-C Cd:26 Cn:30 1010:1010 opc:11 Rm:12 11000010110:11000010110
	.inst 0xc2c12000 // SCBNDSE-C.CR-C Cd:0 Cn:0 000:000 opc:01 0:0 Rm:1 11000010110:11000010110
	.inst 0xe255cafe // ALDURSH-R.RI-64 Rt:30 Rn:23 op2:10 imm9:101011100 V:0 op1:01 11100010:11100010
	.inst 0x3a0f0001 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:0 000000:000000 Rm:15 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2c21300
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006ac // ldr c12, [x21, #1]
	.inst 0xc2400aad // ldr c13, [x21, #2]
	.inst 0xc2400eb7 // ldr c23, [x21, #3]
	.inst 0xc24012ba // ldr c26, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_csp_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603315 // ldr c21, [c24, #3]
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	.inst 0x82601315 // ldr c21, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b8 // ldr c24, [x21, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24006b8 // ldr c24, [x21, #1]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2400ab8 // ldr c24, [x21, #2]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2400eb8 // ldr c24, [x21, #3]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc24012b8 // ldr c24, [x21, #4]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc24016b8 // ldr c24, [x21, #5]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2401ab8 // ldr c24, [x21, #6]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2401eb8 // ldr c24, [x21, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x427ffffec2c411a1
	mov x24, v1.d[0]
	cmp x21, x24
	b.ne comparison_fail
	ldr x21, =0xf997bffe3cc98d81
	mov x24, v1.d[1]
	cmp x21, x24
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
	ldr x0, =0x00001fec
	ldr x1, =check_data1
	ldr x2, =0x00001fee
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff4
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00403ff0
	ldr x1, =check_data4
	ldr x2, =0x00403ff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr ddc_el3, c21
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
