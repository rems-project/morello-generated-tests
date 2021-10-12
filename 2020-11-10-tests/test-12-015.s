.section data0, #alloc, #write
	.byte 0x46, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 256
	.byte 0xb0, 0x16, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x06, 0x08, 0x00, 0x80, 0x00, 0x20
	.zero 3328
	.byte 0xff, 0xae, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 464
.data
check_data0:
	.byte 0x00, 0x10
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xb0, 0x16, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x06, 0x08, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0x09
.data
check_data4:
	.byte 0xff, 0xae
.data
check_data5:
	.byte 0xf0, 0x83, 0xbe, 0x38, 0x01, 0x30, 0xd2, 0xc2
.data
check_data6:
	.byte 0xfe, 0x43, 0x97, 0x82, 0x41, 0x10, 0x3e, 0x38, 0x9e, 0x12, 0xc0, 0x5a, 0x40, 0x7a, 0x20, 0x78
	.byte 0xff, 0x73, 0x7e, 0xf8, 0x74, 0x40, 0x1c, 0xf1, 0x2d, 0x4a, 0x2e, 0xb4
.data
check_data7:
	.byte 0x5f, 0x13, 0x20, 0x78, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000204180060000000000001000
	/* C2 */
	.octa 0x1000
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0xfffffffffffff000
	/* C20 */
	.octa 0x1a
	/* C23 */
	.octa 0x8c0
	/* C26 */
	.octa 0x1e20
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x90100000204180060000000000001000
	/* C1 */
	.octa 0x46
	/* C2 */
	.octa 0x1000
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0xfffffffffffff000
	/* C23 */
	.octa 0x8c0
	/* C26 */
	.octa 0x1e20
	/* C30 */
	.octa 0x1b
initial_SP_EL3_value:
	.octa 0xc0000000000000000000000000001080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001110
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38be83f0 // swpb:aarch64/instrs/memory/atomicops/swp Rt:16 Rn:31 100000:100000 Rs:30 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2d23001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:0010001 110000101101:110000101101
	.zero 5800
	.inst 0x829743fe // ASTRB-R.RRB-B Rt:30 Rn:31 opc:00 S:0 option:010 Rm:23 0:0 L:0 100000101:100000101
	.inst 0x383e1041 // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:2 00:00 opc:001 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x5ac0129e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:20 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x78207a40 // strh_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:18 10:10 S:1 option:011 Rm:0 1:1 opc:00 111000:111000 size:01
	.inst 0xf87e73ff // ldumin:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:31 00:00 opc:111 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xf11c4074 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:20 Rn:3 imm12:011100010000 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xb42e4a2d // cbz:aarch64/instrs/branch/conditional/compare Rt:13 imm19:0010111001001010001 op:0 011010:011010 sf:1
	.zero 379200
	.inst 0x7820135f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21320
	.zero 663532
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2400e32 // ldr c18, [x17, #3]
	.inst 0xc2401234 // ldr c20, [x17, #4]
	.inst 0xc2401637 // ldr c23, [x17, #5]
	.inst 0xc2401a3a // ldr c26, [x17, #6]
	.inst 0xc2401e3e // ldr c30, [x17, #7]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851037
	msr SCTLR_EL3, x17
	ldr x17, =0x0
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603331 // ldr c17, [c25, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601331 // ldr c17, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400239 // ldr c25, [x17, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400639 // ldr c25, [x17, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a39 // ldr c25, [x17, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400e39 // ldr c25, [x17, #3]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401239 // ldr c25, [x17, #4]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401639 // ldr c25, [x17, #5]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401a39 // ldr c25, [x17, #6]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2401e39 // ldr c25, [x17, #7]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2402239 // ldr c25, [x17, #8]
	.inst 0xc2d9a7c1 // chkeq c30, c25
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001110
	ldr x1, =check_data2
	ldr x2, =0x00001120
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001940
	ldr x1, =check_data3
	ldr x2, =0x00001941
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001e20
	ldr x1, =check_data4
	ldr x2, =0x00001e22
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004016b0
	ldr x1, =check_data6
	ldr x2, =0x004016cc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0045e00c
	ldr x1, =check_data7
	ldr x2, =0x0045e014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
