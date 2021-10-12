.section data0, #alloc, #write
	.zero 768
	.byte 0x01, 0x10, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3312
.data
check_data0:
	.byte 0x01, 0x10, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x01, 0x10, 0x00, 0x10
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x3f, 0x94, 0x19, 0xa2, 0x14, 0x81, 0x7d, 0x38, 0x40, 0x73, 0xf5, 0xb8, 0x9d, 0x29, 0xe4, 0xb6
	.byte 0x40, 0xde, 0x1f, 0xf8, 0x42, 0x50, 0xef, 0x54, 0x3f, 0xa8, 0x63, 0x79, 0x00, 0x7d, 0x9f, 0x48
	.byte 0x00, 0xfe, 0x16, 0x48, 0x21, 0x28, 0xdd, 0x9a, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C8 */
	.octa 0x1000
	/* C16 */
	.octa 0x1000
	/* C18 */
	.octa 0x1003
	/* C21 */
	.octa 0x84000000
	/* C26 */
	.octa 0x1300
	/* C29 */
	.octa 0x1000000000000000
final_cap_values:
	/* C0 */
	.octa 0x10001001
	/* C1 */
	.octa 0x990
	/* C8 */
	.octa 0x1000
	/* C16 */
	.octa 0x1000
	/* C18 */
	.octa 0x1000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x84000000
	/* C22 */
	.octa 0x1
	/* C26 */
	.octa 0x1300
	/* C29 */
	.octa 0x1000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000009400500fffffe0a809583
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa219943f // STR-C.RIAW-C Ct:31 Rn:1 01:01 imm9:110011001 0:0 opc:00 10100010:10100010
	.inst 0x387d8114 // swpb:aarch64/instrs/memory/atomicops/swp Rt:20 Rn:8 100000:100000 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xb8f57340 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:26 00:00 opc:111 0:0 Rs:21 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xb6e4299d // tbz:aarch64/instrs/branch/conditional/test Rt:29 imm14:10000101001100 b40:11100 op:0 011011:011011 b5:1
	.inst 0xf81fde40 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:18 11:11 imm9:111111101 0:0 opc:00 111000:111000 size:11
	.inst 0x54ef5042 // b_cond:aarch64/instrs/branch/conditional/cond cond:0010 0:0 imm19:1110111101010000010 01010100:01010100
	.inst 0x7963a83f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:1 imm12:100011101010 opc:01 111001:111001 size:01
	.inst 0x489f7d00 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:8 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x4816fe00 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:16 Rt2:11111 o0:1 Rs:22 0:0 L:0 0010000:0010000 size:01
	.inst 0x9add2821 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:1 op2:10 0010:0010 Rm:29 0011010110:0011010110 sf:1
	.inst 0xc2c211e0
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400488 // ldr c8, [x4, #1]
	.inst 0xc2400890 // ldr c16, [x4, #2]
	.inst 0xc2400c92 // ldr c18, [x4, #3]
	.inst 0xc2401095 // ldr c21, [x4, #4]
	.inst 0xc240149a // ldr c26, [x4, #5]
	.inst 0xc240189d // ldr c29, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e4 // ldr c4, [c15, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826011e4 // ldr c4, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x15, #0x2
	and x4, x4, x15
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008f // ldr c15, [x4, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240048f // ldr c15, [x4, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240088f // ldr c15, [x4, #2]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc240108f // ldr c15, [x4, #4]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc240148f // ldr c15, [x4, #5]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc240188f // ldr c15, [x4, #6]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc2401c8f // ldr c15, [x4, #7]
	.inst 0xc2cfa6c1 // chkeq c22, c15
	b.ne comparison_fail
	.inst 0xc240208f // ldr c15, [x4, #8]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240248f // ldr c15, [x4, #9]
	.inst 0xc2cfa7a1 // chkeq c29, c15
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
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001304
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b64
	ldr x1, =check_data2
	ldr x2, =0x00001b66
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
