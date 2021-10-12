.section data0, #alloc, #write
	.zero 3536
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 336
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data3:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data4:
	.byte 0x5f, 0x37, 0x03, 0xd5, 0xc5, 0x23, 0x10, 0x12, 0x3b, 0x05, 0xb4, 0x9b, 0xdd, 0x90, 0x7f, 0xc8
	.byte 0xfe, 0x9b, 0x41, 0xb8, 0x58, 0x58, 0xfe, 0xc2, 0x1d, 0xb8, 0x43, 0x38, 0xdf, 0xaf, 0x4e, 0xa2
	.byte 0x80, 0xff, 0xdf, 0x48, 0x40, 0xe1, 0x9e, 0x5a, 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1004
	/* C2 */
	.octa 0x800100040000000000000000
	/* C6 */
	.octa 0x1e90
	/* C28 */
	.octa 0x1002
final_cap_values:
	/* C2 */
	.octa 0x800100040000000000000000
	/* C4 */
	.octa 0x0
	/* C6 */
	.octa 0x1e90
	/* C24 */
	.octa 0x800100040000000000001000
	/* C28 */
	.octa 0x1002
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1ea0
initial_SP_EL3_value:
	.octa 0x1dbf
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000620070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x900000006079000c00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001ea0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd503375f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0111 11010101000000110011:11010101000000110011
	.inst 0x121023c5 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:5 Rn:30 imms:001000 immr:010000 N:0 100100:100100 opc:00 sf:0
	.inst 0x9bb4053b // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:27 Rn:9 Ra:1 o0:0 Rm:20 01:01 U:1 10011011:10011011
	.inst 0xc87f90dd // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:6 Rt2:00100 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xb8419bfe // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:31 10:10 imm9:000011001 0:0 opc:01 111000:111000 size:10
	.inst 0xc2fe5858 // CVTZ-C.CR-C Cd:24 Cn:2 0110:0110 1:1 0:0 Rm:30 11000010111:11000010111
	.inst 0x3843b81d // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:0 10:10 imm9:000111011 0:0 opc:01 111000:111000 size:00
	.inst 0xa24eafdf // LDR-C.RIBW-C Ct:31 Rn:30 11:11 imm9:011101010 0:0 opc:01 10100010:10100010
	.inst 0x48dfff80 // ldarh:aarch64/instrs/memory/ordered Rt:0 Rn:28 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x5a9ee140 // csinv:aarch64/instrs/integer/conditional/select Rd:0 Rn:10 o2:0 0:0 cond:1110 Rm:30 011010100:011010100 op:1 sf:0
	.inst 0xc2c21260
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400dfc // ldr c28, [x15, #3]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x0
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
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001f3 // ldr c19, [x15, #0]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc24005f3 // ldr c19, [x15, #1]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc24009f3 // ldr c19, [x15, #2]
	.inst 0xc2d3a4c1 // chkeq c6, c19
	b.ne comparison_fail
	.inst 0xc2400df3 // ldr c19, [x15, #3]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc24011f3 // ldr c19, [x15, #4]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc24015f3 // ldr c19, [x15, #5]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc24019f3 // ldr c19, [x15, #6]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103f
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001dd8
	ldr x1, =check_data2
	ldr x2, =0x00001ddc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e90
	ldr x1, =check_data3
	ldr x2, =0x00001eb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
