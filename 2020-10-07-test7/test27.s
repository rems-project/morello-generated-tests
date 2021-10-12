.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x20, 0xe8, 0xcc, 0xc2, 0x47, 0x54, 0x02, 0xb8, 0xc1, 0x03, 0x00, 0xba, 0xd7, 0x7f, 0x9f, 0x48
	.byte 0xdf, 0xa6, 0x5e, 0xad, 0xd6, 0x46, 0x50, 0x37
.data
check_data3:
	.byte 0x9f, 0xc6, 0x0a, 0xf8, 0xf2, 0x0b, 0x53, 0xe2, 0xf8, 0x08, 0xd2, 0xc2, 0xe0, 0x7b, 0xf2, 0x8a
	.byte 0x60, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 32
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x40000000000100070000000000001000
	/* C7 */
	.octa 0x0
	/* C20 */
	.octa 0x400000005c020c030000000000001800
	/* C22 */
	.octa 0x80000000040784130000000000400c00
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000073900060000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000100070000000000001025
	/* C7 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x400000005c020c0300000000000018ac
	/* C22 */
	.octa 0x80000000040784130000000000400c00
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000073900060000000000001000
initial_SP_EL3_value:
	.octa 0x404000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000e0100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000600ffc00000000005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cce820 // CTHI-C.CR-C Cd:0 Cn:1 1010:1010 opc:11 Rm:12 11000010110:11000010110
	.inst 0xb8025447 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:7 Rn:2 01:01 imm9:000100101 0:0 opc:00 111000:111000 size:10
	.inst 0xba0003c1 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:30 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:1
	.inst 0x489f7fd7 // stllrh:aarch64/instrs/memory/ordered Rt:23 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xad5ea6df // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:31 Rn:22 Rt2:01001 imm7:0111101 L:1 1011010:1011010 opc:10
	.inst 0x375046d6 // tbnz:aarch64/instrs/branch/conditional/test Rt:22 imm14:00001000110110 b40:01010 op:1 011011:011011 b5:0
	.zero 2260
	.inst 0xf80ac69f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:20 01:01 imm9:010101100 0:0 opc:00 111000:111000 size:11
	.inst 0xe2530bf2 // ALDURSH-R.RI-64 Rt:18 Rn:31 op2:10 imm9:100110000 V:0 op1:01 11100010:11100010
	.inst 0xc2d208f8 // SEAL-C.CC-C Cd:24 Cn:7 0010:0010 opc:00 Cm:18 11000010110:11000010110
	.inst 0x8af27be0 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:31 imm6:011110 Rm:18 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0xc2c21160
	.zero 1046272
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
	.inst 0xc24001a2 // ldr c2, [x13, #0]
	.inst 0xc24005a7 // ldr c7, [x13, #1]
	.inst 0xc24009b4 // ldr c20, [x13, #2]
	.inst 0xc2400db6 // ldr c22, [x13, #3]
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc24015be // ldr c30, [x13, #5]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085003a
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
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001ab // ldr c11, [x13, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24005ab // ldr c11, [x13, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc24009ab // ldr c11, [x13, #2]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc2400dab // ldr c11, [x13, #3]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24011ab // ldr c11, [x13, #4]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc24015ab // ldr c11, [x13, #5]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc24019ab // ldr c11, [x13, #6]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2401dab // ldr c11, [x13, #7]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc24021ab // ldr c11, [x13, #8]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x11, v9.d[0]
	cmp x13, x11
	b.ne comparison_fail
	ldr x13, =0x0
	mov x11, v9.d[1]
	cmp x13, x11
	b.ne comparison_fail
	ldr x13, =0x0
	mov x11, v31.d[0]
	cmp x13, x11
	b.ne comparison_fail
	ldr x13, =0x0
	mov x11, v31.d[1]
	cmp x13, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001808
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004008ec
	ldr x1, =check_data3
	ldr x2, =0x00400900
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400fd0
	ldr x1, =check_data4
	ldr x2, =0x00400ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403f30
	ldr x1, =check_data5
	ldr x2, =0x00403f32
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
