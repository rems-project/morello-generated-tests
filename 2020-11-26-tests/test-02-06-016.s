.section data0, #alloc, #write
	.zero 2112
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1968
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xff
.data
check_data3:
	.byte 0x7f, 0xb0, 0xe6, 0xc2, 0xe5, 0x27, 0x0b, 0x78, 0x20, 0xd8, 0x05, 0x29, 0x61, 0x70, 0xc3, 0xc2
	.byte 0x9f, 0x20, 0x60, 0x78, 0xc5, 0x0f, 0x4a, 0x3c, 0xbd, 0x0a, 0x5a, 0xa2, 0xc0, 0x7f, 0x5f, 0x48
	.byte 0xbf, 0x12, 0x38, 0x38, 0x7f, 0x52, 0x21, 0xb8, 0x40, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x201
	/* C1 */
	.octa 0x13d0
	/* C3 */
	.octa 0x3500000000001400
	/* C4 */
	.octa 0x1402
	/* C5 */
	.octa 0x0
	/* C19 */
	.octa 0x1400
	/* C21 */
	.octa 0x1840
	/* C22 */
	.octa 0x2010000
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x4fff58
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1800000003500000000001400
	/* C3 */
	.octa 0x3500000000001400
	/* C4 */
	.octa 0x1402
	/* C5 */
	.octa 0x0
	/* C19 */
	.octa 0x1400
	/* C21 */
	.octa 0x1840
	/* C22 */
	.octa 0x2010000
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4ffff8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000801c0050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e6b07f // EORFLGS-C.CI-C Cd:31 Cn:3 0:0 10:10 imm8:00110101 11000010111:11000010111
	.inst 0x780b27e5 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:31 01:01 imm9:010110010 0:0 opc:00 111000:111000 size:01
	.inst 0x2905d820 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:1 Rt2:10110 imm7:0001011 L:0 1010010:1010010 opc:00
	.inst 0xc2c37061 // SEAL-C.CI-C Cd:1 Cn:3 100:100 form:11 11000010110000110:11000010110000110
	.inst 0x7860209f // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:4 00:00 opc:010 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x3c4a0fc5 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:5 Rn:30 11:11 imm9:010100000 0:0 opc:01 111100:111100 size:00
	.inst 0xa25a0abd // LDTR-C.RIB-C Ct:29 Rn:21 10:10 imm9:110100000 0:0 opc:01 10100010:10100010
	.inst 0x485f7fc0 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x383812bf // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:001 o3:0 Rs:24 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xb821527f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:101 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c21240
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e3 // ldr c3, [x7, #2]
	.inst 0xc2400ce4 // ldr c4, [x7, #3]
	.inst 0xc24010e5 // ldr c5, [x7, #4]
	.inst 0xc24014f3 // ldr c19, [x7, #5]
	.inst 0xc24018f5 // ldr c21, [x7, #6]
	.inst 0xc2401cf6 // ldr c22, [x7, #7]
	.inst 0xc24020f8 // ldr c24, [x7, #8]
	.inst 0xc24024fe // ldr c30, [x7, #9]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085103f
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603247 // ldr c7, [c18, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601247 // ldr c7, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f2 // ldr c18, [x7, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24004f2 // ldr c18, [x7, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc24008f2 // ldr c18, [x7, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400cf2 // ldr c18, [x7, #3]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc24010f2 // ldr c18, [x7, #4]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc24014f2 // ldr c18, [x7, #5]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc24018f2 // ldr c18, [x7, #6]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2401cf2 // ldr c18, [x7, #7]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc24020f2 // ldr c18, [x7, #8]
	.inst 0xc2d2a701 // chkeq c24, c18
	b.ne comparison_fail
	.inst 0xc24024f2 // ldr c18, [x7, #9]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc24028f2 // ldr c18, [x7, #10]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x18, v5.d[0]
	cmp x7, x18
	b.ne comparison_fail
	ldr x7, =0x0
	mov x18, v5.d[1]
	cmp x7, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001240
	ldr x1, =check_data0
	ldr x2, =0x00001250
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000013fc
	ldr x1, =check_data1
	ldr x2, =0x00001404
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001840
	ldr x1, =check_data2
	ldr x2, =0x00001841
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
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffa
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
