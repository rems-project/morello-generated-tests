.section data0, #alloc, #write
	.zero 944
	.byte 0x0d, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3136
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x0d, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0x32, 0x70, 0xc0, 0xc2, 0x00, 0xb6, 0x4f, 0x37, 0x01, 0x70, 0xd7, 0xc2, 0xde, 0x3b, 0xd0, 0xc2
	.byte 0xff, 0x3f, 0x31, 0x11, 0xc6, 0x53, 0xc6, 0xc2, 0x9f, 0xfd, 0xa1, 0x88, 0xf9, 0xbc, 0x7d, 0x82
	.byte 0x41, 0xa4, 0xc1, 0xc2, 0x3e, 0xb7, 0x68, 0xe2, 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x71, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90000000400000010000000000001000
	/* C1 */
	.octa 0x700060000000000000001
	/* C2 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C7 */
	.octa 0x4ff118
	/* C12 */
	.octa 0xc0000000000100070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x90000000400000010000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C6 */
	.octa 0x20008000c02c000c000000000040000c
	/* C7 */
	.octa 0x4ff118
	/* C12 */
	.octa 0xc0000000000100070000000000001000
	/* C18 */
	.octa 0x1
	/* C25 */
	.octa 0x1071
	/* C30 */
	.octa 0x20008000c02c000c000000000040000c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000300fe000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000013b0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c07032 // GCOFF-R.C-C Rd:18 Cn:1 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x374fb600 // tbnz:aarch64/instrs/branch/conditional/test Rt:0 imm14:11110110110000 b40:01001 op:1 011011:011011 b5:0
	.inst 0xc2d77001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:0111011 110000101101:110000101101
	.inst 0xc2d03bde // SCBNDS-C.CI-C Cd:30 Cn:30 1110:1110 S:0 imm6:100000 11000010110:11000010110
	.inst 0x11313fff // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:31 imm12:110001001111 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2c653c6 // CLRPERM-C.CI-C Cd:6 Cn:30 100:100 perm:010 1100001011000110:1100001011000110
	.inst 0x88a1fd9f // cas:aarch64/instrs/memory/atomicops/cas/single Rt:31 Rn:12 11111:11111 o0:1 Rs:1 1:1 L:0 0010001:0010001 size:10
	.inst 0x827dbcf9 // ALDR-R.RI-64 Rt:25 Rn:7 op:11 imm9:111011011 L:1 1000001001:1000001001
	.inst 0xc2c1a441 // CHKEQ-_.CC-C 00001:00001 Cn:2 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xe268b73e // ALDUR-V.RI-H Rt:30 Rn:25 op2:01 imm9:010001011 V:1 op1:01 11100010:11100010
	.inst 0xc2c21300
	.zero 1048516
	.inst 0x00001071
	.zero 12
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e87 // ldr c7, [x20, #3]
	.inst 0xc240128c // ldr c12, [x20, #4]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851037
	msr SCTLR_EL3, x20
	ldr x20, =0x84
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603314 // ldr c20, [c24, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601314 // ldr c20, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x24, #0xf
	and x20, x20, x24
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400298 // ldr c24, [x20, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400698 // ldr c24, [x20, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400a98 // ldr c24, [x20, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400e98 // ldr c24, [x20, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401298 // ldr c24, [x20, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401698 // ldr c24, [x20, #5]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401a98 // ldr c24, [x20, #6]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2401e98 // ldr c24, [x20, #7]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402298 // ldr c24, [x20, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x24, v30.d[0]
	cmp x20, x24
	b.ne comparison_fail
	ldr x20, =0x0
	mov x24, v30.d[1]
	cmp x20, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010fc
	ldr x1, =check_data1
	ldr x2, =0x000010fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013b0
	ldr x1, =check_data2
	ldr x2, =0x000013c0
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
	ldr x0, =0x004ffff0
	ldr x1, =check_data4
	ldr x2, =0x004ffff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
