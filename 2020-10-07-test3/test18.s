.section data0, #alloc, #write
	.zero 3904
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 144
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xfd, 0x4f, 0x29, 0xe2, 0xbf, 0xf1, 0x00, 0xf0, 0xde, 0x31, 0x56, 0x38, 0x2c, 0x2c, 0x17, 0x12
	.byte 0xbf, 0x03, 0xc0, 0xda, 0xc4, 0xb3, 0xc0, 0xc2, 0xd9, 0x37, 0x98, 0xda, 0x60, 0x00, 0x3f, 0xd6
	.byte 0xe8, 0xff, 0xdf, 0x48, 0xe0, 0x73, 0xc2, 0xc2, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x400020
	/* C14 */
	.octa 0x8000000000010005000000000000209b
final_cap_values:
	/* C3 */
	.octa 0x400020
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0xc2c2
	/* C14 */
	.octa 0x8000000000010005000000000000209b
	/* C25 */
	.octa 0xc2
	/* C30 */
	.octa 0x200080009ffb00010000000000400021
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000001f4c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001ffb00010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000005000700000000de400000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2294ffd // ALDUR-V.RI-Q Rt:29 Rn:31 op2:11 imm9:010010100 V:1 op1:00 11100010:11100010
	.inst 0xf000f1bf // ADRDP-C.ID-C Rd:31 immhi:000000011110001101 P:0 10000:10000 immlo:11 op:1
	.inst 0x385631de // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:14 00:00 imm9:101100011 0:0 opc:01 111000:111000 size:00
	.inst 0x12172c2c // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:12 Rn:1 imms:001011 immr:010111 N:0 100100:100100 opc:00 sf:0
	.inst 0xdac003bf // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:31 Rn:29 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2c0b3c4 // GCSEAL-R.C-C Rd:4 Cn:30 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xda9837d9 // csneg:aarch64/instrs/integer/conditional/select Rd:25 Rn:30 o2:1 0:0 cond:0011 Rm:24 011010100:011010100 op:1 sf:1
	.inst 0xd63f0060 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:3 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0x48dfffe8 // ldarh:aarch64/instrs/memory/ordered Rt:8 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c21200
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400243 // ldr c3, [x18, #0]
	.inst 0xc240064e // ldr c14, [x18, #1]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	ldr x18, =0x88
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603212 // ldr c18, [c16, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601212 // ldr c18, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x16, #0x2
	and x18, x18, x16
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400250 // ldr c16, [x18, #0]
	.inst 0xc2d0a461 // chkeq c3, c16
	b.ne comparison_fail
	.inst 0xc2400650 // ldr c16, [x18, #1]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400a50 // ldr c16, [x18, #2]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2400e50 // ldr c16, [x18, #3]
	.inst 0xc2d0a5c1 // chkeq c14, c16
	b.ne comparison_fail
	.inst 0xc2401250 // ldr c16, [x18, #4]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401650 // ldr c16, [x18, #5]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0xc2c2c2c2c2c2c2c2
	mov x16, v29.d[0]
	cmp x18, x16
	b.ne comparison_fail
	ldr x18, =0xc2c2c2c2c2c2c2c2
	mov x16, v29.d[1]
	cmp x18, x16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f4c
	ldr x1, =check_data0
	ldr x2, =0x00001f4e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
