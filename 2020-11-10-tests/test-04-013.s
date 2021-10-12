.section data0, #alloc, #write
	.zero 128
	.byte 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0xff, 0xff
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x3f, 0x13, 0x6e, 0x78, 0x80, 0x7b, 0x37, 0xb8, 0x41, 0x68, 0xc2, 0xc2, 0x0d, 0x24, 0xc2, 0x9a
	.byte 0x37, 0xcc, 0x1f, 0x1b, 0x60, 0x48, 0xd7, 0xf2, 0x1e, 0x7f, 0xb6, 0x08, 0x3f, 0xc8, 0x0e, 0xb8
	.byte 0xde, 0x50, 0xc1, 0xc2, 0xe6, 0xef, 0xe4, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000000000000000f14
	/* C4 */
	.octa 0x8000000000001fc0
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x3e8
	/* C24 */
	.octa 0x1000
	/* C25 */
	.octa 0x1080
	/* C28 */
	.octa 0x100
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xba4300000000
	/* C1 */
	.octa 0x800000000000000000000f14
	/* C2 */
	.octa 0x800000000000000000000f14
	/* C4 */
	.octa 0x8000000000001fc0
	/* C6 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x1000
	/* C25 */
	.octa 0x1080
	/* C28 */
	.octa 0x100
initial_SP_EL3_value:
	.octa 0x801000007001a0018000000000408240
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000700060000000000000001
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
	.inst 0x786e133f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:001 o3:0 Rs:14 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xb8377b80 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:28 10:10 S:1 option:011 Rm:23 1:1 opc:00 111000:111000 size:10
	.inst 0xc2c26841 // ORRFLGS-C.CR-C Cd:1 Cn:2 1010:1010 opc:01 Rm:2 11000010110:11000010110
	.inst 0x9ac2240d // lsrv:aarch64/instrs/integer/shift/variable Rd:13 Rn:0 op2:01 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0x1b1fcc37 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:23 Rn:1 Ra:19 o0:1 Rm:31 0011011000:0011011000 sf:0
	.inst 0xf2d74860 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1011101001000011 hw:10 100101:100101 opc:11 sf:1
	.inst 0x08b67f1e // casb:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:24 11111:11111 o0:0 Rs:22 1:1 L:0 0010001:0010001 size:00
	.inst 0xb80ec83f // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:1 10:10 imm9:011101100 0:0 opc:00 111000:111000 size:10
	.inst 0xc2c150de // CFHI-R.C-C Rd:30 Cn:6 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2e4efe6 // ALDR-C.RRB-C Ct:6 Rn:31 1:1 L:1 S:0 option:111 Rm:4 11000010111:11000010111
	.inst 0xc2c21140
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
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400964 // ldr c4, [x11, #2]
	.inst 0xc2400d6e // ldr c14, [x11, #3]
	.inst 0xc2401176 // ldr c22, [x11, #4]
	.inst 0xc2401577 // ldr c23, [x11, #5]
	.inst 0xc2401978 // ldr c24, [x11, #6]
	.inst 0xc2401d79 // ldr c25, [x11, #7]
	.inst 0xc240217c // ldr c28, [x11, #8]
	.inst 0xc240257e // ldr c30, [x11, #9]
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
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314b // ldr c11, [c10, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260114b // ldr c11, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	.inst 0xc240016a // ldr c10, [x11, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240056a // ldr c10, [x11, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240096a // ldr c10, [x11, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400d6a // ldr c10, [x11, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240116a // ldr c10, [x11, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240156a // ldr c10, [x11, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc240196a // ldr c10, [x11, #6]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc2401d6a // ldr c10, [x11, #7]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc240216a // ldr c10, [x11, #8]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc240256a // ldr c10, [x11, #9]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240296a // ldr c10, [x11, #10]
	.inst 0xc2caa781 // chkeq c28, c10
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010a4
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
	ldr x0, =0x0040a200
	ldr x1, =check_data4
	ldr x2, =0x0040a210
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
