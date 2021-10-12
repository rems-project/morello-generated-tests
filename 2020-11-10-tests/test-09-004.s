.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x58, 0x5e, 0x40, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x4c, 0x18, 0x80, 0x13, 0x1f, 0x00, 0x1f, 0xda, 0x22, 0xf3, 0x4d, 0xb1, 0x23, 0x32, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xc0, 0xe5, 0x29, 0xb9, 0x3f, 0x30, 0xa1, 0xc2, 0xae, 0x0e, 0xe6, 0xa8, 0x37, 0xa0, 0xde, 0xc2
	.byte 0x11, 0x08, 0x8e, 0xe2, 0xe2, 0x7f, 0xec, 0x48, 0x80, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000001fa73fe70000000000405e58
	/* C1 */
	.octa 0x7c00400000000004c3c3c
	/* C14 */
	.octa 0xffffffffffffe804
	/* C17 */
	.octa 0x200000008001000700000000004c1010
	/* C21 */
	.octa 0x1fe8
final_cap_values:
	/* C0 */
	.octa 0x800000001fa73fe70000000000405e58
	/* C1 */
	.octa 0x7c00400000000004c3c3c
	/* C3 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x1e48
	/* C23 */
	.octa 0x7c00400000000004c3c3c
	/* C30 */
	.octa 0x20008000840140050000000000400010
initial_RDDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040140050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 128
	.dword initial_RDDC_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1380184c // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:12 Rn:2 imms:000110 Rm:0 0:0 N:0 00100111:00100111 sf:0
	.inst 0xda1f001f // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:0 000000:000000 Rm:31 11010000:11010000 S:0 op:1 sf:1
	.inst 0xb14df322 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:25 imm12:001101111100 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2c23223 // BLRR-C-C 00011:00011 Cn:17 100:100 opc:01 11000010110000100:11000010110000100
	.zero 790528
	.inst 0xb929e5c0 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:14 imm12:101001111001 opc:00 111001:111001 size:10
	.inst 0xc2a1303f // ADD-C.CRI-C Cd:31 Cn:1 imm3:100 option:001 Rm:1 11000010101:11000010101
	.inst 0xa8e60eae // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:14 Rn:21 Rt2:00011 imm7:1001100 L:1 1010001:1010001 opc:10
	.inst 0xc2dea037 // CLRPERM-C.CR-C Cd:23 Cn:1 000:000 1:1 10:10 Rm:30 11000010110:11000010110
	.inst 0xe28e0811 // ALDURSW-R.RI-64 Rt:17 Rn:0 op2:10 imm9:011100000 V:0 op1:10 11100010:11100010
	.inst 0x48ec7fe2 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:2 Rn:31 11111:11111 o0:0 Rs:12 1:1 L:1 0010001:0010001 size:01
	.inst 0xc2c21280
	.zero 258004
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
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2400f51 // ldr c17, [x26, #3]
	.inst 0xc2401355 // ldr c21, [x26, #4]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	ldr x26, =0x80
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	ldr x26, =initial_RDDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28b433a // msr RDDC_EL0, c26
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x8260129a // ldr c26, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400354 // ldr c20, [x26, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400754 // ldr c20, [x26, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400b54 // ldr c20, [x26, #2]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400f54 // ldr c20, [x26, #3]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401754 // ldr c20, [x26, #5]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401b54 // ldr c20, [x26, #6]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2401f54 // ldr c20, [x26, #7]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2402354 // ldr c20, [x26, #8]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011e8
	ldr x1, =check_data0
	ldr x2, =0x000011ec
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe8
	ldr x1, =check_data1
	ldr x2, =0x00001ff8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00405f38
	ldr x1, =check_data3
	ldr x2, =0x00405f3c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004c1010
	ldr x1, =check_data4
	ldr x2, =0x004c102c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004ffffe
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
