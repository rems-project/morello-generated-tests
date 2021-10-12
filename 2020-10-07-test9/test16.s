.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xfe
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x4d, 0x45, 0x1a, 0x39, 0xc2, 0xea, 0xcb, 0x38, 0x21, 0x7c, 0xd5, 0x9b, 0xe0, 0x11, 0xc2, 0xc2
	.byte 0x1e, 0xc1, 0xbf, 0xc2, 0x69, 0xd5, 0x1c, 0xd2, 0xde, 0xf3, 0xd6, 0x82, 0xb8, 0xfd, 0x9f, 0x08
	.byte 0x40, 0x08, 0x4d, 0xd1, 0x00, 0x02, 0x3f, 0xd6
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C8 */
	.octa 0x80022007ffffffffffc0103c
	/* C10 */
	.octa 0x40000000400000020000000000001849
	/* C13 */
	.octa 0x40000000000100050000000000001ffe
	/* C15 */
	.octa 0x20008000800100050000000000400011
	/* C16 */
	.octa 0x480010
	/* C22 */
	.octa 0x80000000480000010000000000400040
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffcbe000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x80022007ffffffffffc0103c
	/* C10 */
	.octa 0x40000000400000020000000000001849
	/* C13 */
	.octa 0x40000000000100050000000000001ffe
	/* C15 */
	.octa 0x20008000800100050000000000400011
	/* C16 */
	.octa 0x480010
	/* C22 */
	.octa 0x80000000480000010000000000400040
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000800100050000000000400029
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000002140050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x391a454d // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:13 Rn:10 imm12:011010010001 opc:00 111001:111001 size:00
	.inst 0x38cbeac2 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:22 10:10 imm9:010111110 0:0 opc:11 111000:111000 size:00
	.inst 0x9bd57c21 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:1 Ra:11111 0:0 Rm:21 10:10 U:1 10011011:10011011
	.inst 0xc2c211e0 // BR-C-C 00000:00000 Cn:15 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2bfc11e // ADD-C.CRI-C Cd:30 Cn:8 imm3:000 option:110 Rm:31 11000010101:11000010101
	.inst 0xd21cd569 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:9 Rn:11 imms:110101 immr:011100 N:0 100100:100100 opc:10 sf:1
	.inst 0x82d6f3de // ALDRB-R.RRB-B Rt:30 Rn:30 opc:00 S:1 option:111 Rm:22 0:0 L:1 100000101:100000101
	.inst 0x089ffdb8 // stlrb:aarch64/instrs/memory/ordered Rt:24 Rn:13 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xd14d0840 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:2 imm12:001101000010 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xd63f0200 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:16 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 524264
	.inst 0xc2c21320
	.zero 524268
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400388 // ldr c8, [x28, #0]
	.inst 0xc240078a // ldr c10, [x28, #1]
	.inst 0xc2400b8d // ldr c13, [x28, #2]
	.inst 0xc2400f8f // ldr c15, [x28, #3]
	.inst 0xc2401390 // ldr c16, [x28, #4]
	.inst 0xc2401796 // ldr c22, [x28, #5]
	.inst 0xc2401b98 // ldr c24, [x28, #6]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x8c
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333c // ldr c28, [c25, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260133c // ldr c28, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400399 // ldr c25, [x28, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400799 // ldr c25, [x28, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400b99 // ldr c25, [x28, #2]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2400f99 // ldr c25, [x28, #3]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401399 // ldr c25, [x28, #4]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401799 // ldr c25, [x28, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401b99 // ldr c25, [x28, #6]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2401f99 // ldr c25, [x28, #7]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2402399 // ldr c25, [x28, #8]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402799 // ldr c25, [x28, #9]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000107c
	ldr x1, =check_data0
	ldr x2, =0x0000107d
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001eda
	ldr x1, =check_data1
	ldr x2, =0x00001edb
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004000fe
	ldr x1, =check_data4
	ldr x2, =0x004000ff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480010
	ldr x1, =check_data5
	ldr x2, =0x00480014
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
