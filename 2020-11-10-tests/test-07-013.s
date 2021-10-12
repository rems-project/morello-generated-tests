.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x66, 0x2a, 0x01, 0xe2, 0xfd, 0x07, 0xc3, 0x68, 0x3e, 0x83, 0xe0, 0x78, 0x2f, 0xbc, 0x00, 0xaa
	.byte 0xdf, 0x07, 0xc0, 0xda, 0x25, 0x08, 0x2b, 0x71, 0x3e, 0x5d, 0xec, 0x22, 0x41, 0x86, 0xc1, 0xc2
	.byte 0xc0, 0x73, 0xc0, 0xc2, 0x41, 0x30, 0xc2, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x90100000000940050000000000001010
	/* C18 */
	.octa 0x106b0030000000000000001
	/* C19 */
	.octa 0x1000
	/* C25 */
	.octa 0xc0000000400200420000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0xfffff53e
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x90100000000940050000000000000d90
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x106b0030000000000000001
	/* C19 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0xc0000000400200420000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x700070000000000000000
initial_SP_EL3_value:
	.octa 0x80000000000080080000000000001200
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000410000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000003000700ffe0000000e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001020
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2012a66 // ALDURSB-R.RI-64 Rt:6 Rn:19 op2:10 imm9:000010010 V:0 op1:00 11100010:11100010
	.inst 0x68c307fd // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:29 Rn:31 Rt2:00001 imm7:0000110 L:1 1010001:1010001 opc:01
	.inst 0x78e0833e // swph:aarch64/instrs/memory/atomicops/swp Rt:30 Rn:25 100000:100000 Rs:0 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xaa00bc2f // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:15 Rn:1 imm6:101111 Rm:0 N:0 shift:00 01010:01010 opc:01 sf:1
	.inst 0xdac007df // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:31 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x712b0825 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:5 Rn:1 imm12:101011000010 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x22ec5d3e // LDP-CC.RIAW-C Ct:30 Rn:9 Ct2:10111 imm7:1011000 L:1 001000101:001000101
	.inst 0xc2c18641 // CHKSS-_.CC-C 00001:00001 Cn:18 001:001 opc:00 1:1 Cm:1 11000010110:11000010110
	.inst 0xc2c073c0 // GCOFF-R.C-C Rd:0 Cn:30 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c21140
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2400b49 // ldr c9, [x26, #2]
	.inst 0xc2400f52 // ldr c18, [x26, #3]
	.inst 0xc2401353 // ldr c19, [x26, #4]
	.inst 0xc2401759 // ldr c25, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851037
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260315a // ldr c26, [c10, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260115a // ldr c26, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x10, #0xf
	and x26, x26, x10
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034a // ldr c10, [x26, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240074a // ldr c10, [x26, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b4a // ldr c10, [x26, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400f4a // ldr c10, [x26, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240134a // ldr c10, [x26, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240174a // ldr c10, [x26, #5]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2401b4a // ldr c10, [x26, #6]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401f4a // ldr c10, [x26, #7]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc240234a // ldr c10, [x26, #8]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc240274a // ldr c10, [x26, #9]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2402b4a // ldr c10, [x26, #10]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc2402f4a // ldr c10, [x26, #11]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240334a // ldr c10, [x26, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001208
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
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
