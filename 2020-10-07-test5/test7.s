.section data0, #alloc, #write
	.byte 0xb6, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.byte 0xb6, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x0c, 0x7c, 0xc0, 0x9b, 0x41, 0x84, 0xdf, 0xc2, 0x5c, 0xa0, 0xdf, 0xc2, 0x3e, 0x78, 0xdd, 0xc2
	.byte 0xe0, 0x50, 0x0d, 0x1b, 0xe1, 0x13, 0xc4, 0xc2
.data
check_data4:
	.byte 0x2e, 0x20, 0xd9, 0x39, 0x01, 0xb5, 0xaa, 0xb6
.data
check_data5:
	.byte 0xfe, 0xc9, 0x53, 0x78, 0x1f, 0x45, 0x7e, 0xea, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1000400000000000000000000000
	/* C2 */
	.octa 0x1000000010000000000000000
	/* C8 */
	.octa 0x0
	/* C15 */
	.octa 0x2000
final_cap_values:
	/* C1 */
	.octa 0x1018000000000000000000019b6
	/* C2 */
	.octa 0x1000000010000000000000000
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x2000
	/* C28 */
	.octa 0x1000000010000000000000000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x90000000000040000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000000070007000000000000c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword final_cap_values + 0
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9bc07c0c // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:12 Rn:0 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0xc2df8441 // CHKSS-_.CC-C 00001:00001 Cn:2 001:001 opc:00 1:1 Cm:31 11000010110:11000010110
	.inst 0xc2dfa05c // CLRPERM-C.CR-C Cd:28 Cn:2 000:000 1:1 10:10 Rm:31 11000010110:11000010110
	.inst 0xc2dd783e // SCBNDS-C.CI-S Cd:30 Cn:1 1110:1110 S:1 imm6:111010 11000010110:11000010110
	.inst 0x1b0d50e0 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:0 Rn:7 Ra:20 o0:0 Rm:13 0011011000:0011011000 sf:0
	.inst 0xc2c413e1 // LDPBR-C.C-C Ct:1 Cn:31 100:100 opc:00 11000010110001000:11000010110001000
	.zero 16360
	.inst 0x39d9202e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:14 Rn:1 imm12:011001001000 opc:11 111001:111001 size:00
	.inst 0xb6aab501 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:01010110101000 b40:10101 op:0 011011:011011 b5:1
	.zero 22172
	.inst 0x7853c9fe // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:15 10:10 imm9:100111100 0:0 opc:01 111000:111000 size:01
	.inst 0xea7e451f // bics:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:8 imm6:010001 Rm:30 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0xc2c212a0
	.zero 1010000
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400482 // ldr c2, [x4, #1]
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a4 // ldr c4, [c21, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826012a4 // ldr c4, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x21, #0xf
	and x4, x4, x21
	cmp x4, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400095 // ldr c21, [x4, #0]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400495 // ldr c21, [x4, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400895 // ldr c21, [x4, #2]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2400c95 // ldr c21, [x4, #3]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401095 // ldr c21, [x4, #4]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401495 // ldr c21, [x4, #5]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc2401895 // ldr c21, [x4, #6]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f3c
	ldr x1, =check_data1
	ldr x2, =0x00001f3e
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
	ldr x2, =0x00400018
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00404000
	ldr x1, =check_data4
	ldr x2, =0x00404008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004096a4
	ldr x1, =check_data5
	ldr x2, =0x004096b0
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
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
