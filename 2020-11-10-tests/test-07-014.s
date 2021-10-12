.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 240
	.byte 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1776
	.byte 0x24, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x02
.data
check_data3:
	.byte 0x24, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x24, 0x00
.data
check_data5:
	.byte 0xff, 0x52, 0x67, 0x38, 0x7f, 0x60, 0x21, 0xf8, 0xc1, 0x13, 0xc2, 0xc2, 0x25, 0xb7, 0x1d, 0x82
	.byte 0xff, 0x43, 0x7f, 0x38, 0xc2, 0xff, 0x5f, 0x42, 0x82, 0xe9, 0x12, 0x79, 0x7f, 0x12, 0xca, 0xe2
	.byte 0x79, 0xed, 0x68, 0xb0, 0x40, 0xb0, 0xc5, 0xc2, 0x40, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1006
	/* C7 */
	.octa 0x2
	/* C12 */
	.octa 0xffe
	/* C19 */
	.octa 0x40000000200100050000000000001007
	/* C23 */
	.octa 0x10fe
	/* C30 */
	.octa 0x17fe
final_cap_values:
	/* C0 */
	.octa 0xb00080000006000f0000000000400824
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x400024
	/* C3 */
	.octa 0x1006
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x2
	/* C12 */
	.octa 0xffe
	/* C19 */
	.octa 0x40000000200100050000000000001007
	/* C23 */
	.octa 0x10fe
	/* C25 */
	.octa 0xd21ac000
	/* C30 */
	.octa 0x17fe
initial_SP_EL3_value:
	.octa 0x10fe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xb00080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000600400020000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x386752ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:101 o3:0 Rs:7 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf821607f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c213c1 // CHKSLD-C-C 00001:00001 Cn:30 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x821db725 // LDR-C.I-C Ct:5 imm17:01110110110111001 1000001000:1000001000
	.inst 0x387f43ff // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:100 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x425fffc2 // LDAR-C.R-C Ct:2 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x7912e982 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:12 imm12:010010111010 opc:00 111001:111001 size:01
	.inst 0xe2ca127f // ASTUR-R.RI-64 Rt:31 Rn:19 op2:00 imm9:010100001 V:0 op1:11 11100010:11100010
	.inst 0xb068ed79 // ADRDP-C.ID-C Rd:25 immhi:110100011101101011 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2c5b040 // CVTP-C.R-C Cd:0 Rn:2 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c21240
	.zero 1048532
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
	ldr x17, =initial_cap_values
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400623 // ldr c3, [x17, #1]
	.inst 0xc2400a27 // ldr c7, [x17, #2]
	.inst 0xc2400e2c // ldr c12, [x17, #3]
	.inst 0xc2401233 // ldr c19, [x17, #4]
	.inst 0xc2401637 // ldr c23, [x17, #5]
	.inst 0xc2401a3e // ldr c30, [x17, #6]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	ldr x17, =0xc
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603251 // ldr c17, [c18, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601251 // ldr c17, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x18, #0xf
	and x17, x17, x18
	cmp x17, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400232 // ldr c18, [x17, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400632 // ldr c18, [x17, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400a32 // ldr c18, [x17, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400e32 // ldr c18, [x17, #3]
	.inst 0xc2d2a461 // chkeq c3, c18
	b.ne comparison_fail
	.inst 0xc2401232 // ldr c18, [x17, #4]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401632 // ldr c18, [x17, #5]
	.inst 0xc2d2a4e1 // chkeq c7, c18
	b.ne comparison_fail
	.inst 0xc2401a32 // ldr c18, [x17, #6]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401e32 // ldr c18, [x17, #7]
	.inst 0xc2d2a661 // chkeq c19, c18
	b.ne comparison_fail
	.inst 0xc2402232 // ldr c18, [x17, #8]
	.inst 0xc2d2a6e1 // chkeq c23, c18
	b.ne comparison_fail
	.inst 0xc2402632 // ldr c18, [x17, #9]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2402a32 // ldr c18, [x17, #10]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001008
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010a8
	ldr x1, =check_data1
	ldr x2, =0x000010b0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001101
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001974
	ldr x1, =check_data4
	ldr x2, =0x00001976
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004edb90
	ldr x1, =check_data6
	ldr x2, =0x004edba0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
