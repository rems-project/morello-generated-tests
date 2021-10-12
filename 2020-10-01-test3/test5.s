.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1f, 0xd0, 0xc0, 0xc2, 0x9f, 0x5b, 0x83, 0x78, 0xdf, 0x53, 0x1d, 0xe2, 0xfa, 0x11, 0xc0, 0xc2
	.byte 0xb2, 0x83, 0x85, 0x78, 0xa1, 0xbf, 0x51, 0x82, 0x7e, 0x7d, 0xbf, 0x9b, 0x42, 0x64, 0xb4, 0x8a
	.byte 0x73, 0xa1, 0xdd, 0xc2, 0x1f, 0x00, 0xda, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x700060000000000000000
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x400000000000000000000000
	/* C28 */
	.octa 0x80000000540100040000000000001001
	/* C29 */
	.octa 0x800000000005000700000000000016d8
	/* C30 */
	.octa 0x2003
final_cap_values:
	/* C0 */
	.octa 0x700060000000000000000
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff800000000000000000000000
	/* C15 */
	.octa 0x400000000000000000000000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x3fff800000000000000000000000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x80000000540100040000000000001001
	/* C29 */
	.octa 0x800000000005000700000000000016d8
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500200000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000288030080000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0d01f // GCPERM-R.C-C Rd:31 Cn:0 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x78835b9f // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:28 10:10 imm9:000110101 0:0 opc:10 111000:111000 size:01
	.inst 0xe21d53df // ASTURB-R.RI-32 Rt:31 Rn:30 op2:00 imm9:111010101 V:0 op1:00 11100010:11100010
	.inst 0xc2c011fa // GCBASE-R.C-C Rd:26 Cn:15 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x788583b2 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:29 00:00 imm9:001011000 0:0 opc:10 111000:111000 size:01
	.inst 0x8251bfa1 // ASTR-R.RI-64 Rt:1 Rn:29 op:11 imm9:100011011 L:0 1000001001:1000001001
	.inst 0x9bbf7d7e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:11 Ra:31 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0x8ab46442 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:2 imm6:011001 Rm:20 N:1 shift:10 01010:01010 opc:00 sf:1
	.inst 0xc2dda173 // CLRPERM-C.CR-C Cd:19 Cn:11 000:000 1:1 10:10 Rm:29 11000010110:11000010110
	.inst 0xc2da001f // SCBNDS-C.CR-C Cd:31 Cn:0 000:000 opc:00 0:0 Rm:26 11000010110:11000010110
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b6b // ldr c11, [x27, #2]
	.inst 0xc2400f6f // ldr c15, [x27, #3]
	.inst 0xc240137c // ldr c28, [x27, #4]
	.inst 0xc240177d // ldr c29, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307b // ldr c27, [c3, #3]
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	.inst 0x8260107b // ldr c27, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400363 // ldr c3, [x27, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400763 // ldr c3, [x27, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b63 // ldr c3, [x27, #2]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2400f63 // ldr c3, [x27, #3]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401363 // ldr c3, [x27, #4]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401763 // ldr c3, [x27, #5]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2401b63 // ldr c3, [x27, #6]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2401f63 // ldr c3, [x27, #7]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2402363 // ldr c3, [x27, #8]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402763 // ldr c3, [x27, #9]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001036
	ldr x1, =check_data0
	ldr x2, =0x00001038
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001730
	ldr x1, =check_data1
	ldr x2, =0x00001732
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fb0
	ldr x1, =check_data2
	ldr x2, =0x00001fb8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fd8
	ldr x1, =check_data3
	ldr x2, =0x00001fd9
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
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
