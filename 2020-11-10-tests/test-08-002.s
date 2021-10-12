.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x53, 0xc0, 0xbf, 0x38, 0xd4, 0x43, 0x27, 0x78, 0x19, 0x98, 0x9e, 0xcb, 0x11, 0xfd, 0x01, 0x48
	.byte 0x3f, 0xcd, 0xd5, 0x78, 0xce, 0x7e, 0x5f, 0x88, 0xe0, 0xff, 0xdf, 0xc8, 0xfe, 0x1b, 0xc5, 0x6a
	.byte 0x56, 0xc9, 0x98, 0xaa, 0x21, 0xa4, 0xc1, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4ffffe
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x500000
	/* C22 */
	.octa 0x4ffff8
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x4ffffe
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x1000
	/* C9 */
	.octa 0x4fff5c
	/* C14 */
	.octa 0xc2c2c2c2
	/* C19 */
	.octa 0xc2
	/* C20 */
	.octa 0x1
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000600060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc053 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:19 Rn:2 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x782743d4 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:30 00:00 opc:100 0:0 Rs:7 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xcb9e9819 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:25 Rn:0 imm6:100110 Rm:30 0:0 shift:10 01011:01011 S:0 op:1 sf:1
	.inst 0x4801fd11 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:17 Rn:8 Rt2:11111 o0:1 Rs:1 0:0 L:0 0010000:0010000 size:01
	.inst 0x78d5cd3f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:9 11:11 imm9:101011100 0:0 opc:11 111000:111000 size:01
	.inst 0x885f7ece // ldxr:aarch64/instrs/memory/exclusive/single Rt:14 Rn:22 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0xc8dfffe0 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x6ac51bfe // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:000110 Rm:5 N:0 shift:11 01010:01010 opc:11 sf:0
	.inst 0xaa98c956 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:10 imm6:110010 Rm:24 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c1a421 // CHKEQ-_.CC-C 00001:00001 Cn:1 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xc2c21060
	.zero 1048368
	.inst 0x0000c2c2
	.zero 152
	.inst 0xc2c2c2c2
	.inst 0x00c20000
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
	.inst 0xc2400747 // ldr c7, [x26, #1]
	.inst 0xc2400b48 // ldr c8, [x26, #2]
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc2401356 // ldr c22, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085103d
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260307a // ldr c26, [c3, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260107a // ldr c26, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	mov x3, #0xf
	and x26, x26, x3
	cmp x26, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400343 // ldr c3, [x26, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400f43 // ldr c3, [x26, #3]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc2401343 // ldr c3, [x26, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401743 // ldr c3, [x26, #5]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401b43 // ldr c3, [x26, #6]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401f43 // ldr c3, [x26, #7]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc2402343 // ldr c3, [x26, #8]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2402743 // ldr c3, [x26, #9]
	.inst 0xc2c3a7c1 // chkeq c30, c3
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
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001018
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
	ldr x0, =0x004fff5c
	ldr x1, =check_data3
	ldr x2, =0x004fff5e
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
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
