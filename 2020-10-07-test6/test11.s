.section data0, #alloc, #write
	.zero 1136
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1584
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
	.zero 1312
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xe2, 0x2f, 0x35, 0xb1, 0xc0, 0x93, 0x8c, 0x39, 0x5a, 0xb9, 0xec, 0x92, 0x41, 0xd0, 0xc5, 0xc2
	.byte 0x4f, 0x08, 0xc2, 0xc2, 0x13, 0x1b, 0x29, 0x92, 0x42, 0x18, 0x1f, 0x6b, 0x34, 0xb6, 0xf8, 0x22
	.byte 0x22, 0x24, 0xcd, 0xc2, 0x24, 0xbe, 0x5a, 0xa2, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C17 */
	.octa 0xa0c
	/* C30 */
	.octa 0xc34
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffc2
	/* C1 */
	.octa 0x80100000640110a4000000000000dfff
	/* C2 */
	.octa 0x80100000640110a4ffffffffffffffff
	/* C4 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C13 */
	.octa 0xc2c2000000c2c2c2c2c2c2c2c2c2c2c2
	/* C15 */
	.octa 0x27ad80000000000000000000cf5b
	/* C17 */
	.octa 0x3cc
	/* C20 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C26 */
	.octa 0x9a35ffffffffffff
	/* C30 */
	.octa 0xc34
initial_SP_EL3_value:
	.octa 0xc210
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000640110a400fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001470
	.dword 0x0000000000001ab0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb1352fe2 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:31 imm12:110101001011 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x398c93c0 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:30 imm12:001100100100 opc:10 111001:111001 size:00
	.inst 0x92ecb95a // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:26 imm16:0110010111001010 hw:11 100101:100101 opc:00 sf:1
	.inst 0xc2c5d041 // CVTDZ-C.R-C Cd:1 Rn:2 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2c2084f // SEAL-C.CC-C Cd:15 Cn:2 0010:0010 opc:00 Cm:2 11000010110:11000010110
	.inst 0x92291b13 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:19 Rn:24 imms:000110 immr:101001 N:0 100100:100100 opc:00 sf:1
	.inst 0x6b1f1842 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:2 Rn:2 imm6:000110 Rm:31 0:0 shift:00 01011:01011 S:1 op:1 sf:0
	.inst 0x22f8b634 // LDP-CC.RIAW-C Ct:20 Rn:17 Ct2:01101 imm7:1110001 L:1 001000101:001000101
	.inst 0xc2cd2422 // CPYTYPE-C.C-C Cd:2 Cn:1 001:001 opc:01 0:0 Cm:13 11000010110:11000010110
	.inst 0xa25abe24 // LDR-C.RIBW-C Ct:4 Rn:17 11:11 imm9:110101011 0:0 opc:01 10100010:10100010
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x3, cptr_el3
	orr x3, x3, #0x200
	msr cptr_el3, x3
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
	ldr x3, =initial_cap_values
	.inst 0xc2400071 // ldr c17, [x3, #0]
	.inst 0xc240047e // ldr c30, [x3, #1]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e3 // ldr c3, [c7, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x826010e3 // ldr c3, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x7, #0xf
	and x3, x3, x7
	cmp x3, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400067 // ldr c7, [x3, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400867 // ldr c7, [x3, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400c67 // ldr c7, [x3, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401067 // ldr c7, [x3, #4]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401467 // ldr c7, [x3, #5]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401867 // ldr c7, [x3, #6]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc2401c67 // ldr c7, [x3, #7]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2402067 // ldr c7, [x3, #8]
	.inst 0xc2c7a741 // chkeq c26, c7
	b.ne comparison_fail
	.inst 0xc2402467 // ldr c7, [x3, #9]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001470
	ldr x1, =check_data0
	ldr x2, =0x00001480
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ab0
	ldr x1, =check_data1
	ldr x2, =0x00001ad0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffd
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
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
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
