.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x25, 0xcc, 0x4a, 0xad, 0x40, 0x84, 0xde, 0xc2
.data
check_data2:
	.byte 0x3e, 0x74, 0xff, 0x82, 0x01, 0xc0, 0xdf, 0xc2, 0xea, 0xe1, 0x84, 0xb8, 0x92, 0xfd, 0x9f, 0x08
	.byte 0x7e, 0x71, 0x98, 0x2b, 0x23, 0x22, 0xc1, 0xc2, 0x54, 0x68, 0x9e, 0xca, 0xa3, 0x10, 0xc2, 0xc2
.data
check_data3:
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
check_data6:
	.zero 32
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x47e0a0
	/* C2 */
	.octa 0x20408002000100070000000000400021
	/* C5 */
	.octa 0x20000000c000c001000000000040c004
	/* C12 */
	.octa 0x40000000000700020000000000001006
	/* C15 */
	.octa 0x8000000050020002000000000040ffb6
	/* C17 */
	.octa 0x800100040000000000000000
	/* C18 */
	.octa 0x0
	/* C30 */
	.octa 0x400002000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x20408002000100070000000000400021
	/* C3 */
	.octa 0xc00100000000000000000000
	/* C5 */
	.octa 0x20000000c000c001000000000040c004
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x40000000000700020000000000001006
	/* C15 */
	.octa 0x8000000050020002000000000040ffb6
	/* C17 */
	.octa 0x800100040000000000000000
	/* C18 */
	.octa 0x0
	/* C29 */
	.octa 0x400000000000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000700ffeda00000e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xad4acc25 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:5 Rn:1 Rt2:10011 imm7:0010101 L:1 1011010:1011010 opc:10
	.inst 0xc2de8440 // BRS-C.C-C 00000:00000 Cn:2 001:001 opc:00 1:1 Cm:30 11000010110:11000010110
	.zero 24
	.inst 0x82ff743e // ALDR-R.RRB-64 Rt:30 Rn:1 opc:01 S:1 option:011 Rm:31 1:1 L:1 100000101:100000101
	.inst 0xc2dfc001 // CVT-R.CC-C Rd:1 Cn:0 110000:110000 Cm:31 11000010110:11000010110
	.inst 0xb884e1ea // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:10 Rn:15 00:00 imm9:001001110 0:0 opc:10 111000:111000 size:10
	.inst 0x089ffd92 // stlrb:aarch64/instrs/memory/ordered Rt:18 Rn:12 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x2b98717e // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:11 imm6:011100 Rm:24 0:0 shift:10 01011:01011 S:1 op:0 sf:0
	.inst 0xc2c12223 // SCBNDSE-C.CR-C Cd:3 Cn:17 000:000 opc:01 0:0 Rm:1 11000010110:11000010110
	.inst 0xca9e6854 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:20 Rn:2 imm6:011010 Rm:30 N:0 shift:10 01010:01010 opc:10 sf:1
	.inst 0xc2c210a3 // BRR-C-C 00011:00011 Cn:5 100:100 opc:00 11000010110000100:11000010110000100
	.zero 49092
	.inst 0xc2c21260
	.zero 999416
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2400f45 // ldr c5, [x26, #3]
	.inst 0xc240134c // ldr c12, [x26, #4]
	.inst 0xc240174f // ldr c15, [x26, #5]
	.inst 0xc2401b51 // ldr c17, [x26, #6]
	.inst 0xc2401f52 // ldr c18, [x26, #7]
	.inst 0xc240235e // ldr c30, [x26, #8]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260327a // ldr c26, [c19, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x8260127a // ldr c26, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400353 // ldr c19, [x26, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400753 // ldr c19, [x26, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400b53 // ldr c19, [x26, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400f53 // ldr c19, [x26, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2401353 // ldr c19, [x26, #4]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401753 // ldr c19, [x26, #5]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2401b53 // ldr c19, [x26, #6]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc2401f53 // ldr c19, [x26, #7]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2402353 // ldr c19, [x26, #8]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc2402753 // ldr c19, [x26, #9]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402b53 // ldr c19, [x26, #10]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x19, v5.d[0]
	cmp x26, x19
	b.ne comparison_fail
	ldr x26, =0x0
	mov x19, v5.d[1]
	cmp x26, x19
	b.ne comparison_fail
	ldr x26, =0x0
	mov x19, v19.d[0]
	cmp x26, x19
	b.ne comparison_fail
	ldr x26, =0x0
	mov x19, v19.d[1]
	cmp x26, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001006
	ldr x1, =check_data0
	ldr x2, =0x00001007
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400020
	ldr x1, =check_data2
	ldr x2, =0x00400040
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040c004
	ldr x1, =check_data3
	ldr x2, =0x0040c008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00410004
	ldr x1, =check_data4
	ldr x2, =0x00410008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0047e0a0
	ldr x1, =check_data5
	ldr x2, =0x0047e0a8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0047e1f0
	ldr x1, =check_data6
	ldr x2, =0x0047e210
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
	.inst 0xc28b413a // msr ddc_el3, c26
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
