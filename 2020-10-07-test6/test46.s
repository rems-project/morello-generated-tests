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
	.zero 16
.data
check_data3:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x04
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xbf, 0xe8, 0x78, 0xa2, 0x83, 0xd6, 0x3e, 0x34, 0x2b, 0xd0, 0xc5, 0xc2, 0xd7, 0x93, 0xee, 0x6d
	.byte 0x85, 0x6a, 0xe9, 0x3c, 0xbb, 0xd4, 0xab, 0xad, 0xe1, 0x63, 0x00, 0x78, 0x41, 0x28, 0x73, 0x6d
	.byte 0x32, 0xf9, 0xd4, 0x38, 0x9e, 0x92, 0x20, 0xb0, 0x00, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x100000000000000
	/* C2 */
	.octa 0x80000000000600050000000000002000
	/* C3 */
	.octa 0xffffffff
	/* C5 */
	.octa 0xc0000000400206c30000000000002010
	/* C9 */
	.octa 0x800000005f8000020000000000002008
	/* C20 */
	.octa 0x8000000040470001000000000040e018
	/* C24 */
	.octa 0xfffffffffffff380
	/* C30 */
	.octa 0x80000000000100070000000000001140
final_cap_values:
	/* C1 */
	.octa 0x100000000000000
	/* C2 */
	.octa 0x80000000000600050000000000002000
	/* C3 */
	.octa 0xffffffff
	/* C5 */
	.octa 0xc0000000400206c30000000000001d80
	/* C9 */
	.octa 0x800000005f8000020000000000002008
	/* C11 */
	.octa 0x4001b801017fffffd000b801
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x8000000040470001000000000040e018
	/* C24 */
	.octa 0xfffffffffffff380
	/* C30 */
	.octa 0x4001b801008000001125d000
initial_SP_EL3_value:
	.octa 0x40000000600200040000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x4001b801007fffffd000c440
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa278e8bf // LDR-C.RRB-C Ct:31 Rn:5 10:10 S:0 option:111 Rm:24 1:1 opc:01 10100010:10100010
	.inst 0x343ed683 // cbz:aarch64/instrs/branch/conditional/compare Rt:3 imm19:0011111011010110100 op:0 011010:011010 sf:0
	.inst 0xc2c5d02b // CVTDZ-C.R-C Cd:11 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x6dee93d7 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:23 Rn:30 Rt2:00100 imm7:1011101 L:1 1011011:1011011 opc:01
	.inst 0x3ce96a85 // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:5 Rn:20 10:10 S:0 option:011 Rm:9 1:1 opc:11 111100:111100 size:00
	.inst 0xadabd4bb // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:27 Rn:5 Rt2:10101 imm7:1010111 L:0 1011011:1011011 opc:10
	.inst 0x780063e1 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:000000110 0:0 opc:00 111000:111000 size:01
	.inst 0x6d732841 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:2 Rt2:01010 imm7:1100110 L:1 1011010:1011010 opc:01
	.inst 0x38d4f932 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:18 Rn:9 10:10 imm9:101001111 0:0 opc:11 111000:111000 size:00
	.inst 0xb020929e // ADRDP-C.ID-C Rd:30 immhi:010000010010010100 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2c21000
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2400da5 // ldr c5, [x13, #3]
	.inst 0xc24011a9 // ldr c9, [x13, #4]
	.inst 0xc24015b4 // ldr c20, [x13, #5]
	.inst 0xc24019b8 // ldr c24, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q21, =0x4010000000000000000000000000000
	ldr q27, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x8260300d // ldr c13, [c0, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260100d // ldr c13, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc24005a0 // ldr c0, [x13, #1]
	.inst 0xc2c0a441 // chkeq c2, c0
	b.ne comparison_fail
	.inst 0xc24009a0 // ldr c0, [x13, #2]
	.inst 0xc2c0a461 // chkeq c3, c0
	b.ne comparison_fail
	.inst 0xc2400da0 // ldr c0, [x13, #3]
	.inst 0xc2c0a4a1 // chkeq c5, c0
	b.ne comparison_fail
	.inst 0xc24011a0 // ldr c0, [x13, #4]
	.inst 0xc2c0a521 // chkeq c9, c0
	b.ne comparison_fail
	.inst 0xc24015a0 // ldr c0, [x13, #5]
	.inst 0xc2c0a561 // chkeq c11, c0
	b.ne comparison_fail
	.inst 0xc24019a0 // ldr c0, [x13, #6]
	.inst 0xc2c0a641 // chkeq c18, c0
	b.ne comparison_fail
	.inst 0xc2401da0 // ldr c0, [x13, #7]
	.inst 0xc2c0a681 // chkeq c20, c0
	b.ne comparison_fail
	.inst 0xc24021a0 // ldr c0, [x13, #8]
	.inst 0xc2c0a701 // chkeq c24, c0
	b.ne comparison_fail
	.inst 0xc24025a0 // ldr c0, [x13, #9]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x0, v1.d[0]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v1.d[1]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v4.d[0]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v4.d[1]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v5.d[0]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v5.d[1]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v10.d[0]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v10.d[1]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v21.d[0]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x401000000000000
	mov x0, v21.d[1]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v23.d[0]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v23.d[1]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v27.d[0]
	cmp x13, x0
	b.ne comparison_fail
	ldr x13, =0x0
	mov x0, v27.d[1]
	cmp x13, x0
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001006
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x00001038
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001390
	ldr x1, =check_data2
	ldr x2, =0x000013a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d80
	ldr x1, =check_data3
	ldr x2, =0x00001da0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f30
	ldr x1, =check_data4
	ldr x2, =0x00001f40
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f57
	ldr x1, =check_data5
	ldr x2, =0x00001f58
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00410020
	ldr x1, =check_data7
	ldr x2, =0x00410030
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
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
