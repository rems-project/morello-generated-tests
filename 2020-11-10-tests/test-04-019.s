.section data0, #alloc, #write
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 96
	.byte 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0xff
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x51, 0xef, 0x42, 0xa2, 0x41, 0x41, 0x7e, 0x38, 0xbe, 0x32, 0xc7, 0xc2, 0xf7, 0x75, 0x89, 0xb4
	.byte 0xbe, 0x13, 0xed, 0x78, 0x1f, 0x01, 0x7e, 0x38, 0x06, 0x7c, 0x5f, 0x08, 0x5e, 0x70, 0x10, 0x3c
	.byte 0x01, 0xa4, 0xc2, 0xc2, 0x40, 0x38, 0xd8, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000001000500000000004ffffe
	/* C2 */
	.octa 0x40000000000100050000000000001104
	/* C8 */
	.octa 0xc0000000000100050000000000001810
	/* C10 */
	.octa 0xc0000000600000140000000000001000
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x80000000200100070000000000001100
	/* C29 */
	.octa 0xc0000000000100050000000000001070
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40000000513411040000000000001104
	/* C1 */
	.octa 0x81
	/* C2 */
	.octa 0x40000000000100050000000000001104
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0xc0000000000100050000000000001810
	/* C10 */
	.octa 0xc0000000600000140000000000001000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x800000002001000700000000000013e0
	/* C29 */
	.octa 0xc0000000000100050000000000001070
	/* C30 */
	.octa 0xff00
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000610070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa242ef51 // LDR-C.RIBW-C Ct:17 Rn:26 11:11 imm9:000101110 0:0 opc:01 10100010:10100010
	.inst 0x387e4141 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:10 00:00 opc:100 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2c732be // RRMASK-R.R-C Rd:30 Rn:21 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xb48975f7 // cbz:aarch64/instrs/branch/conditional/compare Rt:23 imm19:1000100101110101111 op:0 011010:011010 sf:1
	.inst 0x78ed13be // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:29 00:00 opc:001 0:0 Rs:13 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x387e011f // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:8 00:00 opc:000 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x085f7c06 // ldxrb:aarch64/instrs/memory/exclusive/single Rt:6 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x3c10705e // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:30 Rn:2 00:00 imm9:100000111 0:0 opc:00 111100:111100 size:00
	.inst 0xc2c2a401 // CHKEQ-_.CC-C 00001:00001 Cn:0 001:001 opc:01 1:1 Cm:2 11000010110:11000010110
	.inst 0xc2d83840 // SCBNDS-C.CI-C Cd:0 Cn:2 1110:1110 S:0 imm6:110000 11000010110:11000010110
	.inst 0xc2c21060
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400968 // ldr c8, [x11, #2]
	.inst 0xc2400d6a // ldr c10, [x11, #3]
	.inst 0xc240116d // ldr c13, [x11, #4]
	.inst 0xc2401575 // ldr c21, [x11, #5]
	.inst 0xc2401977 // ldr c23, [x11, #6]
	.inst 0xc2401d7a // ldr c26, [x11, #7]
	.inst 0xc240217d // ldr c29, [x11, #8]
	.inst 0xc240257e // ldr c30, [x11, #9]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260106b // ldr c11, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x3, #0xf
	and x11, x11, x3
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400163 // ldr c3, [x11, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400563 // ldr c3, [x11, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400d63 // ldr c3, [x11, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2401163 // ldr c3, [x11, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401563 // ldr c3, [x11, #5]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2401963 // ldr c3, [x11, #6]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2401d63 // ldr c3, [x11, #7]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2402163 // ldr c3, [x11, #8]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2402563 // ldr c3, [x11, #9]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402963 // ldr c3, [x11, #10]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2402d63 // ldr c3, [x11, #11]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2403163 // ldr c3, [x11, #12]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x3, v30.d[0]
	cmp x11, x3
	b.ne comparison_fail
	ldr x11, =0x0
	mov x3, v30.d[1]
	cmp x11, x3
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
	ldr x0, =0x0000100b
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001072
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013e0
	ldr x1, =check_data3
	ldr x2, =0x000013f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001810
	ldr x1, =check_data4
	ldr x2, =0x00001811
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
