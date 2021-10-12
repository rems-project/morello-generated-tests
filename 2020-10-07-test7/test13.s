.section data0, #alloc, #write
	.zero 3232
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00
	.zero 848
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xc1, 0xf7, 0x2c, 0xb9, 0x54, 0x8f, 0x7f, 0x6c, 0x59, 0xd1, 0xc0, 0xc2, 0xe0, 0x73, 0xc2, 0xc2
	.byte 0x02, 0xe8, 0xe5, 0xc2, 0x0f, 0x12, 0x85, 0xab, 0x5e, 0x30, 0xc3, 0xc2, 0x71, 0x7d, 0x9f, 0x48
	.byte 0xee, 0xa2, 0x7c, 0x82, 0xce, 0x13, 0xc0, 0xda, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C11 */
	.octa 0x40000000600100440000000000001000
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0xffffffffffffff7f
	/* C26 */
	.octa 0x103f
	/* C30 */
	.octa 0xfffffffffffff173
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x3fff800000002f00000000000000
	/* C11 */
	.octa 0x40000000600100440000000000001000
	/* C14 */
	.octa 0x2
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0xffffffffffffff7f
	/* C26 */
	.octa 0x103f
	/* C30 */
	.octa 0x800000002f00000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000400200810000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ca0
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb92cf7c1 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:101100111101 opc:00 111001:111001 size:10
	.inst 0x6c7f8f54 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:20 Rn:26 Rt2:00011 imm7:1111111 L:1 1011000:1011000 opc:01
	.inst 0xc2c0d159 // GCPERM-R.C-C Rd:25 Cn:10 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2e5e802 // ORRFLGS-C.CI-C Cd:2 Cn:0 0:0 01:01 imm8:00101111 11000010111:11000010111
	.inst 0xab85120f // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:15 Rn:16 imm6:000100 Rm:5 0:0 shift:10 01011:01011 S:1 op:0 sf:1
	.inst 0xc2c3305e // SEAL-C.CI-C Cd:30 Cn:2 100:100 form:01 11000010110000110:11000010110000110
	.inst 0x489f7d71 // stllrh:aarch64/instrs/memory/ordered Rt:17 Rn:11 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x827ca2ee // ALDR-C.RI-C Ct:14 Rn:23 op:00 imm9:111001010 L:1 1000001001:1000001001
	.inst 0xdac013ce // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:14 Rn:30 op:0 10110101100000000010:10110101100000000010 sf:1
	.inst 0xc2c21180
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a1 // ldr c1, [x21, #1]
	.inst 0xc2400aab // ldr c11, [x21, #2]
	.inst 0xc2400eb1 // ldr c17, [x21, #3]
	.inst 0xc24012b7 // ldr c23, [x21, #4]
	.inst 0xc24016ba // ldr c26, [x21, #5]
	.inst 0xc2401abe // ldr c30, [x21, #6]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603195 // ldr c21, [c12, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601195 // ldr c21, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002ac // ldr c12, [x21, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24006ac // ldr c12, [x21, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400aac // ldr c12, [x21, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400eac // ldr c12, [x21, #3]
	.inst 0xc2cca561 // chkeq c11, c12
	b.ne comparison_fail
	.inst 0xc24012ac // ldr c12, [x21, #4]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc24016ac // ldr c12, [x21, #5]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc2401aac // ldr c12, [x21, #6]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc2401eac // ldr c12, [x21, #7]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc24022ac // ldr c12, [x21, #8]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x12, v3.d[0]
	cmp x21, x12
	b.ne comparison_fail
	ldr x21, =0x0
	mov x12, v3.d[1]
	cmp x21, x12
	b.ne comparison_fail
	ldr x21, =0x0
	mov x12, v20.d[0]
	cmp x21, x12
	b.ne comparison_fail
	ldr x21, =0x0
	mov x12, v20.d[1]
	cmp x21, x12
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
	ldr x0, =0x000010b8
	ldr x1, =check_data1
	ldr x2, =0x000010c8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ca0
	ldr x1, =check_data2
	ldr x2, =0x00001cb0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ee8
	ldr x1, =check_data3
	ldr x2, =0x00001eec
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
