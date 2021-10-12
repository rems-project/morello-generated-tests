.section data0, #alloc, #write
	.zero 256
	.byte 0xff, 0x0f, 0x00, 0x81, 0x0d, 0x40, 0x00, 0xf7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.byte 0xfe, 0x0f, 0x00, 0x81, 0x0d, 0x40, 0x00, 0xf7
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x01, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xdf, 0x13, 0xa1, 0xf8, 0x49, 0x94, 0x93, 0x9a, 0x20, 0x40, 0x89, 0x82, 0xa7, 0x88, 0xf6, 0xc2
	.byte 0xc2, 0x72, 0xf2, 0xc2, 0xe0, 0x8b, 0xc1, 0xc2, 0x49, 0xb7, 0x16, 0x54
.data
check_data4:
	.byte 0x40, 0x46, 0xdd, 0x38, 0xa1, 0xdd, 0x00, 0xa2, 0x02, 0x7f, 0x15, 0x11, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x100000f0000000000001001
	/* C2 */
	.octa 0x11b
	/* C5 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000700200030000000000001110
	/* C18 */
	.octa 0x800000000001000700000000004ffffe
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0xc0000000400001310000000000001100
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x100000f0000000000001001
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xb400000000000000
	/* C9 */
	.octa 0x11b
	/* C13 */
	.octa 0x400000007002000300000000000011e0
	/* C18 */
	.octa 0x800000000001000700000000004fffd2
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0xc0000000400001310000000000001100
initial_SP_EL3_value:
	.octa 0x30000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000580000040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8a113df // ldclr:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:30 00:00 opc:001 0:0 Rs:1 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x9a939449 // csinc:aarch64/instrs/integer/conditional/select Rd:9 Rn:2 o2:1 0:0 cond:1001 Rm:19 011010100:011010100 op:0 sf:1
	.inst 0x82894020 // ASTRB-R.RRB-B Rt:0 Rn:1 opc:00 S:0 option:010 Rm:9 0:0 L:0 100000101:100000101
	.inst 0xc2f688a7 // ORRFLGS-C.CI-C Cd:7 Cn:5 0:0 01:01 imm8:10110100 11000010111:11000010111
	.inst 0xc2f272c2 // EORFLGS-C.CI-C Cd:2 Cn:22 0:0 10:10 imm8:10010011 11000010111:11000010111
	.inst 0xc2c18be0 // CHKSSU-C.CC-C Cd:0 Cn:31 0010:0010 opc:10 Cm:1 11000010110:11000010110
	.inst 0x5416b749 // b_cond:aarch64/instrs/branch/conditional/cond cond:1001 0:0 imm19:0001011010110111010 01010100:01010100
	.zero 186084
	.inst 0x38dd4640 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:18 01:01 imm9:111010100 0:0 opc:11 111000:111000 size:00
	.inst 0xa200dda1 // STR-C.RIBW-C Ct:1 Rn:13 11:11 imm9:000001101 0:0 opc:00 10100010:10100010
	.inst 0x11157f02 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:24 imm12:010101011111 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2c21180
	.zero 862448
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c65 // ldr c5, [x3, #3]
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2401876 // ldr c22, [x3, #6]
	.inst 0xc2401c7e // ldr c30, [x3, #7]
	/* Set up flags and system registers */
	mov x3, #0x60000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603183 // ldr c3, [c12, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601183 // ldr c3, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x12, #0xf
	and x3, x3, x12
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006c // ldr c12, [x3, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240046c // ldr c12, [x3, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240086c // ldr c12, [x3, #2]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240106c // ldr c12, [x3, #4]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240146c // ldr c12, [x3, #5]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240186c // ldr c12, [x3, #6]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc2401c6c // ldr c12, [x3, #7]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240206c // ldr c12, [x3, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001100
	ldr x1, =check_data0
	ldr x2, =0x00001108
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001120
	ldr x1, =check_data1
	ldr x2, =0x00001121
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e0
	ldr x1, =check_data2
	ldr x2, =0x000011f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040001c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0042d700
	ldr x1, =check_data4
	ldr x2, =0x0042d710
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
