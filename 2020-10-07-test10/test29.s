.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x14
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x7e, 0x32, 0x06, 0xe2, 0x28, 0x20, 0xc0, 0x1a, 0x5f, 0x3f, 0x03, 0xd5, 0xec, 0x03, 0x1c, 0x9a
	.byte 0xff, 0xbb, 0xc7, 0xc2, 0x22, 0x00, 0x12, 0x5a, 0xde, 0x4f, 0xc2, 0xc2, 0xea, 0x13, 0x4d, 0xfa
	.byte 0x1f, 0x3f, 0xd4, 0xa9, 0xc1, 0xc7, 0xb5, 0x29, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0xf9e
	/* C24 */
	.octa 0x800000000000800800000000000018c8
	/* C30 */
	.octa 0x40000000400100210000000000002014
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0xf9e
	/* C24 */
	.octa 0x80000000000080080000000000001a08
	/* C30 */
	.octa 0x40000000400100210000000000001fc0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400000040000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe206327e // ASTURB-R.RI-32 Rt:30 Rn:19 op2:00 imm9:001100011 V:0 op1:00 11100010:11100010
	.inst 0x1ac02028 // lslv:aarch64/instrs/integer/shift/variable Rd:8 Rn:1 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0xd5033f5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1111 11010101000000110011:11010101000000110011
	.inst 0x9a1c03ec // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:12 Rn:31 000000:000000 Rm:28 11010000:11010000 S:0 op:0 sf:1
	.inst 0xc2c7bbff // SCBNDS-C.CI-C Cd:31 Cn:31 1110:1110 S:0 imm6:001111 11000010110:11000010110
	.inst 0x5a120022 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:1 000000:000000 Rm:18 11010000:11010000 S:0 op:1 sf:0
	.inst 0xc2c24fde // CSEL-C.CI-C Cd:30 Cn:30 11:11 cond:0100 Cm:2 11000010110:11000010110
	.inst 0xfa4d13ea // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1010 0:0 Rn:31 00:00 cond:0001 Rm:13 111010010:111010010 op:1 sf:1
	.inst 0xa9d43f1f // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:24 Rt2:01111 imm7:0101000 L:1 1010011:1010011 opc:10
	.inst 0x29b5c7c1 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:30 Rt2:10001 imm7:1101011 L:0 1010011:1010011 opc:00
	.inst 0xc2c21320
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
	.inst 0xc2400061 // ldr c1, [x3, #0]
	.inst 0xc2400471 // ldr c17, [x3, #1]
	.inst 0xc2400873 // ldr c19, [x3, #2]
	.inst 0xc2400c78 // ldr c24, [x3, #3]
	.inst 0xc240107e // ldr c30, [x3, #4]
	/* Set up flags and system registers */
	mov x3, #0xc0000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x0
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603323 // ldr c3, [c25, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601323 // ldr c3, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x25, #0xf
	and x3, x3, x25
	cmp x3, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400079 // ldr c25, [x3, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400479 // ldr c25, [x3, #1]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2400879 // ldr c25, [x3, #2]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2400c79 // ldr c25, [x3, #3]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc2401079 // ldr c25, [x3, #4]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2401479 // ldr c25, [x3, #5]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a08
	ldr x1, =check_data1
	ldr x2, =0x00001a18
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fc8
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
