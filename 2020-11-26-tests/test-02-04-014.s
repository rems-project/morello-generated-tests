.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x10, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1968
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 2096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0xd2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data4:
	.byte 0x41, 0xf1, 0xc0, 0xc2, 0xd3, 0x7f, 0x08, 0x22, 0xbf, 0x03, 0x2c, 0xf8, 0x1d, 0x10, 0xc7, 0xc2
	.byte 0x1f, 0x01, 0x3e, 0x38, 0x7f, 0x69, 0xfe, 0x62, 0xe6, 0x52, 0xff, 0x38, 0x12, 0x08, 0x47, 0xe2
	.byte 0x1f, 0x00, 0xca, 0xc2, 0xbd, 0x80, 0xf9, 0x38, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000050005000000000000148c
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x800
	/* C12 */
	.octa 0xd20106fffff00000
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x6
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x500
final_cap_values:
	/* C0 */
	.octa 0x8000000000050005000000000000148c
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1
	/* C8 */
	.octa 0x1
	/* C11 */
	.octa 0x7c0
	/* C12 */
	.octa 0xd20106fffff00000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0x6
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x500
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000001ff60017000000000000ffa1
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017c0
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f141 // GCTYPE-R.C-C Rd:1 Cn:10 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x22087fd3 // STXR-R.CR-C Ct:19 Rn:30 (1)(1)(1)(1)(1):11111 0:0 Rs:8 0:0 L:0 001000100:001000100
	.inst 0xf82c03bf // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:000 o3:0 Rs:12 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c7101d // RRLEN-R.R-C Rd:29 Rn:0 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x383e011f // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:8 00:00 opc:000 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x62fe697f // LDP-C.RIBW-C Ct:31 Rn:11 Ct2:11010 imm7:1111100 L:1 011000101:011000101
	.inst 0x38ff52e6 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:6 Rn:23 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xe2470812 // ALDURSH-R.RI-64 Rt:18 Rn:0 op2:10 imm9:001110000 V:0 op1:01 11100010:11100010
	.inst 0xc2ca001f // SCBNDS-C.CR-C Cd:31 Cn:0 000:000 opc:00 0:0 Rm:10 11000010110:11000010110
	.inst 0x38f980bd // swpb:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:5 100000:100000 Rs:25 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2c21360
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a5 // ldr c5, [x13, #1]
	.inst 0xc24009ab // ldr c11, [x13, #2]
	.inst 0xc2400dac // ldr c12, [x13, #3]
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc24015b7 // ldr c23, [x13, #5]
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	.inst 0xc24021be // ldr c30, [x13, #8]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336d // ldr c13, [c27, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260136d // ldr c13, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001bb // ldr c27, [x13, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24005bb // ldr c27, [x13, #1]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24009bb // ldr c27, [x13, #2]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc2400dbb // ldr c27, [x13, #3]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc24011bb // ldr c27, [x13, #4]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc24015bb // ldr c27, [x13, #5]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc24019bb // ldr c27, [x13, #6]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc2401dbb // ldr c27, [x13, #7]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc24021bb // ldr c27, [x13, #8]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc24025bb // ldr c27, [x13, #9]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc24029bb // ldr c27, [x13, #10]
	.inst 0xc2dba741 // chkeq c26, c27
	b.ne comparison_fail
	.inst 0xc2402dbb // ldr c27, [x13, #11]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc24031bb // ldr c27, [x13, #12]
	.inst 0xc2dba7c1 // chkeq c30, c27
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
	ldr x0, =0x000014fc
	ldr x1, =check_data1
	ldr x2, =0x000014fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001500
	ldr x1, =check_data2
	ldr x2, =0x00001510
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017c0
	ldr x1, =check_data3
	ldr x2, =0x000017e0
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
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
