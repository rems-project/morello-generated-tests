.section data0, #alloc, #write
	.byte 0x1c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 384
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 3664
.data
check_data0:
	.byte 0x1c, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x22, 0xc0, 0x07, 0x79, 0x47, 0x90, 0xc0, 0xc2, 0xaa, 0x85, 0x8e, 0x30, 0x68, 0x23, 0x5c, 0x3a
	.byte 0xd0, 0xaf, 0x59, 0xa2, 0x7f, 0xc8, 0x41, 0x38, 0x20, 0x33, 0xd9, 0xc2, 0x4b, 0x4d, 0x32, 0xab
	.byte 0xe2, 0x5f, 0xe0, 0x22, 0xcc, 0x7f, 0x7f, 0x42, 0x00, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000000c58
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x800000000407a00600000000003ffff3
	/* C25 */
	.octa 0x90100000000300070000000000001370
	/* C30 */
	.octa 0x80100000000100050000000000002000
final_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000000c58
	/* C2 */
	.octa 0x101800000000000000000000000
	/* C3 */
	.octa 0x800000000407a00600000000003ffff3
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x200080000000a008000000000031d0bd
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x101800000000000000000000000
	/* C25 */
	.octa 0x90100000000300070000000000001370
	/* C30 */
	.octa 0x801000000001000500000000000019a0
initial_SP_EL3_value:
	.octa 0x1190
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001190
	.dword 0x00000000000011a0
	.dword 0x00000000000019a0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7907c022 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:1 imm12:000111110000 opc:00 111001:111001 size:01
	.inst 0xc2c09047 // GCTAG-R.C-C Rd:7 Cn:2 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x308e85aa // ADR-C.I-C Rd:10 immhi:000111010000101101 P:1 10000:10000 immlo:01 op:0
	.inst 0x3a5c2368 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1000 0:0 Rn:27 00:00 cond:0010 Rm:28 111010010:111010010 op:0 sf:0
	.inst 0xa259afd0 // LDR-C.RIBW-C Ct:16 Rn:30 11:11 imm9:110011010 0:0 opc:01 10100010:10100010
	.inst 0x3841c87f // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:3 10:10 imm9:000011100 0:0 opc:01 111000:111000 size:00
	.inst 0xc2d93320 // BR-CI-C 0:0 0000:0000 Cn:25 100:100 imm7:1001001 110000101101:110000101101
	.inst 0xab324d4b // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:11 Rn:10 imm3:011 option:010 Rm:18 01011001:01011001 S:1 op:0 sf:1
	.inst 0x22e05fe2 // LDP-CC.RIAW-C Ct:2 Rn:31 Ct2:10111 imm7:1000000 L:1 001000101:001000101
	.inst 0x427f7fcc // ALDARB-R.R-B Rt:12 Rn:30 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c21000
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400121 // ldr c1, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400923 // ldr c3, [x9, #2]
	.inst 0xc2400d39 // ldr c25, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Set up flags and system registers */
	mov x9, #0x20000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850032
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x82603009 // ldr c9, [c0, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601009 // ldr c9, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x0, #0x4
	and x9, x9, x0
	cmp x9, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc2400520 // ldr c0, [x9, #1]
	.inst 0xc2c0a441 // chkeq c2, c0
	b.ne comparison_fail
	.inst 0xc2400920 // ldr c0, [x9, #2]
	.inst 0xc2c0a461 // chkeq c3, c0
	b.ne comparison_fail
	.inst 0xc2400d20 // ldr c0, [x9, #3]
	.inst 0xc2c0a4e1 // chkeq c7, c0
	b.ne comparison_fail
	.inst 0xc2401120 // ldr c0, [x9, #4]
	.inst 0xc2c0a541 // chkeq c10, c0
	b.ne comparison_fail
	.inst 0xc2401520 // ldr c0, [x9, #5]
	.inst 0xc2c0a581 // chkeq c12, c0
	b.ne comparison_fail
	.inst 0xc2401920 // ldr c0, [x9, #6]
	.inst 0xc2c0a601 // chkeq c16, c0
	b.ne comparison_fail
	.inst 0xc2401d20 // ldr c0, [x9, #7]
	.inst 0xc2c0a6e1 // chkeq c23, c0
	b.ne comparison_fail
	.inst 0xc2402120 // ldr c0, [x9, #8]
	.inst 0xc2c0a721 // chkeq c25, c0
	b.ne comparison_fail
	.inst 0xc2402520 // ldr c0, [x9, #9]
	.inst 0xc2c0a7c1 // chkeq c30, c0
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001038
	ldr x1, =check_data1
	ldr x2, =0x0000103a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001190
	ldr x1, =check_data2
	ldr x2, =0x000011b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000019a0
	ldr x1, =check_data3
	ldr x2, =0x000019b0
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
