.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x9e
.data
check_data3:
	.byte 0x21, 0x04, 0x46, 0x82, 0xcf, 0x24, 0xde, 0x38, 0xff, 0xc3, 0x70, 0x62, 0x52, 0x1c, 0x15, 0x38
	.byte 0xeb, 0x2f, 0xcf, 0x9a, 0x5e, 0x7c, 0xdf, 0xc8, 0x2f, 0x24, 0xde, 0x9a, 0x20, 0x24, 0xc2, 0x9a
	.byte 0xff, 0x0f, 0xdc, 0x1a, 0x2a, 0x10, 0x1b, 0x91, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x01
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1e9e
	/* C2 */
	.octa 0xc00000000007007f0000000000001107
	/* C6 */
	.octa 0x800000000001000600000000004fdffe
	/* C18 */
	.octa 0x0
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1e9e
	/* C2 */
	.octa 0xc00000000007007f0000000000001058
	/* C6 */
	.octa 0x800000000001000600000000004fdfe0
	/* C10 */
	.octa 0x2562
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x1e9e
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x900000004000000100000000000011f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000006000000fffffff0000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82460421 // ASTRB-R.RI-B Rt:1 Rn:1 op:01 imm9:001100000 L:0 1000001001:1000001001
	.inst 0x38de24cf // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:15 Rn:6 01:01 imm9:111100010 0:0 opc:11 111000:111000 size:00
	.inst 0x6270c3ff // LDNP-C.RIB-C Ct:31 Rn:31 Ct2:10000 imm7:1100001 L:1 011000100:011000100
	.inst 0x38151c52 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:2 11:11 imm9:101010001 0:0 opc:00 111000:111000 size:00
	.inst 0x9acf2feb // rorv:aarch64/instrs/integer/shift/variable Rd:11 Rn:31 op2:11 0010:0010 Rm:15 0011010110:0011010110 sf:1
	.inst 0xc8df7c5e // ldlar:aarch64/instrs/memory/ordered Rt:30 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x9ade242f // lsrv:aarch64/instrs/integer/shift/variable Rd:15 Rn:1 op2:01 0010:0010 Rm:30 0011010110:0011010110 sf:1
	.inst 0x9ac22420 // lsrv:aarch64/instrs/integer/shift/variable Rd:0 Rn:1 op2:01 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0x1adc0fff // sdiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:31 o1:1 00001:00001 Rm:28 0011010110:0011010110 sf:0
	.inst 0x911b102a // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:10 Rn:1 imm12:011011000100 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xc2c212a0
	.zero 1040336
	.inst 0x00010000
	.zero 8192
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2400f12 // ldr c18, [x24, #3]
	.inst 0xc240131c // ldr c28, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850032
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b8 // ldr c24, [c21, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826012b8 // ldr c24, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400315 // ldr c21, [x24, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400715 // ldr c21, [x24, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400b15 // ldr c21, [x24, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400f15 // ldr c21, [x24, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2401315 // ldr c21, [x24, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401715 // ldr c21, [x24, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401b15 // ldr c21, [x24, #6]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401f15 // ldr c21, [x24, #7]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402315 // ldr c21, [x24, #8]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc2402715 // ldr c21, [x24, #9]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc2402b15 // ldr c21, [x24, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001058
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001efe
	ldr x1, =check_data2
	ldr x2, =0x00001eff
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
	ldr x0, =0x004fdffe
	ldr x1, =check_data4
	ldr x2, =0x004fdfff
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
