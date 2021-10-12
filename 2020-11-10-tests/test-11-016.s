.section data0, #alloc, #write
	.byte 0x6c, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x6c, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe1, 0x53, 0xc3, 0xc2, 0xc0, 0x13, 0x60, 0x78, 0xfe, 0xbc, 0xbb, 0x02, 0x57, 0xad, 0xcb, 0xe2
	.byte 0xe0, 0x3f, 0x01, 0x62, 0xe2, 0x4b, 0xcc, 0xc2, 0x14, 0x00, 0x09, 0x78, 0x42, 0x60, 0xde, 0xc2
	.byte 0xc1, 0xd3, 0xc5, 0xc2, 0x20, 0xa3, 0x3f, 0x92, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C7 */
	.octa 0x400040030020800040000000
	/* C10 */
	.octa 0x80000000000700070000000000000f56
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C1 */
	.octa 0xc000000002c30006002080003ffff111
	/* C2 */
	.octa 0x2080003ffff111
	/* C7 */
	.octa 0x400040030020800040000000
	/* C10 */
	.octa 0x80000000000700070000000000000f56
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x40004003002080003ffff111
initial_SP_EL3_value:
	.octa 0xfe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404200000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000002c3000600ffc00000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c353e1 // SEAL-C.CI-C Cd:1 Cn:31 100:100 form:10 11000010110000110:11000010110000110
	.inst 0x786013c0 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:30 00:00 opc:001 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x02bbbcfe // SUB-C.CIS-C Cd:30 Cn:7 imm12:111011101111 sh:0 A:1 00000010:00000010
	.inst 0xe2cbad57 // ALDUR-C.RI-C Ct:23 Rn:10 op2:11 imm9:010111010 V:0 op1:11 11100010:11100010
	.inst 0x62013fe0 // STNP-C.RIB-C Ct:0 Rn:31 Ct2:01111 imm7:0000010 L:0 011000100:011000100
	.inst 0xc2cc4be2 // UNSEAL-C.CC-C Cd:2 Cn:31 0010:0010 opc:01 Cm:12 11000010110:11000010110
	.inst 0x78090014 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:20 Rn:0 00:00 imm9:010010000 0:0 opc:00 111000:111000 size:01
	.inst 0xc2de6042 // SCOFF-C.CR-C Cd:2 Cn:2 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c5d3c1 // CVTDZ-C.R-C Cd:1 Rn:30 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x923fa320 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:25 imms:101000 immr:111111 N:0 100100:100100 opc:00 sf:1
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2400f0c // ldr c12, [x24, #3]
	.inst 0xc240130f // ldr c15, [x24, #4]
	.inst 0xc2401714 // ldr c20, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103d
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d8 // ldr c24, [c6, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010d8 // ldr c24, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400306 // ldr c6, [x24, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401306 // ldr c6, [x24, #4]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401706 // ldr c6, [x24, #5]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401b06 // ldr c6, [x24, #6]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2401f06 // ldr c6, [x24, #7]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402306 // ldr c6, [x24, #8]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x00001ffc
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
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
