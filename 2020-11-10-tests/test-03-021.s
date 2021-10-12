.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x01, 0xb6, 0x5a, 0x82, 0x80, 0x01, 0x3f, 0xd6
.data
check_data4:
	.byte 0x36, 0x20, 0x6c, 0xe2, 0x01, 0xc1, 0xbf, 0x78, 0x1e, 0x10, 0xc0, 0xc2, 0xa3, 0xfa, 0xa0, 0x9b
	.byte 0x60, 0x30, 0xc7, 0xc2, 0xa1, 0x40, 0xbf, 0x38, 0x02, 0x39, 0x14, 0x33, 0xed, 0xb7, 0x0a, 0xa2
	.byte 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x230f0000008010000023
	/* C1 */
	.octa 0x1000
	/* C5 */
	.octa 0xc0000000403c016000000000000010c2
	/* C8 */
	.octa 0x800000004000c002000000000040cffc
	/* C12 */
	.octa 0x400040
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x1005
	/* C21 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x1
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000403c016000000000000010c2
	/* C8 */
	.octa 0x800000004000c002000000000040cffc
	/* C12 */
	.octa 0x400040
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x1005
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x4000000004070a8f0000000000001240
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000001c6300070000000000008001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x825ab601 // ASTRB-R.RI-B Rt:1 Rn:16 op:01 imm9:110101011 L:0 1000001001:1000001001
	.inst 0xd63f0180 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:12 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 56
	.inst 0xe26c2036 // ASTUR-V.RI-H Rt:22 Rn:1 op2:00 imm9:011000010 V:1 op1:01 11100010:11100010
	.inst 0x78bfc101 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:8 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc2c0101e // GCBASE-R.C-C Rd:30 Cn:0 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9ba0faa3 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:3 Rn:21 Ra:30 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0xc2c73060 // RRMASK-R.R-C Rd:0 Rn:3 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x38bf40a1 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:5 00:00 opc:100 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:00
	.inst 0x33143902 // bfm:aarch64/instrs/integer/bitfield Rd:2 Rn:8 imms:001110 immr:010100 N:0 100110:100110 opc:01 sf:0
	.inst 0xa20ab7ed // STR-C.RIAW-C Ct:13 Rn:31 01:01 imm9:010101011 0:0 opc:00 10100010:10100010
	.inst 0xc2c211e0
	.zero 1048476
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2400d28 // ldr c8, [x9, #3]
	.inst 0xc240112c // ldr c12, [x9, #4]
	.inst 0xc240152d // ldr c13, [x9, #5]
	.inst 0xc2401930 // ldr c16, [x9, #6]
	.inst 0xc2401d35 // ldr c21, [x9, #7]
	/* Vector registers */
	mrs x9, cptr_el3
	bfc x9, #10, #1
	msr cptr_el3, x9
	isb
	ldr q22, =0x1
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085103d
	msr SCTLR_EL3, x9
	ldr x9, =0xc
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031e9 // ldr c9, [c15, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826011e9 // ldr c9, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012f // ldr c15, [x9, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc240052f // ldr c15, [x9, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc240092f // ldr c15, [x9, #2]
	.inst 0xc2cfa461 // chkeq c3, c15
	b.ne comparison_fail
	.inst 0xc2400d2f // ldr c15, [x9, #3]
	.inst 0xc2cfa4a1 // chkeq c5, c15
	b.ne comparison_fail
	.inst 0xc240112f // ldr c15, [x9, #4]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc240152f // ldr c15, [x9, #5]
	.inst 0xc2cfa581 // chkeq c12, c15
	b.ne comparison_fail
	.inst 0xc240192f // ldr c15, [x9, #6]
	.inst 0xc2cfa5a1 // chkeq c13, c15
	b.ne comparison_fail
	.inst 0xc2401d2f // ldr c15, [x9, #7]
	.inst 0xc2cfa601 // chkeq c16, c15
	b.ne comparison_fail
	.inst 0xc240212f // ldr c15, [x9, #8]
	.inst 0xc2cfa6a1 // chkeq c21, c15
	b.ne comparison_fail
	.inst 0xc240252f // ldr c15, [x9, #9]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x9, =0x1
	mov x15, v22.d[0]
	cmp x9, x15
	b.ne comparison_fail
	ldr x9, =0x0
	mov x15, v22.d[1]
	cmp x9, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010c2
	ldr x1, =check_data0
	ldr x2, =0x000010c4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011b0
	ldr x1, =check_data1
	ldr x2, =0x000011b1
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001240
	ldr x1, =check_data2
	ldr x2, =0x00001250
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400008
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400040
	ldr x1, =check_data4
	ldr x2, =0x00400064
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040cffc
	ldr x1, =check_data5
	ldr x2, =0x0040cffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
