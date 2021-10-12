.section data0, #alloc, #write
	.zero 96
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1904
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2064
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x01, 0x00
.data
check_data2:
	.byte 0xbf, 0x27, 0x1e, 0xeb, 0xfe, 0x1e, 0x75, 0x6a, 0x34, 0x10, 0xc0, 0x5a, 0xdf, 0x60, 0x6f, 0x78
	.byte 0x7d, 0x92, 0xc0, 0xc2, 0xf6, 0x50, 0xe9, 0xb0, 0xdd, 0x7f, 0x5f, 0x9b, 0xfe, 0x2b, 0x7d, 0x8a
	.byte 0x3f, 0x40, 0x3a, 0xf8, 0x01, 0x1c, 0x60, 0x82, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000003000700000000003ffff8
	/* C1 */
	.octa 0x1040
	/* C6 */
	.octa 0x17c0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x7fffff80
	/* C23 */
	.octa 0xffffff
	/* C26 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x800000000003000700000000003ffff8
	/* C1 */
	.octa 0x6a751efeeb1e27bf
	/* C6 */
	.octa 0x17c0
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x13
	/* C21 */
	.octa 0x7fffff80
	/* C22 */
	.octa 0xffffffffd2a1d000
	/* C23 */
	.octa 0xffffff
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000807001600ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeb1e27bf // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:29 imm6:001001 Rm:30 0:0 shift:00 01011:01011 S:1 op:1 sf:1
	.inst 0x6a751efe // bics:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:23 imm6:000111 Rm:21 N:1 shift:01 01010:01010 opc:11 sf:0
	.inst 0x5ac01034 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:20 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x786f60df // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:110 o3:0 Rs:15 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c0927d // GCTAG-R.C-C Rd:29 Cn:19 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xb0e950f6 // ADRP-C.IP-C Rd:22 immhi:110100101010000111 P:1 10000:10000 immlo:01 op:1
	.inst 0x9b5f7fdd // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:29 Rn:30 Ra:11111 0:0 Rm:31 10:10 U:0 10011011:10011011
	.inst 0x8a7d2bfe // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:001010 Rm:29 N:1 shift:01 01010:01010 opc:00 sf:1
	.inst 0xf83a403f // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:26 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x82601c01 // ALDR-R.RI-64 Rt:1 Rn:0 op:11 imm9:000000001 L:1 1000001001:1000001001
	.inst 0xc2c21300
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
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400946 // ldr c6, [x10, #2]
	.inst 0xc2400d4f // ldr c15, [x10, #3]
	.inst 0xc2401153 // ldr c19, [x10, #4]
	.inst 0xc2401555 // ldr c21, [x10, #5]
	.inst 0xc2401957 // ldr c23, [x10, #6]
	.inst 0xc2401d5a // ldr c26, [x10, #7]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	ldr x10, =0xc
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330a // ldr c10, [c24, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x8260130a // ldr c10, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
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
	mov x24, #0xf
	and x10, x10, x24
	cmp x10, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400158 // ldr c24, [x10, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400558 // ldr c24, [x10, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400958 // ldr c24, [x10, #2]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2400d58 // ldr c24, [x10, #3]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401158 // ldr c24, [x10, #4]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2401558 // ldr c24, [x10, #5]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2401958 // ldr c24, [x10, #6]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2401d58 // ldr c24, [x10, #7]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2402158 // ldr c24, [x10, #8]
	.inst 0xc2d8a6e1 // chkeq c23, c24
	b.ne comparison_fail
	.inst 0xc2402558 // ldr c24, [x10, #9]
	.inst 0xc2d8a741 // chkeq c26, c24
	b.ne comparison_fail
	.inst 0xc2402958 // ldr c24, [x10, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402d58 // ldr c24, [x10, #11]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001068
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017e0
	ldr x1, =check_data1
	ldr x2, =0x000017e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
