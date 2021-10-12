.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xfd, 0x13, 0xc0, 0x5a, 0xc7, 0x68, 0xe0, 0x78, 0x2f, 0x40, 0xa6, 0xf8, 0x9b, 0x41, 0x3d, 0x38
	.byte 0x45, 0x26, 0xc3, 0x1a, 0x40, 0xc1, 0xbf, 0x38, 0xc7, 0xd3, 0xc0, 0xc2, 0x1d, 0xf4, 0xa4, 0xf9
	.byte 0xe0, 0x11, 0x59, 0xba, 0xbd, 0xfd, 0x1e, 0x48, 0x80, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffc00000400000
	/* C1 */
	.octa 0xc0000000000200070000000000001000
	/* C6 */
	.octa 0x80000000000300070000400000000000
	/* C10 */
	.octa 0x80000000400000100000000000001ffe
	/* C12 */
	.octa 0xc0000000000100050000000000001005
	/* C13 */
	.octa 0x400000000001000500000000004ffffc
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc0000000000200070000000000001000
	/* C6 */
	.octa 0x80000000000300070000400000000000
	/* C10 */
	.octa 0x80000000400000100000000000001ffe
	/* C12 */
	.octa 0xc0000000000100050000000000001005
	/* C13 */
	.octa 0x400000000001000500000000004ffffc
	/* C15 */
	.octa 0x200000
	/* C27 */
	.octa 0x40
	/* C29 */
	.octa 0x20
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac013fd // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:31 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x78e068c7 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:7 Rn:6 10:10 S:0 option:011 Rm:0 1:1 opc:11 111000:111000 size:01
	.inst 0xf8a6402f // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:1 00:00 opc:100 0:0 Rs:6 1:1 R:0 A:1 111000:111000 size:11
	.inst 0x383d419b // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:12 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x1ac32645 // lsrv:aarch64/instrs/integer/shift/variable Rd:5 Rn:18 op2:01 0010:0010 Rm:3 0011010110:0011010110 sf:0
	.inst 0x38bfc140 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:0 Rn:10 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xc2c0d3c7 // GCPERM-R.C-C Rd:7 Cn:30 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xf9a4f41d // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:0 imm12:100100111101 opc:10 111001:111001 size:11
	.inst 0xba5911e0 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:15 00:00 cond:0001 Rm:25 111010010:111010010 op:0 sf:1
	.inst 0x481efdbd // stlxrh:aarch64/instrs/memory/exclusive/single Rt:29 Rn:13 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:01
	.inst 0xc2c21380
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac6 // ldr c6, [x22, #2]
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc24012cc // ldr c12, [x22, #4]
	.inst 0xc24016cd // ldr c13, [x22, #5]
	/* Set up flags and system registers */
	mov x22, #0x40000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851037
	msr SCTLR_EL3, x22
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82601396 // ldr c22, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x28, #0xf
	and x22, x22, x28
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002dc // ldr c28, [x22, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24006dc // ldr c28, [x22, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400adc // ldr c28, [x22, #2]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc2400edc // ldr c28, [x22, #3]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc24012dc // ldr c28, [x22, #4]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24016dc // ldr c28, [x22, #5]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc2401adc // ldr c28, [x22, #6]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc2401edc // ldr c28, [x22, #7]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc24022dc // ldr c28, [x22, #8]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc24026dc // ldr c28, [x22, #9]
	.inst 0xc2dca7c1 // chkeq c30, c28
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
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x004ffffc
	ldr x1, =check_data3
	ldr x2, =0x004ffffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
