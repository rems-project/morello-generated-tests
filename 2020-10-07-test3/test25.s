.section data0, #alloc, #write
	.zero 2272
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1808
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x00, 0x42, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x15, 0xc8, 0x8d, 0xb8, 0xc5, 0x40, 0xe0, 0x82, 0x03, 0xe8, 0x02, 0x38, 0x58, 0x08, 0x24, 0x79
	.byte 0x5a, 0x7e, 0xdf, 0x88, 0x45, 0xa0, 0x65, 0x82, 0xa0, 0xca, 0x3f, 0xeb, 0x60, 0x7b, 0x0c, 0x78
	.byte 0xe0, 0x5c, 0x03, 0xbc, 0xa0, 0x02, 0x1f, 0xd6
.data
check_data7:
	.byte 0xa0, 0x13, 0xc2, 0xc2
.data
check_data8:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1804
	/* C2 */
	.octa 0x90000000000100050000000000000c00
	/* C3 */
	.octa 0x0
	/* C6 */
	.octa 0x800000000001000500000000004fe7f4
	/* C7 */
	.octa 0x1003
	/* C18 */
	.octa 0x4ffff8
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1c09
final_cap_values:
	/* C0 */
	.octa 0x420000
	/* C2 */
	.octa 0x90000000000100050000000000000c00
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x800000000001000500000000004fe7f4
	/* C7 */
	.octa 0x1038
	/* C18 */
	.octa 0x4ffff8
	/* C21 */
	.octa 0x420000
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x1c09
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
	.dword 0x00000000000011a0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88dc815 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:21 Rn:0 10:10 imm9:011011100 0:0 opc:10 111000:111000 size:10
	.inst 0x82e040c5 // ALDR-R.RRB-32 Rt:5 Rn:6 opc:00 S:0 option:010 Rm:0 1:1 L:1 100000101:100000101
	.inst 0x3802e803 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:3 Rn:0 10:10 imm9:000101110 0:0 opc:00 111000:111000 size:00
	.inst 0x79240858 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:24 Rn:2 imm12:100100000010 opc:00 111001:111001 size:01
	.inst 0x88df7e5a // ldlar:aarch64/instrs/memory/ordered Rt:26 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0x8265a045 // ALDR-C.RI-C Ct:5 Rn:2 op:00 imm9:001011010 L:1 1000001001:1000001001
	.inst 0xeb3fcaa0 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:21 imm3:010 option:110 Rm:31 01011001:01011001 S:1 op:1 sf:1
	.inst 0x780c7b60 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:27 10:10 imm9:011000111 0:0 opc:00 111000:111000 size:01
	.inst 0xbc035ce0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:0 Rn:7 11:11 imm9:000110101 0:0 opc:00 111100:111100 size:10
	.inst 0xd61f02a0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:21 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 131032
	.inst 0xc2c213a0
	.zero 917500
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2400f26 // ldr c6, [x25, #3]
	.inst 0xc2401327 // ldr c7, [x25, #4]
	.inst 0xc2401732 // ldr c18, [x25, #5]
	.inst 0xc2401b38 // ldr c24, [x25, #6]
	.inst 0xc2401f3b // ldr c27, [x25, #7]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850032
	msr SCTLR_EL3, x25
	ldr x25, =0x8
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b9 // ldr c25, [c29, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826013b9 // ldr c25, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x29, #0xf
	and x25, x25, x29
	cmp x25, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240033d // ldr c29, [x25, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240073d // ldr c29, [x25, #1]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400b3d // ldr c29, [x25, #2]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc2400f3d // ldr c29, [x25, #3]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc240133d // ldr c29, [x25, #4]
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	.inst 0xc240173d // ldr c29, [x25, #5]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc2401b3d // ldr c29, [x25, #6]
	.inst 0xc2dda641 // chkeq c18, c29
	b.ne comparison_fail
	.inst 0xc2401f3d // ldr c29, [x25, #7]
	.inst 0xc2dda6a1 // chkeq c21, c29
	b.ne comparison_fail
	.inst 0xc240233d // ldr c29, [x25, #8]
	.inst 0xc2dda701 // chkeq c24, c29
	b.ne comparison_fail
	.inst 0xc240273d // ldr c29, [x25, #9]
	.inst 0xc2dda741 // chkeq c26, c29
	b.ne comparison_fail
	.inst 0xc2402b3d // ldr c29, [x25, #10]
	.inst 0xc2dda761 // chkeq c27, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x29, v0.d[0]
	cmp x25, x29
	b.ne comparison_fail
	ldr x25, =0x0
	mov x29, v0.d[1]
	cmp x25, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001038
	ldr x1, =check_data0
	ldr x2, =0x0000103c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011a0
	ldr x1, =check_data1
	ldr x2, =0x000011b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001832
	ldr x1, =check_data2
	ldr x2, =0x00001833
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000018e0
	ldr x1, =check_data3
	ldr x2, =0x000018e4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001cd0
	ldr x1, =check_data4
	ldr x2, =0x00001cd2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e04
	ldr x1, =check_data5
	ldr x2, =0x00001e06
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00420000
	ldr x1, =check_data7
	ldr x2, =0x00420004
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ffff8
	ldr x1, =check_data8
	ldr x2, =0x004ffffc
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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

	.balign 128
vector_table:
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
