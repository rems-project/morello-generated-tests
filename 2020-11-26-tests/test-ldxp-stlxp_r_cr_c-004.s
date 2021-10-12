.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xdf, 0x33, 0x3d, 0x78, 0x1d, 0x4c, 0x47, 0x82, 0x69, 0x73, 0x7f, 0x22, 0xff, 0xf7, 0xbd, 0x82
	.byte 0xdf, 0x28, 0xdd, 0x1a, 0x83, 0x84, 0x20, 0x22, 0xc1, 0xd7, 0x8e, 0x90, 0xdf, 0x23, 0x3a, 0xb8
	.byte 0xdd, 0x23, 0xd7, 0xc2, 0xac, 0x4d, 0xc7, 0xb4, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400000020000000000001000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x1440
	/* C12 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x11c0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc00000000000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0xffffffff1def8000
	/* C3 */
	.octa 0x4000000000000000000000000000
	/* C4 */
	.octa 0x1440
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x11c0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xc00000000000000000001000
initial_SP_EL3_value:
	.octa 0x40000000400402040000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0180000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc100000580006440000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011d0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x783d33df // ldseth:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:30 00:00 opc:011 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x82474c1d // ASTR-R.RI-64 Rt:29 Rn:0 op:11 imm9:001110100 L:0 1000001001:1000001001
	.inst 0x227f7369 // 0x227f7369
	.inst 0x82bdf7ff // ASTR-R.RRB-64 Rt:31 Rn:31 opc:01 S:1 option:111 Rm:29 1:1 L:0 100000101:100000101
	.inst 0x1add28df // asrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:6 op2:10 0010:0010 Rm:29 0011010110:0011010110 sf:0
	.inst 0x22208483 // 0x22208483
	.inst 0x908ed7c1 // ADRP-C.I-C Rd:1 immhi:000111011010111110 P:1 10000:10000 immlo:00 op:1
	.inst 0xb83a23df // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:010 o3:0 Rs:26 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2d723dd // SCBNDSE-C.CR-C Cd:29 Cn:30 000:000 opc:01 0:0 Rm:23 11000010110:11000010110
	.inst 0xb4c74dac // cbz:aarch64/instrs/branch/conditional/compare Rt:12 imm19:1100011101001101101 op:0 011010:011010 sf:1
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d64 // ldr c4, [x11, #3]
	.inst 0xc240116c // ldr c12, [x11, #4]
	.inst 0xc240157a // ldr c26, [x11, #5]
	.inst 0xc240197b // ldr c27, [x11, #6]
	.inst 0xc2401d7d // ldr c29, [x11, #7]
	.inst 0xc240217e // ldr c30, [x11, #8]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x3085103f
	msr SCTLR_EL3, x11
	ldr x11, =0x8
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260320b // ldr c11, [c16, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260120b // ldr c11, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400170 // ldr c16, [x11, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400570 // ldr c16, [x11, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2401170 // ldr c16, [x11, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401570 // ldr c16, [x11, #5]
	.inst 0xc2d0a581 // chkeq c12, c16
	b.ne comparison_fail
	.inst 0xc2401970 // ldr c16, [x11, #6]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2401d70 // ldr c16, [x11, #7]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2402170 // ldr c16, [x11, #8]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402570 // ldr c16, [x11, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x000011c0
	ldr x1, =check_data1
	ldr x2, =0x000011e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013a0
	ldr x1, =check_data2
	ldr x2, =0x000013a8
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
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
