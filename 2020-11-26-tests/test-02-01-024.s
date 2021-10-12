.section data0, #alloc, #write
	.zero 2416
	.byte 0x71, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1664
.data
check_data0:
	.byte 0x71, 0x19, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xd6, 0xff, 0x7f, 0x42, 0x47, 0xac, 0xef, 0x70, 0x0b, 0x34, 0x77, 0xf1, 0x9d, 0x5e, 0xff, 0x37
	.byte 0x86, 0xfe, 0xdf, 0x48, 0xec, 0xff, 0xdf, 0x08, 0x13, 0x91, 0xc4, 0xc2, 0x3f, 0x60, 0x61, 0xf8
	.byte 0xd0, 0xe8, 0xc1, 0xc2, 0xc0, 0x03, 0x3f, 0xd6
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001970
	/* C8 */
	.octa 0x40000000400204020000000000001040
	/* C20 */
	.octa 0x80000000200140050000000000001e40
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x7fc
final_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001970
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x200080001006400700000000003df58f
	/* C8 */
	.octa 0x40000000400204020000000000001040
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x19700000000000000000
	/* C20 */
	.octa 0x80000000200140050000000000001e40
	/* C22 */
	.octa 0x427fffd6
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000100640070000000000400029
initial_SP_EL3_value:
	.octa 0x800000006014000400000000004002be
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004004f8040000000000400000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x427fffd6 // ALDAR-R.R-32 Rt:22 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x70efac47 // ADR-C.I-C Rd:7 immhi:110111110101100010 P:1 10000:10000 immlo:11 op:0
	.inst 0xf177340b // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:11 Rn:0 imm12:110111001101 sh:1 0:0 10001:10001 S:1 op:1 sf:1
	.inst 0x37ff5e9d // tbnz:aarch64/instrs/branch/conditional/test Rt:29 imm14:11101011110100 b40:11111 op:1 011011:011011 b5:0
	.inst 0x48dffe86 // ldarh:aarch64/instrs/memory/ordered Rt:6 Rn:20 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x08dfffec // ldarb:aarch64/instrs/memory/ordered Rt:12 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c49113 // STCT-R.R-_ Rt:19 Rn:8 100:100 opc:00 11000010110001001:11000010110001001
	.inst 0xf861603f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c1e8d0 // CTHI-C.CR-C Cd:16 Cn:6 1010:1010 opc:11 Rm:1 11000010110:11000010110
	.inst 0xd63f03c0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 2004
	.inst 0xc2c21140
	.zero 1046528
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc24008b4 // ldr c20, [x5, #2]
	.inst 0xc2400cbd // ldr c29, [x5, #3]
	.inst 0xc24010be // ldr c30, [x5, #4]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0xc
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603145 // ldr c5, [c10, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601145 // ldr c5, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000aa // ldr c10, [x5, #0]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc24004aa // ldr c10, [x5, #1]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc24008aa // ldr c10, [x5, #2]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc24010aa // ldr c10, [x5, #4]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24014aa // ldr c10, [x5, #5]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc24018aa // ldr c10, [x5, #6]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2401caa // ldr c10, [x5, #7]
	.inst 0xc2caa6c1 // chkeq c22, c10
	b.ne comparison_fail
	.inst 0xc24020aa // ldr c10, [x5, #8]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc24024aa // ldr c10, [x5, #9]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001970
	ldr x1, =check_data0
	ldr x2, =0x00001978
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001e40
	ldr x1, =check_data1
	ldr x2, =0x00001e42
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004002be
	ldr x1, =check_data3
	ldr x2, =0x004002bf
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004007fc
	ldr x1, =check_data4
	ldr x2, =0x00400800
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
