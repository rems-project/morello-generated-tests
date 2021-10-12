.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xb2, 0xff, 0x7f, 0x42, 0xff, 0x23, 0x3f, 0xb8, 0xbf, 0x84, 0x0a, 0xb8, 0xa1, 0x5a, 0xe7, 0xc2
	.byte 0x9e, 0x02, 0xc0, 0xc2, 0x5e, 0x2a, 0xde, 0x1a, 0xc0, 0x83, 0x7f, 0xa2, 0xff, 0x02, 0x3d, 0x78
	.byte 0x60, 0x7c, 0xde, 0x9b, 0x5d, 0x80, 0xdf, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data4:
	.byte 0x20, 0x10, 0x10, 0x10
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x1000
	/* C7 */
	.octa 0x100000000000000
	/* C20 */
	.octa 0x400000000000000000000010
	/* C21 */
	.octa 0x8001c0070000000000000001
	/* C23 */
	.octa 0x1000
	/* C29 */
	.octa 0x80000000080740040000000000420000
final_cap_values:
	/* C1 */
	.octa 0x8001c0070100000000000000
	/* C5 */
	.octa 0x10a8
	/* C7 */
	.octa 0x100000000000000
	/* C18 */
	.octa 0x10101020
	/* C20 */
	.octa 0x400000000000000000000010
	/* C21 */
	.octa 0x8001c0070000000000000001
	/* C23 */
	.octa 0x1000
	/* C30 */
	.octa 0x1010
initial_SP_EL3_value:
	.octa 0x1008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000005401053400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427fffb2 // ALDAR-R.R-32 Rt:18 Rn:29 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xb83f23ff // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xb80a84bf // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:5 01:01 imm9:010101000 0:0 opc:00 111000:111000 size:10
	.inst 0xc2e75aa1 // CVTZ-C.CR-C Cd:1 Cn:21 0110:0110 1:1 0:0 Rm:7 11000010111:11000010111
	.inst 0xc2c0029e // SCBNDS-C.CR-C Cd:30 Cn:20 000:000 opc:00 0:0 Rm:0 11000010110:11000010110
	.inst 0x1ade2a5e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:18 op2:10 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0xa27f83c0 // SWPL-CC.R-C Ct:0 Rn:30 100000:100000 Cs:31 1:1 R:1 A:0 10100010:10100010
	.inst 0x783d02ff // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:000 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x9bde7c60 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:0 Rn:3 Ra:11111 0:0 Rm:30 10:10 U:1 10011011:10011011
	.inst 0xc2df805d // SCTAG-C.CR-C Cd:29 Cn:2 000:000 0:0 10:10 Rm:31 11000010110:11000010110
	.inst 0xc2c21320
	.zero 131028
	.inst 0x10101020
	.zero 917500
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
	ldr x27, =initial_cap_values
	.inst 0xc2400365 // ldr c5, [x27, #0]
	.inst 0xc2400767 // ldr c7, [x27, #1]
	.inst 0xc2400b74 // ldr c20, [x27, #2]
	.inst 0xc2400f75 // ldr c21, [x27, #3]
	.inst 0xc2401377 // ldr c23, [x27, #4]
	.inst 0xc240177d // ldr c29, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333b // ldr c27, [c25, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260133b // ldr c27, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400379 // ldr c25, [x27, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400779 // ldr c25, [x27, #1]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2400b79 // ldr c25, [x27, #2]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2400f79 // ldr c25, [x27, #3]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401379 // ldr c25, [x27, #4]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2401b79 // ldr c25, [x27, #6]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2401f79 // ldr c25, [x27, #7]
	.inst 0xc2d9a7c1 // chkeq c30, c25
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001010
	ldr x1, =check_data2
	ldr x2, =0x00001020
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
	ldr x0, =0x00420000
	ldr x1, =check_data4
	ldr x2, =0x00420004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
