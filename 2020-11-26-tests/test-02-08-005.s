.section data0, #alloc, #write
	.zero 176
	.byte 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3904
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
	.byte 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x7d, 0xa1, 0xc4, 0x38, 0x4c, 0x7f, 0x5f, 0x42, 0xe2, 0x27, 0xc5, 0x42, 0x00, 0x32, 0xc1, 0xc2
	.byte 0x3d, 0xd0, 0x73, 0x51, 0x3f, 0xf4, 0xc9, 0xca, 0xde, 0xd3, 0xf0, 0x39, 0x3e, 0x7d, 0xf0, 0xa2
	.byte 0x67, 0x7c, 0x1f, 0xc8, 0xff, 0x23, 0x3f, 0x78, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x4ffff0
	/* C11 */
	.octa 0x1fb4
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0x90100000400100080000000000001000
	/* C30 */
	.octa 0x4033ca
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x4ffff0
	/* C9 */
	.octa 0x1020
	/* C11 */
	.octa 0x1fb4
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C26 */
	.octa 0x90100000400100080000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38c4a17d // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:11 00:00 imm9:001001010 0:0 opc:11 111000:111000 size:00
	.inst 0x425f7f4c // ALDAR-C.R-C Ct:12 Rn:26 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x42c527e2 // LDP-C.RIB-C Ct:2 Rn:31 Ct2:01001 imm7:0001010 L:1 010000101:010000101
	.inst 0xc2c13200 // GCFLGS-R.C-C Rd:0 Cn:16 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x5173d03d // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:29 Rn:1 imm12:110011110100 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xcac9f43f // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:1 imm6:111101 Rm:9 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0x39f0d3de // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:30 imm12:110000110100 opc:11 111001:111001 size:00
	.inst 0xa2f07d3e // CASA-C.R-C Ct:30 Rn:9 11111:11111 R:0 Cs:16 1:1 L:1 1:1 10100010:10100010
	.inst 0xc81f7c67 // stxr:aarch64/instrs/memory/exclusive/single Rt:7 Rn:3 Rt2:11111 o0:0 Rs:31 0:0 L:0 0010000:0010000 size:11
	.inst 0x783f23ff // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c211e0
	.zero 1048532
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
	ldr x19, =initial_cap_values
	.inst 0xc2400263 // ldr c3, [x19, #0]
	.inst 0xc240066b // ldr c11, [x19, #1]
	.inst 0xc2400a70 // ldr c16, [x19, #2]
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc240127e // ldr c30, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f3 // ldr c19, [c15, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826011f3 // ldr c19, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240026f // ldr c15, [x19, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240066f // ldr c15, [x19, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400a6f // ldr c15, [x19, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400e6f // ldr c15, [x19, #3]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240126f // ldr c15, [x19, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc2401a6f // ldr c15, [x19, #6]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc2401e6f // ldr c15, [x19, #7]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc240226f // ldr c15, [x19, #8]
	.inst 0xc2cfa7c1 // chkeq c30, c15
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010c0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x00403ffe
	ldr x1, =check_data5
	ldr x2, =0x00403fff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff0
	ldr x1, =check_data6
	ldr x2, =0x004ffff8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
