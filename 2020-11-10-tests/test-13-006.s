.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x01
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xea, 0xc3, 0xf3, 0xc2, 0x5e, 0x7c, 0x9f, 0x08, 0x81, 0xc0, 0xc1, 0xc2, 0x46, 0x80, 0x97, 0xda
	.byte 0xdc, 0x07, 0xc0, 0xc2, 0x41, 0x43, 0x7f, 0x78, 0x82, 0xb5, 0x23, 0x22, 0xff, 0x71, 0x74, 0x78
	.byte 0x00, 0x7c, 0x5f, 0xc8, 0xc1, 0x7e, 0x5f, 0x9b, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000000000004ffff0
	/* C2 */
	.octa 0x1ffe
	/* C4 */
	.octa 0x1
	/* C12 */
	.octa 0x4fffc0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C20 */
	.octa 0x0
	/* C26 */
	.octa 0x1808
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1ffe
	/* C3 */
	.octa 0x1
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0x1ffe
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x4fffc0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C20 */
	.octa 0x0
	/* C26 */
	.octa 0x1808
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x0
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f3c3ea // BICFLGS-C.CI-C Cd:10 Cn:31 0:0 00:00 imm8:10011110 11000010111:11000010111
	.inst 0x089f7c5e // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c1c081 // CVT-R.CC-C Rd:1 Cn:4 110000:110000 Cm:1 11000010110:11000010110
	.inst 0xda978046 // csinv:aarch64/instrs/integer/conditional/select Rd:6 Rn:2 o2:0 0:0 cond:1000 Rm:23 011010100:011010100 op:1 sf:1
	.inst 0xc2c007dc // BUILD-C.C-C Cd:28 Cn:30 001:001 opc:00 0:0 Cm:0 11000010110:11000010110
	.inst 0x787f4341 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:26 00:00 opc:100 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x2223b582 // STLXP-R.CR-C Ct:2 Rn:12 Ct2:01101 1:1 Rs:3 1:1 L:0 001000100:001000100
	.inst 0x787471ff // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:15 00:00 opc:111 o3:0 Rs:20 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc85f7c00 // ldxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0x9b5f7ec1 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:22 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0xc2c210a0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400904 // ldr c4, [x8, #2]
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc240110d // ldr c13, [x8, #4]
	.inst 0xc240150f // ldr c15, [x8, #5]
	.inst 0xc2401914 // ldr c20, [x8, #6]
	.inst 0xc2401d1a // ldr c26, [x8, #7]
	.inst 0xc240211e // ldr c30, [x8, #8]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a8 // ldr c8, [c5, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826010a8 // ldr c8, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x5, #0xf
	and x8, x8, x5
	cmp x8, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400105 // ldr c5, [x8, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400505 // ldr c5, [x8, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400905 // ldr c5, [x8, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400d05 // ldr c5, [x8, #3]
	.inst 0xc2c5a461 // chkeq c3, c5
	b.ne comparison_fail
	.inst 0xc2401105 // ldr c5, [x8, #4]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2401505 // ldr c5, [x8, #5]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401905 // ldr c5, [x8, #6]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401d05 // ldr c5, [x8, #7]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2402105 // ldr c5, [x8, #8]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2402505 // ldr c5, [x8, #9]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc2402905 // ldr c5, [x8, #10]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2402d05 // ldr c5, [x8, #11]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	.inst 0xc2403105 // ldr c5, [x8, #12]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2403505 // ldr c5, [x8, #13]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x00001808
	ldr x1, =check_data1
	ldr x2, =0x0000180a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x004ffff0
	ldr x1, =check_data4
	ldr x2, =0x004ffff8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
