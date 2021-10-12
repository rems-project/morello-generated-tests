.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xe0, 0x00
.data
check_data1:
	.byte 0x33, 0xeb, 0xdc, 0xa9, 0x46, 0x00, 0x13, 0xda, 0x5f, 0x3f, 0x1f, 0xea, 0x40, 0x2b, 0xc1, 0x1a
	.byte 0x29, 0x20, 0xc1, 0xc2, 0x1f, 0xd8, 0x9f, 0x82, 0xf9, 0xf3, 0x8b, 0x82, 0xff, 0x23, 0xcc, 0x9a
	.byte 0xd0, 0x87, 0x55, 0x78, 0xa1, 0x1a, 0xe5, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400000000000000000000000
	/* C5 */
	.octa 0x8a0100818bc000
	/* C11 */
	.octa 0xe70
	/* C21 */
	.octa 0x4000c98c0000000000008001
	/* C25 */
	.octa 0x800000001cfc00050000000000401018
	/* C30 */
	.octa 0x80000000500600000000000000400000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x4000c98c008a0100818bc000
	/* C5 */
	.octa 0x8a0100818bc000
	/* C9 */
	.octa 0x400000000000000000000000
	/* C11 */
	.octa 0xe70
	/* C16 */
	.octa 0xeb33
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x4000c98c0000000000008001
	/* C25 */
	.octa 0x800000001cfc000500000000004011e0
	/* C26 */
	.octa 0x1000
	/* C30 */
	.octa 0x800000005006000000000000003fff58
initial_SP_EL3_value:
	.octa 0x190
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004900070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000006000500ffffffff800001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa9dceb33 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:19 Rn:25 Rt2:11010 imm7:0111001 L:1 1010011:1010011 opc:10
	.inst 0xda130046 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:6 Rn:2 000000:000000 Rm:19 11010000:11010000 S:0 op:1 sf:1
	.inst 0xea1f3f5f // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:26 imm6:001111 Rm:31 N:0 shift:00 01010:01010 opc:11 sf:1
	.inst 0x1ac12b40 // asrv:aarch64/instrs/integer/shift/variable Rd:0 Rn:26 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xc2c12029 // SCBNDSE-C.CR-C Cd:9 Cn:1 000:000 opc:01 0:0 Rm:1 11000010110:11000010110
	.inst 0x829fd81f // ALDRSH-R.RRB-64 Rt:31 Rn:0 opc:10 S:1 option:110 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x828bf3f9 // ASTRB-R.RRB-B Rt:25 Rn:31 opc:00 S:1 option:111 Rm:11 0:0 L:0 100000101:100000101
	.inst 0x9acc23ff // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:31 op2:00 0010:0010 Rm:12 0011010110:0011010110 sf:1
	.inst 0x785587d0 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:30 01:01 imm9:101011000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2e51aa1 // CVT-C.CR-C Cd:1 Cn:21 0110:0110 0:0 0:0 Rm:5 11000010111:11000010111
	.inst 0xc2c211a0
	.zero 4540
	.inst 0x00001000
	.zero 1043988
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc24009eb // ldr c11, [x15, #2]
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850038
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031af // ldr c15, [c13, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826011af // ldr c15, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x13, #0xf
	and x15, x15, x13
	cmp x15, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ed // ldr c13, [x15, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24005ed // ldr c13, [x15, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24009ed // ldr c13, [x15, #2]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc2400ded // ldr c13, [x15, #3]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc24011ed // ldr c13, [x15, #4]
	.inst 0xc2cda561 // chkeq c11, c13
	b.ne comparison_fail
	.inst 0xc24015ed // ldr c13, [x15, #5]
	.inst 0xc2cda601 // chkeq c16, c13
	b.ne comparison_fail
	.inst 0xc24019ed // ldr c13, [x15, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401ded // ldr c13, [x15, #7]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc24021ed // ldr c13, [x15, #8]
	.inst 0xc2cda721 // chkeq c25, c13
	b.ne comparison_fail
	.inst 0xc24025ed // ldr c13, [x15, #9]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc24029ed // ldr c13, [x15, #10]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
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
	ldr x0, =0x004011e0
	ldr x1, =check_data2
	ldr x2, =0x004011f0
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
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
