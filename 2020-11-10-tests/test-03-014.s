.section data0, #alloc, #write
	.zero 1024
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xde, 0x07, 0xc0, 0x5a, 0x29, 0x7c, 0x5f, 0x48, 0x49, 0xfc, 0x1f, 0x42, 0x26, 0xe3, 0x1c, 0x54
.data
check_data5:
	.byte 0xff, 0x73, 0x20, 0x38, 0x40, 0x7c, 0x3f, 0x42, 0x1e, 0xc5, 0x30, 0xb5
.data
check_data6:
	.byte 0xe2, 0xb0, 0x14, 0x39, 0xc1, 0x93, 0xc1, 0xc2, 0x2e, 0x51, 0xc0, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000100707a70000000000001780
	/* C2 */
	.octa 0x400000003020d8080000000000001000
	/* C7 */
	.octa 0x40000000000100050000000000001000
	/* C30 */
	.octa 0x40000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000
	/* C2 */
	.octa 0x400000003020d8080000000000001000
	/* C7 */
	.octa 0x40000000000100050000000000001000
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000
initial_SP_EL3_value:
	.octa 0xc0000000400210000000000000001408
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000401000600080008060fc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac007de // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0x485f7c29 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:9 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x421ffc49 // STLR-C.R-C Ct:9 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x541ce326 // b_cond:aarch64/instrs/branch/conditional/cond cond:0110 0:0 imm19:0001110011100011001 01010100:01010100
	.zero 236640
	.inst 0x382073ff // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:111 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x423f7c40 // ASTLRB-R.R-B Rt:0 Rn:2 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xb530c51e // cbnz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:0011000011000101000 op:1 011010:011010 sf:1
	.zero 399516
	.inst 0x3914b0e2 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:7 imm12:010100101100 opc:00 111001:111001 size:00
	.inst 0xc2c193c1 // CLRTAG-C.C-C Cd:1 Cn:30 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc2c0512e // GCVALUE-R.C-C Rd:14 Cn:9 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c21280
	.zero 412376
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2400d87 // ldr c7, [x12, #3]
	.inst 0xc240119e // ldr c30, [x12, #4]
	/* Set up flags and system registers */
	mov x12, #0x10000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260328c // ldr c12, [c20, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260128c // ldr c12, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x20, #0x1
	and x12, x12, x20
	cmp x12, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400194 // ldr c20, [x12, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400594 // ldr c20, [x12, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400994 // ldr c20, [x12, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400d94 // ldr c20, [x12, #3]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2401194 // ldr c20, [x12, #4]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401594 // ldr c20, [x12, #5]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401994 // ldr c20, [x12, #6]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001408
	ldr x1, =check_data1
	ldr x2, =0x00001409
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000152c
	ldr x1, =check_data2
	ldr x2, =0x0000152d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001780
	ldr x1, =check_data3
	ldr x2, =0x00001782
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00439c70
	ldr x1, =check_data5
	ldr x2, =0x00439c7c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0049b518
	ldr x1, =check_data6
	ldr x2, =0x0049b528
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
