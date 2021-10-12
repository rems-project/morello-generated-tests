.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0xe7, 0xa0, 0x7c, 0x69, 0xe0, 0xff, 0xa1, 0x9b, 0x20, 0x00, 0xc2, 0xc2, 0xf7, 0x33, 0x6d, 0x38
	.byte 0x60, 0xc3, 0x7f, 0x22, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x2003400f0000800000007ffb
	/* C2 */
	.octa 0x20207077fff
	/* C7 */
	.octa 0x101c
	/* C13 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2003400f0000800000007ffb
	/* C2 */
	.octa 0x20207077fff
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000008700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000006003000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x697ca0e7 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:7 Rn:7 Rt2:01000 imm7:1111001 L:1 1010010:1010010 opc:01
	.inst 0x9ba1ffe0 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:31 Ra:31 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0x386d33f7 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:23 Rn:31 00:00 opc:011 0:0 Rs:13 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x227fc360 // LDAXP-C.R-C Ct:0 Rn:27 Ct2:10000 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c21340
	.zero 1048552
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400562 // ldr c2, [x11, #1]
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc240117b // ldr c27, [x11, #4]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x3085103f
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334b // ldr c11, [c26, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260134b // ldr c11, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240017a // ldr c26, [x11, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240057a // ldr c26, [x11, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240097a // ldr c26, [x11, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d7a // ldr c26, [x11, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240117a // ldr c26, [x11, #4]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc240157a // ldr c26, [x11, #5]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240197a // ldr c26, [x11, #6]
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	.inst 0xc2401d7a // ldr c26, [x11, #7]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240217a // ldr c26, [x11, #8]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
