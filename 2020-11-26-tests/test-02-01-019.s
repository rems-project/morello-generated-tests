.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x1a, 0xc8, 0x12, 0x1b, 0xc2, 0x11, 0xc2, 0xc2, 0xdc, 0x03, 0x1e, 0xfa, 0xe0, 0xec, 0xf8, 0x02
	.byte 0xa1, 0x3b, 0xde, 0xc2, 0x08, 0xfe, 0xcb, 0x78, 0x24, 0xa8, 0xd6, 0xc2, 0xc1, 0x68, 0x75, 0xf8
	.byte 0xcc, 0x3b, 0x61, 0x82, 0xc1, 0xdb, 0xec, 0x78, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc2
.data
check_data2:
	.byte 0xfa, 0x3f, 0x00, 0x00
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x80000000000100050000000000000000
	/* C7 */
	.octa 0x800020000080000000000000
	/* C14 */
	.octa 0x20008000800100050000000000400009
	/* C16 */
	.octa 0x80000000500100020000000000480001
	/* C21 */
	.octa 0x4fffb0
	/* C29 */
	.octa 0x300070000000000000000
	/* C30 */
	.octa 0x800000000001000500000000004f8008
final_cap_values:
	/* C0 */
	.octa 0x80002000007fffffff1c5000
	/* C1 */
	.octa 0xffffc2c2
	/* C6 */
	.octa 0x80000000000100050000000000000000
	/* C7 */
	.octa 0x800020000080000000000000
	/* C8 */
	.octa 0xffffc2c2
	/* C12 */
	.octa 0x3ffa
	/* C14 */
	.octa 0x20008000800100050000000000400009
	/* C16 */
	.octa 0x800000005001000200000000004800c0
	/* C21 */
	.octa 0x4fffb0
	/* C29 */
	.octa 0x300070000000000000000
	/* C30 */
	.octa 0x800000000001000500000000004f8008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004002801a0000000000500001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1b12c81a // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:26 Rn:0 Ra:18 o0:1 Rm:18 0011011000:0011011000 sf:0
	.inst 0xc2c211c2 // BRS-C-C 00010:00010 Cn:14 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xfa1e03dc // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:28 Rn:30 000000:000000 Rm:30 11010000:11010000 S:1 op:1 sf:1
	.inst 0x02f8ece0 // SUB-C.CIS-C Cd:0 Cn:7 imm12:111000111011 sh:1 A:1 00000010:00000010
	.inst 0xc2de3ba1 // SCBNDS-C.CI-C Cd:1 Cn:29 1110:1110 S:0 imm6:111100 11000010110:11000010110
	.inst 0x78cbfe08 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:8 Rn:16 11:11 imm9:010111111 0:0 opc:11 111000:111000 size:01
	.inst 0xc2d6a824 // EORFLGS-C.CR-C Cd:4 Cn:1 1010:1010 opc:10 Rm:22 11000010110:11000010110
	.inst 0xf87568c1 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:1 Rn:6 10:10 S:0 option:011 Rm:21 1:1 opc:01 111000:111000 size:11
	.inst 0x82613bcc // ALDR-R.RI-32 Rt:12 Rn:30 op:10 imm9:000010011 L:1 1000001001:1000001001
	.inst 0x78ecdbc1 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:30 10:10 S:1 option:110 Rm:12 1:1 opc:11 111000:111000 size:01
	.inst 0xc2c210a0
	.zero 524436
	.inst 0x0000c2c2
	.zero 491408
	.inst 0x00003ffa
	.zero 32600
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 68
	.inst 0x0000c2c2
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
	ldr x20, =initial_cap_values
	.inst 0xc2400286 // ldr c6, [x20, #0]
	.inst 0xc2400687 // ldr c7, [x20, #1]
	.inst 0xc2400a8e // ldr c14, [x20, #2]
	.inst 0xc2400e90 // ldr c16, [x20, #3]
	.inst 0xc2401295 // ldr c21, [x20, #4]
	.inst 0xc240169d // ldr c29, [x20, #5]
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b4 // ldr c20, [c5, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826010b4 // ldr c20, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401685 // ldr c5, [x20, #5]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc2401a85 // ldr c5, [x20, #6]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401e85 // ldr c5, [x20, #7]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2402285 // ldr c5, [x20, #8]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402685 // ldr c5, [x20, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402a85 // ldr c5, [x20, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
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
	ldr x0, =0x004800c0
	ldr x1, =check_data1
	ldr x2, =0x004800c2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x004f8054
	ldr x1, =check_data2
	ldr x2, =0x004f8058
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fffb0
	ldr x1, =check_data3
	ldr x2, =0x004fffb8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffc
	ldr x1, =check_data4
	ldr x2, =0x004ffffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
