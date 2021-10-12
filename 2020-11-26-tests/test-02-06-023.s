.section data0, #alloc, #write
	.byte 0x05, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x3d, 0x22, 0x3e, 0xf8, 0x3f, 0x20, 0x47, 0xb2, 0x42, 0x7c, 0x04, 0x48, 0xf5, 0x25, 0x20, 0x22
	.byte 0xa6, 0x88, 0x48, 0x3a, 0x7f, 0x7d, 0x7f, 0x42, 0xb0, 0x53, 0xa0, 0x38, 0xbe, 0x73, 0x52, 0xb8
	.byte 0xa0, 0xfd, 0x7f, 0x42, 0xff, 0xe5, 0x90, 0x78, 0x00, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1d84
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x800000004004400600000000004f5004
	/* C13 */
	.octa 0x80000000000500030000000000001000
	/* C15 */
	.octa 0x1000
	/* C17 */
	.octa 0x1000
	/* C21 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x1214
final_cap_values:
	/* C0 */
	.octa 0x11
	/* C2 */
	.octa 0x1d84
	/* C4 */
	.octa 0x1
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x800000004004400600000000004f5004
	/* C13 */
	.octa 0x80000000000500030000000000001000
	/* C15 */
	.octa 0xf0e
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x1000
	/* C21 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x1205
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000600400000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf83e223d // ldeor:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:17 00:00 opc:010 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xb247203f // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:1 imms:001000 immr:000111 N:1 100100:100100 opc:01 sf:1
	.inst 0x48047c42 // stxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:2 Rt2:11111 o0:0 Rs:4 0:0 L:0 0010000:0010000 size:01
	.inst 0x222025f5 // STXP-R.CR-C Ct:21 Rn:15 Ct2:01001 0:0 Rs:0 1:1 L:0 001000100:001000100
	.inst 0x3a4888a6 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:5 10:10 cond:1000 imm5:01000 111010010:111010010 op:0 sf:0
	.inst 0x427f7d7f // ALDARB-R.R-B Rt:31 Rn:11 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x38a053b0 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:29 00:00 opc:101 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xb85273be // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:29 00:00 imm9:100100111 0:0 opc:01 111000:111000 size:10
	.inst 0x427ffda0 // ALDAR-R.R-32 Rt:0 Rn:13 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x7890e5ff // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:15 01:01 imm9:100001110 0:0 opc:10 111000:111000 size:01
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400589 // ldr c9, [x12, #1]
	.inst 0xc240098b // ldr c11, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc240118f // ldr c15, [x12, #4]
	.inst 0xc2401591 // ldr c17, [x12, #5]
	.inst 0xc2401995 // ldr c21, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Set up flags and system registers */
	mov x12, #0x60000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851037
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330c // ldr c12, [c24, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260130c // ldr c12, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x24, #0xf
	and x12, x12, x24
	cmp x12, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400198 // ldr c24, [x12, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400598 // ldr c24, [x12, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400998 // ldr c24, [x12, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400d98 // ldr c24, [x12, #3]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401198 // ldr c24, [x12, #4]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401598 // ldr c24, [x12, #5]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc2401998 // ldr c24, [x12, #6]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401d98 // ldr c24, [x12, #7]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2402198 // ldr c24, [x12, #8]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2402598 // ldr c24, [x12, #9]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2402998 // ldr c24, [x12, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402d98 // ldr c24, [x12, #11]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000112c
	ldr x1, =check_data1
	ldr x2, =0x00001130
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001205
	ldr x1, =check_data2
	ldr x2, =0x00001206
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d84
	ldr x1, =check_data3
	ldr x2, =0x00001d86
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
	ldr x0, =0x004f5004
	ldr x1, =check_data5
	ldr x2, =0x004f5005
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
