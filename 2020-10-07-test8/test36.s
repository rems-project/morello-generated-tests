.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x9b
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0x22, 0x50, 0xc0, 0xc2, 0x40, 0x8d, 0xcf, 0xe2, 0x20, 0xb8, 0x0a, 0xe2, 0xcd, 0xa8, 0x4b, 0xf0
	.byte 0xc2, 0x5b, 0x4a, 0xe2, 0xa8, 0x13, 0xc0, 0xc2, 0x6a, 0x7d, 0xde, 0x9b, 0x57, 0xa2, 0x43, 0xb8
	.byte 0xde, 0xfb, 0x21, 0x38, 0x30, 0x1d, 0x5e, 0x69, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1003
	/* C9 */
	.octa 0x80000000000100050000000000001004
	/* C10 */
	.octa 0x10e8
	/* C18 */
	.octa 0x80000000000500070000000000001f82
	/* C29 */
	.octa 0x700060000000000000000
	/* C30 */
	.octa 0x40000000000100050000000000000f9b
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1003
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x80000000000100050000000000001004
	/* C13 */
	.octa 0x80000000000b00070000000097523000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000000500070000000000001f82
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x700060000000000000000
	/* C30 */
	.octa 0x40000000000100050000000000000f9b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000b00070000000000008004
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000011e0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c05022 // GCVALUE-R.C-C Rd:2 Cn:1 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xe2cf8d40 // ALDUR-C.RI-C Ct:0 Rn:10 op2:11 imm9:011111000 V:0 op1:11 11100010:11100010
	.inst 0xe20ab820 // ALDURSB-R.RI-64 Rt:0 Rn:1 op2:10 imm9:010101011 V:0 op1:00 11100010:11100010
	.inst 0xf04ba8cd // ADRDP-C.ID-C Rd:13 immhi:100101110101000110 P:0 10000:10000 immlo:11 op:1
	.inst 0xe24a5bc2 // ALDURSH-R.RI-64 Rt:2 Rn:30 op2:10 imm9:010100101 V:0 op1:01 11100010:11100010
	.inst 0xc2c013a8 // GCBASE-R.C-C Rd:8 Cn:29 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9bde7d6a // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:10 Rn:11 Ra:11111 0:0 Rm:30 10:10 U:1 10011011:10011011
	.inst 0xb843a257 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:23 Rn:18 00:00 imm9:000111010 0:0 opc:01 111000:111000 size:10
	.inst 0x3821fbde // strb_reg:aarch64/instrs/memory/single/general/register Rt:30 Rn:30 10:10 S:1 option:111 Rm:1 1:1 opc:00 111000:111000 size:00
	.inst 0x695e1d30 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:16 Rn:9 Rt2:00111 imm7:0111100 L:1 1010010:1010010 opc:01
	.inst 0xc2c21320
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400749 // ldr c9, [x26, #1]
	.inst 0xc2400b4a // ldr c10, [x26, #2]
	.inst 0xc2400f52 // ldr c18, [x26, #3]
	.inst 0xc240135d // ldr c29, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850032
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333a // ldr c26, [c25, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260133a // ldr c26, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400359 // ldr c25, [x26, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400759 // ldr c25, [x26, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b59 // ldr c25, [x26, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400f59 // ldr c25, [x26, #3]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2401359 // ldr c25, [x26, #4]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401759 // ldr c25, [x26, #5]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401b59 // ldr c25, [x26, #6]
	.inst 0xc2d9a5a1 // chkeq c13, c25
	b.ne comparison_fail
	.inst 0xc2401f59 // ldr c25, [x26, #7]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc2402359 // ldr c25, [x26, #8]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2402759 // ldr c25, [x26, #9]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402b59 // ldr c25, [x26, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402f59 // ldr c25, [x26, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001042
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010ae
	ldr x1, =check_data1
	ldr x2, =0x000010af
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010f4
	ldr x1, =check_data2
	ldr x2, =0x000010fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011e0
	ldr x1, =check_data3
	ldr x2, =0x000011f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f9e
	ldr x1, =check_data4
	ldr x2, =0x00001f9f
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fbc
	ldr x1, =check_data5
	ldr x2, =0x00001fc0
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
