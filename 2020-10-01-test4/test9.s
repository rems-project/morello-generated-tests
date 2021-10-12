.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x40, 0xfc, 0x9f, 0x08, 0xc1, 0xc7, 0x5a, 0x82, 0x2a, 0x9d, 0x82, 0x72, 0xc0, 0xaa, 0xd5, 0xc2
	.byte 0xa2, 0xb0, 0xc5, 0xc2, 0xec, 0xfa, 0x63, 0x82, 0xdf, 0xa7, 0x19, 0xe2, 0x61, 0x2c, 0x0e, 0x31
	.byte 0x5e, 0x7c, 0xda, 0x9b, 0x21, 0x94, 0x7c, 0x70, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x40000000000200010000000000001ffc
	/* C5 */
	.octa 0x80000000000001
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x14fc
	/* C30 */
	.octa 0x10e2
final_cap_values:
	/* C1 */
	.octa 0x200080000001000700000000004f92ab
	/* C2 */
	.octa 0x20008000000100070080000000000001
	/* C5 */
	.octa 0x80000000000001
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x14fc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x089ffc40 // stlrb:aarch64/instrs/memory/ordered Rt:0 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x825ac7c1 // ASTRB-R.RI-B Rt:1 Rn:30 op:01 imm9:110101100 L:0 1000001001:1000001001
	.inst 0x72829d2a // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:10 imm16:0001010011101001 hw:00 100101:100101 opc:11 sf:0
	.inst 0xc2d5aac0 // EORFLGS-C.CR-C Cd:0 Cn:22 1010:1010 opc:10 Rm:21 11000010110:11000010110
	.inst 0xc2c5b0a2 // CVTP-C.R-C Cd:2 Rn:5 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x8263faec // ALDR-R.RI-32 Rt:12 Rn:23 op:10 imm9:000111111 L:1 1000001001:1000001001
	.inst 0xe219a7df // ALDURB-R.RI-32 Rt:31 Rn:30 op2:01 imm9:110011010 V:0 op1:00 11100010:11100010
	.inst 0x310e2c61 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:3 imm12:001110001011 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x9bda7c5e // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:2 Ra:11111 0:0 Rm:26 10:10 U:1 10011011:10011011
	.inst 0x707c9421 // ADR-C.I-C Rd:1 immhi:111110010010100001 P:0 10000:10000 immlo:11 op:0
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b62 // ldr c2, [x27, #2]
	.inst 0xc2400f65 // ldr c5, [x27, #3]
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc2401777 // ldr c23, [x27, #5]
	.inst 0xc2401b7e // ldr c30, [x27, #6]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850032
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031bb // ldr c27, [c13, #3]
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	.inst 0x826011bb // ldr c27, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036d // ldr c13, [x27, #0]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240076d // ldr c13, [x27, #1]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400b6d // ldr c13, [x27, #2]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc2400f6d // ldr c13, [x27, #3]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc240136d // ldr c13, [x27, #4]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc240176d // ldr c13, [x27, #5]
	.inst 0xc2cda6e1 // chkeq c23, c13
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
	ldr x0, =0x0000128e
	ldr x1, =check_data1
	ldr x2, =0x0000128f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000015f8
	ldr x1, =check_data2
	ldr x2, =0x000015fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffd
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
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr ddc_el3, c27
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
