.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x40, 0x02, 0x5f, 0xd6, 0xc4, 0x77, 0x6c, 0x82, 0xe0, 0x73, 0xc2, 0xc2, 0x86, 0x5e, 0x3e, 0xd8
	.byte 0x38, 0x98, 0xff, 0xc2, 0xdf, 0x7f, 0x5f, 0x08, 0x61, 0x1a, 0x00, 0xe2, 0xdd, 0x3f, 0x00, 0xf9
	.byte 0xf4, 0xab, 0x5c, 0x38, 0xdf, 0x23, 0xc0, 0x1a, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C18 */
	.octa 0x400004
	/* C19 */
	.octa 0x80000000000100050000000000001ffd
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1f00
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C18 */
	.octa 0x400004
	/* C19 */
	.octa 0x80000000000100050000000000001ffd
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1f00
initial_SP_EL3_value:
	.octa 0x2030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000006800000100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd65f0240 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:18 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0x826c77c4 // ALDRB-R.RI-B Rt:4 Rn:30 op:01 imm9:011000111 L:1 1000001001:1000001001
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xd83e5e86 // prfm_lit:aarch64/instrs/memory/literal/general Rt:6 imm19:0011111001011110100 011000:011000 opc:11
	.inst 0xc2ff9838 // SUBS-R.CC-C Rd:24 Cn:1 100110:100110 Cm:31 11000010111:11000010111
	.inst 0x085f7fdf // ldxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xe2001a61 // ALDURSB-R.RI-64 Rt:1 Rn:19 op2:10 imm9:000000001 V:0 op1:00 11100010:11100010
	.inst 0xf9003fdd // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:30 imm12:000000001111 opc:00 111001:111001 size:11
	.inst 0x385cabf4 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:20 Rn:31 10:10 imm9:111001010 0:0 opc:01 111000:111000 size:00
	.inst 0x1ac023df // lslv:aarch64/instrs/integer/shift/variable Rd:31 Rn:30 op2:00 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0xc2c210e0
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006f2 // ldr c18, [x23, #1]
	.inst 0xc2400af3 // ldr c19, [x23, #2]
	.inst 0xc2400efd // ldr c29, [x23, #3]
	.inst 0xc24012fe // ldr c30, [x23, #4]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x3085103d
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f7 // ldr c23, [c7, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826010f7 // ldr c23, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x7, #0xf
	and x23, x23, x7
	cmp x23, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e7 // ldr c7, [x23, #0]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24006e7 // ldr c7, [x23, #1]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2c7a641 // chkeq c18, c7
	b.ne comparison_fail
	.inst 0xc2400ee7 // ldr c7, [x23, #3]
	.inst 0xc2c7a661 // chkeq c19, c7
	b.ne comparison_fail
	.inst 0xc24012e7 // ldr c7, [x23, #4]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc24016e7 // ldr c7, [x23, #5]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2401ae7 // ldr c7, [x23, #6]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2401ee7 // ldr c7, [x23, #7]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f00
	ldr x1, =check_data0
	ldr x2, =0x00001f01
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f78
	ldr x1, =check_data1
	ldr x2, =0x00001f80
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc7
	ldr x1, =check_data2
	ldr x2, =0x00001fc8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffa
	ldr x1, =check_data3
	ldr x2, =0x00001ffb
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
