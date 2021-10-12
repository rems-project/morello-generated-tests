.section data0, #alloc, #write
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf4, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 880
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x78, 0x10, 0x00, 0x00
	.zero 3072
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xf4, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x78, 0x10, 0x00, 0x00
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x78, 0x10, 0x00, 0x00
.data
check_data7:
	.zero 2
.data
check_data8:
	.byte 0xc2, 0xbb, 0x45, 0x38, 0xc2, 0x23, 0x56, 0x69, 0x97, 0xa8, 0x42, 0xa2, 0xe5, 0x6f, 0x79, 0x28
	.byte 0x7e, 0xff, 0xdf, 0x88, 0xdb, 0xaf, 0x0d, 0xb9, 0x1f, 0x54, 0x82, 0x2a, 0xe8, 0xcb, 0x8a, 0x78
	.byte 0x22, 0x04, 0x72, 0xe2, 0xc0, 0x7f, 0x9f, 0x48, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000000001000500000000000020dc
	/* C4 */
	.octa 0x1400
	/* C30 */
	.octa 0xfcc
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800000000001000500000000000020dc
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x1400
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1078
	/* C30 */
	.octa 0x11f4
initial_csp_value:
	.octa 0x1430
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600870000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000440407ec0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3845bbc2 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:30 10:10 imm9:001011011 0:0 opc:01 111000:111000 size:00
	.inst 0x695623c2 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:2 Rn:30 Rt2:01000 imm7:0101100 L:1 1010010:1010010 opc:01
	.inst 0xa242a897 // LDTR-C.RIB-C Ct:23 Rn:4 10:10 imm9:000101010 0:0 opc:01 10100010:10100010
	.inst 0x28796fe5 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:5 Rn:31 Rt2:11011 imm7:1110010 L:1 1010000:1010000 opc:00
	.inst 0x88dfff7e // ldar:aarch64/instrs/memory/ordered Rt:30 Rn:27 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xb90dafdb // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:27 Rn:30 imm12:001101101011 opc:00 111001:111001 size:10
	.inst 0x2a82541f // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:0 imm6:010101 Rm:2 N:0 shift:10 01010:01010 opc:01 sf:0
	.inst 0x788acbe8 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:8 Rn:31 10:10 imm9:010101100 0:0 opc:10 111000:111000 size:01
	.inst 0xe2720422 // ALDUR-V.RI-H Rt:2 Rn:1 op2:01 imm9:100100000 V:1 op1:01 11100010:11100010
	.inst 0x489f7fc0 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c21140
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac4 // ldr c4, [x22, #2]
	.inst 0xc2400ede // ldr c30, [x22, #3]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_csp_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850038
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603156 // ldr c22, [c10, #3]
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	.inst 0x82601156 // ldr c22, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ca // ldr c10, [x22, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aca // ldr c10, [x22, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc24016ca // ldr c10, [x22, #5]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc2401aca // ldr c10, [x22, #6]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2401eca // ldr c10, [x22, #7]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24022ca // ldr c10, [x22, #8]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x10, v2.d[0]
	cmp x22, x10
	b.ne comparison_fail
	ldr x22, =0x0
	mov x10, v2.d[1]
	cmp x22, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001027
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011f4
	ldr x1, =check_data2
	ldr x2, =0x000011f6
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000013f8
	ldr x1, =check_data3
	ldr x2, =0x00001400
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000014dc
	ldr x1, =check_data4
	ldr x2, =0x000014de
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000016a0
	ldr x1, =check_data5
	ldr x2, =0x000016b0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fa0
	ldr x1, =check_data6
	ldr x2, =0x00001fa4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001ffc
	ldr x1, =check_data7
	ldr x2, =0x00001ffe
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x0040002c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
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
