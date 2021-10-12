.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0x42, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x42, 0xc0, 0xa5, 0x82, 0xfe, 0xff, 0x9f, 0x48, 0xb0, 0xa6, 0x77, 0x90, 0x12, 0xf8, 0x01, 0x38
	.byte 0xff, 0x23, 0x21, 0xb8, 0x8f, 0x01, 0x6c, 0x38, 0x2d, 0x7c, 0xdf, 0x08, 0x1f, 0x00, 0x7f, 0x78
	.byte 0xc4, 0xca, 0x59, 0x39, 0x02, 0x54, 0x88, 0x38, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000700070000000000001052
	/* C1 */
	.octa 0x80000000400000010000000000001000
	/* C2 */
	.octa 0x421000
	/* C5 */
	.octa 0xffbe0000
	/* C12 */
	.octa 0xc0000000500400000000000000001000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000567606c40000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc00000000007000700000000000010d7
	/* C1 */
	.octa 0x80000000400000010000000000001000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0xffbe0000
	/* C12 */
	.octa 0xc0000000500400000000000000001000
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x400000004000000400000000ef4da000
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000567606c40000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000400100620000000000001060
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400000040000000000006000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82a5c042 // ASTR-R.RRB-32 Rt:2 Rn:2 opc:00 S:0 option:110 Rm:5 1:1 L:0 100000101:100000101
	.inst 0x489ffffe // stlrh:aarch64/instrs/memory/ordered Rt:30 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x9077a6b0 // ADRP-C.I-C Rd:16 immhi:111011110100110101 P:0 10000:10000 immlo:00 op:1
	.inst 0x3801f812 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:18 Rn:0 10:10 imm9:000011111 0:0 opc:00 111000:111000 size:00
	.inst 0xb82123ff // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x386c018f // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:12 00:00 opc:000 0:0 Rs:12 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x08df7c2d // ldlarb:aarch64/instrs/memory/ordered Rt:13 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x787f001f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:000 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x3959cac4 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:4 Rn:22 imm12:011001110010 opc:01 111001:111001 size:00
	.inst 0x38885402 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:010000101 0:0 opc:10 111000:111000 size:00
	.inst 0xc2c212a0
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc2401672 // ldr c18, [x19, #5]
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2401e7e // ldr c30, [x19, #7]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b3 // ldr c19, [c21, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826012b3 // ldr c19, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400275 // ldr c21, [x19, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400675 // ldr c21, [x19, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a75 // ldr c21, [x19, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400e75 // ldr c21, [x19, #3]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2401275 // ldr c21, [x19, #4]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401675 // ldr c21, [x19, #5]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401a75 // ldr c21, [x19, #6]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401e75 // ldr c21, [x19, #7]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2402275 // ldr c21, [x19, #8]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402675 // ldr c21, [x19, #9]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2402a75 // ldr c21, [x19, #10]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402e75 // ldr c21, [x19, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x00001052
	ldr x1, =check_data1
	ldr x2, =0x00001054
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001060
	ldr x1, =check_data2
	ldr x2, =0x00001064
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001071
	ldr x1, =check_data3
	ldr x2, =0x00001072
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001672
	ldr x1, =check_data4
	ldr x2, =0x00001673
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
