.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0xa0, 0x00, 0x00, 0x02, 0x80, 0x00, 0xa0, 0xc2, 0x00, 0x53, 0x00, 0xe2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x56, 0x30, 0xbf, 0xb9, 0xe2, 0x9e, 0xd8, 0x68, 0x91, 0x51, 0x87, 0xb8, 0x20, 0xd8, 0x61, 0xa2
	.byte 0xc6, 0x43, 0x3f, 0xab, 0x40, 0x3d, 0x2c, 0x79, 0x09, 0x69, 0xc2, 0xc2, 0xff, 0xd2, 0xc0, 0xc2
	.byte 0x6d, 0x5e, 0x8c, 0xe2, 0x1e, 0xb8, 0xdf, 0xc2, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000200140050000000000000100
	/* C2 */
	.octa 0x800000004004000a000000000041e0e0
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x400000005004120a00000000000000e4
	/* C12 */
	.octa 0x800000000007000700000000003fff8b
	/* C13 */
	.octa 0xe2005300c2a00080020000a000000000
	/* C19 */
	.octa 0x100b
	/* C23 */
	.octa 0x80000000000100070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x200010000000000000000
	/* C1 */
	.octa 0x80000000200140050000000000000100
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x3fff800000000000000000000000
	/* C10 */
	.octa 0x400000005004120a00000000000000e4
	/* C12 */
	.octa 0x800000000007000700000000003fff8b
	/* C13 */
	.octa 0xe2005300c2a00080020000a000000000
	/* C17 */
	.octa 0xffffffffb9bf3056
	/* C19 */
	.octa 0x100b
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x800000000001000700000000000010c4
	/* C30 */
	.octa 0x403f00000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000003000700ffeeb804000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb9bf3056 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:2 imm12:111111001100 opc:10 111001:111001 size:10
	.inst 0x68d89ee2 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:23 Rt2:00111 imm7:0110001 L:1 1010001:1010001 opc:01
	.inst 0xb8875191 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:17 Rn:12 00:00 imm9:001110101 0:0 opc:10 111000:111000 size:10
	.inst 0xa261d820 // LDR-C.RRB-C Ct:0 Rn:1 10:10 S:1 option:110 Rm:1 1:1 opc:01 10100010:10100010
	.inst 0xab3f43c6 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:6 Rn:30 imm3:000 option:010 Rm:31 01011001:01011001 S:1 op:0 sf:1
	.inst 0x792c3d40 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:10 imm12:101100001111 opc:00 111001:111001 size:01
	.inst 0xc2c26909 // ORRFLGS-C.CR-C Cd:9 Cn:8 1010:1010 opc:01 Rm:2 11000010110:11000010110
	.inst 0xc2c0d2ff // GCPERM-R.C-C Rd:31 Cn:23 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xe28c5e6d // ASTUR-C.RI-C Ct:13 Rn:19 op2:11 imm9:011000101 V:0 op1:10 11100010:11100010
	.inst 0xc2dfb81e // SCBNDS-C.CI-C Cd:30 Cn:0 1110:1110 S:0 imm6:111111 11000010110:11000010110
	.inst 0xc2c213a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400602 // ldr c2, [x16, #1]
	.inst 0xc2400a08 // ldr c8, [x16, #2]
	.inst 0xc2400e0a // ldr c10, [x16, #3]
	.inst 0xc240120c // ldr c12, [x16, #4]
	.inst 0xc240160d // ldr c13, [x16, #5]
	.inst 0xc2401a13 // ldr c19, [x16, #6]
	.inst 0xc2401e17 // ldr c23, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b0 // ldr c16, [c29, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826013b0 // ldr c16, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x29, #0x3
	and x16, x16, x29
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021d // ldr c29, [x16, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240061d // ldr c29, [x16, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400a1d // ldr c29, [x16, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400e1d // ldr c29, [x16, #3]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc240121d // ldr c29, [x16, #4]
	.inst 0xc2dda501 // chkeq c8, c29
	b.ne comparison_fail
	.inst 0xc240161d // ldr c29, [x16, #5]
	.inst 0xc2dda521 // chkeq c9, c29
	b.ne comparison_fail
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc2401e1d // ldr c29, [x16, #7]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc240221d // ldr c29, [x16, #8]
	.inst 0xc2dda5a1 // chkeq c13, c29
	b.ne comparison_fail
	.inst 0xc240261d // ldr c29, [x16, #9]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc2402a1d // ldr c29, [x16, #10]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc2402e1d // ldr c29, [x16, #11]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc240321d // ldr c29, [x16, #12]
	.inst 0xc2dda6e1 // chkeq c23, c29
	b.ne comparison_fail
	.inst 0xc240361d // ldr c29, [x16, #13]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010d0
	ldr x1, =check_data1
	ldr x2, =0x000010e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001702
	ldr x1, =check_data3
	ldr x2, =0x00001704
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
	ldr x0, =0x00422010
	ldr x1, =check_data5
	ldr x2, =0x00422014
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
