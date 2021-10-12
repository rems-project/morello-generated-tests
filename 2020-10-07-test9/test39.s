.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x05, 0xd1, 0xd2, 0x5f, 0xfd, 0x59, 0x78, 0x60, 0x11, 0xc0, 0x5a, 0x05, 0x80, 0xd2, 0xc2
	.byte 0xc1, 0xc0, 0xdf, 0xc2, 0x07, 0x00, 0x0d, 0x9a, 0xc7, 0x3f, 0x2a, 0x54
.data
check_data3:
	.byte 0x75, 0xb2, 0x5f, 0xeb, 0x21, 0x08, 0xd6, 0xc2, 0x2e, 0xec, 0x0f, 0xa2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0xc21
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1
final_cap_values:
	/* C1 */
	.octa 0xfe0
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0xbc0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x208080000006055f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000407040600ffffffffffc001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd2d10500 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1000100000101000 hw:10 100101:100101 opc:10 sf:1
	.inst 0x7859fd5f // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:10 11:11 imm9:110011111 0:0 opc:01 111000:111000 size:01
	.inst 0x5ac01160 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:11 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2d28005 // SCTAG-C.CR-C Cd:5 Cn:0 000:000 0:0 10:10 Rm:18 11000010110:11000010110
	.inst 0xc2dfc0c1 // CVT-R.CC-C Rd:1 Cn:6 110000:110000 Cm:31 11000010110:11000010110
	.inst 0x9a0d0007 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:7 Rn:0 000000:000000 Rm:13 11010000:11010000 S:0 op:0 sf:1
	.inst 0x542a3fc7 // b_cond:aarch64/instrs/branch/conditional/cond cond:0111 0:0 imm19:0010101000111111110 01010100:01010100
	.zero 346100
	.inst 0xeb5fb275 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:21 Rn:19 imm6:101100 Rm:31 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0xc2d60821 // SEAL-C.CC-C Cd:1 Cn:1 0010:0010 opc:00 Cm:22 11000010110:11000010110
	.inst 0xa20fec2e // STR-C.RIBW-C Ct:14 Rn:1 11:11 imm9:011111110 0:0 opc:00 10100010:10100010
	.inst 0xc2c21060
	.zero 702432
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x2, cptr_el3
	orr x2, x2, #0x200
	msr cptr_el3, x2
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
	ldr x2, =initial_cap_values
	.inst 0xc2400046 // ldr c6, [x2, #0]
	.inst 0xc240044a // ldr c10, [x2, #1]
	.inst 0xc240084e // ldr c14, [x2, #2]
	.inst 0xc2400c52 // ldr c18, [x2, #3]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603062 // ldr c2, [c3, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601062 // ldr c2, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x3, #0x3
	and x2, x2, x3
	cmp x2, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400043 // ldr c3, [x2, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400443 // ldr c3, [x2, #1]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc2400843 // ldr c3, [x2, #2]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2400c43 // ldr c3, [x2, #3]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401043 // ldr c3, [x2, #4]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013c0
	ldr x1, =check_data0
	ldr x2, =0x000013c2
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x000017f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040001c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00454810
	ldr x1, =check_data3
	ldr x2, =0x00454820
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
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
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
