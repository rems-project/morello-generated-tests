.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xc2, 0x19, 0x10, 0xc2, 0xde, 0x57, 0xdb, 0x82, 0x09, 0xcc, 0x5b, 0xe2, 0xa1, 0x32, 0xca, 0xb6
	.byte 0x07, 0xef, 0x0c, 0x78, 0x3e, 0x44, 0xb6, 0xaa, 0xe0, 0x73, 0xc2, 0xc2, 0x38, 0xdb, 0x8f, 0x37
	.byte 0x00, 0xe8, 0x5f, 0x3a, 0x06, 0x7d, 0x7f, 0x42, 0x60, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2008
	/* C1 */
	.octa 0x200000000000000
	/* C2 */
	.octa 0x4000000000000100004000000000
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x800000005a019a02000000000040d9e2
	/* C14 */
	.octa 0x480000001006000fffffffffffffd0a0
	/* C24 */
	.octa 0x40000000100710370000000000001018
	/* C27 */
	.octa 0x1002
	/* C30 */
	.octa 0x1
final_cap_values:
	/* C0 */
	.octa 0x2008
	/* C1 */
	.octa 0x200000000000000
	/* C2 */
	.octa 0x4000000000000100004000000000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x800000005a019a02000000000040d9e2
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x480000001006000fffffffffffffd0a0
	/* C24 */
	.octa 0x400000001007103700000000000010e6
	/* C27 */
	.octa 0x1002
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004032c0340000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000006001000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc21019c2 // STR-C.RIB-C Ct:2 Rn:14 imm12:010000000110 L:0 110000100:110000100
	.inst 0x82db57de // ALDRSB-R.RRB-32 Rt:30 Rn:30 opc:01 S:1 option:010 Rm:27 0:0 L:1 100000101:100000101
	.inst 0xe25bcc09 // ALDURSH-R.RI-32 Rt:9 Rn:0 op2:11 imm9:110111100 V:0 op1:01 11100010:11100010
	.inst 0xb6ca32a1 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:01000110010101 b40:11001 op:0 011011:011011 b5:1
	.inst 0x780cef07 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:7 Rn:24 11:11 imm9:011001110 0:0 opc:00 111000:111000 size:01
	.inst 0xaab6443e // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:1 imm6:010001 Rm:22 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x378fdb38 // tbnz:aarch64/instrs/branch/conditional/test Rt:24 imm14:11111011011001 b40:10001 op:1 011011:011011 b5:0
	.inst 0x3a5fe800 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0000 0:0 Rn:0 10:10 cond:1110 imm5:11111 111010010:111010010 op:0 sf:0
	.inst 0x427f7d06 // ALDARB-R.R-B Rt:6 Rn:8 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c21060
	.zero 1048532
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
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de7 // ldr c7, [x15, #3]
	.inst 0xc24011e8 // ldr c8, [x15, #4]
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc24019f8 // ldr c24, [x15, #6]
	.inst 0xc2401dfb // ldr c27, [x15, #7]
	.inst 0xc24021fe // ldr c30, [x15, #8]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306f // ldr c15, [c3, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260106f // ldr c15, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	mov x3, #0xf
	and x15, x15, x3
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e3 // ldr c3, [x15, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005e3 // ldr c3, [x15, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009e3 // ldr c3, [x15, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400de3 // ldr c3, [x15, #3]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc24011e3 // ldr c3, [x15, #4]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc24015e3 // ldr c3, [x15, #5]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc24019e3 // ldr c3, [x15, #6]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2401de3 // ldr c3, [x15, #7]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc24021e3 // ldr c3, [x15, #8]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc24025e3 // ldr c3, [x15, #9]
	.inst 0xc2c3a761 // chkeq c27, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001003
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010e6
	ldr x1, =check_data1
	ldr x2, =0x000010e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc4
	ldr x1, =check_data3
	ldr x2, =0x00001fc6
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
	ldr x0, =0x0040d9e2
	ldr x1, =check_data5
	ldr x2, =0x0040d9e3
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
