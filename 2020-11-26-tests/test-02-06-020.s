.section data0, #alloc, #write
	.zero 2080
	.byte 0x0d, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1968
.data
check_data0:
	.byte 0x00, 0x00, 0x41, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x81, 0xa7, 0xc1, 0xc2, 0xbc, 0x72, 0xbf, 0x78, 0xa3, 0x33, 0xc2, 0xc2
.data
check_data4:
	.byte 0xed, 0x23, 0x7e, 0xf8, 0xac, 0xff, 0xdf, 0x08, 0xdd, 0xab, 0xea, 0xc2, 0x40, 0x0e, 0xd0, 0x1a
	.byte 0x7e, 0xf2, 0xc5, 0xc2, 0x00, 0x21, 0x70, 0xaa, 0xe0, 0xb8, 0x54, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x8010000000010005ffffffffffffcd00
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000006000
	/* C21 */
	.octa 0xc0000000000500050000000000001840
	/* C28 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C29 */
	.octa 0xa00000000007810700000000004183f9
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x8010000000010005ffffffffffffcd00
	/* C12 */
	.octa 0x23
	/* C13 */
	.octa 0x10001000d
	/* C16 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000006000
	/* C21 */
	.octa 0xc0000000000500050000000000001840
	/* C28 */
	.octa 0x10
	/* C29 */
	.octa 0x2000800004008408550000000040000d
	/* C30 */
	.octa 0xa0000000000781070080000000006000
initial_RSP_EL0_value:
	.octa 0xc0000000000100050000000000001820
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040084080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_RSP_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1a781 // CHKEQ-_.CC-C 00001:00001 Cn:28 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0x78bf72bc // lduminh:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:21 00:00 opc:111 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2c233a3 // BLRR-C-C 00011:00011 Cn:29 100:100 opc:01 11000010110000100:11000010110000100
	.zero 99308
	.inst 0xf87e23ed // ldeor:aarch64/instrs/memory/atomicops/ld Rt:13 Rn:31 00:00 opc:010 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x08dfffac // ldarb:aarch64/instrs/memory/ordered Rt:12 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2eaabdd // ORRFLGS-C.CI-C Cd:29 Cn:30 0:0 01:01 imm8:01010101 11000010111:11000010111
	.inst 0x1ad00e40 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:0 Rn:18 o1:1 00001:00001 Rm:16 0011010110:0011010110 sf:0
	.inst 0xc2c5f27e // CVTPZ-C.R-C Cd:30 Rn:19 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xaa702100 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:8 imm6:001000 Rm:16 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0xc254b8e0 // LDR-C.RIB-C Ct:0 Rn:7 imm12:010100101110 L:1 110000100:110000100
	.inst 0xc2c210a0
	.zero 949224
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c1 // ldr c1, [x22, #0]
	.inst 0xc24006c7 // ldr c7, [x22, #1]
	.inst 0xc2400ad0 // ldr c16, [x22, #2]
	.inst 0xc2400ed3 // ldr c19, [x22, #3]
	.inst 0xc24012d5 // ldr c21, [x22, #4]
	.inst 0xc24016dc // ldr c28, [x22, #5]
	.inst 0xc2401add // ldr c29, [x22, #6]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	ldr x22, =initial_RSP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc28f4176 // msr RSP_EL0, c22
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826010b6 // ldr c22, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x5, #0xf
	and x22, x22, x5
	cmp x22, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002c5 // ldr c5, [x22, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24006c5 // ldr c5, [x22, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400ac5 // ldr c5, [x22, #2]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc2400ec5 // ldr c5, [x22, #3]
	.inst 0xc2c5a581 // chkeq c12, c5
	b.ne comparison_fail
	.inst 0xc24012c5 // ldr c5, [x22, #4]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc24016c5 // ldr c5, [x22, #5]
	.inst 0xc2c5a601 // chkeq c16, c5
	b.ne comparison_fail
	.inst 0xc2401ac5 // ldr c5, [x22, #6]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2401ec5 // ldr c5, [x22, #7]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc24022c5 // ldr c5, [x22, #8]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc24026c5 // ldr c5, [x22, #9]
	.inst 0xc2c5a7a1 // chkeq c29, c5
	b.ne comparison_fail
	.inst 0xc2402ac5 // ldr c5, [x22, #10]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001820
	ldr x1, =check_data0
	ldr x2, =0x00001828
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001840
	ldr x1, =check_data1
	ldr x2, =0x00001842
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040000c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004183f8
	ldr x1, =check_data4
	ldr x2, =0x00418418
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
