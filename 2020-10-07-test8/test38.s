.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xc8
.data
check_data2:
	.byte 0x21, 0xd8, 0x03, 0x38, 0x1d, 0xb0, 0x3e, 0x0b, 0xbf, 0x8a, 0xfe, 0xc2, 0x02, 0x7c, 0x7f, 0x42
	.byte 0xfa, 0x27, 0xc6, 0xc2, 0x81, 0x12, 0xc0, 0xc2, 0x47, 0x5b, 0x4a, 0x3a, 0xd1, 0x63, 0x82, 0xda
	.byte 0x1f, 0xac, 0x28, 0xab, 0xa0, 0x10, 0xc5, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000200710070000000000001000
	/* C1 */
	.octa 0xffffffffffffffc8
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x800000000000000000000000
	/* C20 */
	.octa 0x700060000000000000000
	/* C21 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0xffffffffffffffff
	/* C20 */
	.octa 0x700060000000000000000
	/* C21 */
	.octa 0x0
	/* C26 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000120100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000001007100700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3803d821 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:000111101 0:0 opc:00 111000:111000 size:00
	.inst 0x0b3eb01d // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:29 Rn:0 imm3:100 option:101 Rm:30 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2fe8abf // ORRFLGS-C.CI-C Cd:31 Cn:21 0:0 01:01 imm8:11110100 11000010111:11000010111
	.inst 0x427f7c02 // ALDARB-R.R-B Rt:2 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c627fa // CPYTYPE-C.C-C Cd:26 Cn:31 001:001 opc:01 0:0 Cm:6 11000010110:11000010110
	.inst 0xc2c01281 // GCBASE-R.C-C Rd:1 Cn:20 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x3a4a5b47 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0111 0:0 Rn:26 10:10 cond:0101 imm5:01010 111010010:111010010 op:0 sf:0
	.inst 0xda8263d1 // csinv:aarch64/instrs/integer/conditional/select Rd:17 Rn:30 o2:0 0:0 cond:0110 Rm:2 011010100:011010100 op:1 sf:1
	.inst 0xab28ac1f // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:0 imm3:011 option:101 Rm:8 01011001:01011001 S:1 op:0 sf:1
	.inst 0xc2c510a0 // CVTD-R.C-C Rd:0 Cn:5 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400985 // ldr c5, [x12, #2]
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc2401194 // ldr c20, [x12, #4]
	.inst 0xc2401595 // ldr c21, [x12, #5]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306c // ldr c12, [c3, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260106c // ldr c12, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x3, #0xf
	and x12, x12, x3
	cmp x12, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400183 // ldr c3, [x12, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400583 // ldr c3, [x12, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400983 // ldr c3, [x12, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400d83 // ldr c3, [x12, #3]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2401183 // ldr c3, [x12, #4]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401583 // ldr c3, [x12, #5]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401983 // ldr c3, [x12, #6]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2401d83 // ldr c3, [x12, #7]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402183 // ldr c3, [x12, #8]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001005
	ldr x1, =check_data1
	ldr x2, =0x00001006
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
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
