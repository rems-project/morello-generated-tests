.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x02, 0x00, 0x00
	.zero 16
	.byte 0x01, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4032
.data
check_data0:
	.byte 0x0e, 0x10, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x02, 0x00, 0x00
	.zero 16
	.byte 0x01, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0x21, 0x28, 0x1f, 0xb8, 0x4f, 0xfc, 0x3f, 0x42, 0x89, 0x32, 0xc4, 0xc2
.data
check_data3:
	.byte 0x89, 0x36, 0x0d, 0x78, 0x5e, 0xc0, 0x3f, 0xa2, 0x5f, 0x60, 0x6d, 0x78, 0xce, 0xd3, 0xf5, 0x02
	.byte 0x9e, 0xc6, 0xe5, 0x90, 0x87, 0x1f, 0x85, 0xf2, 0xa9, 0x67, 0x9a, 0x37, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x100e
	/* C2 */
	.octa 0xd0100000000100050000000000001010
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0xd0100000400200230000000000001020
final_cap_values:
	/* C1 */
	.octa 0x100e
	/* C2 */
	.octa 0xd0100000000100050000000000001010
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x20080000000ffffffffff28c000
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0xd01000004002002300000000000010f3
	/* C30 */
	.octa 0x2000800000000000ffffffffcbcd4000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000000003000700ffe00000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001030
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb81f2821 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:1 10:10 imm9:111110010 0:0 opc:00 111000:111000 size:10
	.inst 0x423ffc4f // ASTLR-R.R-32 Rt:15 Rn:2 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c43289 // LDPBLR-C.C-C Ct:9 Cn:20 100:100 opc:01 11000010110001000:11000010110001000
	.zero 16372
	.inst 0x780d3689 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:9 Rn:20 01:01 imm9:011010011 0:0 opc:00 111000:111000 size:01
	.inst 0xa23fc05e // LDAPR-C.R-C Ct:30 Rn:2 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x786d605f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:2 00:00 opc:110 o3:0 Rs:13 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x02f5d3ce // SUB-C.CIS-C Cd:14 Cn:30 imm12:110101110100 sh:1 A:1 00000010:00000010
	.inst 0x90e5c69e // ADRP-C.I-C Rd:30 immhi:110010111000110100 P:1 10000:10000 immlo:00 op:1
	.inst 0xf2851f87 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:7 imm16:0010100011111100 hw:00 100101:100101 opc:11 sf:1
	.inst 0x379a67a9 // tbnz:aarch64/instrs/branch/conditional/test Rt:9 imm14:01001100111101 b40:10011 op:1 011011:011011 b5:0
	.inst 0xc2c21260
	.zero 1032160
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400aed // ldr c13, [x23, #2]
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc24012f4 // ldr c20, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851037
	msr SCTLR_EL3, x23
	ldr x23, =0x84
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603277 // ldr c23, [c19, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601277 // ldr c23, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f3 // ldr c19, [x23, #0]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24006f3 // ldr c19, [x23, #1]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400af3 // ldr c19, [x23, #2]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc2d3a5a1 // chkeq c13, c19
	b.ne comparison_fail
	.inst 0xc24012f3 // ldr c19, [x23, #4]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc24016f3 // ldr c19, [x23, #5]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401af3 // ldr c19, [x23, #6]
	.inst 0xc2d3a681 // chkeq c20, c19
	b.ne comparison_fail
	.inst 0xc2401ef3 // ldr c19, [x23, #7]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00404000
	ldr x1, =check_data3
	ldr x2, =0x00404020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
