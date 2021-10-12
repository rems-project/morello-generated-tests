.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb3, 0x00
	.zero 3952
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x3a
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0xff
.data
check_data4:
	.byte 0xee, 0xdb, 0x6a, 0x91, 0x59, 0xb4, 0x08, 0x38, 0xe1, 0x2f, 0x18, 0xb2, 0xde, 0x53, 0xe0, 0x82
	.byte 0xb7, 0x0c, 0xd4, 0xe2, 0x81, 0x61, 0x49, 0xe2, 0x5f, 0x40, 0x60, 0x38, 0x3b, 0x08, 0xc5, 0xc2
	.byte 0x03, 0x53, 0x9e, 0x1a, 0xe2, 0xfb, 0x94, 0xb8, 0x00, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x43a
	/* C2 */
	.octa 0xc0000000000080080000000000001003
	/* C5 */
	.octa 0x400840
	/* C12 */
	.octa 0x1f66
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0xc10
final_cap_values:
	/* C0 */
	.octa 0x43a
	/* C1 */
	.octa 0xfff00000fff00
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x400840
	/* C12 */
	.octa 0x1f66
	/* C14 */
	.octa 0xeb64a9
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x42000000000000fff00000fff00
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004004a9
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000d8200000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x916adbee // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:14 Rn:31 imm12:101010110110 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x3808b459 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:25 Rn:2 01:01 imm9:010001011 0:0 opc:00 111000:111000 size:00
	.inst 0xb2182fe1 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:31 imms:001011 immr:011000 N:0 100100:100100 opc:01 sf:1
	.inst 0x82e053de // ALDR-R.RRB-32 Rt:30 Rn:30 opc:00 S:1 option:010 Rm:0 1:1 L:1 100000101:100000101
	.inst 0xe2d40cb7 // ALDUR-C.RI-C Ct:23 Rn:5 op2:11 imm9:101000000 V:0 op1:11 11100010:11100010
	.inst 0xe2496181 // ASTURH-R.RI-32 Rt:1 Rn:12 op2:00 imm9:010010110 V:0 op1:01 11100010:11100010
	.inst 0x3860405f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:100 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c5083b // SEAL-C.CC-C Cd:27 Cn:1 0010:0010 opc:00 Cm:5 11000010110:11000010110
	.inst 0x1a9e5303 // csel:aarch64/instrs/integer/conditional/select Rd:3 Rn:24 o2:0 0:0 cond:0101 Rm:30 011010100:011010100 op:0 sf:0
	.inst 0xb894fbe2 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:31 10:10 imm9:101001111 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21200
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e5 // ldr c5, [x15, #2]
	.inst 0xc2400dec // ldr c12, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320f // ldr c15, [c16, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260120f // ldr c15, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x16, #0x8
	and x15, x15, x16
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f0 // ldr c16, [x15, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc24005f0 // ldr c16, [x15, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc24009f0 // ldr c16, [x15, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400df0 // ldr c16, [x15, #3]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc24011f0 // ldr c16, [x15, #4]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc24015f0 // ldr c16, [x15, #5]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc24019f0 // ldr c16, [x15, #6]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2401df0 // ldr c16, [x15, #7]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc24021f0 // ldr c16, [x15, #8]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc24025f0 // ldr c16, [x15, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001003
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000108e
	ldr x1, =check_data1
	ldr x2, =0x0000108f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001cf8
	ldr x1, =check_data2
	ldr x2, =0x00001cfc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004003f8
	ldr x1, =check_data5
	ldr x2, =0x004003fc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400780
	ldr x1, =check_data6
	ldr x2, =0x00400790
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
