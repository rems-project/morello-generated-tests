.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xfe, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x1f, 0x80, 0xd3, 0x39, 0xf4, 0x9d, 0xdb, 0x28, 0x00, 0x50, 0xc2, 0xc2
.data
check_data6:
	.byte 0x20, 0x9c, 0x57, 0xf8, 0x42, 0x80, 0xbe, 0x38, 0x3f, 0x80, 0x47, 0xa2, 0xdf, 0x7b, 0x44, 0xa2
	.byte 0xa8, 0xc3, 0xbf, 0x38, 0x0f, 0x7c, 0x00, 0x1b, 0xbd, 0x31, 0x23, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
check_data8:
	.zero 8
.data
check_data9:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xa0008000660220010000000000402011
	/* C1 */
	.octa 0x8000000000140007000000000000181f
	/* C2 */
	.octa 0xc0000000502200040000000000001000
	/* C13 */
	.octa 0x4c0000000006000fffffffffffff8800
	/* C15 */
	.octa 0x80000000600000020000000000440ffc
	/* C29 */
	.octa 0x800000000003000700000000000012fe
	/* C30 */
	.octa 0x801000001007800f000000000047b800
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000001400070000000000001798
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x4c0000000006000fffffffffffff8800
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000003000700000000000012fe
	/* C30 */
	.octa 0x801000001007800f000000000047b800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f80000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001810
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x39d3801f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:0 imm12:010011100000 opc:11 111001:111001 size:00
	.inst 0x28db9df4 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:20 Rn:15 Rt2:00111 imm7:0110111 L:1 1010001:1010001 opc:00
	.inst 0xc2c25000 // RET-C-C 00000:00000 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 8196
	.inst 0xf8579c20 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:101111001 0:0 opc:01 111000:111000 size:11
	.inst 0x38be8042 // swpb:aarch64/instrs/memory/atomicops/swp Rt:2 Rn:2 100000:100000 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xa247803f // LDUR-C.RI-C Ct:31 Rn:1 00:00 imm9:001111000 0:0 opc:01 10100010:10100010
	.inst 0xa2447bdf // LDTR-C.RIB-C Ct:31 Rn:30 10:10 imm9:001000111 0:0 opc:01 10100010:10100010
	.inst 0x38bfc3a8 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:8 Rn:29 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x1b007c0f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:15 Rn:0 Ra:31 o0:0 Rm:0 0011011000:0011011000 sf:0
	.inst 0xc22331bd // STR-C.RIB-C Ct:29 Rn:13 imm12:100011001100 L:0 110000100:110000100
	.inst 0xc2c210c0
	.zero 1040336
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c2 // ldr c2, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc24015dd // ldr c29, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851037
	msr SCTLR_EL3, x14
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826010ce // ldr c14, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c6 // ldr c6, [x14, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24005c6 // ldr c6, [x14, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc24011c6 // ldr c6, [x14, #4]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc24015c6 // ldr c6, [x14, #5]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc24019c6 // ldr c6, [x14, #6]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401dc6 // ldr c6, [x14, #7]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc24021c6 // ldr c6, [x14, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc24025c6 // ldr c6, [x14, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x000012fe
	ldr x1, =check_data1
	ldr x2, =0x000012ff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000014c0
	ldr x1, =check_data2
	ldr x2, =0x000014d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001798
	ldr x1, =check_data3
	ldr x2, =0x000017a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001810
	ldr x1, =check_data4
	ldr x2, =0x00001820
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040000c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00402010
	ldr x1, =check_data6
	ldr x2, =0x00402030
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004024f1
	ldr x1, =check_data7
	ldr x2, =0x004024f2
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00440ffc
	ldr x1, =check_data8
	ldr x2, =0x00441004
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x0047bc70
	ldr x1, =check_data9
	ldr x2, =0x0047bc80
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
