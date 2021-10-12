.section data0, #alloc, #write
	.byte 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc2
.data
check_data1:
	.byte 0x84, 0x83, 0x42, 0xa2, 0x4e, 0xf8, 0xd4, 0xc2, 0xe3, 0xdf, 0x9c, 0xb8, 0x00, 0x5d, 0x3a, 0x52
	.byte 0x35, 0x90, 0x80, 0x5a, 0x21, 0x10, 0xc7, 0xc2, 0x2a, 0xe8, 0x4d, 0x3a, 0xc1, 0xe7, 0x7d, 0x82
	.byte 0xe0, 0xab, 0x96, 0x38, 0x23, 0x50, 0x75, 0x51, 0x80, 0x12, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xc00000000000000000000000
	/* C28 */
	.octa 0x3fffe8
	/* C30 */
	.octa 0x800000007ffd10000000000000000e24
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffc2
	/* C1 */
	.octa 0xc2
	/* C2 */
	.octa 0xc00000000000000000000000
	/* C3 */
	.octa 0xff2ac0c2
	/* C4 */
	.octa 0x827de7c13a4de82ac2c710215a809035
	/* C14 */
	.octa 0xc29000000000000000000000
	/* C28 */
	.octa 0x3fffe8
	/* C30 */
	.octa 0x800000007ffd10000000000000000e24
initial_SP_EL3_value:
	.octa 0x4f0103
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000001f064007000000000080c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2428384 // LDUR-C.RI-C Ct:4 Rn:28 00:00 imm9:000101000 0:0 opc:01 10100010:10100010
	.inst 0xc2d4f84e // SCBNDS-C.CI-S Cd:14 Cn:2 1110:1110 S:1 imm6:101001 11000010110:11000010110
	.inst 0xb89cdfe3 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:3 Rn:31 11:11 imm9:111001101 0:0 opc:10 111000:111000 size:10
	.inst 0x523a5d00 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:8 imms:010111 immr:111010 N:0 100100:100100 opc:10 sf:0
	.inst 0x5a809035 // csinv:aarch64/instrs/integer/conditional/select Rd:21 Rn:1 o2:0 0:0 cond:1001 Rm:0 011010100:011010100 op:1 sf:0
	.inst 0xc2c71021 // RRLEN-R.R-C Rd:1 Rn:1 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3a4de82a // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:1010 0:0 Rn:1 10:10 cond:1110 imm5:01101 111010010:111010010 op:0 sf:0
	.inst 0x827de7c1 // ALDRB-R.RI-B Rt:1 Rn:30 op:01 imm9:111011110 L:1 1000001001:1000001001
	.inst 0x3896abe0 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:31 10:10 imm9:101101010 0:0 opc:10 111000:111000 size:00
	.inst 0x51755023 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:3 Rn:1 imm12:110101010100 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2c21280
	.zero 983052
	.inst 0x00c20000
	.zero 148
	.inst 0xc2c2c2c2
	.zero 65324
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008fc // ldr c28, [x7, #2]
	.inst 0xc2400cfe // ldr c30, [x7, #3]
	/* Set up flags and system registers */
	mov x7, #0x20000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	ldr x7, =0x0
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603287 // ldr c7, [c20, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601287 // ldr c7, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x20, #0xf
	and x7, x7, x20
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f4 // ldr c20, [x7, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004f4 // ldr c20, [x7, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008f4 // ldr c20, [x7, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400cf4 // ldr c20, [x7, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24014f4 // ldr c20, [x7, #5]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc24018f4 // ldr c20, [x7, #6]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2401cf4 // ldr c20, [x7, #7]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004f003a
	ldr x1, =check_data2
	ldr x2, =0x004f003b
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004f00d0
	ldr x1, =check_data3
	ldr x2, =0x004f00d4
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
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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
