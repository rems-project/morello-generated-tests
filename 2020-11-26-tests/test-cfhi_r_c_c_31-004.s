.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x3c, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x05, 0x17, 0xc0, 0x5a, 0xcc, 0x6f, 0x59, 0xe2, 0x3a, 0x72, 0x81, 0xca, 0x60, 0xe8, 0x04, 0xa2
	.byte 0xaf, 0xff, 0xb9, 0x08, 0xf0, 0x53, 0xc1, 0xc2, 0xe0, 0xb7, 0x7e, 0x31, 0xfe, 0xab, 0x8f, 0xb8
	.byte 0x5d, 0x5c, 0x4e, 0x82, 0xd7, 0xd3, 0xc0, 0xc2, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1018
	/* C3 */
	.octa 0x4c000000004500070000000000000c60
	/* C15 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0xc000000020071007000000000000123c
	/* C30 */
	.octa 0x106c
final_cap_values:
	/* C0 */
	.octa 0xfaec02
	/* C2 */
	.octa 0x1018
	/* C3 */
	.octa 0x4c000000004500070000000000000c60
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0x8000000040000002
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0xc000000020071007000000000000123c
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000400000020000000000001c02
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010700030000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004501060400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac01705 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:5 Rn:24 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xe2596fcc // ALDURSH-R.RI-32 Rt:12 Rn:30 op2:11 imm9:110010110 V:0 op1:01 11100010:11100010
	.inst 0xca81723a // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:26 Rn:17 imm6:011100 Rm:1 N:0 shift:10 01010:01010 opc:10 sf:1
	.inst 0xa204e860 // STTR-C.RIB-C Ct:0 Rn:3 10:10 imm9:001001110 0:0 opc:00 10100010:10100010
	.inst 0x08b9ffaf // casb:aarch64/instrs/memory/atomicops/cas/single Rt:15 Rn:29 11111:11111 o0:1 Rs:25 1:1 L:0 0010001:0010001 size:00
	.inst 0xc2c153f0 // 0xc2c153f0
	.inst 0x317eb7e0 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:31 imm12:111110101101 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xb88fabfe // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:31 10:10 imm9:011111010 0:0 opc:10 111000:111000 size:10
	.inst 0x824e5c5d // ASTR-R.RI-64 Rt:29 Rn:2 op:11 imm9:011100101 L:0 1000001001:1000001001
	.inst 0xc2c0d3d7 // GCPERM-R.C-C Rd:23 Cn:30 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2c21100
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
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2400daf // ldr c15, [x13, #3]
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310d // ldr c13, [c8, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260110d // ldr c13, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
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
	mov x8, #0xf
	and x13, x13, x8
	cmp x13, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a8 // ldr c8, [x13, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24005a8 // ldr c8, [x13, #1]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc24009a8 // ldr c8, [x13, #2]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2400da8 // ldr c8, [x13, #3]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc24011a8 // ldr c8, [x13, #4]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc24015a8 // ldr c8, [x13, #5]
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	.inst 0xc24019a8 // ldr c8, [x13, #6]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2401da8 // ldr c8, [x13, #7]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc24021a8 // ldr c8, [x13, #8]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc24025a8 // ldr c8, [x13, #9]
	.inst 0xc2c8a7c1 // chkeq c30, c8
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
	ldr x0, =0x00001140
	ldr x1, =check_data1
	ldr x2, =0x00001150
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000123c
	ldr x1, =check_data2
	ldr x2, =0x0000123d
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001740
	ldr x1, =check_data3
	ldr x2, =0x00001748
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001cfc
	ldr x1, =check_data4
	ldr x2, =0x00001d00
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
