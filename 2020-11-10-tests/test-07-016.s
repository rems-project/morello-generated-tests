.section data0, #alloc, #write
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x3f, 0x22, 0x7f, 0xf8, 0xf3, 0xb1, 0xc0, 0xc2, 0x20, 0x10, 0xc2, 0xc2, 0x5e, 0x0c, 0xc0, 0xda
	.byte 0xc6, 0xa2, 0xdc, 0xc2, 0xdf, 0x13, 0x60, 0x78, 0x5d, 0xfc, 0x5f, 0x22, 0x5f, 0xa0, 0xd7, 0x92
	.byte 0x5f, 0x28, 0xc1, 0xc2, 0x48, 0x1c, 0xdb, 0x28, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000800052010009000000000040000c
	/* C2 */
	.octa 0x800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x500
	/* C22 */
	.octa 0x3fff800000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2000800052010009000000000040000c
	/* C2 */
	.octa 0xd8
	/* C6 */
	.octa 0x3fff800000000000000000000000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xffff
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x500
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0xffff
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000206000e0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf87f223f // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:17 00:00 opc:010 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c0b1f3 // GCSEAL-R.C-C Rd:19 Cn:15 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c21020 // BR-C-C 00000:00000 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xdac00c5e // rev:aarch64/instrs/integer/arithmetic/rev Rd:30 Rn:2 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2dca2c6 // CLRPERM-C.CR-C Cd:6 Cn:22 000:000 1:1 10:10 Rm:28 11000010110:11000010110
	.inst 0x786013df // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x225ffc5d // LDAXR-C.R-C Ct:29 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x92d7a05f // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:31 imm16:1011110100000010 hw:10 100101:100101 opc:00 sf:1
	.inst 0xc2c1285f // BICFLGS-C.CR-C Cd:31 Cn:2 1010:1010 opc:00 Rm:1 11000010110:11000010110
	.inst 0x28db1c48 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:8 Rn:2 Rt2:00111 imm7:0110110 L:1 1010001:1010001 opc:00
	.inst 0xc2c21300
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae2 // ldr c2, [x23, #2]
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc24012f1 // ldr c17, [x23, #4]
	.inst 0xc24016f6 // ldr c22, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851037
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603317 // ldr c23, [c24, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601317 // ldr c23, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f8 // ldr c24, [x23, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24006f8 // ldr c24, [x23, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400af8 // ldr c24, [x23, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400ef8 // ldr c24, [x23, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc24012f8 // ldr c24, [x23, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24016f8 // ldr c24, [x23, #5]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401af8 // ldr c24, [x23, #6]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401ef8 // ldr c24, [x23, #7]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc24022f8 // ldr c24, [x23, #8]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc24026f8 // ldr c24, [x23, #9]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2402af8 // ldr c24, [x23, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402ef8 // ldr c24, [x23, #11]
	.inst 0xc2d8a7c1 // chkeq c30, c24
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
	ldr x0, =0x00001500
	ldr x1, =check_data1
	ldr x2, =0x00001508
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
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
