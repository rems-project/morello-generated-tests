.section data0, #alloc, #write
	.zero 256
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3808
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1e, 0x50, 0x7f, 0x38, 0x00, 0xfe, 0x17, 0x08, 0xbe, 0x7c, 0x12, 0x48, 0xae, 0x1b, 0x42, 0xba
	.byte 0xfd, 0x7f, 0x0d, 0x22, 0xff, 0xb4, 0x10, 0xb8, 0x80, 0x88, 0xdf, 0xc2, 0x39, 0x52, 0xa5, 0x38
	.byte 0xbd, 0x7f, 0xc0, 0x82, 0x1f, 0x7c, 0x9f, 0x08, 0x00, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc00000001de980050000000000001100
	/* C4 */
	.octa 0x40000000a00500060000000000001000
	/* C5 */
	.octa 0x40000000100000100000000000410000
	/* C7 */
	.octa 0x40000000400000020000000000001000
	/* C16 */
	.octa 0x40000000000700060000000000400000
	/* C17 */
	.octa 0xc0000000000100050000000000001ffe
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40000000200500060000000000001000
	/* C4 */
	.octa 0x40000000a00500060000000000001000
	/* C5 */
	.octa 0x40000000100000100000000000410000
	/* C7 */
	.octa 0x40000000400000020000000000000f0b
	/* C13 */
	.octa 0x1
	/* C16 */
	.octa 0x40000000000700060000000000400000
	/* C17 */
	.octa 0xc0000000000100050000000000001ffe
	/* C18 */
	.octa 0x1
	/* C23 */
	.octa 0x1
	/* C25 */
	.octa 0x2
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x4c000000000100050000000000001fe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000026008000fffffff04c0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x387f501e // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x0817fe00 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:0 Rn:16 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:00
	.inst 0x48127cbe // stxrh:aarch64/instrs/memory/exclusive/single Rt:30 Rn:5 Rt2:11111 o0:0 Rs:18 0:0 L:0 0010000:0010000 size:01
	.inst 0xba421bae // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1110 0:0 Rn:29 10:10 cond:0001 imm5:00010 111010010:111010010 op:0 sf:1
	.inst 0x220d7ffd // STXR-R.CR-C Ct:29 Rn:31 (1)(1)(1)(1)(1):11111 0:0 Rs:13 0:0 L:0 001000100:001000100
	.inst 0xb810b4ff // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:100001011 0:0 opc:00 111000:111000 size:10
	.inst 0xc2df8880 // CHKSSU-C.CC-C Cd:0 Cn:4 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0x38a55239 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:25 Rn:17 00:00 opc:101 0:0 Rs:5 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x82c07fbd // ALDRH-R.RRB-32 Rt:29 Rn:29 opc:11 S:1 option:011 Rm:0 0:0 L:1 100000101:100000101
	.inst 0x089f7c1f // stllrb:aarch64/instrs/memory/ordered Rt:31 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c21100
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400544 // ldr c4, [x10, #1]
	.inst 0xc2400945 // ldr c5, [x10, #2]
	.inst 0xc2400d47 // ldr c7, [x10, #3]
	.inst 0xc2401150 // ldr c16, [x10, #4]
	.inst 0xc2401551 // ldr c17, [x10, #5]
	.inst 0xc240195d // ldr c29, [x10, #6]
	/* Set up flags and system registers */
	mov x10, #0x40000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103f
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310a // ldr c10, [c8, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260110a // ldr c10, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x10, x10, x8
	cmp x10, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400148 // ldr c8, [x10, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400548 // ldr c8, [x10, #1]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400948 // ldr c8, [x10, #2]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401148 // ldr c8, [x10, #4]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401548 // ldr c8, [x10, #5]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401948 // ldr c8, [x10, #6]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2401d48 // ldr c8, [x10, #7]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2402148 // ldr c8, [x10, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402548 // ldr c8, [x10, #9]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2402948 // ldr c8, [x10, #10]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402d48 // ldr c8, [x10, #11]
	.inst 0xc2c8a7c1 // chkeq c30, c8
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001101
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00402000
	ldr x1, =check_data5
	ldr x2, =0x00402002
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00410000
	ldr x1, =check_data6
	ldr x2, =0x00410002
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
