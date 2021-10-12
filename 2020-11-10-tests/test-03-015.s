.section data0, #alloc, #write
	.zero 32
	.byte 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x18, 0x00, 0x40, 0x00
.data
check_data2:
	.byte 0xdf, 0x8c, 0x37, 0xab, 0x07, 0x03, 0x7f, 0xb8, 0xf4, 0xa3, 0x98, 0xb8, 0xd2, 0x1b, 0xe0, 0xc2
	.byte 0x50, 0x68, 0xde, 0xc2, 0xa0, 0x03, 0x3f, 0xd6
.data
check_data3:
	.byte 0x0b, 0x94, 0x14, 0xcb, 0x02, 0xac, 0xa0, 0x9b, 0x61, 0x63, 0xfe, 0xb8, 0xcf, 0x63, 0x81, 0x6a
	.byte 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0xf86
	/* C27 */
	.octa 0xfa6
	/* C29 */
	.octa 0x480000
	/* C30 */
	.octa 0x800120040000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x19
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x3fff800000000000000000000000
	/* C18 */
	.octa 0x800120040000000000000000
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0xf86
	/* C27 */
	.octa 0xfa6
	/* C29 */
	.octa 0x480000
	/* C30 */
	.octa 0x400018
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200020000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005800007a00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xab378cdf // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:6 imm3:011 option:100 Rm:23 01011001:01011001 S:1 op:0 sf:1
	.inst 0xb87f0307 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:24 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xb898a3f4 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:20 Rn:31 00:00 imm9:110001010 0:0 opc:10 111000:111000 size:10
	.inst 0xc2e01bd2 // CVT-C.CR-C Cd:18 Cn:30 0110:0110 0:0 0:0 Rm:0 11000010111:11000010111
	.inst 0xc2de6850 // ORRFLGS-C.CR-C Cd:16 Cn:2 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0xd63f03a0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 524264
	.inst 0xcb14940b // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:11 Rn:0 imm6:100101 Rm:20 0:0 shift:00 01011:01011 S:0 op:1 sf:1
	.inst 0x9ba0ac02 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:0 Ra:11 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xb8fe6361 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:27 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x6a8163cf // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:15 Rn:30 imm6:011000 Rm:1 N:0 shift:10 01010:01010 opc:11 sf:0
	.inst 0xc2c21120
	.zero 524268
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc2400958 // ldr c24, [x10, #2]
	.inst 0xc2400d5b // ldr c27, [x10, #3]
	.inst 0xc240115d // ldr c29, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x3085103d
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260312a // ldr c10, [c9, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260112a // ldr c10, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x9, #0xf
	and x10, x10, x9
	cmp x10, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400149 // ldr c9, [x10, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400549 // ldr c9, [x10, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400d49 // ldr c9, [x10, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc2401149 // ldr c9, [x10, #4]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401549 // ldr c9, [x10, #5]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401949 // ldr c9, [x10, #6]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401d49 // ldr c9, [x10, #7]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2402149 // ldr c9, [x10, #8]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402549 // ldr c9, [x10, #9]
	.inst 0xc2c9a701 // chkeq c24, c9
	b.ne comparison_fail
	.inst 0xc2402949 // ldr c9, [x10, #10]
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	.inst 0xc2402d49 // ldr c9, [x10, #11]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2403149 // ldr c9, [x10, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400018
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00480000
	ldr x1, =check_data3
	ldr x2, =0x00480014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
