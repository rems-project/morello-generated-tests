.section data0, #alloc, #write
	.zero 4000
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00
	.byte 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x80, 0x01, 0xb0, 0x00, 0x80, 0x00, 0x20
	.zero 64
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00
	.byte 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x80, 0x01, 0xb0, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xf5, 0x97, 0xf3, 0x2d, 0xc0, 0xff, 0x08, 0x22, 0xbe, 0xfc, 0x02, 0x22, 0x2f, 0x12, 0xc7, 0xc2
	.byte 0x01, 0x7c, 0xd0, 0xe2, 0x2d, 0x60, 0x37, 0x92, 0xc1, 0x77, 0x4c, 0x39, 0xf2, 0x33, 0xc4, 0xc2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xfb, 0xd0, 0xc1, 0xc2, 0xf7, 0xc2, 0xbf, 0x78, 0x60, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x20d9
	/* C5 */
	.octa 0x4c0000000001000500000000004fffe0
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x403400
	/* C30 */
	.octa 0xc00000000001000500000000000011e0
final_cap_values:
	/* C0 */
	.octa 0x20d9
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C5 */
	.octa 0x4c0000000001000500000000004fffe0
	/* C8 */
	.octa 0x1
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x200000000000000000000000000
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000410100000000000000400021
initial_SP_EL3_value:
	.octa 0x90000000000700070000000000002004
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000020100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fa0
	.dword 0x0000000000001fb0
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2df397f5 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:21 Rn:31 Rt2:00101 imm7:1100111 L:1 1011011:1011011 opc:00
	.inst 0x2208ffc0 // STLXR-R.CR-C Ct:0 Rn:30 (1)(1)(1)(1)(1):11111 1:1 Rs:8 0:0 L:0 001000100:001000100
	.inst 0x2202fcbe // STLXR-R.CR-C Ct:30 Rn:5 (1)(1)(1)(1)(1):11111 1:1 Rs:2 0:0 L:0 001000100:001000100
	.inst 0xc2c7122f // RRLEN-R.R-C Rd:15 Rn:17 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0xe2d07c01 // ALDUR-C.RI-C Ct:1 Rn:0 op2:11 imm9:100000111 V:0 op1:11 11100010:11100010
	.inst 0x9237602d // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:13 Rn:1 imms:011000 immr:110111 N:0 100100:100100 opc:00 sf:1
	.inst 0x394c77c1 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:30 imm12:001100011101 opc:01 111001:111001 size:00
	.inst 0xc2c433f2 // LDPBLR-C.C-C Ct:18 Cn:31 100:100 opc:01 11000010110001000:11000010110001000
	.zero 32736
	.inst 0xc2c1d0fb // CPY-C.C-C Cd:27 Cn:7 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x78bfc2f7 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:23 Rn:23 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc2c21060
	.zero 1015796
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
	.inst 0xc2400545 // ldr c5, [x10, #1]
	.inst 0xc2400951 // ldr c17, [x10, #2]
	.inst 0xc2400d57 // ldr c23, [x10, #3]
	.inst 0xc240115e // ldr c30, [x10, #4]
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
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306a // ldr c10, [c3, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260106a // ldr c10, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400143 // ldr c3, [x10, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400543 // ldr c3, [x10, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400943 // ldr c3, [x10, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400d43 // ldr c3, [x10, #3]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc2401143 // ldr c3, [x10, #4]
	.inst 0xc2c3a501 // chkeq c8, c3
	b.ne comparison_fail
	.inst 0xc2401543 // ldr c3, [x10, #5]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2401943 // ldr c3, [x10, #6]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401d43 // ldr c3, [x10, #7]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2402143 // ldr c3, [x10, #8]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2402543 // ldr c3, [x10, #9]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402943 // ldr c3, [x10, #10]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x3, v5.d[0]
	cmp x10, x3
	b.ne comparison_fail
	ldr x10, =0x0
	mov x3, v5.d[1]
	cmp x10, x3
	b.ne comparison_fail
	ldr x10, =0x0
	mov x3, v21.d[0]
	cmp x10, x3
	b.ne comparison_fail
	ldr x10, =0x0
	mov x3, v21.d[1]
	cmp x10, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011e0
	ldr x1, =check_data0
	ldr x2, =0x000011f0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000014fd
	ldr x1, =check_data1
	ldr x2, =0x000014fe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fa0
	ldr x1, =check_data2
	ldr x2, =0x00001fc0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00403400
	ldr x1, =check_data5
	ldr x2, =0x00403402
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408000
	ldr x1, =check_data6
	ldr x2, =0x0040800c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004fffe0
	ldr x1, =check_data7
	ldr x2, =0x004ffff0
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
