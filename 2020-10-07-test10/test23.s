.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xa7, 0x12, 0x42, 0xaa, 0xc1, 0xa7, 0xde, 0xc2, 0x63, 0x11, 0xc2, 0xc2
	.byte 0x27, 0x7c, 0x5e, 0x9b, 0x60, 0x20, 0xe2, 0xc2, 0x21, 0xa8, 0xd2, 0xc2, 0x14, 0x90, 0xc5, 0xc2
	.byte 0x3f, 0x40, 0xc0, 0xc2, 0x3f, 0x84, 0x0e, 0xa2, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000040000fc20000000000001fc0
	/* C3 */
	.octa 0x8000000000ffffffffffe001
	/* C11 */
	.octa 0x20000000800080080000000000400011
	/* C18 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x8000000000ffffffffffe001
	/* C1 */
	.octa 0x4000000040000fc20000000000002e40
	/* C3 */
	.octa 0x8000000000ffffffffffe001
	/* C11 */
	.octa 0x20000000800080080000000000400011
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x1200400ffffffffffe001
initial_RDDC_EL0_value:
	.octa 0x1200400ffffc7fffbe004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xaa4212a7 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:7 Rn:21 imm6:000100 Rm:2 N:0 shift:01 01010:01010 opc:01 sf:1
	.inst 0xc2dea7c1 // CHKEQ-_.CC-C 00001:00001 Cn:30 001:001 opc:01 1:1 Cm:30 11000010110:11000010110
	.inst 0xc2c21163 // BRR-C-C 00011:00011 Cn:11 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x9b5e7c27 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:7 Rn:1 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0xc2e22060 // BICFLGS-C.CI-C Cd:0 Cn:3 0:0 00:00 imm8:00010001 11000010111:11000010111
	.inst 0xc2d2a821 // EORFLGS-C.CR-C Cd:1 Cn:1 1010:1010 opc:10 Rm:18 11000010110:11000010110
	.inst 0xc2c59014 // CVTD-C.R-C Cd:20 Rn:0 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c0403f // SCVALUE-C.CR-C Cd:31 Cn:1 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0xa20e843f // STR-C.RIAW-C Ct:31 Rn:1 01:01 imm9:011101000 0:0 opc:00 10100010:10100010
	.inst 0xc2c21260
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2400b2b // ldr c11, [x25, #2]
	.inst 0xc2400f32 // ldr c18, [x25, #3]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	ldr x25, =initial_RDDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28b4339 // msr RDDC_EL0, c25
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601279 // ldr c25, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x19, #0xf
	and x25, x25, x19
	cmp x25, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400333 // ldr c19, [x25, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400733 // ldr c19, [x25, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b33 // ldr c19, [x25, #2]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400f33 // ldr c19, [x25, #3]
	.inst 0xc2d3a561 // chkeq c11, c19
	b.ne comparison_fail
	.inst 0xc2401333 // ldr c19, [x25, #4]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401733 // ldr c19, [x25, #5]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fc0
	ldr x1, =check_data0
	ldr x2, =0x00001fd0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
