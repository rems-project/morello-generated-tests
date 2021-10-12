.section data0, #alloc, #write
	.zero 1024
	.byte 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3056
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xbf, 0x32, 0x7e, 0x38, 0x5a, 0x5c, 0x69, 0x69, 0xfe, 0xc3, 0xc7, 0xc2, 0x7d, 0x92, 0x99, 0x78
	.byte 0x21, 0x58, 0xe1, 0xc2, 0xc1, 0x85, 0xc0, 0xc2, 0xcf, 0xa5, 0x15, 0xd0, 0xf3, 0x6b, 0xeb, 0x82
	.byte 0x11, 0x01, 0x11, 0xfa, 0x01, 0xb0, 0xdb, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0xc0, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x90100000100100050000000000001630
	/* C1 */
	.octa 0x4029fff0090000000000001
	/* C2 */
	.octa 0x2004
	/* C11 */
	.octa 0x4678f0
	/* C14 */
	.octa 0x6fefc0000082a0970000000000000001
	/* C19 */
	.octa 0x401001
	/* C21 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x90100000100100050000000000001630
	/* C1 */
	.octa 0x4029fff0090000000000001
	/* C2 */
	.octa 0x2004
	/* C11 */
	.octa 0x4678f0
	/* C14 */
	.octa 0x6fefc0000082a0970000000000000001
	/* C15 */
	.octa 0x2b8b9000
	/* C19 */
	.octa 0x401001
	/* C21 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000a00600170000000000400028
initial_SP_EL3_value:
	.octa 0x800000000000c0000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200600170000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001400
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x387e32bf // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:011 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x69695c5a // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:26 Rn:2 Rt2:10111 imm7:1010010 L:1 1010010:1010010 opc:01
	.inst 0xc2c7c3fe // CVT-R.CC-C Rd:30 Cn:31 110000:110000 Cm:7 11000010110:11000010110
	.inst 0x7899927d // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:19 00:00 imm9:110011001 0:0 opc:10 111000:111000 size:01
	.inst 0xc2e15821 // CVTZ-C.CR-C Cd:1 Cn:1 0110:0110 1:1 0:0 Rm:1 11000010111:11000010111
	.inst 0xc2c085c1 // CHKSS-_.CC-C 00001:00001 Cn:14 001:001 opc:00 1:1 Cm:0 11000010110:11000010110
	.inst 0xd015a5cf // ADRP-C.I-C Rd:15 immhi:001010110100101110 P:0 10000:10000 immlo:10 op:1
	.inst 0x82eb6bf3 // ALDR-V.RRB-D Rt:19 Rn:31 opc:10 S:0 option:011 Rm:11 1:1 L:1 100000101:100000101
	.inst 0xfa110111 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:8 000000:000000 Rm:17 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2dbb001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:1011101 110000101101:110000101101
	.zero 32728
	.inst 0xc2c212c0
	.zero 1015804
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400942 // ldr c2, [x10, #2]
	.inst 0xc2400d4b // ldr c11, [x10, #3]
	.inst 0xc240114e // ldr c14, [x10, #4]
	.inst 0xc2401553 // ldr c19, [x10, #5]
	.inst 0xc2401955 // ldr c21, [x10, #6]
	.inst 0xc2401d5e // ldr c30, [x10, #7]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	ldr x10, =0x88
	msr S3_6_C1_C2_2, x10 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032ca // ldr c10, [c22, #3]
	.inst 0xc28b412a // msr DDC_EL3, c10
	isb
	.inst 0x826012ca // ldr c10, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400156 // ldr c22, [x10, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400556 // ldr c22, [x10, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400956 // ldr c22, [x10, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400d56 // ldr c22, [x10, #3]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401156 // ldr c22, [x10, #4]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401956 // ldr c22, [x10, #6]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2402156 // ldr c22, [x10, #8]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2402556 // ldr c22, [x10, #9]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402956 // ldr c22, [x10, #10]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402d56 // ldr c22, [x10, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x10, =0x0
	mov x22, v19.d[0]
	cmp x10, x22
	b.ne comparison_fail
	ldr x10, =0x0
	mov x22, v19.d[1]
	cmp x10, x22
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f4c
	ldr x1, =check_data2
	ldr x2, =0x00001f54
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400f9a
	ldr x1, =check_data4
	ldr x2, =0x00400f9c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00408000
	ldr x1, =check_data5
	ldr x2, =0x00408004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004678f0
	ldr x1, =check_data6
	ldr x2, =0x004678f8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
