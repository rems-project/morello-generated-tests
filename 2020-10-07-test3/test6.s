.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xdf, 0x03, 0xc0, 0x5a, 0x28, 0x00, 0x16, 0x5a, 0xdd, 0x96, 0xa3, 0xe2, 0xe9, 0x67, 0x09, 0xf1
	.byte 0x5f, 0x3f, 0x03, 0xd5, 0xe0, 0x8f, 0x95, 0x38, 0xbf, 0xc3, 0x1f, 0xa2, 0x89, 0x0a, 0xee, 0xc2
	.byte 0xd2, 0x3f, 0x26, 0xa9, 0x27, 0x52, 0x5f, 0xfa, 0x40, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x3fffe3
	/* C29 */
	.octa 0x40000000400100040000000000001c24
	/* C30 */
	.octa 0x40000000400000010000000000001808
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C9 */
	.octa 0x3fff800000007000000000000000
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x3fffe3
	/* C29 */
	.octa 0x40000000400100040000000000001c24
	/* C30 */
	.octa 0x40000000400000010000000000001808
initial_SP_EL3_value:
	.octa 0x80000000001f80270000000000408100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000004000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000007001700000000003fe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac003df // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:30 101101011000000000000:101101011000000000000 sf:0
	.inst 0x5a160028 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:8 Rn:1 000000:000000 Rm:22 11010000:11010000 S:0 op:1 sf:0
	.inst 0xe2a396dd // ALDUR-V.RI-S Rt:29 Rn:22 op2:01 imm9:000111001 V:1 op1:10 11100010:11100010
	.inst 0xf10967e9 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:9 Rn:31 imm12:001001011001 sh:0 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0xd5033f5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1111 11010101000000110011:11010101000000110011
	.inst 0x38958fe0 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:31 11:11 imm9:101011000 0:0 opc:10 111000:111000 size:00
	.inst 0xa21fc3bf // STUR-C.RI-C Ct:31 Rn:29 00:00 imm9:111111100 0:0 opc:00 10100010:10100010
	.inst 0xc2ee0a89 // ORRFLGS-C.CI-C Cd:9 Cn:20 0:0 01:01 imm8:01110000 11000010111:11000010111
	.inst 0xa9263fd2 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:18 Rn:30 Rt2:01111 imm7:1001100 L:0 1010010:1010010 opc:10
	.inst 0xfa5f5227 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0111 0:0 Rn:17 00:00 cond:0101 Rm:31 111010010:111010010 op:1 sf:1
	.inst 0xc2c21140
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
	.inst 0xc24001af // ldr c15, [x13, #0]
	.inst 0xc24005b2 // ldr c18, [x13, #1]
	.inst 0xc24009b4 // ldr c20, [x13, #2]
	.inst 0xc2400db6 // ldr c22, [x13, #3]
	.inst 0xc24011bd // ldr c29, [x13, #4]
	.inst 0xc24015be // ldr c30, [x13, #5]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085003a
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260314d // ldr c13, [c10, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260114d // ldr c13, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x10, #0x3
	and x13, x13, x10
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001aa // ldr c10, [x13, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24005aa // ldr c10, [x13, #1]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc24009aa // ldr c10, [x13, #2]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2400daa // ldr c10, [x13, #3]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24011aa // ldr c10, [x13, #4]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc24015aa // ldr c10, [x13, #5]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24019aa // ldr c10, [x13, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2401daa // ldr c10, [x13, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0xc2ee0a89
	mov x10, v29.d[0]
	cmp x13, x10
	b.ne comparison_fail
	ldr x13, =0x0
	mov x10, v29.d[1]
	cmp x13, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001668
	ldr x1, =check_data0
	ldr x2, =0x00001678
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001c20
	ldr x1, =check_data1
	ldr x2, =0x00001c30
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00408058
	ldr x1, =check_data3
	ldr x2, =0x00408059
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
