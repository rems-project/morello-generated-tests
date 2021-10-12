.section data0, #alloc, #write
	.zero 4080
	.byte 0x21, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xd5, 0xff, 0x13, 0x8b, 0xc7, 0xf8, 0x9c, 0xe2, 0x0c, 0xd3, 0x94, 0xf8, 0xf4, 0x65, 0x99, 0x39
	.byte 0xdf, 0x2b, 0x0e, 0x9b, 0xf1, 0x7f, 0x5f, 0xc8, 0x5f, 0x36, 0x03, 0xd5, 0xc3, 0xc3, 0xbf, 0xf8
	.byte 0x22, 0x28, 0x8e, 0xf0, 0x37, 0xfc, 0xe6, 0xc8, 0x80, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001ff0
	/* C6 */
	.octa 0x480021
	/* C15 */
	.octa 0x800000000003000700000000000019a5
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000004ffff0
final_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001ff0
	/* C2 */
	.octa 0x2000800020062007000000001c907000
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x480021
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0x800000000003000700000000000019a5
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000004ffff0
initial_SP_EL3_value:
	.octa 0x8000000000008008000000000043eff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8b13ffd5 // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:21 Rn:30 imm6:111111 Rm:19 0:0 shift:00 01011:01011 S:0 op:0 sf:1
	.inst 0xe29cf8c7 // ALDURSW-R.RI-64 Rt:7 Rn:6 op2:10 imm9:111001111 V:0 op1:10 11100010:11100010
	.inst 0xf894d30c // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:12 Rn:24 00:00 imm9:101001101 0:0 opc:10 111000:111000 size:11
	.inst 0x399965f4 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:20 Rn:15 imm12:011001011001 opc:10 111001:111001 size:00
	.inst 0x9b0e2bdf // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:30 Ra:10 o0:0 Rm:14 0011011000:0011011000 sf:1
	.inst 0xc85f7ff1 // ldxr:aarch64/instrs/memory/exclusive/single Rt:17 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xd503365f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0110 11010101000000110011:11010101000000110011
	.inst 0xf8bfc3c3 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:3 Rn:30 110000:110000 Rs:11111 111000101:111000101 size:11
	.inst 0xf08e2822 // ADRP-C.IP-C Rd:2 immhi:000111000101000001 P:1 10000:10000 immlo:11 op:1
	.inst 0xc8e6fc37 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:23 Rn:1 11111:11111 o0:1 Rs:6 1:1 L:1 0010001:0010001 size:11
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
	ldr x8, =initial_cap_values
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400506 // ldr c6, [x8, #1]
	.inst 0xc240090f // ldr c15, [x8, #2]
	.inst 0xc2400d17 // ldr c23, [x8, #3]
	.inst 0xc240111e // ldr c30, [x8, #4]
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
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603388 // ldr c8, [c28, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601388 // ldr c8, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011c // ldr c28, [x8, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240051c // ldr c28, [x8, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc240091c // ldr c28, [x8, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400d1c // ldr c28, [x8, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240111c // ldr c28, [x8, #4]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc240151c // ldr c28, [x8, #5]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc240191c // ldr c28, [x8, #6]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401d1c // ldr c28, [x8, #7]
	.inst 0xc2dca681 // chkeq c20, c28
	b.ne comparison_fail
	.inst 0xc240211c // ldr c28, [x8, #8]
	.inst 0xc2dca6e1 // chkeq c23, c28
	b.ne comparison_fail
	.inst 0xc240251c // ldr c28, [x8, #9]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff0
	ldr x1, =check_data0
	ldr x2, =0x00001ff8
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
	ldr x0, =0x0043eff0
	ldr x1, =check_data3
	ldr x2, =0x0043eff8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0047fff0
	ldr x1, =check_data4
	ldr x2, =0x0047fff4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff0
	ldr x1, =check_data5
	ldr x2, =0x004ffff8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
