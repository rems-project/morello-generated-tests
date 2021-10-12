.section data0, #alloc, #write
	.zero 2064
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 2016
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xe0, 0x65, 0x1a, 0x39, 0x00, 0x78, 0xd0, 0xc2, 0x3e, 0xa8, 0x1b, 0x79, 0x4d, 0x11, 0xc4, 0xc2
.data
check_data4:
	.byte 0xdf, 0x8b, 0xf5, 0xc2, 0x06, 0x7d, 0xc4, 0x9b, 0x3e, 0x27, 0xc0, 0xc2, 0x2d, 0x08, 0xbf, 0x9b
	.byte 0x3d, 0x64, 0xc0, 0xc2, 0x3a, 0xa0, 0x04, 0xf2, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000000000000000001
	/* C1 */
	.octa 0x8000001802f0000000000000000
	/* C10 */
	.octa 0x90000000400c10020000000000001800
	/* C15 */
	.octa 0x129
	/* C25 */
	.octa 0x105fea1fc10000000000000023
	/* C30 */
	.octa 0x1000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x420100010000000000000001
	/* C1 */
	.octa 0x8000001802f0000000000000000
	/* C10 */
	.octa 0x90000000400c10020000000000001800
	/* C15 */
	.octa 0x129
	/* C25 */
	.octa 0x105fea1fc10000000000000023
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x8000001802f0000000000000001
	/* C30 */
	.octa 0x105fea1fc1ffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001ffd00030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005e0910020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001810
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x391a65e0 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:15 imm12:011010011001 opc:00 111001:111001 size:00
	.inst 0xc2d07800 // SCBNDS-C.CI-S Cd:0 Cn:0 1110:1110 S:1 imm6:100000 11000010110:11000010110
	.inst 0x791ba83e // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:011011101010 opc:00 111001:111001 size:01
	.inst 0xc2c4114d // LDPBR-C.C-C Ct:13 Cn:10 100:100 opc:00 11000010110001000:11000010110001000
	.zero 131056
	.inst 0xc2f58bdf // ORRFLGS-C.CI-C Cd:31 Cn:30 0:0 01:01 imm8:10101100 11000010111:11000010111
	.inst 0x9bc47d06 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:6 Rn:8 Ra:11111 0:0 Rm:4 10:10 U:1 10011011:10011011
	.inst 0xc2c0273e // CPYTYPE-C.C-C Cd:30 Cn:25 001:001 opc:01 0:0 Cm:0 11000010110:11000010110
	.inst 0x9bbf082d // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:13 Rn:1 Ra:2 o0:0 Rm:31 01:01 U:1 10011011:10011011
	.inst 0xc2c0643d // CPYVALUE-C.C-C Cd:29 Cn:1 001:001 opc:11 0:0 Cm:0 11000010110:11000010110
	.inst 0xf204a03a // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:26 Rn:1 imms:101000 immr:000100 N:0 100100:100100 opc:11 sf:1
	.inst 0xc2c21380
	.zero 917476
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2401139 // ldr c25, [x9, #4]
	.inst 0xc240153e // ldr c30, [x9, #5]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x4
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603389 // ldr c9, [c28, #3]
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	.inst 0x82601389 // ldr c9, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr ddc_el3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x28, #0xf
	and x9, x9, x28
	cmp x9, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240013c // ldr c28, [x9, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240053c // ldr c28, [x9, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240093c // ldr c28, [x9, #2]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc2400d3c // ldr c28, [x9, #3]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc240113c // ldr c28, [x9, #4]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc240153c // ldr c28, [x9, #5]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	.inst 0xc240193c // ldr c28, [x9, #6]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2401d3c // ldr c28, [x9, #7]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017c4
	ldr x1, =check_data0
	ldr x2, =0x000017c5
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001820
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001dd6
	ldr x1, =check_data2
	ldr x2, =0x00001dd8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400010
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00420000
	ldr x1, =check_data4
	ldr x2, =0x0042001c
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
	.inst 0xc28b4129 // msr ddc_el3, c9
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
