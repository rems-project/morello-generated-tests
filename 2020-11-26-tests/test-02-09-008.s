.section data0, #alloc, #write
	.byte 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x80
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x40, 0x01, 0x10, 0x00, 0x01, 0x04, 0x02, 0x10, 0x80
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3e, 0x71, 0x7d, 0x78, 0x07, 0xfc, 0xfa, 0x08, 0xcb, 0xe9, 0x87, 0xb8, 0xfd, 0x5b, 0xbb, 0x78
	.byte 0x5d, 0x7c, 0xd6, 0x9b, 0xad, 0x33, 0xc0, 0xc2, 0xe7, 0xc3, 0x98, 0x82, 0xb7, 0xe0, 0xf5, 0x68
	.byte 0x1b, 0xe8, 0x31, 0xe2, 0x85, 0xfc, 0x7f, 0xc8, 0x00, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc000000058010cba0000000000001422
	/* C4 */
	.octa 0x8000000002014005000000000040e560
	/* C5 */
	.octa 0x80000000000100070000000000400004
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0xc0000000600100040000000000001000
	/* C14 */
	.octa 0x800000004002000c00000000003fffb6
	/* C24 */
	.octa 0xffc0abbc
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x4a20
	/* C29 */
	.octa 0xa000
final_cap_values:
	/* C0 */
	.octa 0xc000000058010cba0000000000001422
	/* C4 */
	.octa 0x8000000002014005000000000040e560
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0xc0000000600100040000000000001000
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0xffffffffffffffff
	/* C14 */
	.octa 0x800000004002000c00000000003fffb6
	/* C23 */
	.octa 0x8fafc07
	/* C24 */
	.octa 0xffffffffb887e9cb
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x4a20
	/* C30 */
	.octa 0x8001
initial_SP_EL3_value:
	.octa 0x800000000807884e00000000003f6c40
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000006001000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x787d713e // lduminh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:9 00:00 opc:111 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x08fafc07 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:7 Rn:0 11111:11111 o0:1 Rs:26 1:1 L:1 0010001:0010001 size:00
	.inst 0xb887e9cb // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:11 Rn:14 10:10 imm9:001111110 0:0 opc:10 111000:111000 size:10
	.inst 0x78bb5bfd // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:31 10:10 S:1 option:010 Rm:27 1:1 opc:10 111000:111000 size:01
	.inst 0x9bd67c5d // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:29 Rn:2 Ra:11111 0:0 Rm:22 10:10 U:1 10011011:10011011
	.inst 0xc2c033ad // GCLEN-R.C-C Rd:13 Cn:29 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x8298c3e7 // ASTRB-R.RRB-B Rt:7 Rn:31 opc:00 S:0 option:110 Rm:24 0:0 L:0 100000101:100000101
	.inst 0x68f5e0b7 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:23 Rn:5 Rt2:11000 imm7:1101011 L:1 1010001:1010001 opc:01
	.inst 0xe231e81b // ASTUR-V.RI-Q Rt:27 Rn:0 op2:10 imm9:100011110 V:1 op1:00 11100010:11100010
	.inst 0xc87ffc85 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:5 Rn:4 Rt2:11111 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c21100
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400724 // ldr c4, [x25, #1]
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2400f27 // ldr c7, [x25, #3]
	.inst 0xc2401329 // ldr c9, [x25, #4]
	.inst 0xc240172e // ldr c14, [x25, #5]
	.inst 0xc2401b38 // ldr c24, [x25, #6]
	.inst 0xc2401f3a // ldr c26, [x25, #7]
	.inst 0xc240233b // ldr c27, [x25, #8]
	.inst 0xc240273d // ldr c29, [x25, #9]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q27, =0x80100204010010014000020000000000
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x3085103f
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603119 // ldr c25, [c8, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601119 // ldr c25, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400328 // ldr c8, [x25, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400728 // ldr c8, [x25, #1]
	.inst 0xc2c8a481 // chkeq c4, c8
	b.ne comparison_fail
	.inst 0xc2400b28 // ldr c8, [x25, #2]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2400f28 // ldr c8, [x25, #3]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401328 // ldr c8, [x25, #4]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc2401728 // ldr c8, [x25, #5]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401b28 // ldr c8, [x25, #6]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401f28 // ldr c8, [x25, #7]
	.inst 0xc2c8a5c1 // chkeq c14, c8
	b.ne comparison_fail
	.inst 0xc2402328 // ldr c8, [x25, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402728 // ldr c8, [x25, #9]
	.inst 0xc2c8a701 // chkeq c24, c8
	b.ne comparison_fail
	.inst 0xc2402b28 // ldr c8, [x25, #10]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402f28 // ldr c8, [x25, #11]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2403328 // ldr c8, [x25, #12]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x4000020000000000
	mov x8, v27.d[0]
	cmp x25, x8
	b.ne comparison_fail
	ldr x25, =0x8010020401001001
	mov x8, v27.d[1]
	cmp x25, x8
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
	ldr x0, =0x00001340
	ldr x1, =check_data1
	ldr x2, =0x00001350
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001422
	ldr x1, =check_data2
	ldr x2, =0x00001423
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017fc
	ldr x1, =check_data3
	ldr x2, =0x000017fd
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
	ldr x0, =0x00400034
	ldr x1, =check_data5
	ldr x2, =0x00400038
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x00400082
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0040e560
	ldr x1, =check_data7
	ldr x2, =0x0040e570
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
