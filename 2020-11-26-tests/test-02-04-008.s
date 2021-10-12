.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x5e, 0x8a, 0x0a, 0xa2, 0xb5, 0x23, 0xdf, 0x1a, 0xa0, 0x03, 0xb3, 0x9b, 0xce, 0x71, 0xc0, 0xc2
	.byte 0x3d, 0x40, 0x43, 0x38, 0x3d, 0x14, 0xc0, 0xda, 0xfd, 0x83, 0x58, 0xbc, 0x31, 0x17, 0x4a, 0xe2
	.byte 0x56, 0xc4, 0x3c, 0xd0, 0x72, 0x61, 0x3b, 0x78, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000400400050000000000000fcc
	/* C11 */
	.octa 0xc000000000010005000000000000100e
	/* C14 */
	.octa 0x300060000000000000000
	/* C18 */
	.octa 0x40000000400100020000000000000580
	/* C25 */
	.octa 0x101f
	/* C27 */
	.octa 0x8000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x80000000400400050000000000000fcc
	/* C11 */
	.octa 0xc000000000010005000000000000100e
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000540200040100000079889000
	/* C25 */
	.octa 0x101f
	/* C27 */
	.octa 0x8000
	/* C29 */
	.octa 0x33
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000600030000000000001500
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005402000400fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa20a8a5e // STTR-C.RIB-C Ct:30 Rn:18 10:10 imm9:010101000 0:0 opc:00 10100010:10100010
	.inst 0x1adf23b5 // lslv:aarch64/instrs/integer/shift/variable Rd:21 Rn:29 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0x9bb303a0 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:29 Ra:0 o0:0 Rm:19 01:01 U:1 10011011:10011011
	.inst 0xc2c071ce // GCOFF-R.C-C Rd:14 Cn:14 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x3843403d // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:1 00:00 imm9:000110100 0:0 opc:01 111000:111000 size:00
	.inst 0xdac0143d // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:29 Rn:1 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xbc5883fd // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:29 Rn:31 00:00 imm9:110001000 0:0 opc:01 111100:111100 size:10
	.inst 0xe24a1731 // ALDURH-R.RI-32 Rt:17 Rn:25 op2:01 imm9:010100001 V:0 op1:01 11100010:11100010
	.inst 0xd03cc456 // ADRP-C.I-C Rd:22 immhi:011110011000100010 P:0 10000:10000 immlo:10 op:1
	.inst 0x783b6172 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:11 00:00 opc:110 0:0 Rs:27 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2c21060
	.zero 1048532
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
	ldr x20, =initial_cap_values
	.inst 0xc2400281 // ldr c1, [x20, #0]
	.inst 0xc240068b // ldr c11, [x20, #1]
	.inst 0xc2400a8e // ldr c14, [x20, #2]
	.inst 0xc2400e92 // ldr c18, [x20, #3]
	.inst 0xc2401299 // ldr c25, [x20, #4]
	.inst 0xc240169b // ldr c27, [x20, #5]
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603074 // ldr c20, [c3, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601074 // ldr c20, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400283 // ldr c3, [x20, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400683 // ldr c3, [x20, #1]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2400a83 // ldr c3, [x20, #2]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2400e83 // ldr c3, [x20, #3]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401283 // ldr c3, [x20, #4]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401683 // ldr c3, [x20, #5]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc2401a83 // ldr c3, [x20, #6]
	.inst 0xc2c3a721 // chkeq c25, c3
	b.ne comparison_fail
	.inst 0xc2401e83 // ldr c3, [x20, #7]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	.inst 0xc2402283 // ldr c3, [x20, #8]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402683 // ldr c3, [x20, #9]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x3, v29.d[0]
	cmp x20, x3
	b.ne comparison_fail
	ldr x20, =0x0
	mov x3, v29.d[1]
	cmp x20, x3
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
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010c2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001488
	ldr x1, =check_data2
	ldr x2, =0x0000148c
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
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
