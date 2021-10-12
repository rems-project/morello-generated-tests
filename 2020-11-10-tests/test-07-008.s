.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2384
	.byte 0xfe, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1424
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x9d
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xfe, 0x01
.data
check_data5:
	.byte 0xfe, 0xa3, 0xd1, 0xac, 0xb6, 0x23, 0xd5, 0xe2, 0x1e, 0xfc, 0x5f, 0x48, 0xeb, 0xf9, 0x10, 0x82
	.byte 0xfa, 0x63, 0xe0, 0x78, 0x39, 0xb0, 0x5c, 0xe2, 0x21, 0x32, 0xc2, 0xc2, 0x03, 0x50, 0xc2, 0xc2
.data
check_data6:
	.byte 0x5f, 0x50, 0x3d, 0x78, 0x50, 0xd0, 0x36, 0x6b, 0x80, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2000000060020004000000000040003c
	/* C1 */
	.octa 0x40000000000000000000000000001415
	/* C2 */
	.octa 0x1108
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000c000000000000000110e
final_cap_values:
	/* C0 */
	.octa 0x2000000060020004000000000040003c
	/* C1 */
	.octa 0x40000000000000000000000000001415
	/* C2 */
	.octa 0x1108
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0x1108
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x1fe
	/* C29 */
	.octa 0x400000000000c000000000000000110e
	/* C30 */
	.octa 0x505f
initial_SP_EL3_value:
	.octa 0x1830
initial_RDDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0108000200100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe0000000e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xacd1a3fe // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:30 Rn:31 Rt2:01000 imm7:0100011 L:1 1011001:1011001 opc:10
	.inst 0xe2d523b6 // ASTUR-R.RI-64 Rt:22 Rn:29 op2:00 imm9:101010010 V:0 op1:11 11100010:11100010
	.inst 0x485ffc1e // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:30 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x8210f9eb // LDR-C.I-C Ct:11 imm17:01000011111001111 1000001000:1000001000
	.inst 0x78e063fa // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:31 00:00 opc:110 0:0 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xe25cb039 // ASTURH-R.RI-32 Rt:25 Rn:1 op2:00 imm9:111001011 V:0 op1:01 11100010:11100010
	.inst 0xc2c23221 // CHKTGD-C-C 00001:00001 Cn:17 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c25003 // RETR-C-C 00011:00011 Cn:0 100:100 opc:10 11000010110000100:11000010110000100
	.zero 28
	.inst 0x783d505f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:101 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x6b36d050 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:16 Rn:2 imm3:100 option:110 Rm:22 01011001:01011001 S:1 op:1 sf:0
	.inst 0xc2c21080
	.zero 1048504
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f71 // ldr c17, [x27, #3]
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2401b7d // ldr c29, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x3085103f
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	ldr x27, =initial_RDDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc28b433b // msr RDDC_EL0, c27
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260309b // ldr c27, [c4, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260109b // ldr c27, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x4, #0xf
	and x27, x27, x4
	cmp x27, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400364 // ldr c4, [x27, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b64 // ldr c4, [x27, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400f64 // ldr c4, [x27, #3]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401364 // ldr c4, [x27, #4]
	.inst 0xc2c4a601 // chkeq c16, c4
	b.ne comparison_fail
	.inst 0xc2401764 // ldr c4, [x27, #5]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401b64 // ldr c4, [x27, #6]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2401f64 // ldr c4, [x27, #7]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2402364 // ldr c4, [x27, #8]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402764 // ldr c4, [x27, #9]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402b64 // ldr c4, [x27, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x4, v8.d[0]
	cmp x27, x4
	b.ne comparison_fail
	ldr x27, =0x0
	mov x4, v8.d[1]
	cmp x27, x4
	b.ne comparison_fail
	ldr x27, =0x0
	mov x4, v30.d[0]
	cmp x27, x4
	b.ne comparison_fail
	ldr x27, =0x0
	mov x4, v30.d[1]
	cmp x27, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001068
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001108
	ldr x1, =check_data1
	ldr x2, =0x0000110a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013e0
	ldr x1, =check_data2
	ldr x2, =0x000013e2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001830
	ldr x1, =check_data3
	ldr x2, =0x00001850
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001a60
	ldr x1, =check_data4
	ldr x2, =0x00001a62
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400020
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040003c
	ldr x1, =check_data6
	ldr x2, =0x00400048
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00487cf0
	ldr x1, =check_data7
	ldr x2, =0x00487d00
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
