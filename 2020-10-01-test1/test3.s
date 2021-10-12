.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xae, 0x30, 0x90, 0xb8, 0x5f, 0x00, 0xe3, 0xc2, 0x6f, 0x25, 0xc0, 0x1a, 0x7f, 0x2d, 0xc0, 0x9a
	.byte 0xe2, 0x7a, 0xbf, 0x9b, 0x42, 0x63, 0xc1, 0xc2, 0xe1, 0x67, 0x41, 0xcb, 0x81, 0x60, 0x2a, 0xe2
	.byte 0x42, 0xd8, 0xa4, 0xf8, 0xf8, 0x83, 0xc0, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
check_data2:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xa00000000000dfe
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x16d8
	/* C5 */
	.octa 0x80000000000780270000000000408405
	/* C26 */
	.octa 0xc00600010040000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xfffffffb00000000
	/* C2 */
	.octa 0xc00600010a40000000000dff
	/* C4 */
	.octa 0x16d8
	/* C5 */
	.octa 0x80000000000780270000000000408405
	/* C14 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0xc00600010040000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007c0240000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000600400040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb89030ae // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:5 00:00 imm9:100000011 0:0 opc:10 111000:111000 size:10
	.inst 0xc2e3005f // BICFLGS-C.CI-C Cd:31 Cn:2 0:0 00:00 imm8:00011000 11000010111:11000010111
	.inst 0x1ac0256f // lsrv:aarch64/instrs/integer/shift/variable Rd:15 Rn:11 op2:01 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0x9ac02d7f // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:11 op2:11 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0x9bbf7ae2 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:23 Ra:30 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c16342 // SCOFF-C.CR-C Cd:2 Cn:26 000:000 opc:11 0:0 Rm:1 11000010110:11000010110
	.inst 0xcb4167e1 // sub_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:31 imm6:011001 Rm:1 0:0 shift:01 01011:01011 S:0 op:1 sf:1
	.inst 0xe22a6081 // ASTUR-V.RI-B Rt:1 Rn:4 op2:00 imm9:010100110 V:1 op1:00 11100010:11100010
	.inst 0xf8a4d842 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:2 10:10 S:1 option:110 Rm:4 1:1 opc:10 111000:111000 size:11
	.inst 0xc2c083f8 // SCTAG-C.CR-C Cd:24 Cn:31 000:000 0:0 10:10 Rm:0 11000010110:11000010110
	.inst 0xc2c21140
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400862 // ldr c2, [x3, #2]
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2401065 // ldr c5, [x3, #4]
	.inst 0xc240147a // ldr c26, [x3, #5]
	/* Vector registers */
	mrs x3, cptr_el3
	bfc x3, #10, #1
	msr cptr_el3, x3
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603143 // ldr c3, [c10, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x82601143 // ldr c3, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006a // ldr c10, [x3, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240046a // ldr c10, [x3, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240086a // ldr c10, [x3, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400c6a // ldr c10, [x3, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240106a // ldr c10, [x3, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240146a // ldr c10, [x3, #5]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240186a // ldr c10, [x3, #6]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2401c6a // ldr c10, [x3, #7]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x10, v1.d[0]
	cmp x3, x10
	b.ne comparison_fail
	ldr x3, =0x0
	mov x10, v1.d[1]
	cmp x3, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000177e
	ldr x1, =check_data0
	ldr x2, =0x0000177f
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
	ldr x0, =0x00408308
	ldr x1, =check_data2
	ldr x2, =0x0040830c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
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
