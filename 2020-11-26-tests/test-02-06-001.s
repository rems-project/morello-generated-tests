.section data0, #alloc, #write
	.zero 32
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4048
.data
check_data0:
	.byte 0x01, 0x08, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xfd, 0x63, 0x21, 0x38, 0x3e, 0xfc, 0x1f, 0x42, 0xf4, 0x7b, 0xc1, 0x2a, 0x1e, 0x00, 0x24, 0x9b
	.byte 0x2e, 0x46, 0xde, 0xe2, 0xce, 0x07, 0xc0, 0xda, 0xe9, 0x33, 0xe8, 0xb8, 0x05, 0x70, 0xbe, 0x78
	.byte 0x50, 0x20, 0xdf, 0x9a, 0x1f, 0xd8, 0x42, 0x82, 0x20, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001208
	/* C1 */
	.octa 0x1200
	/* C4 */
	.octa 0x3fff
	/* C8 */
	.octa 0x800
	/* C17 */
	.octa 0x8000000000010005000000000042bc9c
	/* C30 */
	.octa 0x1602000000000080000000
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001208
	/* C1 */
	.octa 0x1200
	/* C4 */
	.octa 0x3fff
	/* C5 */
	.octa 0x200
	/* C8 */
	.octa 0x800
	/* C9 */
	.octa 0x1
	/* C14 */
	.octa 0x82040000
	/* C17 */
	.octa 0x8000000000010005000000000042bc9c
	/* C20 */
	.octa 0x4800
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x4820000
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000004002002000ffffffffffe010
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x382163fd // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:31 00:00 opc:110 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x421ffc3e // STLR-C.R-C Ct:30 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x2ac17bf4 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:20 Rn:31 imm6:011110 Rm:1 N:0 shift:11 01010:01010 opc:01 sf:0
	.inst 0x9b24001e // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:0 Ra:0 o0:0 Rm:4 01:01 U:0 10011011:10011011
	.inst 0xe2de462e // ALDUR-R.RI-64 Rt:14 Rn:17 op2:01 imm9:111100100 V:0 op1:11 11100010:11100010
	.inst 0xdac007ce // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:14 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xb8e833e9 // ldset:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:31 00:00 opc:011 0:0 Rs:8 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x78be7005 // lduminh:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:0 00:00 opc:111 0:0 Rs:30 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x9adf2050 // lslv:aarch64/instrs/integer/shift/variable Rd:16 Rn:2 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x8242d81f // ASTR-R.RI-32 Rt:31 Rn:0 op:10 imm9:000101101 L:0 1000001001:1000001001
	.inst 0xc2c21320
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
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b44 // ldr c4, [x26, #2]
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc2401351 // ldr c17, [x26, #4]
	.inst 0xc240175e // ldr c30, [x26, #5]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x3085103f
	msr SCTLR_EL3, x26
	ldr x26, =0x4
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260333a // ldr c26, [c25, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260133a // ldr c26, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400359 // ldr c25, [x26, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400759 // ldr c25, [x26, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b59 // ldr c25, [x26, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400f59 // ldr c25, [x26, #3]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401359 // ldr c25, [x26, #4]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401759 // ldr c25, [x26, #5]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401b59 // ldr c25, [x26, #6]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401f59 // ldr c25, [x26, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2402359 // ldr c25, [x26, #8]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402759 // ldr c25, [x26, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2402b59 // ldr c25, [x26, #10]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001024
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001220
	ldr x1, =check_data1
	ldr x2, =0x00001230
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012bc
	ldr x1, =check_data2
	ldr x2, =0x000012c0
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
	ldr x0, =0x0042bc80
	ldr x1, =check_data4
	ldr x2, =0x0042bc88
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
