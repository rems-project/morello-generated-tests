.section data0, #alloc, #write
	.zero 4032
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x22, 0x23, 0x11, 0x82, 0xb2, 0x32, 0xd1, 0xb5, 0xbf, 0x50, 0xfc, 0xc2, 0x5f, 0x91, 0x5b, 0xa2
	.byte 0x90, 0x96, 0xcc, 0x2d, 0x2c, 0x44, 0xcf, 0xc2, 0xc1, 0x8f, 0x21, 0x6b, 0xe0, 0x23, 0xd8, 0xc2
	.byte 0x3e, 0x08, 0xf8, 0x6a, 0xf1, 0x0b, 0xd2, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0xc00000000000000000000000
	/* C10 */
	.octa 0x2007
	/* C15 */
	.octa 0x800000000000000000000000
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x1f90
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000e200000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C5 */
	.octa 0xc00000000000000000000000
	/* C10 */
	.octa 0x2007
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x1ff4
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fc0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82112322 // LDR-C.I-C Ct:2 imm17:01000100100011001 1000001000:1000001000
	.inst 0xb5d132b2 // cbnz:aarch64/instrs/branch/conditional/compare Rt:18 imm19:1101000100110010101 op:1 011010:011010 sf:1
	.inst 0xc2fc50bf // EORFLGS-C.CI-C Cd:31 Cn:5 0:0 10:10 imm8:11100010 11000010111:11000010111
	.inst 0xa25b915f // LDUR-C.RI-C Ct:31 Rn:10 00:00 imm9:110111001 0:0 opc:01 10100010:10100010
	.inst 0x2dcc9690 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:16 Rn:20 Rt2:00101 imm7:0011001 L:1 1011011:1011011 opc:00
	.inst 0xc2cf442c // CSEAL-C.C-C Cd:12 Cn:1 001:001 opc:10 0:0 Cm:15 11000010110:11000010110
	.inst 0x6b218fc1 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:30 imm3:011 option:100 Rm:1 01011001:01011001 S:1 op:1 sf:0
	.inst 0xc2d823e0 // SCBNDSE-C.CR-C Cd:0 Cn:31 000:000 opc:01 0:0 Rm:24 11000010110:11000010110
	.inst 0x6af8083e // bics:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:1 imm6:000010 Rm:24 N:1 shift:11 01010:01010 opc:11 sf:0
	.inst 0xc2d20bf1 // SEAL-C.CC-C Cd:17 Cn:31 0010:0010 opc:00 Cm:18 11000010110:11000010110
	.inst 0xc2c21360
	.zero 561508
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 487008
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a1 // ldr c1, [x29, #0]
	.inst 0xc24007a5 // ldr c5, [x29, #1]
	.inst 0xc2400baa // ldr c10, [x29, #2]
	.inst 0xc2400faf // ldr c15, [x29, #3]
	.inst 0xc24013b2 // ldr c18, [x29, #4]
	.inst 0xc24017b4 // ldr c20, [x29, #5]
	.inst 0xc2401bb8 // ldr c24, [x29, #6]
	.inst 0xc2401fbe // ldr c30, [x29, #7]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850032
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337d // ldr c29, [c27, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260137d // ldr c29, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x27, #0xf
	and x29, x29, x27
	cmp x29, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003bb // ldr c27, [x29, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc24007bb // ldr c27, [x29, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400bbb // ldr c27, [x29, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400fbb // ldr c27, [x29, #3]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24013bb // ldr c27, [x29, #4]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc24017bb // ldr c27, [x29, #5]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc2401bbb // ldr c27, [x29, #6]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401fbb // ldr c27, [x29, #7]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc24023bb // ldr c27, [x29, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc24027bb // ldr c27, [x29, #9]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc2402bbb // ldr c27, [x29, #10]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc2402fbb // ldr c27, [x29, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0xc2c2c2c2
	mov x27, v5.d[0]
	cmp x29, x27
	b.ne comparison_fail
	ldr x29, =0x0
	mov x27, v5.d[1]
	cmp x29, x27
	b.ne comparison_fail
	ldr x29, =0xc2c2c2c2
	mov x27, v16.d[0]
	cmp x29, x27
	b.ne comparison_fail
	ldr x29, =0x0
	mov x27, v16.d[1]
	cmp x29, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fc0
	ldr x1, =check_data0
	ldr x2, =0x00001fd0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff4
	ldr x1, =check_data1
	ldr x2, =0x00001ffc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00489190
	ldr x1, =check_data3
	ldr x2, =0x004891a0
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
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
