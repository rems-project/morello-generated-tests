.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xfa, 0xd3, 0x58, 0xe2, 0x01, 0x64, 0xcd, 0x78, 0xe7, 0x09, 0xc0, 0xda, 0xc0, 0xfc, 0x5f, 0x42
	.byte 0x5e, 0xfc, 0xb6, 0xa2, 0x3f, 0x10, 0x3c, 0xe2, 0xbf, 0x69, 0xe2, 0x29, 0x9e, 0xc1, 0x1d, 0x38
	.byte 0x7e, 0x81, 0xd1, 0xc2, 0x42, 0x30, 0xc5, 0xc2, 0x80, 0x13, 0xc2, 0xc2
.data
check_data7:
	.byte 0xb4, 0x1f
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000005000f0000000000420002
	/* C2 */
	.octa 0xdc000000400102610000000000001440
	/* C6 */
	.octa 0x90100000548108000000000000001460
	/* C12 */
	.octa 0x400000005fe40be20000000000001040
	/* C13 */
	.octa 0x80000000110000000000000000002010
	/* C17 */
	.octa 0x1
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1fb4
	/* C2 */
	.octa 0x1440
	/* C6 */
	.octa 0x90100000548108000000000000001460
	/* C12 */
	.octa 0x400000005fe40be20000000000001040
	/* C13 */
	.octa 0x80000000110000000000000000001f20
	/* C17 */
	.octa 0x1
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x208080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004002005900ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001440
	.dword 0x0000000000001460
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe258d3fa // ASTURH-R.RI-32 Rt:26 Rn:31 op2:00 imm9:110001101 V:0 op1:01 11100010:11100010
	.inst 0x78cd6401 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:0 01:01 imm9:011010110 0:0 opc:11 111000:111000 size:01
	.inst 0xdac009e7 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:7 Rn:15 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x425ffcc0 // LDAR-C.R-C Ct:0 Rn:6 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xa2b6fc5e // CASL-C.R-C Ct:30 Rn:2 11111:11111 R:1 Cs:22 1:1 L:0 1:1 10100010:10100010
	.inst 0xe23c103f // ASTUR-V.RI-B Rt:31 Rn:1 op2:00 imm9:111000001 V:1 op1:00 11100010:11100010
	.inst 0x29e269bf // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:13 Rt2:11010 imm7:1000100 L:1 1010011:1010011 opc:00
	.inst 0x381dc19e // sturb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:12 00:00 imm9:111011100 0:0 opc:00 111000:111000 size:00
	.inst 0xc2d1817e // SCTAG-C.CR-C Cd:30 Cn:11 000:000 0:0 10:10 Rm:17 11000010110:11000010110
	.inst 0xc2c53042 // CVTP-R.C-C Rd:2 Cn:2 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xc2c21380
	.zero 131028
	.inst 0x1fb40000
	.zero 917500
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
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2400e6c // ldr c12, [x19, #3]
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc2401671 // ldr c17, [x19, #5]
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2401e7a // ldr c26, [x19, #7]
	.inst 0xc240227e // ldr c30, [x19, #8]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x3085103f
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x82603393 // ldr c19, [c28, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601393 // ldr c19, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x28, #0xf
	and x19, x19, x28
	cmp x19, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027c // ldr c28, [x19, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240067c // ldr c28, [x19, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400a7c // ldr c28, [x19, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400e7c // ldr c28, [x19, #3]
	.inst 0xc2dca4c1 // chkeq c6, c28
	b.ne comparison_fail
	.inst 0xc240127c // ldr c28, [x19, #4]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc240167c // ldr c28, [x19, #5]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc2401a7c // ldr c28, [x19, #6]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401e7c // ldr c28, [x19, #7]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc240227c // ldr c28, [x19, #8]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x28, v31.d[0]
	cmp x19, x28
	b.ne comparison_fail
	ldr x19, =0x0
	mov x28, v31.d[1]
	cmp x19, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001006
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101c
	ldr x1, =check_data1
	ldr x2, =0x0000101d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001440
	ldr x1, =check_data2
	ldr x2, =0x00001450
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001460
	ldr x1, =check_data3
	ldr x2, =0x00001470
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f20
	ldr x1, =check_data4
	ldr x2, =0x00001f28
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fce
	ldr x1, =check_data5
	ldr x2, =0x00001fcf
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00420002
	ldr x1, =check_data7
	ldr x2, =0x00420004
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
