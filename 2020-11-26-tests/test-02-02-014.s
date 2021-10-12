.section data0, #alloc, #write
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 3840
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xc0, 0x87, 0xdd, 0xc2, 0xa0, 0x85, 0x3f, 0x6b, 0x33, 0x70, 0x20, 0x78, 0xe1, 0x7f, 0xdf, 0x48
	.byte 0x60, 0x01, 0x1f, 0xd6, 0x52, 0x0a, 0xc1, 0xc2, 0x41, 0x6b, 0x1d, 0x0b, 0x21, 0x20, 0x93, 0xf8
	.byte 0x2f, 0xa0, 0x40, 0x7a, 0xe1, 0x17, 0xc0, 0xda, 0x20, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc00000000001000500000000000010fc
	/* C11 */
	.octa 0x400014
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C29 */
	.octa 0x401000000000000000000000000000
	/* C30 */
	.octa 0x20409000000080080000000000400005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x3f
	/* C11 */
	.octa 0x400014
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x20409000000080080000000000400005
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004ffff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600010000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dd87c0 // BRS-C.C-C 00000:00000 Cn:30 001:001 opc:00 1:1 Cm:29 11000010110:11000010110
	.inst 0x6b3f85a0 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:13 imm3:001 option:100 Rm:31 01011001:01011001 S:1 op:1 sf:0
	.inst 0x78207033 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:1 00:00 opc:111 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x48df7fe1 // ldlarh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xd61f0160 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:11 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0xc2c10a52 // SEAL-C.CC-C Cd:18 Cn:18 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0x0b1d6b41 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:26 imm6:011010 Rm:29 0:0 shift:00 01011:01011 S:0 op:0 sf:0
	.inst 0xf8932021 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:1 00:00 imm9:100110010 0:0 opc:10 111000:111000 size:11
	.inst 0x7a40a02f // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1111 0:0 Rn:1 00:00 cond:1010 Rm:0 111010010:111010010 op:1 sf:0
	.inst 0xdac017e1 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:1 Rn:31 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c21320
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc240068b // ldr c11, [x20, #1]
	.inst 0xc2400a8d // ldr c13, [x20, #2]
	.inst 0xc2400e92 // ldr c18, [x20, #3]
	.inst 0xc240129d // ldr c29, [x20, #4]
	.inst 0xc240169e // ldr c30, [x20, #5]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x3085103d
	msr SCTLR_EL3, x20
	ldr x20, =0x8
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601334 // ldr c20, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x25, #0x3
	and x20, x20, x25
	cmp x20, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400299 // ldr c25, [x20, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400699 // ldr c25, [x20, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400a99 // ldr c25, [x20, #2]
	.inst 0xc2d9a561 // chkeq c11, c25
	b.ne comparison_fail
	.inst 0xc2400e99 // ldr c25, [x20, #3]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401299 // ldr c25, [x20, #4]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401699 // ldr c25, [x20, #5]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2401a99 // ldr c25, [x20, #6]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2401e99 // ldr c25, [x20, #7]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010fc
	ldr x1, =check_data0
	ldr x2, =0x000010fe
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004ffff0
	ldr x1, =check_data2
	ldr x2, =0x004ffff2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
