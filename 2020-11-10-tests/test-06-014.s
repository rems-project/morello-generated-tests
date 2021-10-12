.section data0, #alloc, #write
	.byte 0xf4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x5b, 0x10, 0xc6, 0xc2, 0x43, 0x7c, 0x1f, 0x48, 0x40, 0x00, 0x1f, 0xd6, 0x3e, 0x00, 0xa2, 0x38
	.byte 0x1f, 0x03, 0xc1, 0xc2, 0xa1, 0x09, 0xc0, 0xda, 0x7f, 0x98, 0xe1, 0xc2, 0x66, 0x7c, 0xe2, 0xc8
	.byte 0x40, 0x02, 0x5f, 0xd6
.data
check_data2:
	.byte 0x40, 0x26, 0x50, 0xe2, 0x80, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x4000000000000000000040000c
	/* C3 */
	.octa 0x407800
	/* C18 */
	.octa 0x80000000000100050000000000400100
	/* C24 */
	.octa 0x400000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0xc2c6
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x407800
	/* C18 */
	.octa 0x80000000000100050000000000400100
	/* C24 */
	.octa 0x400000000000000000000000
	/* C27 */
	.octa 0x4000000000000000000040000c
	/* C30 */
	.octa 0xf4
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c6105b // CLRPERM-C.CI-C Cd:27 Cn:2 100:100 perm:000 1100001011000110:1100001011000110
	.inst 0x481f7c43 // stxrh:aarch64/instrs/memory/exclusive/single Rt:3 Rn:2 Rt2:11111 o0:0 Rs:31 0:0 L:0 0010000:0010000 size:01
	.inst 0xd61f0040 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0x38a2003e // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:1 00:00 opc:000 0:0 Rs:2 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2c1031f // SCBNDS-C.CR-C Cd:31 Cn:24 000:000 opc:00 0:0 Rm:1 11000010110:11000010110
	.inst 0xdac009a1 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:13 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2e1987f // SUBS-R.CC-C Rd:31 Cn:3 100110:100110 Cm:1 11000010111:11000010111
	.inst 0xc8e27c66 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:6 Rn:3 11111:11111 o0:0 Rs:2 1:1 L:1 0010001:0010001 size:11
	.inst 0xd65f0240 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:18 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 220
	.inst 0xe2502640 // ALDURH-R.RI-32 Rt:0 Rn:18 op2:01 imm9:100000010 V:0 op1:01 11100010:11100010
	.inst 0xc2c21380
	.zero 1048312
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851037
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338e // ldr c14, [c28, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260138e // ldr c14, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x28, #0xf
	and x14, x14, x28
	cmp x14, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001dc // ldr c28, [x14, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005dc // ldr c28, [x14, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc24009dc // ldr c28, [x14, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400ddc // ldr c28, [x14, #3]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc24011dc // ldr c28, [x14, #4]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24015dc // ldr c28, [x14, #5]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc24019dc // ldr c28, [x14, #6]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400024
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400100
	ldr x1, =check_data2
	ldr x2, =0x00400108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00407800
	ldr x1, =check_data3
	ldr x2, =0x00407808
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
