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
	.zero 2
.data
check_data3:
	.byte 0x5e, 0x04, 0x1f, 0x38, 0xe1, 0x13, 0xc2, 0xc2, 0xe6, 0x07, 0xd0, 0xc2, 0xc1, 0x53, 0xc1, 0xc2
	.byte 0x5e, 0xb0, 0xc5, 0xc2, 0x44, 0x00, 0x0e, 0xba, 0x21, 0x50, 0x4e, 0x78, 0x00, 0x2c, 0xcc, 0x1a
	.byte 0x77, 0x97, 0x13, 0x7c, 0x7f, 0xbe, 0x1d, 0xe2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x3
	/* C12 */
	.octa 0x1
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x800000001ffb000700000000004ff828
	/* C27 */
	.octa 0xffc
	/* C30 */
	.octa 0xffffffffffffff1b0000000000000000
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xfffffffffffffff3
	/* C6 */
	.octa 0x0
	/* C12 */
	.octa 0x1
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x800000001ffb000700000000004ff828
	/* C27 */
	.octa 0xf35
	/* C30 */
	.octa 0x2000800000060027fffffffffffffff3
initial_csp_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600270000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000708060000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x381f045e // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:2 01:01 imm9:111110000 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2d007e6 // BUILD-C.C-C Cd:6 Cn:31 001:001 opc:00 0:0 Cm:16 11000010110:11000010110
	.inst 0xc2c153c1 // CFHI-R.C-C Rd:1 Cn:30 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c5b05e // CVTP-C.R-C Cd:30 Rn:2 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xba0e0044 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:4 Rn:2 000000:000000 Rm:14 11010000:11010000 S:1 op:0 sf:1
	.inst 0x784e5021 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:011100101 0:0 opc:01 111000:111000 size:01
	.inst 0x1acc2c00 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:0 op2:11 0010:0010 Rm:12 0011010110:0011010110 sf:0
	.inst 0x7c139777 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:23 Rn:27 01:01 imm9:100111001 0:0 opc:00 111100:111100 size:01
	.inst 0xe21dbe7f // ALDURSB-R.RI-32 Rt:31 Rn:19 op2:11 imm9:111011011 V:0 op1:00 11100010:11100010
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e2 // ldr c2, [x23, #0]
	.inst 0xc24006ec // ldr c12, [x23, #1]
	.inst 0xc2400af0 // ldr c16, [x23, #2]
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc24012fb // ldr c27, [x23, #4]
	.inst 0xc24016fe // ldr c30, [x23, #5]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q23, =0x0
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_csp_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603077 // ldr c23, [c3, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x82601077 // ldr c23, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e3 // ldr c3, [x23, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24006e3 // ldr c3, [x23, #1]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400ae3 // ldr c3, [x23, #2]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2400ee3 // ldr c3, [x23, #3]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc24012e3 // ldr c3, [x23, #4]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc24016e3 // ldr c3, [x23, #5]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2401ae3 // ldr c3, [x23, #6]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2401ee3 // ldr c3, [x23, #7]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x3, v23.d[0]
	cmp x23, x3
	b.ne comparison_fail
	ldr x23, =0x0
	mov x3, v23.d[1]
	cmp x23, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001003
	ldr x1, =check_data1
	ldr x2, =0x00001004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004ff803
	ldr x1, =check_data4
	ldr x2, =0x004ff804
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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
