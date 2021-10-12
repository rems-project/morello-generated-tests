.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xb6, 0x13, 0xc1, 0xc2, 0x32, 0xa8, 0x56, 0xa8, 0xd2, 0x91, 0xef, 0xc2, 0xc5, 0x6c, 0xe0, 0xd8
	.byte 0x05, 0x20, 0xc5, 0xc2, 0xbf, 0x30, 0xc1, 0xc2, 0xbf, 0xec, 0x8c, 0xb9, 0xf7, 0x33, 0x27, 0x31
	.byte 0xc1, 0x97, 0x59, 0x69, 0xe0, 0x73, 0xc2, 0xc2, 0x40, 0x13, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800300070000000000000114
	/* C1 */
	.octa 0x4
	/* C14 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000000000000000e001
	/* C30 */
	.octa 0x710
final_cap_values:
	/* C0 */
	.octa 0x800300070000000000000114
	/* C1 */
	.octa 0xffffffffc2c2c2c2
	/* C5 */
	.octa 0xffffffffc2c2c2c2
	/* C10 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x7c00000000000000
	/* C22 */
	.octa 0x10000
	/* C29 */
	.octa 0x40000000000000000000e001
	/* C30 */
	.octa 0x710
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000057f40004000000000040e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c113b6 // GCLIM-R.C-C Rd:22 Cn:29 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xa856a832 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:18 Rn:1 Rt2:01010 imm7:0101101 L:1 1010000:1010000 opc:10
	.inst 0xc2ef91d2 // EORFLGS-C.CI-C Cd:18 Cn:14 0:0 10:10 imm8:01111100 11000010111:11000010111
	.inst 0xd8e06cc5 // prfm_lit:aarch64/instrs/memory/literal/general Rt:5 imm19:1110000001101100110 011000:011000 opc:11
	.inst 0xc2c52005 // SCBNDSE-C.CR-C Cd:5 Cn:0 000:000 opc:01 0:0 Rm:5 11000010110:11000010110
	.inst 0xc2c130bf // GCFLGS-R.C-C Rd:31 Cn:5 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xb98cecbf // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:5 imm12:001100111011 opc:10 111001:111001 size:10
	.inst 0x312733f7 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:23 Rn:31 imm12:100111001100 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x695997c1 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:30 Rt2:00101 imm7:0110011 L:1 1010010:1010010 opc:01
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c21340
	.zero 65860
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1632
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1564
	.inst 0xc2c2c2c2
	.zero 979448
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
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a0e // ldr c14, [x16, #2]
	.inst 0xc2400e1d // ldr c29, [x16, #3]
	.inst 0xc240121e // ldr c30, [x16, #4]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82603350 // ldr c16, [c26, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601350 // ldr c16, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
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
	.inst 0xc240021a // ldr c26, [x16, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240061a // ldr c26, [x16, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a1a // ldr c26, [x16, #2]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc2400e1a // ldr c26, [x16, #3]
	.inst 0xc2daa541 // chkeq c10, c26
	b.ne comparison_fail
	.inst 0xc240121a // ldr c26, [x16, #4]
	.inst 0xc2daa5c1 // chkeq c14, c26
	b.ne comparison_fail
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2daa6c1 // chkeq c22, c26
	b.ne comparison_fail
	.inst 0xc2401e1a // ldr c26, [x16, #7]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240221a // ldr c26, [x16, #8]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00410170
	ldr x1, =check_data1
	ldr x2, =0x00410180
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004107e0
	ldr x1, =check_data2
	ldr x2, =0x004107e8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410e04
	ldr x1, =check_data3
	ldr x2, =0x00410e08
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
