.section data0, #alloc, #write
	.byte 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2064
	.byte 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2000
.data
check_data0:
	.byte 0x12
.data
check_data1:
	.byte 0x80
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xc0
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x04, 0xb0, 0xc5, 0xc2, 0x9e, 0x5b, 0xea, 0xc2, 0xdf, 0x51, 0x7f, 0x38, 0x09, 0x70, 0x3d, 0x38
	.byte 0x62, 0x52, 0xc2, 0xc2
.data
check_data7:
	.byte 0x1a, 0x94, 0xba, 0x29, 0xbe, 0x7f, 0x9f, 0x88, 0x5f, 0x42, 0x20, 0x38, 0x1f, 0xbd, 0x1c, 0x7c
	.byte 0x1f, 0x50, 0x26, 0xb8, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000080080000000000001820
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000
	/* C8 */
	.octa 0x40000000000100050000000000002005
	/* C10 */
	.octa 0x200000000000000
	/* C14 */
	.octa 0x1008
	/* C18 */
	.octa 0xc0000000500400020000000000001000
	/* C19 */
	.octa 0x20008000800180060000000000400021
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x10000200020080000000000001
	/* C29 */
	.octa 0x40000000000100050000000000001cc0
final_cap_values:
	/* C0 */
	.octa 0xc00000000000800800000000000017f4
	/* C4 */
	.octa 0x20008000000080080000000000001820
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000
	/* C8 */
	.octa 0x40000000000100050000000000001fd0
	/* C9 */
	.octa 0xc0
	/* C10 */
	.octa 0x200000000000000
	/* C14 */
	.octa 0x1008
	/* C18 */
	.octa 0xc0000000500400020000000000001000
	/* C19 */
	.octa 0x20008000800180060000000000400021
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x10000200020080000000000001
	/* C29 */
	.octa 0x40000000000100050000000000001cc0
	/* C30 */
	.octa 0x10000200020200000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 160
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c5b004 // CVTP-C.R-C Cd:4 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2ea5b9e // CVTZ-C.CR-C Cd:30 Cn:28 0110:0110 1:1 0:0 Rm:10 11000010111:11000010111
	.inst 0x387f51df // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:14 00:00 opc:101 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x383d7009 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:0 00:00 opc:111 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc2c25262 // RETS-C-C 00010:00010 Cn:19 100:100 opc:10 11000010110000100:11000010110000100
	.zero 12
	.inst 0x29ba941a // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:26 Rn:0 Rt2:00101 imm7:1110101 L:0 1010011:1010011 opc:00
	.inst 0x889f7fbe // stllr:aarch64/instrs/memory/ordered Rt:30 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x3820425f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:100 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x7c1cbd1f // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:31 Rn:8 11:11 imm9:111001011 0:0 opc:00 111100:111100 size:01
	.inst 0xb826501f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:101 o3:0 Rs:6 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c212a0
	.zero 1048520
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
	.inst 0xc24005e5 // ldr c5, [x15, #1]
	.inst 0xc24009e6 // ldr c6, [x15, #2]
	.inst 0xc2400de8 // ldr c8, [x15, #3]
	.inst 0xc24011ea // ldr c10, [x15, #4]
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc24019f2 // ldr c18, [x15, #6]
	.inst 0xc2401df3 // ldr c19, [x15, #7]
	.inst 0xc24021fa // ldr c26, [x15, #8]
	.inst 0xc24025fc // ldr c28, [x15, #9]
	.inst 0xc24029fd // ldr c29, [x15, #10]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x8
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032af // ldr c15, [c21, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x826012af // ldr c15, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
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
	.inst 0xc24001f5 // ldr c21, [x15, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005f5 // ldr c21, [x15, #1]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc24009f5 // ldr c21, [x15, #2]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2400df5 // ldr c21, [x15, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24011f5 // ldr c21, [x15, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc24019f5 // ldr c21, [x15, #6]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401df5 // ldr c21, [x15, #7]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc24021f5 // ldr c21, [x15, #8]
	.inst 0xc2d5a641 // chkeq c18, c21
	b.ne comparison_fail
	.inst 0xc24025f5 // ldr c21, [x15, #9]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc24029f5 // ldr c21, [x15, #10]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402df5 // ldr c21, [x15, #11]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24031f5 // ldr c21, [x15, #12]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc24035f5 // ldr c21, [x15, #13]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x21, v31.d[0]
	cmp x15, x21
	b.ne comparison_fail
	ldr x15, =0x0
	mov x21, v31.d[1]
	cmp x15, x21
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
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x00001009
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f4
	ldr x1, =check_data2
	ldr x2, =0x000017fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001820
	ldr x1, =check_data3
	ldr x2, =0x00001821
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001cc0
	ldr x1, =check_data4
	ldr x2, =0x00001cc4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fd0
	ldr x1, =check_data5
	ldr x2, =0x00001fd2
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400020
	ldr x1, =check_data7
	ldr x2, =0x00400038
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
