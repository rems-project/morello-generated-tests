.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 496
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x07
.data
check_data2:
	.byte 0x80
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x61, 0xc2, 0xbf, 0x78, 0x7e, 0x11, 0x3f, 0x38, 0xbd, 0x84, 0x01, 0x39, 0x03, 0x04, 0x21, 0x9b
	.byte 0x02, 0x22, 0xdd, 0xc2, 0x8a, 0x2e, 0x6f, 0x82, 0x41, 0x10, 0xc2, 0xc2, 0x13, 0x70, 0xfe, 0xb8
	.byte 0x5e, 0xfc, 0x9f, 0xc8, 0xc2, 0x46, 0xd0, 0xf2, 0x80, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000200180050000000000001000
	/* C5 */
	.octa 0x40000000000100070000000000001020
	/* C11 */
	.octa 0xc0000000000200070000000000001200
	/* C16 */
	.octa 0x4000000060c700020000000000001000
	/* C19 */
	.octa 0x8000000008014005000000000041fc00
	/* C20 */
	.octa 0x1237
	/* C29 */
	.octa 0x1007
final_cap_values:
	/* C0 */
	.octa 0xc0000000200180050000000000001000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x823600001000
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000000100070000000000001020
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0xc0000000000200070000000000001200
	/* C16 */
	.octa 0x4000000060c700020000000000001000
	/* C19 */
	.octa 0x1
	/* C20 */
	.octa 0x1237
	/* C29 */
	.octa 0x1007
	/* C30 */
	.octa 0x80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000404000810000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78bfc261 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:19 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x383f117e // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:11 00:00 opc:001 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x390184bd // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:5 imm12:000001100001 opc:00 111001:111001 size:00
	.inst 0x9b210403 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:3 Rn:0 Ra:1 o0:0 Rm:1 01:01 U:0 10011011:10011011
	.inst 0xc2dd2202 // SCBNDSE-C.CR-C Cd:2 Cn:16 000:000 opc:01 0:0 Rm:29 11000010110:11000010110
	.inst 0x826f2e8a // ALDR-R.RI-64 Rt:10 Rn:20 op:11 imm9:011110010 L:1 1000001001:1000001001
	.inst 0xc2c21041 // CHKSLD-C-C 00001:00001 Cn:2 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xb8fe7013 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:19 Rn:0 00:00 opc:111 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc89ffc5e // stlr:aarch64/instrs/memory/ordered Rt:30 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xf2d046c2 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:2 imm16:1000001000110110 hw:10 100101:100101 opc:11 sf:1
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400765 // ldr c5, [x27, #1]
	.inst 0xc2400b6b // ldr c11, [x27, #2]
	.inst 0xc2400f70 // ldr c16, [x27, #3]
	.inst 0xc2401373 // ldr c19, [x27, #4]
	.inst 0xc2401774 // ldr c20, [x27, #5]
	.inst 0xc2401b7d // ldr c29, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30851037
	msr SCTLR_EL3, x27
	ldr x27, =0x4
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260339b // ldr c27, [c28, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260139b // ldr c27, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x28, #0xf
	and x27, x27, x28
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240037c // ldr c28, [x27, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240077c // ldr c28, [x27, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b7c // ldr c28, [x27, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400f7c // ldr c28, [x27, #3]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc240137c // ldr c28, [x27, #4]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc240177c // ldr c28, [x27, #5]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc2401f7c // ldr c28, [x27, #7]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc240237c // ldr c28, [x27, #8]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc240277c // ldr c28, [x27, #9]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc2402b7c // ldr c28, [x27, #10]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2402f7c // ldr c28, [x27, #11]
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
	ldr x0, =0x00001081
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001201
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a48
	ldr x1, =check_data3
	ldr x2, =0x00001a50
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0041fc00
	ldr x1, =check_data5
	ldr x2, =0x0041fc02
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
