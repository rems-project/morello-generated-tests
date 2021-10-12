.section data0, #alloc, #write
	.zero 720
	.byte 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3360
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x42, 0x04, 0x00, 0x00, 0x06, 0x00, 0xc2, 0x9d, 0x9d, 0x00, 0x00, 0x06
.data
check_data2:
	.byte 0x82
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x00, 0x09
.data
check_data7:
	.byte 0x9e, 0x0c, 0xdb, 0x69, 0x3e, 0x7c, 0xdf, 0x08, 0x2d, 0x02, 0xc0, 0x5a, 0x42, 0xfc, 0x82, 0x82
	.byte 0x2d, 0x7f, 0x4f, 0x82, 0xc8, 0x3b, 0x0b, 0xa9, 0x1b, 0x43, 0x98, 0x3d, 0x9d, 0x3b, 0xdd, 0xc2
	.byte 0x06, 0x88, 0x1e, 0x9b, 0x80, 0xec, 0x1a, 0x78, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x402
	/* C2 */
	.octa 0x40000000000700070000000000000900
	/* C4 */
	.octa 0x40a
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x3f000000000000
	/* C17 */
	.octa 0x0
	/* C24 */
	.octa 0xffffffffffffa292
	/* C25 */
	.octa 0x40000000000300060000000000001288
	/* C28 */
	.octa 0x300070000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x402
	/* C2 */
	.octa 0x40000000000700070000000000000900
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x490
	/* C6 */
	.octa 0x900
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x3f000000000000
	/* C17 */
	.octa 0x0
	/* C24 */
	.octa 0xffffffffffffa292
	/* C25 */
	.octa 0x40000000000300060000000000001288
	/* C28 */
	.octa 0x300070000000000000000
	/* C29 */
	.octa 0x403a00000000000000000000
	/* C30 */
	.octa 0x82
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004400c4040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000054140ece00ffffffffffff77
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 128
	.dword final_cap_values + 32
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x69db0c9e // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:30 Rn:4 Rt2:00011 imm7:0110110 L:1 1010011:1010011 opc:01
	.inst 0x08df7c3e // ldlarb:aarch64/instrs/memory/ordered Rt:30 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x5ac0022d // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:13 Rn:17 101101011000000000000:101101011000000000000 sf:0
	.inst 0x8282fc42 // ASTRH-R.RRB-32 Rt:2 Rn:2 opc:11 S:1 option:111 Rm:2 0:0 L:0 100000101:100000101
	.inst 0x824f7f2d // ASTR-R.RI-64 Rt:13 Rn:25 op:11 imm9:011110111 L:0 1000001001:1000001001
	.inst 0xa90b3bc8 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:8 Rn:30 Rt2:01110 imm7:0010110 L:0 1010010:1010010 opc:10
	.inst 0x3d98431b // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:27 Rn:24 imm12:011000010000 opc:10 111101:111101 size:00
	.inst 0xc2dd3b9d // SCBNDS-C.CI-C Cd:29 Cn:28 1110:1110 S:0 imm6:111010 11000010110:11000010110
	.inst 0x9b1e8806 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:6 Rn:0 Ra:2 o0:1 Rm:30 0011011000:0011011000 sf:1
	.inst 0x781aec80 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:4 11:11 imm9:110101110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21160
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x18, cptr_el3
	orr x18, x18, #0x200
	msr cptr_el3, x18
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e44 // ldr c4, [x18, #3]
	.inst 0xc2401248 // ldr c8, [x18, #4]
	.inst 0xc240164e // ldr c14, [x18, #5]
	.inst 0xc2401a51 // ldr c17, [x18, #6]
	.inst 0xc2401e58 // ldr c24, [x18, #7]
	.inst 0xc2402259 // ldr c25, [x18, #8]
	.inst 0xc240265c // ldr c28, [x18, #9]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q27, =0x600009d9dc200060000044200000000
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30850032
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603172 // ldr c18, [c11, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601172 // ldr c18, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024b // ldr c11, [x18, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240064b // ldr c11, [x18, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a4b // ldr c11, [x18, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc240124b // ldr c11, [x18, #4]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc240164b // ldr c11, [x18, #5]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc2401a4b // ldr c11, [x18, #6]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc2401e4b // ldr c11, [x18, #7]
	.inst 0xc2cba5a1 // chkeq c13, c11
	b.ne comparison_fail
	.inst 0xc240224b // ldr c11, [x18, #8]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc240264b // ldr c11, [x18, #9]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc2402a4b // ldr c11, [x18, #10]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc2402e4b // ldr c11, [x18, #11]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc240324b // ldr c11, [x18, #12]
	.inst 0xc2cba781 // chkeq c28, c11
	b.ne comparison_fail
	.inst 0xc240364b // ldr c11, [x18, #13]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2403a4b // ldr c11, [x18, #14]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x44200000000
	mov x11, v27.d[0]
	cmp x18, x11
	b.ne comparison_fail
	ldr x18, =0x600009d9dc20006
	mov x11, v27.d[1]
	cmp x18, x11
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
	ldr x0, =0x00001260
	ldr x1, =check_data1
	ldr x2, =0x00001270
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012d0
	ldr x1, =check_data2
	ldr x2, =0x000012d1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000135e
	ldr x1, =check_data3
	ldr x2, =0x00001360
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000013b0
	ldr x1, =check_data4
	ldr x2, =0x000013b8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001a40
	ldr x1, =check_data5
	ldr x2, =0x00001a48
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001b00
	ldr x1, =check_data6
	ldr x2, =0x00001b02
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
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
