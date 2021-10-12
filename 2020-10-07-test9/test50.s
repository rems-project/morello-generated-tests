.section data0, #alloc, #write
	.zero 304
	.byte 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3760
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00
.data
check_data0:
	.byte 0xc0
.data
check_data1:
	.byte 0xc0
.data
check_data2:
	.byte 0xe2, 0x2b, 0xdf, 0xc2, 0xc0, 0x0b, 0xc0, 0xda, 0xe2, 0x4c, 0x20, 0xeb, 0x5a, 0x20, 0x20, 0x8b
	.byte 0xd8, 0x43, 0x8b, 0x38, 0xfd, 0x0b, 0xc0, 0x5a, 0xeb, 0x7f, 0xdf, 0x08, 0x02, 0x32, 0xc0, 0xc2
	.byte 0x82, 0xdd, 0x57, 0x38, 0xe0, 0x83, 0xc0, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc0
.data
.balign 16
initial_cap_values:
	/* C12 */
	.octa 0x2081
	/* C16 */
	.octa 0x400000000007ffffffffe001
	/* C30 */
	.octa 0x1080
final_cap_values:
	/* C0 */
	.octa 0x4fc500
	/* C2 */
	.octa 0xc0
	/* C11 */
	.octa 0xc0
	/* C12 */
	.octa 0x1ffe
	/* C16 */
	.octa 0x400000000007ffffffffe001
	/* C24 */
	.octa 0xffffffffffffffc0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1080
initial_SP_EL3_value:
	.octa 0x4fc500
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000ff900060000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df2be2 // BICFLGS-C.CR-C Cd:2 Cn:31 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0xdac00bc0 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:30 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0xeb204ce2 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:7 imm3:011 option:010 Rm:0 01011001:01011001 S:1 op:1 sf:1
	.inst 0x8b20205a // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:26 Rn:2 imm3:000 option:001 Rm:0 01011001:01011001 S:0 op:0 sf:1
	.inst 0x388b43d8 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:24 Rn:30 00:00 imm9:010110100 0:0 opc:10 111000:111000 size:00
	.inst 0x5ac00bfd // rev:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:31 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0x08df7feb // ldlarb:aarch64/instrs/memory/ordered Rt:11 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c03202 // GCLEN-R.C-C Rd:2 Cn:16 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0x3857dd82 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:12 11:11 imm9:101111101 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c083e0 // SCTAG-C.CR-C Cd:0 Cn:31 000:000 0:0 10:10 Rm:0 11000010110:11000010110
	.inst 0xc2c211a0
	.zero 1033428
	.inst 0x000000c0
	.zero 15100
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc240024c // ldr c12, [x18, #0]
	.inst 0xc2400650 // ldr c16, [x18, #1]
	.inst 0xc2400a5e // ldr c30, [x18, #2]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850038
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b2 // ldr c18, [c13, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826011b2 // ldr c18, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024d // ldr c13, [x18, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240064d // ldr c13, [x18, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400a4d // ldr c13, [x18, #2]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc2400e4d // ldr c13, [x18, #3]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc240164d // ldr c13, [x18, #5]
	.inst 0xc2cda701 // chkeq c24, c13
	b.ne comparison_fail
	.inst 0xc2401a4d // ldr c13, [x18, #6]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2401e4d // ldr c13, [x18, #7]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001134
	ldr x1, =check_data0
	ldr x2, =0x00001135
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
	ldr x0, =0x004fc500
	ldr x1, =check_data3
	ldr x2, =0x004fc501
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
