.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data2:
	.byte 0x8c, 0x60, 0xd6, 0xc2, 0xcd, 0x7f, 0x7f, 0x42, 0xc1, 0x93, 0xc1, 0xc2, 0x3f, 0xb6, 0x5a, 0x79
	.byte 0xc2, 0x93, 0xc8, 0x78, 0x1f, 0x9b, 0xda, 0xc2, 0x07, 0x61, 0x85, 0xb8, 0xcd, 0xd3, 0x82, 0x9a
	.byte 0x7f, 0xd7, 0xb7, 0x42, 0x9c, 0x65, 0xc2, 0xc2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x400121100000000000002112
	/* C8 */
	.octa 0x1fa2
	/* C17 */
	.octa 0x3ff802
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x20100000000000
	/* C24 */
	.octa 0x20000100040000000000000000
	/* C27 */
	.octa 0x2080
	/* C30 */
	.octa 0x80000000000100050000000000001f73
final_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000001f73
	/* C2 */
	.octa 0x1
	/* C4 */
	.octa 0x400121100000000000002112
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1fa2
	/* C12 */
	.octa 0x400121100020100000002110
	/* C13 */
	.octa 0x1f73
	/* C17 */
	.octa 0x3ff802
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x20100000000000
	/* C24 */
	.octa 0x20000100040000000000000000
	/* C27 */
	.octa 0x2080
	/* C28 */
	.octa 0x400121100000000000000001
	/* C30 */
	.octa 0x80000000000100050000000000001f73
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 112
	.dword final_cap_values + 208
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d6608c // SCOFF-C.CR-C Cd:12 Cn:4 000:000 opc:11 0:0 Rm:22 11000010110:11000010110
	.inst 0x427f7fcd // ALDARB-R.R-B Rt:13 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c193c1 // CLRTAG-C.C-C Cd:1 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0x795ab63f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:17 imm12:011010101101 opc:01 111001:111001 size:01
	.inst 0x78c893c2 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:30 00:00 imm9:010001001 0:0 opc:11 111000:111000 size:01
	.inst 0xc2da9b1f // ALIGND-C.CI-C Cd:31 Cn:24 0110:0110 U:0 imm6:110101 11000010110:11000010110
	.inst 0xb8856107 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:8 00:00 imm9:001010110 0:0 opc:10 111000:111000 size:10
	.inst 0x9a82d3cd // csel:aarch64/instrs/integer/conditional/select Rd:13 Rn:30 o2:0 0:0 cond:1101 Rm:2 011010100:011010100 op:0 sf:1
	.inst 0x42b7d77f // STP-C.RIB-C Ct:31 Rn:27 Ct2:10101 imm7:1101111 L:0 010000101:010000101
	.inst 0xc2c2659c // CPYVALUE-C.C-C Cd:28 Cn:12 001:001 opc:11 0:0 Cm:2 11000010110:11000010110
	.inst 0xc2c21260
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e4 // ldr c4, [x23, #0]
	.inst 0xc24006e8 // ldr c8, [x23, #1]
	.inst 0xc2400af1 // ldr c17, [x23, #2]
	.inst 0xc2400ef5 // ldr c21, [x23, #3]
	.inst 0xc24012f6 // ldr c22, [x23, #4]
	.inst 0xc24016f8 // ldr c24, [x23, #5]
	.inst 0xc2401afb // ldr c27, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	mov x23, #0x80000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603277 // ldr c23, [c19, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601277 // ldr c23, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x19, #0x9
	and x23, x23, x19
	cmp x23, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f3 // ldr c19, [x23, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24006f3 // ldr c19, [x23, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400af3 // ldr c19, [x23, #2]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc24012f3 // ldr c19, [x23, #4]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc24016f3 // ldr c19, [x23, #5]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401af3 // ldr c19, [x23, #6]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc2401ef3 // ldr c19, [x23, #7]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc24022f3 // ldr c19, [x23, #8]
	.inst 0xc2d3a6a1 // chkeq c21, c19
	b.ne comparison_fail
	.inst 0xc24026f3 // ldr c19, [x23, #9]
	.inst 0xc2d3a6c1 // chkeq c22, c19
	b.ne comparison_fail
	.inst 0xc2402af3 // ldr c19, [x23, #10]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2402ef3 // ldr c19, [x23, #11]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc24032f3 // ldr c19, [x23, #12]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc24036f3 // ldr c19, [x23, #13]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f70
	ldr x1, =check_data0
	ldr x2, =0x00001f90
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
	ldr x1, =check_data1
	ldr x2, =0x00001ffe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040055c
	ldr x1, =check_data3
	ldr x2, =0x0040055e
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
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
