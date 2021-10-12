.section data0, #alloc, #write
	.zero 64
	.byte 0x77, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x60, 0x06, 0x00, 0x08, 0x01, 0x00, 0x00
	.zero 4016
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
	.byte 0x77, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x60, 0x06, 0x00, 0x08, 0x01, 0x00, 0x00
.data
check_data2:
	.zero 16
	.byte 0x40, 0x00
.data
check_data3:
	.byte 0xbe, 0xe3, 0xc1, 0xc2, 0x08, 0x05, 0x7a, 0x62, 0x3e, 0xd4, 0xbb, 0x02, 0xb0, 0x44, 0x25, 0xb6
	.byte 0x5c, 0x82, 0x64, 0x78, 0x5e, 0x7c, 0xdf, 0x48, 0xf4, 0x1b, 0xdc, 0xa8, 0xdf, 0x6c, 0x26, 0xe2
	.byte 0xbe, 0xff, 0xe4, 0xc2, 0x51, 0x08, 0xdb, 0x9a, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000500a00020000000000400040
	/* C4 */
	.octa 0x3fff9bd5f800040
	/* C8 */
	.octa 0x801000000086000300000000000010f0
	/* C16 */
	.octa 0x1000000000
	/* C18 */
	.octa 0xc000000000c180060000000000001080
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000c000642a07fffc00
final_cap_values:
	/* C1 */
	.octa 0x108000660070000000000000077
	/* C2 */
	.octa 0x80000000500a00020000000000400040
	/* C4 */
	.octa 0x3fff9bd5f800040
	/* C6 */
	.octa 0xa
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x1000000000
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0xc000000000c180060000000000001080
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000c000642a07fffc00
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000580488050000000000409008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000001007010300fffffffffe0001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001030
	.dword 0x0000000000001040
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1e3be // SCFLGS-C.CR-C Cd:30 Cn:29 111000:111000 Rm:1 11000010110:11000010110
	.inst 0x627a0508 // LDNP-C.RIB-C Ct:8 Rn:8 Ct2:00001 imm7:1110100 L:1 011000100:011000100
	.inst 0x02bbd43e // SUB-C.CIS-C Cd:30 Cn:1 imm12:111011110101 sh:0 A:1 00000010:00000010
	.inst 0xb62544b0 // tbz:aarch64/instrs/branch/conditional/test Rt:16 imm14:10101000100101 b40:00100 op:0 011011:011011 b5:1
	.inst 0x7864825c // swph:aarch64/instrs/memory/atomicops/swp Rt:28 Rn:18 100000:100000 Rs:4 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x48df7c5e // ldlarh:aarch64/instrs/memory/ordered Rt:30 Rn:2 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xa8dc1bf4 // ldp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:20 Rn:31 Rt2:00110 imm7:0111000 L:1 1010001:1010001 opc:10
	.inst 0xe2266cdf // ALDUR-V.RI-Q Rt:31 Rn:6 op2:11 imm9:001100110 V:1 op1:00 11100010:11100010
	.inst 0xc2e4ffbe // ALDR-C.RRB-C Ct:30 Rn:29 1:1 L:1 S:1 option:111 Rm:4 11000010111:11000010111
	.inst 0x9adb0851 // udiv:aarch64/instrs/integer/arithmetic/div Rd:17 Rn:2 o1:0 00001:00001 Rm:27 0011010110:0011010110 sf:1
	.inst 0xc2c211c0
	.zero 36836
	.inst 0x0000000a
	.zero 1011692
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400584 // ldr c4, [x12, #1]
	.inst 0xc2400988 // ldr c8, [x12, #2]
	.inst 0xc2400d90 // ldr c16, [x12, #3]
	.inst 0xc2401192 // ldr c18, [x12, #4]
	.inst 0xc240159b // ldr c27, [x12, #5]
	.inst 0xc240199d // ldr c29, [x12, #6]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031cc // ldr c12, [c14, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x826011cc // ldr c12, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240018e // ldr c14, [x12, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240058e // ldr c14, [x12, #1]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc240098e // ldr c14, [x12, #2]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc2400d8e // ldr c14, [x12, #3]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc240118e // ldr c14, [x12, #4]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc240158e // ldr c14, [x12, #5]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc240198e // ldr c14, [x12, #6]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc2401d8e // ldr c14, [x12, #7]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240218e // ldr c14, [x12, #8]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc240258e // ldr c14, [x12, #9]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc240298e // ldr c14, [x12, #10]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc2402d8e // ldr c14, [x12, #11]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240318e // ldr c14, [x12, #12]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x14, v31.d[0]
	cmp x12, x14
	b.ne comparison_fail
	ldr x12, =0x0
	mov x14, v31.d[1]
	cmp x12, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001070
	ldr x1, =check_data2
	ldr x2, =0x00001082
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
	ldr x0, =0x00400040
	ldr x1, =check_data4
	ldr x2, =0x00400042
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00409008
	ldr x1, =check_data5
	ldr x2, =0x00409018
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
