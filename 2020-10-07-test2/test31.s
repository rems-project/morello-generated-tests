.section data0, #alloc, #write
	.zero 1088
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2992
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc6, 0xe2, 0x08, 0x00
.data
check_data1:
	.byte 0x10
.data
check_data2:
	.byte 0x00, 0x08, 0x00, 0x00, 0x80, 0x00, 0x40, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x00, 0x08
.data
check_data5:
	.zero 32
.data
check_data6:
	.zero 32
.data
check_data7:
	.byte 0xe8, 0x9d, 0xe3, 0x42, 0x3e, 0xe4, 0x1e, 0x28, 0xfe, 0x7f, 0x9f, 0x48, 0x20, 0x28, 0x4c, 0x38
	.byte 0x5f, 0x3d, 0x03, 0xd5, 0x5f, 0x50, 0x70, 0x62, 0x17, 0x14, 0x1b, 0xa2, 0x20, 0x87, 0xce, 0xc2
.data
check_data8:
	.byte 0x20, 0x56, 0xb8, 0x72, 0xc7, 0xff, 0x9f, 0xc8, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x398
	/* C2 */
	.octa 0x10b0
	/* C14 */
	.octa 0x400002000000000000000000000000
	/* C15 */
	.octa 0x11b0
	/* C23 */
	.octa 0x8e2c6000000000000000000000000
	/* C25 */
	.octa 0x204080025007004e0000000000400080
	/* C30 */
	.octa 0x800
final_cap_values:
	/* C0 */
	.octa 0xc2b1fb20
	/* C1 */
	.octa 0x398
	/* C2 */
	.octa 0x10b0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x400002000000000000000000000000
	/* C15 */
	.octa 0x11b0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x8e2c6000000000000000000000000
	/* C25 */
	.octa 0x204080025007004e0000000000400080
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x800
initial_SP_EL3_value:
	.octa 0x850
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000006ff00ff000fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001e10
	.dword 0x0000000000001e20
	.dword 0x0000000000001ea0
	.dword 0x0000000000001eb0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x42e39de8 // LDP-C.RIB-C Ct:8 Rn:15 Ct2:00111 imm7:1000111 L:1 010000101:010000101
	.inst 0x281ee43e // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:30 Rn:1 Rt2:11001 imm7:0111101 L:0 1010000:1010000 opc:00
	.inst 0x489f7ffe // stllrh:aarch64/instrs/memory/ordered Rt:30 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x384c2820 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:011000010 0:0 opc:01 111000:111000 size:00
	.inst 0xd5033d5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1101 11010101000000110011:11010101000000110011
	.inst 0x6270505f // LDNP-C.RIB-C Ct:31 Rn:2 Ct2:10100 imm7:1100000 L:1 011000100:011000100
	.inst 0xa21b1417 // STR-C.RIAW-C Ct:23 Rn:0 01:01 imm9:110110001 0:0 opc:00 10100010:10100010
	.inst 0xc2ce8720 // BRS-C.C-C 00000:00000 Cn:25 001:001 opc:00 1:1 Cm:14 11000010110:11000010110
	.zero 96
	.inst 0x72b85620 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:1100001010110001 hw:01 100101:100101 opc:11 sf:0
	.inst 0xc89fffc7 // stlr:aarch64/instrs/memory/ordered Rt:7 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c210c0
	.zero 1048436
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x10, cptr_el3
	orr x10, x10, #0x200
	msr cptr_el3, x10
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
	ldr x10, =initial_cap_values
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400542 // ldr c2, [x10, #1]
	.inst 0xc240094e // ldr c14, [x10, #2]
	.inst 0xc2400d4f // ldr c15, [x10, #3]
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc2401559 // ldr c25, [x10, #5]
	.inst 0xc240195e // ldr c30, [x10, #6]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30850038
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030ca // ldr c10, [c6, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010ca // ldr c10, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400146 // ldr c6, [x10, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400946 // ldr c6, [x10, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d46 // ldr c6, [x10, #3]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2401146 // ldr c6, [x10, #4]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401546 // ldr c6, [x10, #5]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401946 // ldr c6, [x10, #6]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401d46 // ldr c6, [x10, #7]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402146 // ldr c6, [x10, #8]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402546 // ldr c6, [x10, #9]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402946 // ldr c6, [x10, #10]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc2402d46 // ldr c6, [x10, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x0000144a
	ldr x1, =check_data1
	ldr x2, =0x0000144b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000147c
	ldr x1, =check_data2
	ldr x2, =0x00001484
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017f0
	ldr x1, =check_data3
	ldr x2, =0x000017f8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001840
	ldr x1, =check_data4
	ldr x2, =0x00001842
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001e10
	ldr x1, =check_data5
	ldr x2, =0x00001e30
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001ea0
	ldr x1, =check_data6
	ldr x2, =0x00001ec0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x00400020
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400080
	ldr x1, =check_data8
	ldr x2, =0x0040008c
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
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
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
