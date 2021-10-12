.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 7
.data
check_data2:
	.byte 0x81, 0x60, 0x4b, 0x38, 0xe2, 0x12, 0xc2, 0xc2, 0xa0, 0x00, 0x5f, 0xd6
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xc1, 0xf3, 0x4b, 0xb9, 0xe5, 0xfc, 0x7f, 0xb0, 0xc1, 0xfd, 0xdb, 0x78, 0x38, 0x7e, 0x51, 0xa2
	.byte 0xba, 0x8f, 0x4d, 0xb8, 0xe2, 0xf7, 0x06, 0x38, 0xfa, 0xd9, 0x06, 0x7d, 0x20, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
check_data6:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000000080080000000000001f48
	/* C5 */
	.octa 0x480000
	/* C14 */
	.octa 0x50003d
	/* C15 */
	.octa 0x1c90
	/* C17 */
	.octa 0x500e70
	/* C23 */
	.octa 0x20008000000100050000000000400008
	/* C29 */
	.octa 0x1f20
	/* C30 */
	.octa 0x403408
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000000080080000000000001f48
	/* C5 */
	.octa 0x10041d000
	/* C14 */
	.octa 0x4ffffc
	/* C15 */
	.octa 0x1c90
	/* C17 */
	.octa 0x4fffe0
	/* C23 */
	.octa 0x20008000000100050000000000400008
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x1ff8
	/* C30 */
	.octa 0x403408
initial_SP_EL3_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x384b6081 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:4 00:00 imm9:010110110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c212e2 // BRS-C-C 00010:00010 Cn:23 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xd65f00a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:5 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 524276
	.inst 0xb94bf3c1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:001011111100 opc:01 111001:111001 size:10
	.inst 0xb07ffce5 // ADRDP-C.ID-C Rd:5 immhi:111111111111100111 P:0 10000:10000 immlo:01 op:1
	.inst 0x78dbfdc1 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:14 11:11 imm9:110111111 0:0 opc:11 111000:111000 size:01
	.inst 0xa2517e38 // LDR-C.RIBW-C Ct:24 Rn:17 11:11 imm9:100010111 0:0 opc:01 10100010:10100010
	.inst 0xb84d8fba // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:26 Rn:29 11:11 imm9:011011000 0:0 opc:01 111000:111000 size:10
	.inst 0x3806f7e2 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:31 01:01 imm9:001101111 0:0 opc:00 111000:111000 size:00
	.inst 0x7d06d9fa // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:26 Rn:15 imm12:000110110110 opc:00 111101:111101 size:01
	.inst 0xc2c21320
	.zero 524256
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
	.inst 0xc24001a2 // ldr c2, [x13, #0]
	.inst 0xc24005a4 // ldr c4, [x13, #1]
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400dae // ldr c14, [x13, #3]
	.inst 0xc24011af // ldr c15, [x13, #4]
	.inst 0xc24015b1 // ldr c17, [x13, #5]
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	.inst 0xc24021be // ldr c30, [x13, #8]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q26, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850038
	msr SCTLR_EL3, x13
	ldr x13, =0x8
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260332d // ldr c13, [c25, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260132d // ldr c13, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
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
	.inst 0xc24001b9 // ldr c25, [x13, #0]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24005b9 // ldr c25, [x13, #1]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc24021b9 // ldr c25, [x13, #8]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc24025b9 // ldr c25, [x13, #9]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc24029b9 // ldr c25, [x13, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402db9 // ldr c25, [x13, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x25, v26.d[0]
	cmp x13, x25
	b.ne comparison_fail
	ldr x13, =0x0
	mov x25, v26.d[1]
	cmp x13, x25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff8
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
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403ff8
	ldr x1, =check_data3
	ldr x2, =0x00403ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00480000
	ldr x1, =check_data4
	ldr x2, =0x00480020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fffe0
	ldr x1, =check_data5
	ldr x2, =0x004ffff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffc
	ldr x1, =check_data6
	ldr x2, =0x004ffffe
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
