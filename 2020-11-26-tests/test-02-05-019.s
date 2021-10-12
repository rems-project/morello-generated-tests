.section data0, #alloc, #write
	.byte 0xb0, 0x2e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0x00, 0x40
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 8
.data
check_data4:
	.byte 0x7f, 0x3a, 0x47, 0x38, 0x26, 0x42, 0x79, 0x78, 0x42, 0x50, 0x4c, 0xf8, 0x7f, 0x4d, 0x1a, 0xb8
	.byte 0x81, 0xff, 0x5f, 0xc8, 0xd7, 0x3c, 0x51, 0xa2, 0xb1, 0xdb, 0xd5, 0xc2, 0x20, 0xda, 0xd6, 0xc2
	.byte 0xe5, 0x3a, 0xda, 0xc2, 0xa1, 0x42, 0xbc, 0x39, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1f2b
	/* C11 */
	.octa 0x106c
	/* C17 */
	.octa 0x1000
	/* C19 */
	.octa 0x1f4b
	/* C21 */
	.octa 0x4030ee
	/* C25 */
	.octa 0x4000
	/* C28 */
	.octa 0x4ffff0
	/* C29 */
	.octa 0xa207e2060000800000000000
final_cap_values:
	/* C0 */
	.octa 0xa207e2060000800000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x101c03400000000000000000000
	/* C6 */
	.octa 0x1fe0
	/* C11 */
	.octa 0x1010
	/* C17 */
	.octa 0xa207e2060000800000000000
	/* C19 */
	.octa 0x1f4b
	/* C21 */
	.octa 0x4030ee
	/* C23 */
	.octa 0x101800000000000000000000000
	/* C25 */
	.octa 0x4000
	/* C28 */
	.octa 0x4ffff0
	/* C29 */
	.octa 0xa207e2060000800000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38473a7f // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:19 10:10 imm9:001110011 0:0 opc:01 111000:111000 size:00
	.inst 0x78794226 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:17 00:00 opc:100 0:0 Rs:25 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xf84c5042 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:2 00:00 imm9:011000101 0:0 opc:01 111000:111000 size:11
	.inst 0xb81a4d7f // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:11 11:11 imm9:110100100 0:0 opc:00 111000:111000 size:10
	.inst 0xc85fff81 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:1 Rn:28 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xa2513cd7 // LDR-C.RIBW-C Ct:23 Rn:6 11:11 imm9:100010011 0:0 opc:01 10100010:10100010
	.inst 0xc2d5dbb1 // ALIGNU-C.CI-C Cd:17 Cn:29 0110:0110 U:1 imm6:101011 11000010110:11000010110
	.inst 0xc2d6da20 // ALIGNU-C.CI-C Cd:0 Cn:17 0110:0110 U:1 imm6:101101 11000010110:11000010110
	.inst 0xc2da3ae5 // SCBNDS-C.CI-C Cd:5 Cn:23 1110:1110 S:0 imm6:110100 11000010110:11000010110
	.inst 0x39bc42a1 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:21 imm12:111100010000 opc:10 111001:111001 size:00
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
	ldr x18, =initial_cap_values
	.inst 0xc2400242 // ldr c2, [x18, #0]
	.inst 0xc240064b // ldr c11, [x18, #1]
	.inst 0xc2400a51 // ldr c17, [x18, #2]
	.inst 0xc2400e53 // ldr c19, [x18, #3]
	.inst 0xc2401255 // ldr c21, [x18, #4]
	.inst 0xc2401659 // ldr c25, [x18, #5]
	.inst 0xc2401a5c // ldr c28, [x18, #6]
	.inst 0xc2401e5d // ldr c29, [x18, #7]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f2 // ldr c18, [c15, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826011f2 // ldr c18, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024f // ldr c15, [x18, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240064f // ldr c15, [x18, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400a4f // ldr c15, [x18, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400e4f // ldr c15, [x18, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240124f // ldr c15, [x18, #4]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240164f // ldr c15, [x18, #5]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc2401a4f // ldr c15, [x18, #6]
	.inst 0xc2cfa621 // chkeq c17, c15
	b.ne comparison_fail
	.inst 0xc2401e4f // ldr c15, [x18, #7]
	.inst 0xc2cfa661 // chkeq c19, c15
	b.ne comparison_fail
	.inst 0xc240224f // ldr c15, [x18, #8]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240264f // ldr c15, [x18, #9]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc2402a4f // ldr c15, [x18, #10]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc2402e4f // ldr c15, [x18, #11]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc240324f // ldr c15, [x18, #12]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fbe
	ldr x1, =check_data2
	ldr x2, =0x00001fbf
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	ldr x0, =0x00403ffe
	ldr x1, =check_data5
	ldr x2, =0x00403fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff0
	ldr x1, =check_data6
	ldr x2, =0x004ffff8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
