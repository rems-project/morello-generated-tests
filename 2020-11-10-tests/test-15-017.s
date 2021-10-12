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
	.zero 2
.data
check_data3:
	.byte 0x92, 0x80, 0x7f, 0xa2, 0x3f, 0x3e, 0x79, 0x02, 0xff, 0x2e, 0x14, 0x78, 0x01, 0x00, 0xe2, 0x78
	.byte 0x22, 0x90, 0xc0, 0xc2, 0x11, 0x28, 0xc3, 0x1a, 0x05, 0x6b, 0xe7, 0x39, 0x4e, 0x41, 0x4a, 0x38
	.byte 0x9f, 0x01, 0x32, 0x78, 0x22, 0x24, 0xc2, 0x9a, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000600000810000000000001080
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0xc0000000600400040000000000001000
	/* C10 */
	.octa 0x80000000020500030000000000401000
	/* C12 */
	.octa 0xc0000000400400100000000000001000
	/* C17 */
	.octa 0x40040002000007fffffff800080
	/* C23 */
	.octa 0x40000000080600040000000000001100
	/* C24 */
	.octa 0x800000000007000700000000003ff800
final_cap_values:
	/* C0 */
	.octa 0xc0000000600000810000000000001080
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0xc0000000600400040000000000001000
	/* C5 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000020500030000000000401000
	/* C12 */
	.octa 0xc0000000400400100000000000001000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000080600040000000000001042
	/* C24 */
	.octa 0x800000000007000700000000003ff800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa27f8092 // SWPL-CC.R-C Ct:18 Rn:4 100000:100000 Cs:31 1:1 R:1 A:0 10100010:10100010
	.inst 0x02793e3f // ADD-C.CIS-C Cd:31 Cn:17 imm12:111001001111 sh:1 A:0 00000010:00000010
	.inst 0x78142eff // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:23 11:11 imm9:101000010 0:0 opc:00 111000:111000 size:01
	.inst 0x78e20001 // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:0 00:00 opc:000 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xc2c09022 // GCTAG-R.C-C Rd:2 Cn:1 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x1ac32811 // asrv:aarch64/instrs/integer/shift/variable Rd:17 Rn:0 op2:10 0010:0010 Rm:3 0011010110:0011010110 sf:0
	.inst 0x39e76b05 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:5 Rn:24 imm12:100111011010 opc:11 111001:111001 size:00
	.inst 0x384a414e // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:10 00:00 imm9:010100100 0:0 opc:01 111000:111000 size:00
	.inst 0x7832019f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:000 o3:0 Rs:18 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x9ac22422 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:1 op2:01 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0xc2c211a0
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2400cea // ldr c10, [x7, #3]
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc24014f1 // ldr c17, [x7, #5]
	.inst 0xc24018f7 // ldr c23, [x7, #6]
	.inst 0xc2401cf8 // ldr c24, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851037
	msr SCTLR_EL3, x7
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011a7 // ldr c7, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ed // ldr c13, [x7, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24004ed // ldr c13, [x7, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24008ed // ldr c13, [x7, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400ced // ldr c13, [x7, #3]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc24010ed // ldr c13, [x7, #4]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc24014ed // ldr c13, [x7, #5]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc24018ed // ldr c13, [x7, #6]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc2401ced // ldr c13, [x7, #7]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc24020ed // ldr c13, [x7, #8]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc24024ed // ldr c13, [x7, #9]
	.inst 0xc2cda6e1 // chkeq c23, c13
	b.ne comparison_fail
	.inst 0xc24028ed // ldr c13, [x7, #10]
	.inst 0xc2cda701 // chkeq c24, c13
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
	ldr x0, =0x00001042
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001082
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004001da
	ldr x1, =check_data4
	ldr x2, =0x004001db
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004010a4
	ldr x1, =check_data5
	ldr x2, =0x004010a5
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
