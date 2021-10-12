.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x82
.data
check_data2:
	.byte 0x40, 0x0c, 0x02, 0x38, 0x52, 0x10, 0xc7, 0xc2, 0x33, 0x28, 0xc6, 0x38, 0xe5, 0x7f, 0xc8, 0x82
	.byte 0x5f, 0xe5, 0x55, 0x38, 0x01, 0x6c, 0x57, 0xb8, 0xce, 0xe3, 0xd2, 0xc2, 0xa0, 0x01, 0x00, 0xba
	.byte 0x2d, 0x1b, 0xf7, 0xc2, 0xf6, 0x18, 0x09, 0x38, 0x60, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4ff782
	/* C1 */
	.octa 0x4fff9c
	/* C2 */
	.octa 0x1f9e
	/* C7 */
	.octa 0x1064
	/* C8 */
	.octa 0xfde
	/* C10 */
	.octa 0x4ffffe
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000
	/* C25 */
	.octa 0x800190050000040000000000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1fbe
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x1064
	/* C8 */
	.octa 0xfde
	/* C10 */
	.octa 0x4fff5c
	/* C13 */
	.octa 0x800190054000040000000000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1fbe
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000
	/* C25 */
	.octa 0x800190050000040000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38020c40 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:2 11:11 imm9:000100000 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c71052 // RRLEN-R.R-C Rd:18 Rn:2 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x38c62833 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:19 Rn:1 10:10 imm9:001100010 0:0 opc:11 111000:111000 size:00
	.inst 0x82c87fe5 // ALDRH-R.RRB-32 Rt:5 Rn:31 opc:11 S:1 option:011 Rm:8 0:0 L:1 100000101:100000101
	.inst 0x3855e55f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:10 01:01 imm9:101011110 0:0 opc:01 111000:111000 size:00
	.inst 0xb8576c01 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:0 11:11 imm9:101110110 0:0 opc:01 111000:111000 size:10
	.inst 0xc2d2e3ce // SCFLGS-C.CR-C Cd:14 Cn:30 111000:111000 Rm:18 11000010110:11000010110
	.inst 0xba0001a0 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:13 000000:000000 Rm:0 11010000:11010000 S:1 op:0 sf:1
	.inst 0xc2f71b2d // CVT-C.CR-C Cd:13 Cn:25 0110:0110 0:0 0:0 Rm:23 11000010111:11000010111
	.inst 0x380918f6 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:7 10:10 imm9:010010001 0:0 opc:00 111000:111000 size:00
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400882 // ldr c2, [x4, #2]
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2401088 // ldr c8, [x4, #4]
	.inst 0xc240148a // ldr c10, [x4, #5]
	.inst 0xc2401896 // ldr c22, [x4, #6]
	.inst 0xc2401c97 // ldr c23, [x4, #7]
	.inst 0xc2402099 // ldr c25, [x4, #8]
	.inst 0xc240249e // ldr c30, [x4, #9]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851037
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603164 // ldr c4, [c11, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601164 // ldr c4, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008b // ldr c11, [x4, #0]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc240048b // ldr c11, [x4, #1]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400c8b // ldr c11, [x4, #3]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc240108b // ldr c11, [x4, #4]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240148b // ldr c11, [x4, #5]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc240188b // ldr c11, [x4, #6]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc2401c8b // ldr c11, [x4, #7]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc240208b // ldr c11, [x4, #8]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc240248b // ldr c11, [x4, #9]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc240288b // ldr c11, [x4, #10]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc2402c8b // ldr c11, [x4, #11]
	.inst 0xc2cba6e1 // chkeq c23, c11
	b.ne comparison_fail
	.inst 0xc240308b // ldr c11, [x4, #12]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc240348b // ldr c11, [x4, #13]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f5
	ldr x1, =check_data0
	ldr x2, =0x000010f6
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fbc
	ldr x1, =check_data1
	ldr x2, =0x00001fbf
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
	ldr x0, =0x004ff6f8
	ldr x1, =check_data3
	ldr x2, =0x004ff6fc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
