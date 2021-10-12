.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xf4, 0x7f, 0xdf, 0x48, 0xa0, 0x03, 0x3f, 0xd6
.data
check_data2:
	.byte 0xb4, 0x83, 0x53, 0x38, 0x5e, 0x2d, 0xdf, 0x1a, 0x41, 0xfd, 0x9f, 0x08, 0x60, 0x10, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xa1, 0x13, 0xc0, 0xc2, 0xe7, 0x03, 0x1d, 0x9a, 0xe7, 0xdf, 0xc6, 0x54, 0x98, 0x35, 0x60, 0xf0
	.byte 0x00, 0x30, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20008000800100050000000000400021
	/* C10 */
	.octa 0x40000000000100050000000000001ffe
	/* C29 */
	.octa 0x80000000000100050000000000404004
final_cap_values:
	/* C0 */
	.octa 0x20008000800100050000000000400021
	/* C1 */
	.octa 0x0
	/* C10 */
	.octa 0x40000000000100050000000000001ffe
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0xc000400000800000106b5000
	/* C29 */
	.octa 0x80000000000100050000000000404004
	/* C30 */
	.octa 0x1ffe
initial_SP_EL3_value:
	.octa 0x800000006804a001000000000041a200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0004000007fffff50002001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x48df7ff4 // ldlarh:aarch64/instrs/memory/ordered Rt:20 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xd63f03a0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 24
	.inst 0x385383b4 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:20 Rn:29 00:00 imm9:100111000 0:0 opc:01 111000:111000 size:00
	.inst 0x1adf2d5e // rorv:aarch64/instrs/integer/shift/variable Rd:30 Rn:10 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0x089ffd41 // stlrb:aarch64/instrs/memory/ordered Rt:1 Rn:10 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c21060
	.zero 16340
	.inst 0xc2c013a1 // GCBASE-R.C-C Rd:1 Cn:29 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9a1d03e7 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:31 000000:000000 Rm:29 11010000:11010000 S:0 op:0 sf:1
	.inst 0x54c6dfe7 // b_cond:aarch64/instrs/branch/conditional/cond cond:0111 0:0 imm19:1100011011011111111 01010100:01010100
	.inst 0xf0603598 // ADRDP-C.ID-C Rd:24 immhi:110000000110101100 P:0 10000:10000 immlo:11 op:1
	.inst 0xc2c23000 // BLR-C-C 00000:00000 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.zero 1032168
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc240066a // ldr c10, [x19, #1]
	.inst 0xc2400a7d // ldr c29, [x19, #2]
	/* Set up flags and system registers */
	mov x19, #0x10000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x88
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603073 // ldr c19, [c3, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601073 // ldr c19, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x3, #0x1
	and x19, x19, x3
	cmp x19, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400263 // ldr c3, [x19, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400663 // ldr c3, [x19, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400a63 // ldr c3, [x19, #2]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2400e63 // ldr c3, [x19, #3]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2401263 // ldr c3, [x19, #4]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc2401663 // ldr c3, [x19, #5]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2401a63 // ldr c3, [x19, #6]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffe
	ldr x1, =check_data0
	ldr x2, =0x00001fff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400020
	ldr x1, =check_data2
	ldr x2, =0x00400030
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403f3c
	ldr x1, =check_data3
	ldr x2, =0x00403f3d
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404004
	ldr x1, =check_data4
	ldr x2, =0x00404018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0041a200
	ldr x1, =check_data5
	ldr x2, =0x0041a202
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
