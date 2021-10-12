.section data0, #alloc, #write
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x1f, 0x52, 0x21, 0x78, 0xa8, 0x98, 0x93, 0xe2, 0x5f, 0x0d, 0x18, 0xe2, 0x02, 0x00, 0xff, 0xb8
	.byte 0x20, 0xe0, 0x42, 0xba, 0x1e, 0x84, 0x1c, 0x3c, 0xe0, 0x83, 0x66, 0xf8, 0x83, 0x31, 0xb3, 0x38
	.byte 0x21, 0x7e, 0x5e, 0x9b, 0x86, 0xfe, 0xdf, 0x48, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000020000000000000001000
	/* C1 */
	.octa 0x4000
	/* C5 */
	.octa 0x400103
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x400100
	/* C12 */
	.octa 0xc0000000000100050000000000001007
	/* C16 */
	.octa 0xc0000000000100050000000000001000
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x800000000001000500000000004ffffc
final_cap_values:
	/* C0 */
	.octa 0x100000000000000
	/* C2 */
	.octa 0x8
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x400103
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x400100
	/* C12 */
	.octa 0xc0000000000100050000000000001007
	/* C16 */
	.octa 0xc0000000000100050000000000001000
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x800000000001000500000000004ffffc
initial_SP_EL3_value:
	.octa 0xc0000000000100050000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000006200f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7821521f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:101 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xe29398a8 // ALDURSW-R.RI-64 Rt:8 Rn:5 op2:10 imm9:100111001 V:0 op1:10 11100010:11100010
	.inst 0xe2180d5f // ALDURSB-R.RI-32 Rt:31 Rn:10 op2:11 imm9:110000000 V:0 op1:00 11100010:11100010
	.inst 0xb8ff0002 // ldadd:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:0 00:00 opc:000 0:0 Rs:31 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xba42e020 // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0000 0:0 Rn:1 00:00 cond:1110 Rm:2 111010010:111010010 op:0 sf:1
	.inst 0x3c1c841e // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:30 Rn:0 01:01 imm9:111001000 0:0 opc:00 111100:111100 size:00
	.inst 0xf86683e0 // swp:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:31 100000:100000 Rs:6 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x38b33183 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:12 00:00 opc:011 0:0 Rs:19 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x9b5e7e21 // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:17 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0x48dffe86 // ldarh:aarch64/instrs/memory/ordered Rt:6 Rn:20 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c212e0
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400da6 // ldr c6, [x13, #3]
	.inst 0xc24011aa // ldr c10, [x13, #4]
	.inst 0xc24015ac // ldr c12, [x13, #5]
	.inst 0xc24019b0 // ldr c16, [x13, #6]
	.inst 0xc2401db3 // ldr c19, [x13, #7]
	.inst 0xc24021b4 // ldr c20, [x13, #8]
	/* Vector registers */
	mrs x13, cptr_el3
	bfc x13, #10, #1
	msr cptr_el3, x13
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085103d
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032ed // ldr c13, [c23, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012ed // ldr c13, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x23, #0xf
	and x13, x13, x23
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b7 // ldr c23, [x13, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24005b7 // ldr c23, [x13, #1]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc24009b7 // ldr c23, [x13, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400db7 // ldr c23, [x13, #3]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc24011b7 // ldr c23, [x13, #4]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc24015b7 // ldr c23, [x13, #5]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc24019b7 // ldr c23, [x13, #6]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401db7 // ldr c23, [x13, #7]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc24021b7 // ldr c23, [x13, #8]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc24025b7 // ldr c23, [x13, #9]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc24029b7 // ldr c23, [x13, #10]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x23, v30.d[0]
	cmp x13, x23
	b.ne comparison_fail
	ldr x13, =0x0
	mov x23, v30.d[1]
	cmp x13, x23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0040003c
	ldr x1, =check_data2
	ldr x2, =0x00400040
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400080
	ldr x1, =check_data3
	ldr x2, =0x00400081
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffc
	ldr x1, =check_data4
	ldr x2, =0x004ffffe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
