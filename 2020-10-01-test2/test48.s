.section data0, #alloc, #write
	.zero 128
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x5f, 0x60, 0xd3, 0xc2, 0x3d, 0xb0, 0xf4, 0xc2, 0x40, 0x89, 0xde, 0xc2, 0x9b, 0x24, 0xf4, 0x68
	.byte 0x07, 0x90, 0xc0, 0xc2, 0x82, 0x59, 0xed, 0xc2, 0xe4, 0x10, 0xee, 0xc2, 0x1e, 0x20, 0x99, 0x5a
	.byte 0xde, 0x03, 0x02, 0xda, 0xe1, 0xf9, 0xd9, 0x78, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1a0030000000000000000
	/* C4 */
	.octa 0x80000000000180050000000000001080
	/* C10 */
	.octa 0x100181b70080000000000001
	/* C12 */
	.octa 0x8001000700ff000000000000
	/* C13 */
	.octa 0xff000000000000
	/* C15 */
	.octa 0x8000000045df001c000000000040007d
	/* C19 */
	.octa 0x0
	/* C30 */
	.octa 0x100040000000000000000
final_cap_values:
	/* C0 */
	.octa 0x100181b70080000000000001
	/* C1 */
	.octa 0x201e
	/* C2 */
	.octa 0x8001000700ff000000000000
	/* C4 */
	.octa 0x7000000000000000
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0xffffffffc2c2c2c2
	/* C10 */
	.octa 0x100181b70080000000000001
	/* C12 */
	.octa 0x8001000700ff000000000000
	/* C13 */
	.octa 0xff000000000000
	/* C15 */
	.octa 0x8000000045df001c000000000040007d
	/* C19 */
	.octa 0x0
	/* C27 */
	.octa 0xffffffffc2c2c2c2
	/* C29 */
	.octa 0xa500000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 144
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d3605f // SCOFF-C.CR-C Cd:31 Cn:2 000:000 opc:11 0:0 Rm:19 11000010110:11000010110
	.inst 0xc2f4b03d // EORFLGS-C.CI-C Cd:29 Cn:1 0:0 10:10 imm8:10100101 11000010111:11000010111
	.inst 0xc2de8940 // CHKSSU-C.CC-C Cd:0 Cn:10 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0x68f4249b // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:27 Rn:4 Rt2:01001 imm7:1101000 L:1 1010001:1010001 opc:01
	.inst 0xc2c09007 // GCTAG-R.C-C Rd:7 Cn:0 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2ed5982 // CVTZ-C.CR-C Cd:2 Cn:12 0110:0110 1:1 0:0 Rm:13 11000010111:11000010111
	.inst 0xc2ee10e4 // EORFLGS-C.CI-C Cd:4 Cn:7 0:0 10:10 imm8:01110000 11000010111:11000010111
	.inst 0x5a99201e // csinv:aarch64/instrs/integer/conditional/select Rd:30 Rn:0 o2:0 0:0 cond:0010 Rm:25 011010100:011010100 op:1 sf:0
	.inst 0xda0203de // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:30 000000:000000 Rm:2 11010000:11010000 S:0 op:1 sf:1
	.inst 0x78d9f9e1 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:15 10:10 imm9:110011111 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c21160
	.zero 1048532
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
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc240124c // ldr c12, [x18, #4]
	.inst 0xc240164d // ldr c13, [x18, #5]
	.inst 0xc2401a4f // ldr c15, [x18, #6]
	.inst 0xc2401e53 // ldr c19, [x18, #7]
	.inst 0xc240225e // ldr c30, [x18, #8]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82601172 // ldr c18, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x11, #0xf
	and x18, x18, x11
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024b // ldr c11, [x18, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240064b // ldr c11, [x18, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a4b // ldr c11, [x18, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240124b // ldr c11, [x18, #4]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc240164b // ldr c11, [x18, #5]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc2401a4b // ldr c11, [x18, #6]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc2401e4b // ldr c11, [x18, #7]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc240224b // ldr c11, [x18, #8]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240264b // ldr c11, [x18, #9]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc2402a4b // ldr c11, [x18, #10]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc2402e4b // ldr c11, [x18, #11]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc240324b // ldr c11, [x18, #12]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x00001088
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr ddc_el3, c18
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
