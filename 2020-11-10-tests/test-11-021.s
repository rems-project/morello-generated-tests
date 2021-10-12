.section data0, #alloc, #write
	.zero 4064
	.byte 0xff, 0xff, 0xff, 0xff, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0xff, 0xff, 0xff, 0xff, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x40, 0x97, 0x65, 0x79, 0xd8, 0x33, 0x7f, 0xf8, 0x7a, 0x34, 0x3c, 0x11, 0x76, 0xca, 0x9c, 0xeb
	.byte 0xc4, 0x97, 0x7f, 0xc8, 0x01, 0x30, 0xc0, 0xc2, 0x3c, 0xc3, 0xdf, 0xc2, 0xdf, 0x79, 0x77, 0xa2
	.byte 0x22, 0xc2, 0x3f, 0xa2, 0xde, 0x13, 0xf0, 0xb8, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x17e0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x1fe0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x3fed36
	/* C30 */
	.octa 0x1fe0
final_cap_values:
	/* C0 */
	.octa 0x9740
	/* C1 */
	.octa 0xffffffffffffffff
	/* C2 */
	.octa 0x10101ffffffff
	/* C4 */
	.octa 0x10101ffffffff
	/* C5 */
	.octa 0x0
	/* C14 */
	.octa 0x17e0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x1fe0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x10101ffffffff
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000017e0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x79659740 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:26 imm12:100101100101 opc:01 111001:111001 size:01
	.inst 0xf87f33d8 // ldset:aarch64/instrs/memory/atomicops/ld Rt:24 Rn:30 00:00 opc:011 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x113c347a // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:26 Rn:3 imm12:111100001101 sh:0 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xeb9cca76 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:22 Rn:19 imm6:110010 Rm:28 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0xc87f97c4 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:4 Rn:30 Rt2:00101 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c03001 // GCLEN-R.C-C Rd:1 Cn:0 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2dfc33c // CVT-R.CC-C Rd:28 Cn:25 110000:110000 Cm:31 11000010110:11000010110
	.inst 0xa27779df // LDR-C.RRB-C Ct:31 Rn:14 10:10 S:1 option:011 Rm:23 1:1 opc:01 10100010:10100010
	.inst 0xa23fc222 // LDAPR-C.R-C Ct:2 Rn:17 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0xb8f013de // ldclr:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:30 00:00 opc:001 0:0 Rs:16 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc2c21100
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
	.inst 0xc24001ee // ldr c14, [x15, #0]
	.inst 0xc24005f0 // ldr c16, [x15, #1]
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2400df7 // ldr c23, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fa // ldr c26, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310f // ldr c15, [c8, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260110f // ldr c15, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x15, x15, x8
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e8 // ldr c8, [x15, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24005e8 // ldr c8, [x15, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc24009e8 // ldr c8, [x15, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc24011e8 // ldr c8, [x15, #4]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc24015e8 // ldr c8, [x15, #5]
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	.inst 0xc24019e8 // ldr c8, [x15, #6]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc2401de8 // ldr c8, [x15, #7]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc24021e8 // ldr c8, [x15, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc24025e8 // ldr c8, [x15, #9]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc24029e8 // ldr c8, [x15, #10]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2402de8 // ldr c8, [x15, #11]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc24031e8 // ldr c8, [x15, #12]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017e0
	ldr x1, =check_data0
	ldr x2, =0x000017f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
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
