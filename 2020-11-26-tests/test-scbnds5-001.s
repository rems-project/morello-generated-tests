.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xde, 0xb3, 0x90, 0x50, 0xc8, 0x7f, 0xdf, 0x9b, 0x20, 0x00, 0xc2, 0xc2, 0x6c, 0x7c, 0x59, 0xa8
	.byte 0xe6, 0x73, 0x49, 0xba, 0x80, 0x10, 0xc2, 0xc2
.data
check_data1:
	.byte 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x20007dde4c2500752c95f2f67ddb
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x8000000000460080000000000045bef0
final_cap_values:
	/* C0 */
	.octa 0x20007ddb7ddb00752c95f2f67ddb
	/* C1 */
	.octa 0x20007dde4c2500752c95f2f67ddb
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x8000000000460080000000000045bef0
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x5050505050505050
	/* C30 */
	.octa 0x200080004800e80b000000000032167a
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004800e80b0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5090b3de // ADR-C.I-C Rd:30 immhi:001000010110011110 P:1 10000:10000 immlo:10 op:0
	.inst 0x9bdf7fc8 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:8 Rn:30 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xa8597c6c // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:12 Rn:3 Rt2:11111 imm7:0110010 L:1 1010000:1010000 opc:10
	.inst 0xba4973e6 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0110 0:0 Rn:31 00:00 cond:0111 Rm:9 111010010:111010010 op:0 sf:1
	.inst 0xc2c21080
	.zero 376936
	.inst 0x50505050
	.inst 0x50505050
	.inst 0x50505050
	.inst 0x50505050
	.zero 671600
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
	ldr x25, =initial_cap_values
	.inst 0xc2400321 // ldr c1, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	/* Set up flags and system registers */
	mov x25, #0x10000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601099 // ldr c25, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x4, #0xf
	and x25, x25, x4
	cmp x25, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400324 // ldr c4, [x25, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400724 // ldr c4, [x25, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b24 // ldr c4, [x25, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400f24 // ldr c4, [x25, #3]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2401324 // ldr c4, [x25, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401724 // ldr c4, [x25, #5]
	.inst 0xc2c4a581 // chkeq c12, c4
	b.ne comparison_fail
	.inst 0xc2401b24 // ldr c4, [x25, #6]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x00400018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0045c080
	ldr x1, =check_data1
	ldr x2, =0x0045c090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
