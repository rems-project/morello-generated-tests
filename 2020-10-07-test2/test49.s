.section data0, #alloc, #write
	.zero 480
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x58, 0x00, 0x50, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3600
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x05
.data
check_data2:
	.byte 0x58, 0x00, 0x50, 0x00
.data
check_data3:
	.byte 0x42, 0xd8, 0x66, 0x82, 0x5f, 0x33, 0x03, 0xd5, 0x42, 0x88, 0x54, 0xb8, 0x00, 0x50, 0xc2, 0xc2
	.byte 0xbe, 0x0a, 0xd2, 0x1a, 0x3a, 0xab, 0xc2, 0xc2, 0x3e, 0x50, 0xc1, 0xc2, 0x8a, 0x2c, 0x98, 0xf9
	.byte 0x3e, 0x70, 0x04, 0xe2, 0x3f, 0x80, 0x1b, 0x78, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000000100050000000000400011
	/* C1 */
	.octa 0x4000000000010005000000000000105e
	/* C2 */
	.octa 0x80000000000100050000000000001034
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x20008000000100050000000000400011
	/* C1 */
	.octa 0x4000000000010005000000000000105e
	/* C2 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000010005
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000004000200fffc0000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8266d842 // ALDR-R.RI-32 Rt:2 Rn:2 op:10 imm9:001101101 L:1 1000001001:1000001001
	.inst 0xd503335f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0011 11010101000000110011:11010101000000110011
	.inst 0xb8548842 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:2 10:10 imm9:101001000 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.inst 0x1ad20abe // udiv:aarch64/instrs/integer/arithmetic/div Rd:30 Rn:21 o1:0 00001:00001 Rm:18 0011010110:0011010110 sf:0
	.inst 0xc2c2ab3a // EORFLGS-C.CR-C Cd:26 Cn:25 1010:1010 opc:10 Rm:2 11000010110:11000010110
	.inst 0xc2c1503e // CFHI-R.C-C Rd:30 Cn:1 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xf9982c8a // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:10 Rn:4 imm12:011000001011 opc:10 111001:111001 size:11
	.inst 0xe204703e // ASTURB-R.RI-32 Rt:30 Rn:1 op2:00 imm9:001000111 V:0 op1:00 11100010:11100010
	.inst 0x781b803f // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:110111000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c210e0
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f72 // ldr c18, [x27, #3]
	.inst 0xc2401379 // ldr c25, [x27, #4]
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
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030fb // ldr c27, [c7, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826010fb // ldr c27, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400367 // ldr c7, [x27, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400767 // ldr c7, [x27, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400b67 // ldr c7, [x27, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400f67 // ldr c7, [x27, #3]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2401367 // ldr c7, [x27, #4]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc2401767 // ldr c7, [x27, #5]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2401b67 // ldr c7, [x27, #6]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001016
	ldr x1, =check_data0
	ldr x2, =0x00001018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010a5
	ldr x1, =check_data1
	ldr x2, =0x000010a6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e8
	ldr x1, =check_data2
	ldr x2, =0x000011ec
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
	ldr x0, =0x004fffa0
	ldr x1, =check_data4
	ldr x2, =0x004fffa4
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
	.inst 0xc28b413b // msr DDC_EL3, c27
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
