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
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x2c, 0xbe, 0x46, 0xa2, 0xdb, 0x67, 0x47, 0xe2, 0xd3, 0x7f, 0x3f, 0x42, 0xf8, 0x43, 0xc0, 0xc2
	.byte 0x20, 0xb0, 0x92, 0xf8, 0xd2, 0x9b, 0x5e, 0x38, 0x41, 0x18, 0xe8, 0xc2, 0xff, 0xf9, 0x71, 0x7c
	.byte 0x07, 0x88, 0x6f, 0x82, 0x7f, 0x66, 0x37, 0x52, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0xc0014001000000000200a000
	/* C8 */
	.octa 0x2000
	/* C15 */
	.octa 0x800000000001000500000000004fb2b6
	/* C17 */
	.octa 0x90000000408008310000000000001000
	/* C19 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100050000000000001080
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0xc00140010000000002006001
	/* C2 */
	.octa 0xc0014001000000000200a000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x2000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x800000000001000500000000004fb2b6
	/* C17 */
	.octa 0x900000004080083100000000000016b0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C24 */
	.octa 0x400200920000000000001000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100050000000000001080
initial_csp_value:
	.octa 0x4002009200ffffffffffe000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000016b0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa246be2c // LDR-C.RIBW-C Ct:12 Rn:17 11:11 imm9:001101011 0:0 opc:01 10100010:10100010
	.inst 0xe24767db // ALDURH-R.RI-32 Rt:27 Rn:30 op2:01 imm9:001110110 V:0 op1:01 11100010:11100010
	.inst 0x423f7fd3 // ASTLRB-R.R-B Rt:19 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c043f8 // SCVALUE-C.CR-C Cd:24 Cn:31 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0xf892b020 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:1 00:00 imm9:100101011 0:0 opc:10 111000:111000 size:11
	.inst 0x385e9bd2 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:18 Rn:30 10:10 imm9:111101001 0:0 opc:01 111000:111000 size:00
	.inst 0xc2e81841 // CVT-C.CR-C Cd:1 Cn:2 0110:0110 0:0 0:0 Rm:8 11000010111:11000010111
	.inst 0x7c71f9ff // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:31 Rn:15 10:10 S:1 option:111 Rm:17 1:1 opc:01 111100:111100 size:01
	.inst 0x826f8807 // ALDR-R.RI-32 Rt:7 Rn:0 op:10 imm9:011111000 L:1 1000001001:1000001001
	.inst 0x5237667f // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:19 imms:011001 immr:110111 N:0 100100:100100 opc:10 sf:0
	.inst 0xc2c212e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400968 // ldr c8, [x11, #2]
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2401573 // ldr c19, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_csp_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032eb // ldr c11, [c23, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x826012eb // ldr c11, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400177 // ldr c23, [x11, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400577 // ldr c23, [x11, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400977 // ldr c23, [x11, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400d77 // ldr c23, [x11, #3]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc2401177 // ldr c23, [x11, #4]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401577 // ldr c23, [x11, #5]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401977 // ldr c23, [x11, #6]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401d77 // ldr c23, [x11, #7]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2402177 // ldr c23, [x11, #8]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2402577 // ldr c23, [x11, #9]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402977 // ldr c23, [x11, #10]
	.inst 0xc2d7a701 // chkeq c24, c23
	b.ne comparison_fail
	.inst 0xc2402d77 // ldr c23, [x11, #11]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2403177 // ldr c23, [x11, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x23, v31.d[0]
	cmp x11, x23
	b.ne comparison_fail
	ldr x11, =0x0
	mov x23, v31.d[1]
	cmp x11, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001069
	ldr x1, =check_data0
	ldr x2, =0x0000106a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001081
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f6
	ldr x1, =check_data2
	ldr x2, =0x000010f8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013e0
	ldr x1, =check_data3
	ldr x2, =0x000013e4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000016b0
	ldr x1, =check_data4
	ldr x2, =0x000016c0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fe016
	ldr x1, =check_data6
	ldr x2, =0x004fe018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
