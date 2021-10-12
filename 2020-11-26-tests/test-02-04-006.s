.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 5
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x1e, 0x7c, 0xde, 0x9b, 0xe1, 0xcf, 0x01, 0x3c, 0x20, 0x66, 0x19, 0x3c, 0x21, 0xfc, 0x1d, 0x22
	.byte 0x01, 0x98, 0x7f, 0x22, 0x41, 0xff, 0x1f, 0xc8, 0xe0, 0x8f, 0xe1, 0xd8, 0x77, 0x62, 0x21, 0xb8
	.byte 0xbf, 0x21, 0x39, 0xe2, 0x47, 0x78, 0x05, 0x9b, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80100000001600170000000000001000
	/* C1 */
	.octa 0x4c000000400100020000000000001060
	/* C13 */
	.octa 0x2000
	/* C17 */
	.octa 0x40000000600700000000000000001000
	/* C19 */
	.octa 0xc00000006002000a0000000000001040
	/* C26 */
	.octa 0x40000000000700060000000000001000
final_cap_values:
	/* C0 */
	.octa 0x80100000001600170000000000001000
	/* C1 */
	.octa 0x10000000000000
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x2000
	/* C17 */
	.octa 0x40000000600700000000000000000f96
	/* C19 */
	.octa 0xc00000006002000a0000000000001040
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000000700060000000000001000
	/* C29 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x40000000012500070000000000001028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000008000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000207000700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bde7c1e // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:0 Ra:11111 0:0 Rm:30 10:10 U:1 10011011:10011011
	.inst 0x3c01cfe1 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:1 Rn:31 11:11 imm9:000011100 0:0 opc:00 111100:111100 size:00
	.inst 0x3c196620 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:0 Rn:17 01:01 imm9:110010110 0:0 opc:00 111100:111100 size:00
	.inst 0x221dfc21 // STLXR-R.CR-C Ct:1 Rn:1 (1)(1)(1)(1)(1):11111 1:1 Rs:29 0:0 L:0 001000100:001000100
	.inst 0x227f9801 // LDAXP-C.R-C Ct:1 Rn:0 Ct2:00110 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc81fff41 // stlxr:aarch64/instrs/memory/exclusive/single Rt:1 Rn:26 Rt2:11111 o0:1 Rs:31 0:0 L:0 0010000:0010000 size:11
	.inst 0xd8e18fe0 // prfm_lit:aarch64/instrs/memory/literal/general Rt:0 imm19:1110000110001111111 011000:011000 opc:11
	.inst 0xb8216277 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:23 Rn:19 00:00 opc:110 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xe23921bf // ASTUR-V.RI-B Rt:31 Rn:13 op2:00 imm9:110010010 V:1 op1:00 11100010:11100010
	.inst 0x9b057847 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:7 Rn:2 Ra:30 o0:0 Rm:5 0011011000:0011011000 sf:1
	.inst 0xc2c21160
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
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc240094d // ldr c13, [x10, #2]
	.inst 0xc2400d51 // ldr c17, [x10, #3]
	.inst 0xc2401153 // ldr c19, [x10, #4]
	.inst 0xc240155a // ldr c26, [x10, #5]
	/* Vector registers */
	mrs x10, cptr_el3
	bfc x10, #10, #1
	msr cptr_el3, x10
	isb
	ldr q0, =0x0
	ldr q1, =0x0
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316a // ldr c10, [c11, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260116a // ldr c10, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240014b // ldr c11, [x10, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240054b // ldr c11, [x10, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240094b // ldr c11, [x10, #2]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240114b // ldr c11, [x10, #4]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc240154b // ldr c11, [x10, #5]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc240194b // ldr c11, [x10, #6]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc2401d4b // ldr c11, [x10, #7]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc240214b // ldr c11, [x10, #8]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x11, v0.d[0]
	cmp x10, x11
	b.ne comparison_fail
	ldr x10, =0x0
	mov x11, v0.d[1]
	cmp x10, x11
	b.ne comparison_fail
	ldr x10, =0x0
	mov x11, v1.d[0]
	cmp x10, x11
	b.ne comparison_fail
	ldr x10, =0x0
	mov x11, v1.d[1]
	cmp x10, x11
	b.ne comparison_fail
	ldr x10, =0x0
	mov x11, v31.d[0]
	cmp x10, x11
	b.ne comparison_fail
	ldr x10, =0x0
	mov x11, v31.d[1]
	cmp x10, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001045
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001060
	ldr x1, =check_data2
	ldr x2, =0x00001070
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f92
	ldr x1, =check_data3
	ldr x2, =0x00001f93
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
