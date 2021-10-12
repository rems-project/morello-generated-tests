.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x23, 0x5c, 0x9e, 0xe2, 0xe7, 0x7b, 0xd4, 0xc2, 0xfe, 0x03, 0x00, 0x9a, 0xa8, 0xf3, 0x52, 0xa2
	.byte 0x1c, 0x5b, 0x19, 0x35
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x9d, 0x51, 0x9d, 0xab, 0x2d, 0xff, 0xfe, 0xc2, 0xff, 0x03, 0x31, 0x38, 0xff, 0xff, 0x1f, 0x42
	.byte 0x1a, 0x23, 0x60, 0x78, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4c0000001007000f000000000000101b
	/* C3 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C24 */
	.octa 0x1082
	/* C25 */
	.octa 0x90000000500000040000000000410040
	/* C28 */
	.octa 0xffffffff
	/* C29 */
	.octa 0x2081
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4c0000001007000f000000000000101b
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x528010000000000000001000
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C24 */
	.octa 0x1082
	/* C25 */
	.octa 0x90000000500000040000000000410040
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xffffffff
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x300070000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000a0100000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000100600000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fb0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe29e5c23 // ASTUR-C.RI-C Ct:3 Rn:1 op2:11 imm9:111100101 V:0 op1:10 11100010:11100010
	.inst 0xc2d47be7 // SCBNDS-C.CI-S Cd:7 Cn:31 1110:1110 S:1 imm6:101000 11000010110:11000010110
	.inst 0x9a0003fe // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:31 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:1
	.inst 0xa252f3a8 // LDUR-C.RI-C Ct:8 Rn:29 00:00 imm9:100101111 0:0 opc:01 10100010:10100010
	.inst 0x35195b1c // cbnz:aarch64/instrs/branch/conditional/compare Rt:28 imm19:0001100101011011000 op:1 011010:011010 sf:0
	.zero 207708
	.inst 0xab9d519d // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:29 Rn:12 imm6:010100 Rm:29 0:0 shift:10 01011:01011 S:1 op:0 sf:1
	.inst 0xc2feff2d // ALDR-C.RRB-C Ct:13 Rn:25 1:1 L:1 S:1 option:111 Rm:30 11000010111:11000010111
	.inst 0x383103ff // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:000 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x421fffff // STLR-C.R-C Ct:31 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x7860231a // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:26 Rn:24 00:00 opc:010 0:0 Rs:0 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c210c0
	.zero 840824
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400943 // ldr c3, [x10, #2]
	.inst 0xc2400d51 // ldr c17, [x10, #3]
	.inst 0xc2401158 // ldr c24, [x10, #4]
	.inst 0xc2401559 // ldr c25, [x10, #5]
	.inst 0xc240195c // ldr c28, [x10, #6]
	.inst 0xc2401d5d // ldr c29, [x10, #7]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030ca // ldr c10, [c6, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826010ca // ldr c10, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x6, #0x3
	and x10, x10, x6
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400146 // ldr c6, [x10, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400546 // ldr c6, [x10, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400946 // ldr c6, [x10, #2]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2400d46 // ldr c6, [x10, #3]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2401146 // ldr c6, [x10, #4]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401546 // ldr c6, [x10, #5]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc2401946 // ldr c6, [x10, #6]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401d46 // ldr c6, [x10, #7]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2402146 // ldr c6, [x10, #8]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc2402546 // ldr c6, [x10, #9]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402946 // ldr c6, [x10, #10]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc2402d46 // ldr c6, [x10, #11]
	.inst 0xc2c6a7c1 // chkeq c30, c6
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
	ldr x0, =0x00001082
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fb0
	ldr x1, =check_data2
	ldr x2, =0x00001fc0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00410040
	ldr x1, =check_data4
	ldr x2, =0x00410050
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00432b70
	ldr x1, =check_data5
	ldr x2, =0x00432b88
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
