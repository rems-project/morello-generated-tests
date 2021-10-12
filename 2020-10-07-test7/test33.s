.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0xfe, 0x43, 0xc5, 0xc2, 0x62, 0xd1, 0xc0, 0xc2, 0x3c, 0xff, 0xb6, 0x9b, 0x0c, 0xf6, 0x86, 0xe2
	.byte 0xdf, 0xf7, 0x96, 0x62, 0xce, 0x6f, 0xff, 0x6a, 0xe2, 0x22, 0xd8, 0x78, 0xfe, 0x74, 0xe1, 0xca
	.byte 0xff, 0xd3, 0x31, 0x0b, 0x7c, 0x0e, 0xd5, 0x9a, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x1830
	/* C16 */
	.octa 0x800000004004000c0000000000001001
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x1a7e
	/* C29 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1830
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x1b00
	/* C16 */
	.octa 0x800000004004000c0000000000001001
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x1a7e
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x4000000000000000000000000000
initial_SP_EL3_value:
	.octa 0x601120010000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000400409140000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c543fe // SCVALUE-C.CR-C Cd:30 Cn:31 000:000 opc:10 0:0 Rm:5 11000010110:11000010110
	.inst 0xc2c0d162 // GCPERM-R.C-C Rd:2 Cn:11 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x9bb6ff3c // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:28 Rn:25 Ra:31 o0:1 Rm:22 01:01 U:1 10011011:10011011
	.inst 0xe286f60c // ALDUR-R.RI-32 Rt:12 Rn:16 op2:01 imm9:001101111 V:0 op1:10 11100010:11100010
	.inst 0x6296f7df // STP-C.RIBW-C Ct:31 Rn:30 Ct2:11101 imm7:0101101 L:0 011000101:011000101
	.inst 0x6aff6fce // bics:aarch64/instrs/integer/logical/shiftedreg Rd:14 Rn:30 imm6:011011 Rm:31 N:1 shift:11 01010:01010 opc:11 sf:0
	.inst 0x78d822e2 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:23 00:00 imm9:110000010 0:0 opc:11 111000:111000 size:01
	.inst 0xcae174fe // eon:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:7 imm6:011101 Rm:1 N:1 shift:11 01010:01010 opc:10 sf:1
	.inst 0x0b31d3ff // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:31 imm3:100 option:110 Rm:17 01011001:01011001 S:0 op:0 sf:0
	.inst 0x9ad50e7c // sdiv:aarch64/instrs/integer/arithmetic/div Rd:28 Rn:19 o1:1 00001:00001 Rm:21 0011010110:0011010110 sf:1
	.inst 0xc2c210c0
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
	.inst 0xc24001a5 // ldr c5, [x13, #0]
	.inst 0xc24005b0 // ldr c16, [x13, #1]
	.inst 0xc24009b5 // ldr c21, [x13, #2]
	.inst 0xc2400db7 // ldr c23, [x13, #3]
	.inst 0xc24011bd // ldr c29, [x13, #4]
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
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030cd // ldr c13, [c6, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826010cd // ldr c13, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	mov x6, #0xf
	and x13, x13, x6
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a6 // ldr c6, [x13, #0]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc24005a6 // ldr c6, [x13, #1]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc24009a6 // ldr c6, [x13, #2]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2400da6 // ldr c6, [x13, #3]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc24011a6 // ldr c6, [x13, #4]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc24015a6 // ldr c6, [x13, #5]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc24019a6 // ldr c6, [x13, #6]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2401da6 // ldr c6, [x13, #7]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc24021a6 // ldr c6, [x13, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001074
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a00
	ldr x1, =check_data1
	ldr x2, =0x00001a02
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b00
	ldr x1, =check_data2
	ldr x2, =0x00001b20
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
