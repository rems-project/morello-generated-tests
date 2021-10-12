.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x01, 0xe4, 0x00, 0xf8, 0x13, 0x08, 0xde, 0xc2, 0x5e, 0x14, 0xd6, 0x28, 0x42, 0x60, 0x11, 0x02
	.byte 0xde, 0xdb, 0x1f, 0xca, 0x5f, 0xb5, 0xc3, 0xd8, 0xec, 0xd3, 0x0e, 0x78, 0xa1, 0x30, 0xc1, 0xc2
	.byte 0x22, 0xf0, 0xc5, 0xc2, 0x37, 0xba, 0x4f, 0xf8, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xfc7
	/* C1 */
	.octa 0xc000000000000
	/* C2 */
	.octa 0x1007
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x444
final_cap_values:
	/* C0 */
	.octa 0xfd5
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x444
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x810
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000060000e0100ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf800e401 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:0 01:01 imm9:000001110 0:0 opc:00 111000:111000 size:11
	.inst 0xc2de0813 // SEAL-C.CC-C Cd:19 Cn:0 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0x28d6145e // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:2 Rt2:00101 imm7:0101100 L:1 1010001:1010001 opc:00
	.inst 0x02116042 // ADD-C.CIS-C Cd:2 Cn:2 imm12:010001011000 sh:0 A:0 00000010:00000010
	.inst 0xca1fdbde // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:30 imm6:110110 Rm:31 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0xd8c3b55f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1100001110110101010 011000:011000 opc:11
	.inst 0x780ed3ec // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:12 Rn:31 00:00 imm9:011101101 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c130a1 // GCFLGS-R.C-C Rd:1 Cn:5 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc2c5f022 // CVTPZ-C.R-C Cd:2 Rn:1 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xf84fba37 // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:23 Rn:17 10:10 imm9:011111011 0:0 opc:01 111000:111000 size:11
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400902 // ldr c2, [x8, #2]
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc2401111 // ldr c17, [x8, #4]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850038
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603328 // ldr c8, [c25, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601328 // ldr c8, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400119 // ldr c25, [x8, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400519 // ldr c25, [x8, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400919 // ldr c25, [x8, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400d19 // ldr c25, [x8, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401119 // ldr c25, [x8, #4]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401519 // ldr c25, [x8, #5]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401919 // ldr c25, [x8, #6]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2401d19 // ldr c25, [x8, #7]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001340
	ldr x1, =check_data0
	ldr x2, =0x00001348
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000016fe
	ldr x1, =check_data1
	ldr x2, =0x00001700
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001dc8
	ldr x1, =check_data2
	ldr x2, =0x00001dd0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e08
	ldr x1, =check_data3
	ldr x2, =0x00001e10
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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
