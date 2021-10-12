.section data0, #alloc, #write
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0xfd, 0xff, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3968
.data
check_data0:
	.byte 0xfd, 0xff, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x06, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xe5, 0x33, 0xce, 0x29, 0xc0, 0xab, 0xde, 0xc2, 0x1e, 0xa8, 0xc1, 0xc2, 0xf5, 0xfe, 0xdf, 0x08
	.byte 0x29, 0xb2, 0xc0, 0xc2, 0x3e, 0x77, 0xa1, 0x82, 0x3e, 0xea, 0xa1, 0xf8, 0x02, 0xa0, 0x45, 0xfc
	.byte 0x00, 0x00, 0x5f, 0xd6
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x42, 0xe0, 0xc5, 0x82, 0x40, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x260
	/* C2 */
	.octa 0x80000000000100050000000000000001
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x4003fe
	/* C25 */
	.octa 0x40000000000100050000000000000000
	/* C30 */
	.octa 0x1406
final_cap_values:
	/* C0 */
	.octa 0x1406
	/* C1 */
	.octa 0x260
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x4ffffd
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x4003fe
	/* C25 */
	.octa 0x40000000000100050000000000000000
	/* C30 */
	.octa 0x1406
initial_SP_EL3_value:
	.octa 0x1004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004840f3fa0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000200030080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x29ce33e5 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:5 Rn:31 Rt2:01100 imm7:0011100 L:1 1010011:1010011 opc:00
	.inst 0xc2deabc0 // EORFLGS-C.CR-C Cd:0 Cn:30 1010:1010 opc:10 Rm:30 11000010110:11000010110
	.inst 0xc2c1a81e // EORFLGS-C.CR-C Cd:30 Cn:0 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0x08dffef5 // ldarb:aarch64/instrs/memory/ordered Rt:21 Rn:23 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c0b229 // GCSEAL-R.C-C Rd:9 Cn:17 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x82a1773e // ASTR-R.RRB-64 Rt:30 Rn:25 opc:01 S:1 option:011 Rm:1 1:1 L:0 100000101:100000101
	.inst 0xf8a1ea3e // prfm_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:17 10:10 S:0 option:111 Rm:1 1:1 opc:10 111000:111000 size:11
	.inst 0xfc45a002 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:2 Rn:0 00:00 imm9:001011010 0:0 opc:01 111100:111100 size:11
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 2012
	.inst 0x82c5e042 // ALDRB-R.RRB-B Rt:2 Rn:2 opc:00 S:0 option:111 Rm:5 0:0 L:1 100000101:100000101
	.inst 0xc2c21240
	.zero 1046520
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a11 // ldr c17, [x16, #2]
	.inst 0xc2400e17 // ldr c23, [x16, #3]
	.inst 0xc2401219 // ldr c25, [x16, #4]
	.inst 0xc240161e // ldr c30, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x8
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603250 // ldr c16, [c18, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601250 // ldr c16, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400212 // ldr c18, [x16, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400612 // ldr c18, [x16, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400a12 // ldr c18, [x16, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400e12 // ldr c18, [x16, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401212 // ldr c18, [x16, #4]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401612 // ldr c18, [x16, #5]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401a12 // ldr c18, [x16, #6]
	.inst 0xc2d2a621 // chkeq c17, c18
	b.ne comparison_fail
	.inst 0xc2401e12 // ldr c18, [x16, #7]
	.inst 0xc2d2a6a1 // chkeq c21, c18
	b.ne comparison_fail
	.inst 0xc2402212 // ldr c18, [x16, #8]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2402612 // ldr c18, [x16, #9]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2402a12 // ldr c18, [x16, #10]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x18, v2.d[0]
	cmp x16, x18
	b.ne comparison_fail
	ldr x16, =0x0
	mov x18, v2.d[1]
	cmp x16, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001074
	ldr x1, =check_data0
	ldr x2, =0x0000107c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001308
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001460
	ldr x1, =check_data2
	ldr x2, =0x00001468
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004003fe
	ldr x1, =check_data4
	ldr x2, =0x004003ff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400800
	ldr x1, =check_data5
	ldr x2, =0x00400808
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
