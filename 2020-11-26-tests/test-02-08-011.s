.section data0, #alloc, #write
	.byte 0xc4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xc4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x00, 0x07, 0x08, 0x00, 0x00, 0x00, 0xc0
.data
check_data3:
	.byte 0x23, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x65, 0xa2, 0x81, 0xd8, 0x89, 0x05, 0x1d, 0x1b, 0xef, 0x1f, 0xcb, 0x38, 0xb0, 0x54, 0x0d, 0xe2
	.byte 0x20, 0x73, 0xe9, 0xf0, 0xbf, 0x33, 0x7d, 0x38, 0x1d, 0xd5, 0x28, 0xc2, 0xff, 0x93, 0xc0, 0xc2
	.byte 0xdf, 0x73, 0xc3, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C5 */
	.octa 0x1000
	/* C8 */
	.octa 0x4c00000000030005ffffffffffff6e50
	/* C17 */
	.octa 0x2000000000010007000000000040fff5
	/* C29 */
	.octa 0xc0000000080700460000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x2000000000010007ffffffffd3277000
	/* C5 */
	.octa 0x1000
	/* C8 */
	.octa 0x4c00000000030005ffffffffffff6e50
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x2000000000010007000000000040fff5
	/* C29 */
	.octa 0xc0000000080700460000000000001000
	/* C30 */
	.octa 0x0
initial_RDDC_EL0_value:
	.octa 0x800000001007000f0000000000000001
initial_RSP_EL0_value:
	.octa 0x800000000007800b000000000047ffe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_RDDC_EL0_value
	.dword initial_RSP_EL0_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c21223 // BRR-C-C 00011:00011 Cn:17 100:100 opc:00 11000010110000100:11000010110000100
	.zero 65520
	.inst 0xd881a265 // prfm_lit:aarch64/instrs/memory/literal/general Rt:5 imm19:1000000110100010011 011000:011000 opc:11
	.inst 0x1b1d0589 // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:9 Rn:12 Ra:1 o0:0 Rm:29 0011011000:0011011000 sf:0
	.inst 0x38cb1fef // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:15 Rn:31 11:11 imm9:010110001 0:0 opc:11 111000:111000 size:00
	.inst 0xe20d54b0 // ALDURB-R.RI-32 Rt:16 Rn:5 op2:01 imm9:011010101 V:0 op1:00 11100010:11100010
	.inst 0xf0e97320 // ADRP-C.I-C Rd:0 immhi:110100101110011001 P:1 10000:10000 immlo:11 op:1
	.inst 0x387d33bf // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc228d51d // STR-C.RIB-C Ct:29 Rn:8 imm12:101000110101 L:0 110000100:110000100
	.inst 0xc2c093ff // GCTAG-R.C-C Rd:31 Cn:31 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xc2c373df // SEAL-C.CI-C Cd:31 Cn:30 100:100 form:11 11000010110000110:11000010110000110
	.inst 0xc2c21320
	.zero 983012
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a5 // ldr c5, [x21, #0]
	.inst 0xc24006a8 // ldr c8, [x21, #1]
	.inst 0xc2400ab1 // ldr c17, [x21, #2]
	.inst 0xc2400ebd // ldr c29, [x21, #3]
	.inst 0xc24012be // ldr c30, [x21, #4]
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103d
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	ldr x21, =initial_RDDC_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28b4335 // msr RDDC_EL0, c21
	ldr x21, =initial_RSP_EL0_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc28f4175 // msr RSP_EL0, c21
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601335 // ldr c21, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b9 // ldr c25, [x21, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24006b9 // ldr c25, [x21, #1]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2400ab9 // ldr c25, [x21, #2]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2400eb9 // ldr c25, [x21, #3]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc24012b9 // ldr c25, [x21, #4]
	.inst 0xc2d9a601 // chkeq c16, c25
	b.ne comparison_fail
	.inst 0xc24016b9 // ldr c25, [x21, #5]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc2401ab9 // ldr c25, [x21, #6]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc2401eb9 // ldr c25, [x21, #7]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010dd
	ldr x1, =check_data1
	ldr x2, =0x000010de
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011a0
	ldr x1, =check_data2
	ldr x2, =0x000011b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400004
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040fff4
	ldr x1, =check_data4
	ldr x2, =0x0041001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480091
	ldr x1, =check_data5
	ldr x2, =0x00480092
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
