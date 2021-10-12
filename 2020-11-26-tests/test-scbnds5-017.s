.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x04, 0xd8
.data
check_data1:
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38
	.byte 0x04, 0xd8, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x83, 0x10, 0x01, 0x92, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x86, 0x06, 0x97, 0x42, 0x3f, 0x82, 0xe1, 0x78, 0x20, 0x00, 0xc2, 0xc2, 0xdd, 0xfb, 0xd2, 0xc2
	.byte 0x01, 0x10, 0xc2, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x92011083ffffffffffffd804
	/* C2 */
	.octa 0x7ffa
	/* C6 */
	.octa 0x38000000000000000000010000000004
	/* C17 */
	.octa 0x1000
	/* C20 */
	.octa 0xe00
	/* C30 */
	.octa 0x10007fffffffffffff821
final_cap_values:
	/* C0 */
	.octa 0xac07ec06ffffffffffffd804
	/* C1 */
	.octa 0x92011083ffffffffffffd804
	/* C2 */
	.octa 0x7ffa
	/* C6 */
	.octa 0x38000000000000000000010000000004
	/* C17 */
	.octa 0x1000
	/* C20 */
	.octa 0xe00
	/* C29 */
	.octa 0x7a71f821fffffffffffff821
	/* C30 */
	.octa 0x10007fffffffffffff821
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200180060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000000003000700fff59c78004003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x42970686 // STP-C.RIB-C Ct:6 Rn:20 Ct2:00001 imm7:0101110 L:0 010000101:010000101
	.inst 0x78e1823f // swph:aarch64/instrs/memory/atomicops/swp Rt:31 Rn:17 100000:100000 Rs:1 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2d2fbdd // SCBNDS-C.CI-S Cd:29 Cn:30 1110:1110 S:1 imm6:100101 11000010110:11000010110
	.inst 0xc2c21001 // CHKSLD-C-C 00001:00001 Cn:0 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c21340
	.zero 1048552
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400946 // ldr c6, [x10, #2]
	.inst 0xc2400d51 // ldr c17, [x10, #3]
	.inst 0xc2401154 // ldr c20, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334a // ldr c10, [c26, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260134a // ldr c10, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x26, #0xf
	and x10, x10, x26
	cmp x10, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015a // ldr c26, [x10, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240055a // ldr c26, [x10, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240095a // ldr c26, [x10, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d5a // ldr c26, [x10, #3]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc240115a // ldr c26, [x10, #4]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc2daa681 // chkeq c20, c26
	b.ne comparison_fail
	.inst 0xc240195a // ldr c26, [x10, #6]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2401d5a // ldr c26, [x10, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x00001100
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
