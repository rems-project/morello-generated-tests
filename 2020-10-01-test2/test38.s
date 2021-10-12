.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x94
.data
check_data2:
	.byte 0xa1, 0x2d, 0xc1, 0x9a, 0xff, 0x77, 0x7e, 0x90, 0x76, 0xfc, 0xcf, 0x50, 0x41, 0x24, 0xde, 0x1a
	.byte 0x02, 0xab, 0xba, 0xb4, 0x14, 0xa4, 0x4c, 0x28, 0xa1, 0x79, 0xe2, 0x82, 0xc0, 0x63, 0x19, 0x38
	.byte 0x63, 0x31, 0xc2, 0xc2
.data
check_data3:
	.byte 0x21, 0x10, 0xc2, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000002007e0070000000000480694
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x204
	/* C11 */
	.octa 0x20000000c000a005000000000040a008
	/* C13 */
	.octa 0x8
	/* C30 */
	.octa 0x40000000000100050000000000002068
final_cap_values:
	/* C0 */
	.octa 0x800000002007e0070000000000480694
	/* C1 */
	.octa 0x2
	/* C2 */
	.octa 0x204
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x20000000c000a005000000000040a008
	/* C13 */
	.octa 0x8
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x2000800041b3d000000000000039ff96
	/* C30 */
	.octa 0x2000800041b3d0000000000000400025
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x2000800041b3d0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000003c07000901fffffffff82010
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9ac12da1 // rorv:aarch64/instrs/integer/shift/variable Rd:1 Rn:13 op2:11 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x907e77ff // ADRDP-C.ID-C Rd:31 immhi:111111001110111111 P:0 10000:10000 immlo:00 op:1
	.inst 0x50cffc76 // ADR-C.I-C Rd:22 immhi:100111111111100011 P:1 10000:10000 immlo:10 op:0
	.inst 0x1ade2441 // lsrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:2 op2:01 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0xb4baab02 // cbz:aarch64/instrs/branch/conditional/compare Rt:2 imm19:1011101010101011000 op:0 011010:011010 sf:1
	.inst 0x284ca414 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:20 Rn:0 Rt2:01001 imm7:0011001 L:1 1010000:1010000 opc:00
	.inst 0x82e279a1 // ALDR-V.RRB-D Rt:1 Rn:13 opc:10 S:1 option:011 Rm:2 1:1 L:1 100000101:100000101
	.inst 0x381963c0 // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:30 00:00 imm9:110010110 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c23163 // BLRR-C-C 00011:00011 Cn:11 100:100 opc:01 11000010110000100:11000010110000100
	.zero 40932
	.inst 0xc2c21021 // CHKSLD-C-C 00001:00001 Cn:1 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xc2c21180
	.zero 1007600
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
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
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
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603183 // ldr c3, [c12, #3]
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	.inst 0x82601183 // ldr c3, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr ddc_el3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x12, #0xf
	and x3, x3, x12
	cmp x3, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006c // ldr c12, [x3, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240046c // ldr c12, [x3, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240086c // ldr c12, [x3, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240106c // ldr c12, [x3, #4]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc240146c // ldr c12, [x3, #5]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240186c // ldr c12, [x3, #6]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc2401c6c // ldr c12, [x3, #7]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240206c // ldr c12, [x3, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0x0
	mov x12, v1.d[0]
	cmp x3, x12
	b.ne comparison_fail
	ldr x3, =0x0
	mov x12, v1.d[1]
	cmp x3, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040a008
	ldr x1, =check_data3
	ldr x2, =0x0040a010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004806f8
	ldr x1, =check_data4
	ldr x2, =0x00480700
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
