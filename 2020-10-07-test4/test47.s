.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xca, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x40, 0x80, 0x50, 0x82, 0x42, 0x28, 0xc0, 0xc2, 0xa1, 0x3a, 0xdb, 0xc2, 0x58, 0x13, 0x03, 0xb8
	.byte 0x16, 0x01, 0x1d, 0x1a, 0xc8, 0x63, 0xc7, 0xc2, 0xc1, 0xd3, 0xc0, 0xc2, 0x49, 0x90, 0xc5, 0xc2
	.byte 0xb1, 0x6f, 0xaa, 0xf0, 0xe0, 0x1b, 0x86, 0xb8, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xca0000000000000000000000000000
	/* C2 */
	.octa 0x200000000ffffffffffffff80
	/* C7 */
	.octa 0x0
	/* C21 */
	.octa 0x400000000000000000000000
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000400200040000000000000fe3
	/* C30 */
	.octa 0x800020000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x200000000ffffffffffffff80
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x800020000000000000000000
	/* C9 */
	.octa 0x4000000000020007ffffffffffffff80
	/* C17 */
	.octa 0x200080001007901700000000551f7000
	/* C21 */
	.octa 0x400000000000000000000000
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x40000000400200040000000000000fe3
	/* C30 */
	.octa 0x800020000000000000000000
initial_SP_EL3_value:
	.octa 0x80000000000e00050000000000001c43
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100790170000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4000000000020007007fffffffffff88
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82508040 // ASTR-C.RI-C Ct:0 Rn:2 op:00 imm9:100001000 L:0 1000001001:1000001001
	.inst 0xc2c02842 // BICFLGS-C.CR-C Cd:2 Cn:2 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0xc2db3aa1 // SCBNDS-C.CI-C Cd:1 Cn:21 1110:1110 S:0 imm6:110110 11000010110:11000010110
	.inst 0xb8031358 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:24 Rn:26 00:00 imm9:000110001 0:0 opc:00 111000:111000 size:10
	.inst 0x1a1d0116 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:22 Rn:8 000000:000000 Rm:29 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c763c8 // SCOFF-C.CR-C Cd:8 Cn:30 000:000 opc:11 0:0 Rm:7 11000010110:11000010110
	.inst 0xc2c0d3c1 // GCPERM-R.C-C Rd:1 Cn:30 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c59049 // CVTD-C.R-C Cd:9 Rn:2 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xf0aa6fb1 // ADRP-C.I-C Rd:17 immhi:010101001101111101 P:1 10000:10000 immlo:11 op:1
	.inst 0xb8861be0 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:31 10:10 imm9:001100001 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400462 // ldr c2, [x3, #1]
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2400c75 // ldr c21, [x3, #3]
	.inst 0xc2401078 // ldr c24, [x3, #4]
	.inst 0xc240147a // ldr c26, [x3, #5]
	.inst 0xc240187e // ldr c30, [x3, #6]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603083 // ldr c3, [c4, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601083 // ldr c3, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2401064 // ldr c4, [x3, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401464 // ldr c4, [x3, #5]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc2401864 // ldr c4, [x3, #6]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401c64 // ldr c4, [x3, #7]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2402064 // ldr c4, [x3, #8]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2402464 // ldr c4, [x3, #9]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402864 // ldr c4, [x3, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001014
	ldr x1, =check_data1
	ldr x2, =0x00001018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ca4
	ldr x1, =check_data2
	ldr x2, =0x00001ca8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
