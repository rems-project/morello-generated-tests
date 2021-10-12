.section data0, #alloc, #write
	.byte 0x08, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2656
	.byte 0x00, 0x97, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa4, 0x8d, 0x80, 0xd7, 0x00, 0x80, 0x00, 0x20
	.zero 1408
.data
check_data0:
	.byte 0x19, 0x00
.data
check_data1:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x97, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa4, 0x8d, 0x80, 0xd7, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xf8, 0x04
.data
check_data5:
	.byte 0x95, 0x62, 0xfd, 0x78, 0x48, 0x5d, 0xa4, 0x02, 0x44, 0x30, 0xbf, 0x6a, 0xc0, 0xea, 0xf8, 0xb6
	.byte 0x3e, 0xcc, 0x15, 0x78, 0x61, 0xb2, 0xdc, 0xc2
.data
check_data6:
	.byte 0xfb, 0xa8, 0x6a, 0x62, 0x49, 0x82, 0xbe, 0x78, 0xe2, 0x83, 0x06, 0xb8, 0xef, 0x8b, 0xcf, 0xc2
	.byte 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000000000
	/* C1 */
	.octa 0x4000000040040ffe0000000000002020
	/* C2 */
	.octa 0x1
	/* C7 */
	.octa 0x2040
	/* C10 */
	.octa 0x8001e0030000000000000000
	/* C15 */
	.octa 0x100010000000000000000
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x90000000000700040000000000001c20
	/* C20 */
	.octa 0xc0000000000600050000000000001000
	/* C29 */
	.octa 0xb000
	/* C30 */
	.octa 0x4f8
final_cap_values:
	/* C0 */
	.octa 0x8000000000000000
	/* C1 */
	.octa 0x4000000040040ffe0000000000001f7c
	/* C2 */
	.octa 0x1
	/* C4 */
	.octa 0x1
	/* C7 */
	.octa 0x2040
	/* C8 */
	.octa 0x8001e003fffffffffffff6e9
	/* C9 */
	.octa 0xb000
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x200080080000000000001300
	/* C18 */
	.octa 0x1000
	/* C19 */
	.octa 0x90000000000700040000000000001c20
	/* C20 */
	.octa 0xc0000000000600050000000000001000
	/* C21 */
	.octa 0x3008
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xb000
	/* C30 */
	.octa 0x20008000408200000000000000400019
initial_SP_EL3_value:
	.octa 0x200080080000000000001300
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408200000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000080140050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001a70
	.dword initial_cap_values + 16
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 240
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78fd6295 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:21 Rn:20 00:00 opc:110 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x02a45d48 // SUB-C.CIS-C Cd:8 Cn:10 imm12:100100010111 sh:0 A:1 00000010:00000010
	.inst 0x6abf3044 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:4 Rn:2 imm6:001100 Rm:31 N:1 shift:10 01010:01010 opc:11 sf:0
	.inst 0xb6f8eac0 // tbz:aarch64/instrs/branch/conditional/test Rt:0 imm14:00011101010110 b40:11111 op:0 011011:011011 b5:1
	.inst 0x7815cc3e // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:1 11:11 imm9:101011100 0:0 opc:00 111000:111000 size:01
	.inst 0xc2dcb261 // BLR-CI-C 1:1 0000:0000 Cn:19 100:100 imm7:1100101 110000101101:110000101101
	.zero 104168
	.inst 0x626aa8fb // LDNP-C.RIB-C Ct:27 Rn:7 Ct2:01010 imm7:1010101 L:1 011000100:011000100
	.inst 0x78be8249 // swph:aarch64/instrs/memory/atomicops/swp Rt:9 Rn:18 100000:100000 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xb80683e2 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:31 00:00 imm9:001101000 0:0 opc:00 111000:111000 size:10
	.inst 0xc2cf8bef // CHKSSU-C.CC-C Cd:15 Cn:31 0010:0010 opc:10 Cm:15 11000010110:11000010110
	.inst 0xc2c211a0
	.zero 944364
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e27 // ldr c7, [x17, #3]
	.inst 0xc240122a // ldr c10, [x17, #4]
	.inst 0xc240162f // ldr c15, [x17, #5]
	.inst 0xc2401a32 // ldr c18, [x17, #6]
	.inst 0xc2401e33 // ldr c19, [x17, #7]
	.inst 0xc2402234 // ldr c20, [x17, #8]
	.inst 0xc240263d // ldr c29, [x17, #9]
	.inst 0xc2402a3e // ldr c30, [x17, #10]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x3085103d
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b1 // ldr c17, [c13, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826011b1 // ldr c17, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x13, #0xf
	and x17, x17, x13
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc240022d // ldr c13, [x17, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240062d // ldr c13, [x17, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a2d // ldr c13, [x17, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400e2d // ldr c13, [x17, #3]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc240122d // ldr c13, [x17, #4]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240162d // ldr c13, [x17, #5]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc2401a2d // ldr c13, [x17, #6]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc2401e2d // ldr c13, [x17, #7]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240222d // ldr c13, [x17, #8]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc240262d // ldr c13, [x17, #9]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc2402a2d // ldr c13, [x17, #10]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2402e2d // ldr c13, [x17, #11]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240322d // ldr c13, [x17, #12]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc240362d // ldr c13, [x17, #13]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc2403a2d // ldr c13, [x17, #14]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2403e2d // ldr c13, [x17, #15]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001368
	ldr x1, =check_data1
	ldr x2, =0x0000136c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a70
	ldr x1, =check_data2
	ldr x2, =0x00001a80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d90
	ldr x1, =check_data3
	ldr x2, =0x00001db0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f7c
	ldr x1, =check_data4
	ldr x2, =0x00001f7e
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00419700
	ldr x1, =check_data6
	ldr x2, =0x00419714
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
