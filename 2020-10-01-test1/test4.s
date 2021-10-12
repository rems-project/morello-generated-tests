.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
	.byte 0x40, 0x00, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x42, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xe2, 0xa7, 0x01, 0xa2, 0x60, 0x90, 0x4c, 0xf8, 0x9d, 0xcd, 0x2d, 0x5c, 0x21, 0xd8, 0xdb, 0xc2
	.byte 0x48, 0xc0, 0x87, 0x38, 0xc0, 0xcb, 0x50, 0x78, 0x4c, 0x30, 0xc1, 0xc2, 0xc0, 0xcf, 0x32, 0x6d
	.byte 0xc2, 0x32, 0xc4, 0xc2
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x22, 0x04, 0xc0, 0x5a, 0x80, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1042a10f0000108010ffc001
	/* C2 */
	.octa 0x20008000420100010000000000480040
	/* C3 */
	.octa 0xf8f
	/* C22 */
	.octa 0x90100000110600030000000000001640
	/* C30 */
	.octa 0x1828
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1042a10f0080000000000000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xf8f
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x90100000110600030000000000001640
	/* C30 */
	.octa 0xa0008000240022000000000000400024
initial_csp_value:
	.octa 0x1650
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000240022000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa201a7e2 // STR-C.RIAW-C Ct:2 Rn:31 01:01 imm9:000011010 0:0 opc:00 10100010:10100010
	.inst 0xf84c9060 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:3 00:00 imm9:011001001 0:0 opc:01 111000:111000 size:11
	.inst 0x5c2dcd9d // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:29 imm19:0010110111001101100 011100:011100 opc:01
	.inst 0xc2dbd821 // ALIGNU-C.CI-C Cd:1 Cn:1 0110:0110 U:1 imm6:110111 11000010110:11000010110
	.inst 0x3887c048 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:8 Rn:2 00:00 imm9:001111100 0:0 opc:10 111000:111000 size:00
	.inst 0x7850cbc0 // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:30 10:10 imm9:100001100 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c1304c // GCFLGS-R.C-C Rd:12 Cn:2 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x6d32cfc0 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:30 Rt2:10011 imm7:1100101 L:0 1011010:1011010 opc:01
	.inst 0xc2c432c2 // LDPBLR-C.C-C Ct:2 Cn:22 100:100 opc:01 11000010110001000:11000010110001000
	.zero 524316
	.inst 0x5ac00422 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:2 Rn:1 opc:01 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c21380
	.zero 524216
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b03 // ldr c3, [x24, #2]
	.inst 0xc2400f16 // ldr c22, [x24, #3]
	.inst 0xc240131e // ldr c30, [x24, #4]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q0, =0x2000000010000000
	ldr q19, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_csp_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603398 // ldr c24, [c28, #3]
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	.inst 0x82601398 // ldr c24, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240031c // ldr c28, [x24, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240071c // ldr c28, [x24, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b1c // ldr c28, [x24, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400f1c // ldr c28, [x24, #3]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc240131c // ldr c28, [x24, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240171c // ldr c28, [x24, #5]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc2401b1c // ldr c28, [x24, #6]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2401f1c // ldr c28, [x24, #7]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x2000000010000000
	mov x28, v0.d[0]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v0.d[1]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v19.d[0]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v19.d[1]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v29.d[0]
	cmp x24, x28
	b.ne comparison_fail
	ldr x24, =0x0
	mov x28, v29.d[1]
	cmp x24, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001058
	ldr x1, =check_data0
	ldr x2, =0x00001060
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001640
	ldr x1, =check_data1
	ldr x2, =0x00001660
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001734
	ldr x1, =check_data2
	ldr x2, =0x00001736
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001750
	ldr x1, =check_data3
	ldr x2, =0x00001760
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400024
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0045b9b8
	ldr x1, =check_data5
	ldr x2, =0x0045b9c0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00480040
	ldr x1, =check_data6
	ldr x2, =0x00480048
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004800bc
	ldr x1, =check_data7
	ldr x2, =0x004800bd
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr ddc_el3, c24
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
