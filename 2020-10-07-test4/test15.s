.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x85, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x14, 0xe0, 0x95, 0x38, 0xe9, 0xc2, 0xfa, 0x8a, 0x01, 0xe8, 0x61, 0x38, 0xe9, 0x88, 0xc6, 0xc2
	.byte 0x80, 0x34, 0x82, 0x22, 0x1f, 0x9f, 0x0d, 0x78, 0x03, 0x0f, 0xde, 0xca, 0xc1, 0x7f, 0x9f, 0x88
	.byte 0xec, 0x93, 0x59, 0x3a, 0x43, 0x30, 0xc2, 0xc2
.data
check_data5:
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2085
	/* C1 */
	.octa 0xfffffffffffff004
	/* C2 */
	.octa 0x20000000800700870000000000401cc0
	/* C4 */
	.octa 0x1010
	/* C6 */
	.octa 0x500258020000000000000001
	/* C7 */
	.octa 0x20004004701100ffffffffff8001
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C24 */
	.octa 0xf27
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x2085
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x20000000800700870000000000401cc0
	/* C3 */
	.octa 0x1200
	/* C4 */
	.octa 0x1050
	/* C6 */
	.octa 0x500258020000000000000001
	/* C7 */
	.octa 0x20004004701100ffffffffff8001
	/* C9 */
	.octa 0x4004701100ffffffffff8001
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x1000
	/* C30 */
	.octa 0x20008000800300070000000000400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000005fe80bf90000000000000000
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
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3895e014 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:20 Rn:0 00:00 imm9:101011110 0:0 opc:10 111000:111000 size:00
	.inst 0x8afac2e9 // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:9 Rn:23 imm6:110000 Rm:26 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x3861e801 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:0 10:10 S:0 option:111 Rm:1 1:1 opc:01 111000:111000 size:00
	.inst 0xc2c688e9 // CHKSSU-C.CC-C Cd:9 Cn:7 0010:0010 opc:10 Cm:6 11000010110:11000010110
	.inst 0x22823480 // STP-CC.RIAW-C Ct:0 Rn:4 Ct2:01101 imm7:0000100 L:0 001000101:001000101
	.inst 0x780d9f1f // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:24 11:11 imm9:011011001 0:0 opc:00 111000:111000 size:01
	.inst 0xcade0f03 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:3 Rn:24 imm6:000011 Rm:30 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0x889f7fc1 // stllr:aarch64/instrs/memory/ordered Rt:1 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x3a5993ec // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1100 0:0 Rn:31 00:00 cond:1001 Rm:25 111010010:111010010 op:0 sf:0
	.inst 0xc2c23043 // BLRR-C-C 00011:00011 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.zero 7320
	.inst 0xc2c21260
	.zero 1041212
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2400ea4 // ldr c4, [x21, #3]
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc24016a7 // ldr c7, [x21, #5]
	.inst 0xc2401aad // ldr c13, [x21, #6]
	.inst 0xc2401eb8 // ldr c24, [x21, #7]
	.inst 0xc24022be // ldr c30, [x21, #8]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x80
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603275 // ldr c21, [c19, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601275 // ldr c21, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x19, #0x3
	and x21, x21, x19
	cmp x21, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b3 // ldr c19, [x21, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24006b3 // ldr c19, [x21, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400ab3 // ldr c19, [x21, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400eb3 // ldr c19, [x21, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc24012b3 // ldr c19, [x21, #4]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc24016b3 // ldr c19, [x21, #5]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2401ab3 // ldr c19, [x21, #6]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401eb3 // ldr c19, [x21, #7]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc24022b3 // ldr c19, [x21, #8]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc24026b3 // ldr c19, [x21, #9]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2402ab3 // ldr c19, [x21, #10]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2402eb3 // ldr c19, [x21, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001089
	ldr x1, =check_data2
	ldr x2, =0x0000108a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe3
	ldr x1, =check_data3
	ldr x2, =0x00001fe4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401cc0
	ldr x1, =check_data5
	ldr x2, =0x00401cc4
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
