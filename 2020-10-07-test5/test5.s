.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x02, 0x65, 0xf4, 0x6a, 0x5e, 0x48, 0x4d, 0x69, 0x7e, 0xde, 0x52, 0xa2, 0x7e, 0x9a, 0xe7, 0xc2
	.byte 0x94, 0x41, 0x4a, 0x6c, 0xe0, 0x63, 0xfa, 0xc2, 0x3f, 0x0c, 0xc0, 0x9a, 0xaa, 0x5c, 0x31, 0xea
	.byte 0xe1, 0x64, 0x80, 0x1a, 0xe0, 0xf3, 0xc0, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x40000c0
	/* C12 */
	.octa 0x9b80
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x10000
	/* C20 */
	.octa 0x80080001
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x40000c0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x9b80
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0xffffffffc2c2c2c2
	/* C19 */
	.octa 0xf2d0
	/* C20 */
	.octa 0x80080001
	/* C30 */
	.octa 0xf2d0
initial_SP_EL3_value:
	.octa 0x800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000040e040300fffffffe000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6af46502 // bics:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:8 imm6:011001 Rm:20 N:1 shift:11 01010:01010 opc:11 sf:0
	.inst 0x694d485e // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:30 Rn:2 Rt2:10010 imm7:0011010 L:1 1010010:1010010 opc:01
	.inst 0xa252de7e // LDR-C.RIBW-C Ct:30 Rn:19 11:11 imm9:100101101 0:0 opc:01 10100010:10100010
	.inst 0xc2e79a7e // SUBS-R.CC-C Rd:30 Cn:19 100110:100110 Cm:7 11000010111:11000010111
	.inst 0x6c4a4194 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:20 Rn:12 Rt2:10000 imm7:0010100 L:1 1011000:1011000 opc:01
	.inst 0xc2fa63e0 // BICFLGS-C.CI-C Cd:0 Cn:31 0:0 00:00 imm8:11010011 11000010111:11000010111
	.inst 0x9ac00c3f // sdiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:1 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:1
	.inst 0xea315caa // bics:aarch64/instrs/integer/logical/shiftedreg Rd:10 Rn:5 imm6:010111 Rm:17 N:1 shift:00 01010:01010 opc:11 sf:1
	.inst 0x1a8064e1 // csinc:aarch64/instrs/integer/conditional/select Rd:1 Rn:7 o2:1 0:0 cond:0110 Rm:0 011010100:011010100 op:0 sf:0
	.inst 0xc2c0f3e0 // GCTYPE-R.C-C Rd:0 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c21080
	.zero 60
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 39856
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 22176
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 986400
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
	.inst 0xc2400065 // ldr c5, [x3, #0]
	.inst 0xc2400467 // ldr c7, [x3, #1]
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2400c6c // ldr c12, [x3, #3]
	.inst 0xc2401071 // ldr c17, [x3, #4]
	.inst 0xc2401473 // ldr c19, [x3, #5]
	.inst 0xc2401874 // ldr c20, [x3, #6]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30850032
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603083 // ldr c3, [c4, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601083 // ldr c3, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
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
	mov x4, #0xf
	and x3, x3, x4
	cmp x3, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400464 // ldr c4, [x3, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400c64 // ldr c4, [x3, #3]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2401064 // ldr c4, [x3, #4]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2401464 // ldr c4, [x3, #5]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401864 // ldr c4, [x3, #6]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc2401c64 // ldr c4, [x3, #7]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2402064 // ldr c4, [x3, #8]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2402464 // ldr c4, [x3, #9]
	.inst 0xc2c4a641 // chkeq c18, c4
	b.ne comparison_fail
	.inst 0xc2402864 // ldr c4, [x3, #10]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2402c64 // ldr c4, [x3, #11]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2403064 // ldr c4, [x3, #12]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x3, =0xc2c2c2c2c2c2c2c2
	mov x4, v16.d[0]
	cmp x3, x4
	b.ne comparison_fail
	ldr x3, =0x0
	mov x4, v16.d[1]
	cmp x3, x4
	b.ne comparison_fail
	ldr x3, =0xc2c2c2c2c2c2c2c2
	mov x4, v20.d[0]
	cmp x3, x4
	b.ne comparison_fail
	ldr x3, =0x0
	mov x4, v20.d[1]
	cmp x3, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x0040002c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400068
	ldr x1, =check_data1
	ldr x2, =0x00400070
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00409c20
	ldr x1, =check_data2
	ldr x2, =0x00409c30
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040f2d0
	ldr x1, =check_data3
	ldr x2, =0x0040f2e0
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
