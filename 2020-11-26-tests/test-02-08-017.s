.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x01
.data
check_data2:
	.byte 0xc0, 0x03, 0x1f, 0xd6
.data
check_data3:
	.zero 32
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x9f, 0x41, 0x7e, 0x38, 0x2c, 0x28, 0xc0, 0xad, 0xdf, 0xff, 0x5f, 0x42, 0xa1, 0x33, 0xc5, 0xc2
	.byte 0x9d, 0x78, 0x7d, 0x38, 0xe4, 0xd8, 0xa1, 0xb8, 0x20, 0xf0, 0xc0, 0xc2, 0xe1, 0x9f, 0x1e, 0xe2
	.byte 0x57, 0x52, 0x9e, 0xb4, 0x60, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x800000001407940b0000000000410000
	/* C4 */
	.octa 0x80000000700020020000000000448001
	/* C7 */
	.octa 0x80000000000100050000000000001ff8
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C23 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0xffffffffffffa07f
	/* C30 */
	.octa 0x80000000000100050000000000480000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x80000000000100050000000000001ff8
	/* C12 */
	.octa 0xc0000000000100050000000000001ffe
	/* C23 */
	.octa 0xffffffffffffffff
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100050000000000480000
initial_SP_EL3_value:
	.octa 0x500010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000400000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd61f03c0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 524284
	.inst 0x387e419f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:12 00:00 opc:100 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xadc0282c // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:12 Rn:1 Rt2:01010 imm7:0000000 L:1 1011011:1011011 opc:10
	.inst 0x425fffdf // LDAR-C.R-C Ct:31 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c533a1 // CVTP-R.C-C Rd:1 Cn:29 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x387d789d // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:4 10:10 S:1 option:011 Rm:29 1:1 opc:01 111000:111000 size:00
	.inst 0xb8a1d8e4 // ldrsw_reg:aarch64/instrs/memory/single/general/register Rt:4 Rn:7 10:10 S:1 option:110 Rm:1 1:1 opc:10 111000:111000 size:10
	.inst 0xc2c0f020 // GCTYPE-R.C-C Rd:0 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xe21e9fe1 // ALDURSB-R.RI-32 Rt:1 Rn:31 op2:11 imm9:111101001 V:0 op1:00 11100010:11100010
	.inst 0xb49e5257 // cbz:aarch64/instrs/branch/conditional/compare Rt:23 imm19:1001111001010010010 op:0 011010:011010 sf:1
	.inst 0xc2c21260
	.zero 524248
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e4 // ldr c4, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400dec // ldr c12, [x15, #3]
	.inst 0xc24011f7 // ldr c23, [x15, #4]
	.inst 0xc24015fd // ldr c29, [x15, #5]
	.inst 0xc24019fe // ldr c30, [x15, #6]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085103f
	msr SCTLR_EL3, x15
	ldr x15, =0x8
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326f // ldr c15, [c19, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260126f // ldr c15, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x19, #0xf
	and x15, x15, x19
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f3 // ldr c19, [x15, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24005f3 // ldr c19, [x15, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24009f3 // ldr c19, [x15, #2]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc2400df3 // ldr c19, [x15, #3]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc24011f3 // ldr c19, [x15, #4]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc24015f3 // ldr c19, [x15, #5]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc24019f3 // ldr c19, [x15, #6]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2401df3 // ldr c19, [x15, #7]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x19, v10.d[0]
	cmp x15, x19
	b.ne comparison_fail
	ldr x15, =0x0
	mov x19, v10.d[1]
	cmp x15, x19
	b.ne comparison_fail
	ldr x15, =0x0
	mov x19, v12.d[0]
	cmp x15, x19
	b.ne comparison_fail
	ldr x15, =0x0
	mov x19, v12.d[1]
	cmp x15, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff8
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00410000
	ldr x1, =check_data3
	ldr x2, =0x00410020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00442080
	ldr x1, =check_data4
	ldr x2, =0x00442081
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x00480028
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff9
	ldr x1, =check_data6
	ldr x2, =0x004ffffa
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
