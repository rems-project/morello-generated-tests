.section data0, #alloc, #write
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xdb, 0xc3
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xe0, 0xf4, 0x41, 0xa2, 0xcb, 0xf0, 0xc5, 0xc2, 0x72, 0x25, 0x52, 0xf8, 0xa8, 0xb1, 0xf4, 0xf2
	.byte 0xdd, 0x13, 0x3b, 0x38, 0xe9, 0xba, 0x53, 0xe2, 0xdb, 0x7f, 0x9f, 0xc8, 0x19, 0x30, 0xc1, 0xc2
	.byte 0xda, 0x07, 0x0c, 0x1b, 0x9e, 0xb5, 0xa2, 0xe2, 0xe0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x400000
	/* C7 */
	.octa 0x1200
	/* C12 */
	.octa 0x800000006000100a0000000000001021
	/* C23 */
	.octa 0x80000000000100050000000000002085
	/* C27 */
	.octa 0xc3db000000000000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C6 */
	.octa 0x400000
	/* C7 */
	.octa 0x13f0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x3fff22
	/* C12 */
	.octa 0x800000006000100a0000000000001021
	/* C18 */
	.octa 0xc2c5f0cba241f4e0
	/* C23 */
	.octa 0x80000000000100050000000000002085
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0xc3db000000000000
	/* C29 */
	.octa 0xff
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000304100050080000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001200
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa241f4e0 // LDR-C.RIAW-C Ct:0 Rn:7 01:01 imm9:000011111 0:0 opc:01 10100010:10100010
	.inst 0xc2c5f0cb // CVTPZ-C.R-C Cd:11 Rn:6 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xf8522572 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:18 Rn:11 01:01 imm9:100100010 0:0 opc:01 111000:111000 size:11
	.inst 0xf2f4b1a8 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:8 imm16:1010010110001101 hw:11 100101:100101 opc:11 sf:1
	.inst 0x383b13dd // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:30 00:00 opc:001 0:0 Rs:27 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xe253bae9 // ALDURSH-R.RI-64 Rt:9 Rn:23 op2:10 imm9:100111011 V:0 op1:01 11100010:11100010
	.inst 0xc89f7fdb // stllr:aarch64/instrs/memory/ordered Rt:27 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0xc2c13019 // GCFLGS-R.C-C Rd:25 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x1b0c07da // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:26 Rn:30 Ra:1 o0:0 Rm:12 0011011000:0011011000 sf:0
	.inst 0xe2a2b59e // ALDUR-V.RI-S Rt:30 Rn:12 op2:01 imm9:000101011 V:1 op1:10 11100010:11100010
	.inst 0xc2c211e0
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
	ldr x10, =initial_cap_values
	.inst 0xc2400146 // ldr c6, [x10, #0]
	.inst 0xc2400547 // ldr c7, [x10, #1]
	.inst 0xc240094c // ldr c12, [x10, #2]
	.inst 0xc2400d57 // ldr c23, [x10, #3]
	.inst 0xc240115b // ldr c27, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851037
	msr SCTLR_EL3, x10
	ldr x10, =0x4
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ea // ldr c10, [c15, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826011ea // ldr c10, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	.inst 0xc240014f // ldr c15, [x10, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240054f // ldr c15, [x10, #1]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc240094f // ldr c15, [x10, #2]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2400d4f // ldr c15, [x10, #3]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc240114f // ldr c15, [x10, #4]
	.inst 0xc2cfa561 // chkeq c11, c15
	b.ne comparison_fail
	.inst 0xc240154f // ldr c15, [x10, #5]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc240194f // ldr c15, [x10, #6]
	.inst 0xc2cfa641 // chkeq c18, c15
	b.ne comparison_fail
	.inst 0xc2401d4f // ldr c15, [x10, #7]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc240214f // ldr c15, [x10, #8]
	.inst 0xc2cfa721 // chkeq c25, c15
	b.ne comparison_fail
	.inst 0xc240254f // ldr c15, [x10, #9]
	.inst 0xc2cfa761 // chkeq c27, c15
	b.ne comparison_fail
	.inst 0xc240294f // ldr c15, [x10, #10]
	.inst 0xc2cfa7a1 // chkeq c29, c15
	b.ne comparison_fail
	.inst 0xc2402d4f // ldr c15, [x10, #11]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x15, v30.d[0]
	cmp x10, x15
	b.ne comparison_fail
	ldr x10, =0x0
	mov x15, v30.d[1]
	cmp x10, x15
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
	ldr x0, =0x0000104c
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fc0
	ldr x1, =check_data3
	ldr x2, =0x00001fc2
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
