.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xf7, 0x7f, 0x5f, 0x42, 0x08, 0xfc, 0xdf, 0xc8, 0x42, 0x00, 0x10, 0xf8, 0x22, 0x0a, 0xdf, 0x9a
	.byte 0xe5, 0x24, 0x89, 0x78, 0xa0, 0x75, 0xd0, 0x69, 0xc6, 0xd9, 0xaa, 0xf8, 0xff, 0xfd, 0x3f, 0x42
	.byte 0xc1, 0x7b, 0x1f, 0x9b, 0xe3, 0x7f, 0x9f, 0xc8, 0x40, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000090600170000000000001000
	/* C2 */
	.octa 0x40000000600107050000000000001800
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x800000004000400200000000004057fe
	/* C13 */
	.octa 0x80000000000100050000000000001074
	/* C15 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000400040020000000000405890
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x800000000001000500000000000010f4
	/* C15 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000000001000500000000000017f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005000d0020000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425f7ff7 // ALDAR-C.R-C Ct:23 Rn:31 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc8dffc08 // ldar:aarch64/instrs/memory/ordered Rt:8 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xf8100042 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:2 00:00 imm9:100000000 0:0 opc:00 111000:111000 size:11
	.inst 0x9adf0a22 // udiv:aarch64/instrs/integer/arithmetic/div Rd:2 Rn:17 o1:0 00001:00001 Rm:31 0011010110:0011010110 sf:1
	.inst 0x788924e5 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:7 01:01 imm9:010010010 0:0 opc:10 111000:111000 size:01
	.inst 0x69d075a0 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:13 Rt2:11101 imm7:0100000 L:1 1010011:1010011 opc:01
	.inst 0xf8aad9c6 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:6 Rn:14 10:10 S:1 option:110 Rm:10 1:1 opc:10 111000:111000 size:11
	.inst 0x423ffdff // ASTLR-R.R-32 Rt:31 Rn:15 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0x9b1f7bc1 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:1 Rn:30 Ra:30 o0:0 Rm:31 0011011000:0011011000 sf:1
	.inst 0xc89f7fe3 // stllr:aarch64/instrs/memory/ordered Rt:3 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c21240
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc240108d // ldr c13, [x4, #4]
	.inst 0xc240148f // ldr c15, [x4, #5]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850038
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603244 // ldr c4, [c18, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601244 // ldr c4, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400092 // ldr c18, [x4, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400492 // ldr c18, [x4, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400892 // ldr c18, [x4, #2]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2400c92 // ldr c18, [x4, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401092 // ldr c18, [x4, #4]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2401492 // ldr c18, [x4, #5]
	.inst 0xc2d2a501 // chkeq c8, c18
	b.ne comparison_fail
	.inst 0xc2401892 // ldr c18, [x4, #6]
	.inst 0xc2d2a5a1 // chkeq c13, c18
	b.ne comparison_fail
	.inst 0xc2401c92 // ldr c18, [x4, #7]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc2402092 // ldr c18, [x4, #8]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2402492 // ldr c18, [x4, #9]
	.inst 0xc2d2a7a1 // chkeq c29, c18
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
	ldr x0, =0x000010f4
	ldr x1, =check_data1
	ldr x2, =0x000010fc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001700
	ldr x1, =check_data2
	ldr x2, =0x00001708
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f0
	ldr x1, =check_data3
	ldr x2, =0x00001800
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
	ldr x0, =0x004057fe
	ldr x1, =check_data5
	ldr x2, =0x00405800
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
