.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.byte 0xc2, 0x13, 0xc1, 0xc2, 0xa0, 0x16, 0xfd, 0x29, 0xbb, 0x2b, 0xc0, 0x9a, 0x78, 0x46, 0xcd, 0x78
	.byte 0x61, 0x7c, 0xc0, 0x9b, 0x40, 0x51, 0xc2, 0xc2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x4b, 0x40, 0xe1, 0x82, 0x1e, 0x62, 0x7e, 0x78, 0xde, 0x28, 0xde, 0x1a, 0x5f, 0x2c, 0xd0, 0x1a
	.byte 0x40, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x1000000000000000
	/* C10 */
	.octa 0x20008000200748060000000000490009
	/* C16 */
	.octa 0xc0000000000702270000000000001210
	/* C19 */
	.octa 0x800000006884200a00000000004a2800
	/* C21 */
	.octa 0x8000000054000f8a0000000000401004
	/* C30 */
	.octa 0x620020010000000000000001
final_cap_values:
	/* C0 */
	.octa 0x4000000
	/* C1 */
	.octa 0x400000
	/* C2 */
	.octa 0x2200
	/* C3 */
	.octa 0x1000000000000000
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x20008000200748060000000000490009
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0xc0000000000702270000000000001210
	/* C19 */
	.octa 0x800000006884200a00000000004a28d4
	/* C21 */
	.octa 0x8000000054000f8a0000000000400fec
	/* C24 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000700ffe00000008001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c113c2 // GCLIM-R.C-C Rd:2 Cn:30 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x29fd16a0 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:21 Rt2:00101 imm7:1111010 L:1 1010011:1010011 opc:00
	.inst 0x9ac02bbb // asrv:aarch64/instrs/integer/shift/variable Rd:27 Rn:29 op2:10 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0x78cd4678 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:24 Rn:19 01:01 imm9:011010100 0:0 opc:11 111000:111000 size:01
	.inst 0x9bc07c61 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:3 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0xc2c25140 // RET-C-C 00000:00000 Cn:10 100:100 opc:10 11000010110000100:11000010110000100
	.zero 4052
	.inst 0x04000000
	.zero 585752
	.inst 0x82e1404b // ALDR-R.RRB-32 Rt:11 Rn:2 opc:00 S:0 option:010 Rm:1 1:1 L:1 100000101:100000101
	.inst 0x787e621e // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:16 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x1ade28de // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:6 op2:10 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0x1ad02c5f // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:2 op2:11 0010:0010 Rm:16 0011010110:0011010110 sf:0
	.inst 0xc2c21340
	.zero 458724
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
	ldr x8, =initial_cap_values
	.inst 0xc2400103 // ldr c3, [x8, #0]
	.inst 0xc240050a // ldr c10, [x8, #1]
	.inst 0xc2400910 // ldr c16, [x8, #2]
	.inst 0xc2400d13 // ldr c19, [x8, #3]
	.inst 0xc2401115 // ldr c21, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603348 // ldr c8, [c26, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601348 // ldr c8, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011a // ldr c26, [x8, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240051a // ldr c26, [x8, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240091a // ldr c26, [x8, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d1a // ldr c26, [x8, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc240111a // ldr c26, [x8, #4]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc240151a // ldr c26, [x8, #5]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240191a // ldr c26, [x8, #6]
	.inst 0xc2daa561 // chkeq c11, c26
	b.ne comparison_fail
	.inst 0xc2401d1a // ldr c26, [x8, #7]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc240211a // ldr c26, [x8, #8]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc240251a // ldr c26, [x8, #9]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240291a // ldr c26, [x8, #10]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001210
	ldr x1, =check_data0
	ldr x2, =0x00001212
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400fec
	ldr x1, =check_data2
	ldr x2, =0x00400ff4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402200
	ldr x1, =check_data3
	ldr x2, =0x00402204
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00490008
	ldr x1, =check_data4
	ldr x2, =0x0049001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004a2800
	ldr x1, =check_data5
	ldr x2, =0x004a2802
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
