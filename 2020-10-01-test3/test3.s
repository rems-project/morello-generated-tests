.section data0, #alloc, #write
	.zero 2048
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0x5f, 0xa4, 0xf4, 0x68, 0x20, 0x58, 0x5e, 0xaa, 0x5f, 0x28, 0xc0, 0x9a, 0x2a, 0x01, 0xc0, 0x5a
	.byte 0xf8, 0xef, 0xc0, 0xc2, 0x7e, 0xfc, 0xdf, 0x08, 0xc3, 0x29, 0xca, 0xc2, 0x22, 0xdd, 0x75, 0x02
	.byte 0x1f, 0x43, 0xdf, 0x4a, 0x86, 0x70, 0xe8, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1800
	/* C3 */
	.octa 0x1ffe
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x0
final_cap_values:
	/* C2 */
	.octa 0xffffffffc39a32c2
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x3fff800000004300000000000000
	/* C9 */
	.octa 0xffffffffc2c2c2c2
	/* C10 */
	.octa 0x43434343
	/* C14 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0xc2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000040000fff00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x68f4a45f // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:31 Rn:2 Rt2:01001 imm7:1101001 L:1 1010001:1010001 opc:01
	.inst 0xaa5e5820 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:1 imm6:010110 Rm:30 N:0 shift:01 01010:01010 opc:01 sf:1
	.inst 0x9ac0285f // asrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:2 op2:10 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0x5ac0012a // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:10 Rn:9 101101011000000000000:101101011000000000000 sf:0
	.inst 0xc2c0eff8 // CSEL-C.CI-C Cd:24 Cn:31 11:11 cond:1110 Cm:0 11000010110:11000010110
	.inst 0x08dffc7e // ldarb:aarch64/instrs/memory/ordered Rt:30 Rn:3 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2ca29c3 // BICFLGS-C.CR-C Cd:3 Cn:14 1010:1010 opc:00 Rm:10 11000010110:11000010110
	.inst 0x0275dd22 // ADD-C.CIS-C Cd:2 Cn:9 imm12:110101110111 sh:1 A:0 00000010:00000010
	.inst 0x4adf431f // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:24 imm6:010000 Rm:31 N:0 shift:11 01010:01010 opc:10 sf:0
	.inst 0xc2e87086 // EORFLGS-C.CI-C Cd:6 Cn:4 0:0 10:10 imm8:01000011 11000010111:11000010111
	.inst 0xc2c213a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400382 // ldr c2, [x28, #0]
	.inst 0xc2400783 // ldr c3, [x28, #1]
	.inst 0xc2400b84 // ldr c4, [x28, #2]
	.inst 0xc2400f8e // ldr c14, [x28, #3]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033bc // ldr c28, [c29, #3]
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	.inst 0x826013bc // ldr c28, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039d // ldr c29, [x28, #0]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc240079d // ldr c29, [x28, #1]
	.inst 0xc2dda461 // chkeq c3, c29
	b.ne comparison_fail
	.inst 0xc2400b9d // ldr c29, [x28, #2]
	.inst 0xc2dda481 // chkeq c4, c29
	b.ne comparison_fail
	.inst 0xc2400f9d // ldr c29, [x28, #3]
	.inst 0xc2dda4c1 // chkeq c6, c29
	b.ne comparison_fail
	.inst 0xc240139d // ldr c29, [x28, #4]
	.inst 0xc2dda521 // chkeq c9, c29
	b.ne comparison_fail
	.inst 0xc240179d // ldr c29, [x28, #5]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	.inst 0xc2dda5c1 // chkeq c14, c29
	b.ne comparison_fail
	.inst 0xc2401f9d // ldr c29, [x28, #7]
	.inst 0xc2dda701 // chkeq c24, c29
	b.ne comparison_fail
	.inst 0xc240239d // ldr c29, [x28, #8]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001800
	ldr x1, =check_data0
	ldr x2, =0x00001808
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
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
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr ddc_el3, c28
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
