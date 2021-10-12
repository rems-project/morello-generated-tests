.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x10, 0x00, 0x00
.data
check_data0:
	.byte 0xfd, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8a, 0x00, 0x00, 0x00, 0x40, 0x00, 0x48
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x60, 0x10
.data
check_data5:
	.byte 0x23, 0x01, 0xc0, 0xda, 0x80, 0x32, 0xc2, 0xc2
.data
check_data6:
	.byte 0x7e, 0x28, 0xc0, 0x9a, 0xc1, 0x41, 0xeb, 0xc2, 0x08, 0xfc, 0xf3, 0x68, 0x60, 0xb8, 0xc0, 0xc2
	.byte 0x21, 0x3c, 0x90, 0xe2, 0x05, 0x82, 0xb7, 0xa2, 0x00, 0x7a, 0x43, 0x79, 0x11, 0xfc, 0xdf, 0x88
	.byte 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1efc
	/* C14 */
	.octa 0x4800400000008a0000000000000010fd
	/* C16 */
	.octa 0x1e40
	/* C20 */
	.octa 0x20008000800100050000000000400024
	/* C23 */
	.octa 0x4000000100000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1060
	/* C1 */
	.octa 0x4800400000008a0000000000000010fd
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x4800400000008a0000000000000010fd
	/* C16 */
	.octa 0x1e40
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x20008000800100050000000000400024
	/* C23 */
	.octa 0x4000000100000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd8000000400000210000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xdac00123 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:3 Rn:9 101101011000000000000:101101011000000000000 sf:1
	.inst 0xc2c23280 // BLR-C-C 00000:00000 Cn:20 100:100 opc:01 11000010110000100:11000010110000100
	.zero 28
	.inst 0x9ac0287e // asrv:aarch64/instrs/integer/shift/variable Rd:30 Rn:3 op2:10 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0xc2eb41c1 // BICFLGS-C.CI-C Cd:1 Cn:14 0:0 00:00 imm8:01011010 11000010111:11000010111
	.inst 0x68f3fc08 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:8 Rn:0 Rt2:11111 imm7:1100111 L:1 1010001:1010001 opc:01
	.inst 0xc2c0b860 // SCBNDS-C.CI-C Cd:0 Cn:3 1110:1110 S:0 imm6:000001 11000010110:11000010110
	.inst 0xe2903c21 // ASTUR-C.RI-C Ct:1 Rn:1 op2:11 imm9:100000011 V:0 op1:10 11100010:11100010
	.inst 0xa2b78205 // SWPA-CC.R-C Ct:5 Rn:16 100000:100000 Cs:23 1:1 R:0 A:1 10100010:10100010
	.inst 0x79437a00 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:16 imm12:000011011110 opc:01 111001:111001 size:01
	.inst 0x88dffc11 // ldar:aarch64/instrs/memory/ordered Rt:17 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xc2c210c0
	.zero 1048504
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc240070e // ldr c14, [x24, #1]
	.inst 0xc2400b10 // ldr c16, [x24, #2]
	.inst 0xc2400f14 // ldr c20, [x24, #3]
	.inst 0xc2401317 // ldr c23, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x80
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d8 // ldr c24, [c6, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010d8 // ldr c24, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400306 // ldr c6, [x24, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401306 // ldr c6, [x24, #4]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401706 // ldr c6, [x24, #5]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401b06 // ldr c6, [x24, #6]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401f06 // ldr c6, [x24, #7]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402306 // ldr c6, [x24, #8]
	.inst 0xc2c6a6e1 // chkeq c23, c6
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001064
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e40
	ldr x1, =check_data2
	ldr x2, =0x00001e50
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001efc
	ldr x1, =check_data3
	ldr x2, =0x00001f04
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffc
	ldr x1, =check_data4
	ldr x2, =0x00001ffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400008
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400024
	ldr x1, =check_data6
	ldr x2, =0x00400048
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
