.section data0, #alloc, #write
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc1, 0x7f, 0x7f, 0x42, 0xb4, 0x7f, 0x9f, 0xc8, 0xe1, 0xdb, 0x22, 0xa2, 0xd1, 0x7f, 0x4f, 0x9b
	.byte 0x80, 0x11, 0xc1, 0xc2, 0x5f, 0xd0, 0xc1, 0xc2, 0x0a, 0xf6, 0xf8, 0x28, 0x5c, 0x50, 0xbe, 0x38
	.byte 0x01, 0xfd, 0x17, 0x08, 0xde, 0x1f, 0xa1, 0xaa, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1000
	/* C8 */
	.octa 0x1b88
	/* C12 */
	.octa 0x30072027000000000000e000
	/* C16 */
	.octa 0x1000
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x800000001001c0050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x7000
	/* C1 */
	.octa 0x81
	/* C2 */
	.octa 0x1000
	/* C8 */
	.octa 0x1b88
	/* C10 */
	.octa 0x81
	/* C12 */
	.octa 0x30072027000000000000e000
	/* C16 */
	.octa 0xfc4
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x1
	/* C28 */
	.octa 0x81
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xfffffffffffffffe
initial_SP_EL3_value:
	.octa 0xffffffffffff1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004004001200ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427f7fc1 // ALDARB-R.R-B Rt:1 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc89f7fb4 // stllr:aarch64/instrs/memory/ordered Rt:20 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xa222dbe1 // STR-C.RRB-C Ct:1 Rn:31 10:10 S:1 option:110 Rm:2 1:1 opc:00 10100010:10100010
	.inst 0x9b4f7fd1 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:17 Rn:30 Ra:11111 0:0 Rm:15 10:10 U:0 10011011:10011011
	.inst 0xc2c11180 // GCLIM-R.C-C Rd:0 Cn:12 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c1d05f // CPY-C.C-C Cd:31 Cn:2 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x28f8f60a // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:10 Rn:16 Rt2:11101 imm7:1110001 L:1 1010001:1010001 opc:00
	.inst 0x38be505c // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:2 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x0817fd01 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:8 Rt2:11111 o0:1 Rs:23 0:0 L:0 0010000:0010000 size:00
	.inst 0xaaa11fde // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:30 imm6:000111 Rm:1 N:1 shift:10 01010:01010 opc:01 sf:1
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
	ldr x24, =initial_cap_values
	.inst 0xc2400302 // ldr c2, [x24, #0]
	.inst 0xc2400708 // ldr c8, [x24, #1]
	.inst 0xc2400b0c // ldr c12, [x24, #2]
	.inst 0xc2400f10 // ldr c16, [x24, #3]
	.inst 0xc2401314 // ldr c20, [x24, #4]
	.inst 0xc240171d // ldr c29, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603178 // ldr c24, [c11, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601178 // ldr c24, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030b // ldr c11, [x24, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240070b // ldr c11, [x24, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400b0b // ldr c11, [x24, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400f0b // ldr c11, [x24, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240130b // ldr c11, [x24, #4]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc240170b // ldr c11, [x24, #5]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc2401b0b // ldr c11, [x24, #6]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc2401f0b // ldr c11, [x24, #7]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc240230b // ldr c11, [x24, #8]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc240270b // ldr c11, [x24, #9]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc2402b0b // ldr c11, [x24, #10]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402f0b // ldr c11, [x24, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001b88
	ldr x1, =check_data1
	ldr x2, =0x00001b89
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
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
