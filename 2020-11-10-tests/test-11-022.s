.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x7e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.byte 0x05, 0x00, 0x40, 0x00, 0x01, 0x01, 0x00, 0x00
.data
check_data2:
	.byte 0x7e
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x33, 0xc2, 0xc2
.data
check_data5:
	.byte 0x1f, 0x62, 0x22, 0xb8, 0xe0, 0x51, 0x02, 0x12, 0x21, 0xe8, 0xc5, 0xc2, 0x27, 0x40, 0x22, 0x9b
	.byte 0x1f, 0x10, 0x7d, 0x38, 0x1e, 0x0c, 0xa8, 0x29, 0xdf, 0x73, 0x82, 0x6b, 0x00, 0xfd, 0x1c, 0x48
	.byte 0x80, 0xe8, 0xd9, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000
	/* C3 */
	.octa 0x101
	/* C8 */
	.octa 0x1236
	/* C15 */
	.octa 0x1200
	/* C16 */
	.octa 0x1000
	/* C24 */
	.octa 0x20008000800100060000000000410a04
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C2 */
	.octa 0x80000000
	/* C3 */
	.octa 0x101
	/* C8 */
	.octa 0x1236
	/* C15 */
	.octa 0x1200
	/* C16 */
	.octa 0x1000
	/* C24 */
	.octa 0x20008000800100060000000000410a04
	/* C28 */
	.octa 0x1
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000a00000080000000000400005
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000e000100ffffffffffffa0
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23300 // BLR-C-C 00000:00000 Cn:24 100:100 opc:01 11000010110000100:11000010110000100
	.zero 68096
	.inst 0xb822621f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:110 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x120251e0 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:15 imms:010100 immr:000010 N:0 100100:100100 opc:00 sf:0
	.inst 0xc2c5e821 // CTHI-C.CR-C Cd:1 Cn:1 1010:1010 opc:11 Rm:5 11000010110:11000010110
	.inst 0x9b224027 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:7 Rn:1 Ra:16 o0:0 Rm:2 01:01 U:0 10011011:10011011
	.inst 0x387d101f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:001 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x29a80c1e // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:30 Rn:0 Rt2:00011 imm7:1010000 L:0 1010011:1010011 opc:00
	.inst 0x6b8273df // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:30 imm6:011100 Rm:2 0:0 shift:10 01011:01011 S:1 op:1 sf:0
	.inst 0x481cfd00 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:8 Rt2:11111 o0:1 Rs:28 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2d9e880 // CTHI-C.CR-C Cd:0 Cn:4 1010:1010 opc:11 Rm:25 11000010110:11000010110
	.inst 0xc2c21120
	.zero 980436
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
	ldr x26, =initial_cap_values
	.inst 0xc2400342 // ldr c2, [x26, #0]
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2400b48 // ldr c8, [x26, #2]
	.inst 0xc2400f4f // ldr c15, [x26, #3]
	.inst 0xc2401350 // ldr c16, [x26, #4]
	.inst 0xc2401758 // ldr c24, [x26, #5]
	.inst 0xc2401b5d // ldr c29, [x26, #6]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851037
	msr SCTLR_EL3, x26
	ldr x26, =0x84
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313a // ldr c26, [c9, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260113a // ldr c26, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x9, #0xf
	and x26, x26, x9
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400349 // ldr c9, [x26, #0]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400749 // ldr c9, [x26, #1]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401349 // ldr c9, [x26, #4]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401749 // ldr c9, [x26, #5]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2401b49 // ldr c9, [x26, #6]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2401f49 // ldr c9, [x26, #7]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402349 // ldr c9, [x26, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001148
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001201
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001236
	ldr x1, =check_data3
	ldr x2, =0x00001238
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00410a04
	ldr x1, =check_data5
	ldr x2, =0x00410a2c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
