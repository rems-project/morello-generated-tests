.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xea, 0x8b, 0x47, 0xf8, 0x48, 0xa8, 0xf8, 0xc2, 0x20, 0x70, 0xc3, 0xc2, 0x88, 0xeb, 0xd9, 0xc2
	.byte 0xe2, 0xe7, 0xbe, 0x82, 0x9f, 0x2e, 0xdf, 0xc2, 0xdd, 0x41, 0x5d, 0x78, 0xff, 0x1f, 0x19, 0x38
	.byte 0x56, 0x44, 0xda, 0xc2, 0xc2, 0x17, 0x53, 0x2c, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000c000000000000000
	/* C14 */
	.octa 0x1f30
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0xe90
final_cap_values:
	/* C0 */
	.octa 0x1800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x80000000c000000000000000
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x1f30
	/* C22 */
	.octa 0x80000000c000000000000000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xe90
initial_csp_value:
	.octa 0x400000005f0200000000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000407003d0000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8478bea // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:10 Rn:31 10:10 imm9:001111000 0:0 opc:01 111000:111000 size:11
	.inst 0xc2f8a848 // ORRFLGS-C.CI-C Cd:8 Cn:2 0:0 01:01 imm8:11000101 11000010111:11000010111
	.inst 0xc2c37020 // SEAL-C.CI-C Cd:0 Cn:1 100:100 form:11 11000010110000110:11000010110000110
	.inst 0xc2d9eb88 // CTHI-C.CR-C Cd:8 Cn:28 1010:1010 opc:11 Rm:25 11000010110:11000010110
	.inst 0x82bee7e2 // ASTR-R.RRB-64 Rt:2 Rn:31 opc:01 S:0 option:111 Rm:30 1:1 L:0 100000101:100000101
	.inst 0xc2df2e9f // CSEL-C.CI-C Cd:31 Cn:20 11:11 cond:0010 Cm:31 11000010110:11000010110
	.inst 0x785d41dd // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:14 00:00 imm9:111010100 0:0 opc:01 111000:111000 size:01
	.inst 0x38191fff // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:31 11:11 imm9:110010001 0:0 opc:00 111000:111000 size:00
	.inst 0xc2da4456 // CSEAL-C.C-C Cd:22 Cn:2 001:001 opc:10 0:0 Cm:26 11000010110:11000010110
	.inst 0x2c5317c2 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:2 Rn:30 Rt2:00101 imm7:0100110 L:1 1011000:1011000 opc:00
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400261 // ldr c1, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a6e // ldr c14, [x19, #2]
	.inst 0xc2400e7a // ldr c26, [x19, #3]
	.inst 0xc240127e // ldr c30, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_csp_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603233 // ldr c19, [c17, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x82601233 // ldr c19, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x17, #0xf
	and x19, x19, x17
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400271 // ldr c17, [x19, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400671 // ldr c17, [x19, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400a71 // ldr c17, [x19, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc2401271 // ldr c17, [x19, #4]
	.inst 0xc2d1a5c1 // chkeq c14, c17
	b.ne comparison_fail
	.inst 0xc2401671 // ldr c17, [x19, #5]
	.inst 0xc2d1a6c1 // chkeq c22, c17
	b.ne comparison_fail
	.inst 0xc2401a71 // ldr c17, [x19, #6]
	.inst 0xc2d1a741 // chkeq c26, c17
	b.ne comparison_fail
	.inst 0xc2401e71 // ldr c17, [x19, #7]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402271 // ldr c17, [x19, #8]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x17, v2.d[0]
	cmp x19, x17
	b.ne comparison_fail
	ldr x19, =0x0
	mov x17, v2.d[1]
	cmp x19, x17
	b.ne comparison_fail
	ldr x19, =0x0
	mov x17, v5.d[0]
	cmp x19, x17
	b.ne comparison_fail
	ldr x19, =0x0
	mov x17, v5.d[1]
	cmp x19, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001071
	ldr x1, =check_data1
	ldr x2, =0x00001072
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001158
	ldr x1, =check_data2
	ldr x2, =0x00001160
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e90
	ldr x1, =check_data3
	ldr x2, =0x00001e98
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe4
	ldr x1, =check_data4
	ldr x2, =0x00001fe6
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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
