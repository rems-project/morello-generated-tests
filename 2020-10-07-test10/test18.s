.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x1f, 0x30, 0x18, 0x39, 0x42, 0xd4, 0xd4, 0xad, 0x2e, 0xbd, 0x52, 0xa2, 0xc2, 0x23, 0x5f, 0x4b
	.byte 0x1f, 0xa8, 0xdf, 0xc2, 0xb6, 0x2b, 0x02, 0xe2, 0x2e, 0xfc, 0xdf, 0xc8, 0xfe, 0x12, 0xc1, 0xc2
	.byte 0x1e, 0xd0, 0xf8, 0xc2, 0x35, 0x16, 0x07, 0x78, 0x60, 0x11, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000005801000100000000000011f2
	/* C1 */
	.octa 0x80000000000300070000000000001020
	/* C2 */
	.octa 0x800000006001000400000000003ffd80
	/* C9 */
	.octa 0x90100000100000100000000000488d60
	/* C17 */
	.octa 0x40000000000100070000000000001068
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x4004e0800000000000000001
	/* C29 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x400000005801000100000000000011f2
	/* C1 */
	.octa 0x80000000000300070000000000001020
	/* C9 */
	.octa 0x90100000100000100000000000488010
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x400000000001000700000000000010d9
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x4004e0800000000000000001
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x4000000058010001c6000000000011f2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005802000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3918301f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:0 imm12:011000001100 opc:00 111001:111001 size:00
	.inst 0xadd4d442 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:2 Rn:2 Rt2:10101 imm7:0101001 L:1 1011011:1011011 opc:10
	.inst 0xa252bd2e // LDR-C.RIBW-C Ct:14 Rn:9 11:11 imm9:100101011 0:0 opc:01 10100010:10100010
	.inst 0x4b5f23c2 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:30 imm6:001000 Rm:31 0:0 shift:01 01011:01011 S:0 op:1 sf:0
	.inst 0xc2dfa81f // EORFLGS-C.CR-C Cd:31 Cn:0 1010:1010 opc:10 Rm:31 11000010110:11000010110
	.inst 0xe2022bb6 // ALDURSB-R.RI-64 Rt:22 Rn:29 op2:10 imm9:000100010 V:0 op1:00 11100010:11100010
	.inst 0xc8dffc2e // ldar:aarch64/instrs/memory/ordered Rt:14 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c112fe // GCLIM-R.C-C Rd:30 Cn:23 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2f8d01e // EORFLGS-C.CI-C Cd:30 Cn:0 0:0 10:10 imm8:11000110 11000010111:11000010111
	.inst 0x78071635 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:21 Rn:17 01:01 imm9:001110001 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21160
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de9 // ldr c9, [x15, #3]
	.inst 0xc24011f1 // ldr c17, [x15, #4]
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	.inst 0xc24019f7 // ldr c23, [x15, #6]
	.inst 0xc2401dfd // ldr c29, [x15, #7]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316f // ldr c15, [c11, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260116f // ldr c15, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001eb // ldr c11, [x15, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24005eb // ldr c11, [x15, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24009eb // ldr c11, [x15, #2]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc24011eb // ldr c11, [x15, #4]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc24015eb // ldr c11, [x15, #5]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc24019eb // ldr c11, [x15, #6]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc2401deb // ldr c11, [x15, #7]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc24021eb // ldr c11, [x15, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24025eb // ldr c11, [x15, #9]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0xe2022bb6c2dfa81f
	mov x11, v2.d[0]
	cmp x15, x11
	b.ne comparison_fail
	ldr x15, =0xc2c112fec8dffc2e
	mov x11, v2.d[1]
	cmp x15, x11
	b.ne comparison_fail
	ldr x15, =0x78071635c2f8d01e
	mov x11, v21.d[0]
	cmp x15, x11
	b.ne comparison_fail
	ldr x15, =0xc2c21160
	mov x11, v21.d[1]
	cmp x15, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x0000106a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fe
	ldr x1, =check_data2
	ldr x2, =0x000017ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400030
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00488010
	ldr x1, =check_data4
	ldr x2, =0x00488020
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
