.section data0, #alloc, #write
	.zero 368
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 176
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 464
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 1936
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1072
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xdf, 0x11, 0xe1, 0xea, 0xd4, 0x4f, 0x89, 0xb8, 0x42, 0x54, 0x06, 0xe2, 0x57, 0xca, 0x59, 0x62
	.byte 0x82, 0x82, 0x2b, 0x9b, 0xfd, 0xff, 0xdf, 0xc8, 0xa3, 0x31, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data6:
	.byte 0xc2
.data
check_data7:
	.byte 0x3f, 0x20, 0x3f, 0x38, 0x3a, 0x08, 0x94, 0xe2, 0xe1, 0xc7, 0xb1, 0x5c, 0x60, 0x10, 0xc2, 0xc2
.data
check_data8:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001238
	/* C2 */
	.octa 0x403f99
	/* C13 */
	.octa 0xa000800081f601ff000000000049e005
	/* C14 */
	.octa 0x8000000000000123
	/* C18 */
	.octa 0x80100000000100050000000000001880
	/* C30 */
	.octa 0x80000000000080080000000000001384
final_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001238
	/* C13 */
	.octa 0xa000800081f601ff000000000049e005
	/* C14 */
	.octa 0x8000000000000123
	/* C18 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C20 */
	.octa 0xffffffffc2c2c2c2
	/* C23 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
	/* C26 */
	.octa 0xffffffffc2c2c2c2
	/* C29 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C30 */
	.octa 0x2000800000010006000000000040001d
initial_SP_EL3_value:
	.octa 0x800000000001000500000000004ffff0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100060000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001bb0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xeae111df // bics:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:14 imm6:000100 Rm:1 N:1 shift:11 01010:01010 opc:11 sf:1
	.inst 0xb8894fd4 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:20 Rn:30 11:11 imm9:010010100 0:0 opc:10 111000:111000 size:10
	.inst 0xe2065442 // ALDURB-R.RI-32 Rt:2 Rn:2 op2:01 imm9:001100101 V:0 op1:00 11100010:11100010
	.inst 0x6259ca57 // LDNP-C.RIB-C Ct:23 Rn:18 Ct2:10010 imm7:0110011 L:1 011000100:011000100
	.inst 0x9b2b8282 // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:20 Ra:0 o0:1 Rm:11 01:01 U:0 10011011:10011011
	.inst 0xc8dffffd // ldar:aarch64/instrs/memory/ordered Rt:29 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xc2c231a3 // BLRR-C-C 00011:00011 Cn:13 100:100 opc:01 11000010110000100:11000010110000100
	.zero 6380
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 9964
	.inst 0x00c20000
	.zero 630788
	.inst 0x383f203f // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:010 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xe294083a // ALDURSW-R.RI-64 Rt:26 Rn:1 op2:10 imm9:101000000 V:0 op1:10 11100010:11100010
	.inst 0x5cb1c7e1 // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:1 imm19:1011000111000111111 011100:011100 opc:01
	.inst 0xc2c21060
	.zero 401372
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 8
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
	.inst 0xc2400b2d // ldr c13, [x25, #2]
	.inst 0xc2400f2e // ldr c14, [x25, #3]
	.inst 0xc2401332 // ldr c18, [x25, #4]
	.inst 0xc240173e // ldr c30, [x25, #5]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x3085103d
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603079 // ldr c25, [c3, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601079 // ldr c25, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	mov x3, #0xf
	and x25, x25, x3
	cmp x25, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400323 // ldr c3, [x25, #0]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2400b23 // ldr c3, [x25, #2]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2400f23 // ldr c3, [x25, #3]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2401323 // ldr c3, [x25, #4]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2401723 // ldr c3, [x25, #5]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2401b23 // ldr c3, [x25, #6]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc2401f23 // ldr c3, [x25, #7]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402323 // ldr c3, [x25, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0xc2c2c2c2c2c2c2c2
	mov x3, v1.d[0]
	cmp x25, x3
	b.ne comparison_fail
	ldr x25, =0x0
	mov x3, v1.d[1]
	cmp x25, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001178
	ldr x1, =check_data0
	ldr x2, =0x0000117c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001238
	ldr x1, =check_data1
	ldr x2, =0x00001239
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001418
	ldr x1, =check_data2
	ldr x2, =0x0000141c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001bb0
	ldr x1, =check_data3
	ldr x2, =0x00001bd0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401908
	ldr x1, =check_data5
	ldr x2, =0x00401910
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00403ffe
	ldr x1, =check_data6
	ldr x2, =0x00403fff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x0049e004
	ldr x1, =check_data7
	ldr x2, =0x0049e014
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ffff0
	ldr x1, =check_data8
	ldr x2, =0x004ffff8
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
