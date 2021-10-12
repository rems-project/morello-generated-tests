.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xc0, 0x4b, 0x9e, 0x4a, 0x56, 0xfc, 0x9f, 0x48, 0x2d, 0x4e, 0x07, 0x38, 0xff, 0x6b, 0xf7, 0x29
	.byte 0x9f, 0x8a, 0x1c, 0xe2, 0x82, 0x1d, 0x0e, 0x92, 0x09, 0x60, 0x51, 0xf0, 0x77, 0x40, 0x15, 0x82
	.byte 0x44, 0x04, 0x45, 0xe2, 0x59, 0x33, 0xc3, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x400000004000000100000000000013a4
	/* C12 */
	.octa 0x400000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000700060000000000001f88
	/* C20 */
	.octa 0x2036
	/* C22 */
	.octa 0x0
final_cap_values:
	/* C2 */
	.octa 0x400000
	/* C4 */
	.octa 0x0
	/* C9 */
	.octa 0x800000000006000301000000a1c03000
	/* C12 */
	.octa 0x400000
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x40000000000700060000000000001ffc
	/* C20 */
	.octa 0x2036
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x800000000000000000000000
	/* C26 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x8000000008a300070000000000002010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000006000300ffffffff000800
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x4a9e4bc0 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:30 imm6:010010 Rm:30 N:0 shift:10 01010:01010 opc:10 sf:0
	.inst 0x489ffc56 // stlrh:aarch64/instrs/memory/ordered Rt:22 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x38074e2d // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:13 Rn:17 11:11 imm9:001110100 0:0 opc:00 111000:111000 size:00
	.inst 0x29f76bff // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:31 Rt2:11010 imm7:1101110 L:1 1010011:1010011 opc:00
	.inst 0xe21c8a9f // ALDURSB-R.RI-64 Rt:31 Rn:20 op2:10 imm9:111001000 V:0 op1:00 11100010:11100010
	.inst 0x920e1d82 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:12 imms:000111 immr:001110 N:0 100100:100100 opc:00 sf:1
	.inst 0xf0516009 // ADRDP-C.ID-C Rd:9 immhi:101000101100000000 P:0 10000:10000 immlo:11 op:1
	.inst 0x82154077 // LDR-C.I-C Ct:23 imm17:01010101000000011 1000001000:1000001000
	.inst 0xe2450444 // ALDURH-R.RI-32 Rt:4 Rn:2 op2:01 imm9:001010000 V:0 op1:01 11100010:11100010
	.inst 0xc2c33359 // SEAL-C.CI-C Cd:25 Cn:26 100:100 form:01 11000010110000110:11000010110000110
	.inst 0xc2c210a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400262 // ldr c2, [x19, #0]
	.inst 0xc240066c // ldr c12, [x19, #1]
	.inst 0xc2400a6d // ldr c13, [x19, #2]
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc2401676 // ldr c22, [x19, #5]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085003a
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b3 // ldr c19, [c5, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826010b3 // ldr c19, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400265 // ldr c5, [x19, #0]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2c5a481 // chkeq c4, c5
	b.ne comparison_fail
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2c5a521 // chkeq c9, c5
	b.ne comparison_fail
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401265 // ldr c5, [x19, #4]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401665 // ldr c5, [x19, #5]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2401a65 // ldr c5, [x19, #6]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc2401e65 // ldr c5, [x19, #7]
	.inst 0xc2c5a6c1 // chkeq c22, c5
	b.ne comparison_fail
	.inst 0xc2402265 // ldr c5, [x19, #8]
	.inst 0xc2c5a6e1 // chkeq c23, c5
	b.ne comparison_fail
	.inst 0xc2402665 // ldr c5, [x19, #9]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2402a65 // ldr c5, [x19, #10]
	.inst 0xc2c5a741 // chkeq c26, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000013a4
	ldr x1, =check_data0
	ldr x2, =0x000013a6
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fc8
	ldr x1, =check_data1
	ldr x2, =0x00001fd0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffd
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x00400050
	ldr x1, =check_data5
	ldr x2, =0x00400052
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004aa040
	ldr x1, =check_data6
	ldr x2, =0x004aa050
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
