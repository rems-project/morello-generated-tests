.section data0, #alloc, #write
	.zero 2304
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
	.zero 1776
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0xc0, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x28, 0x46, 0xce, 0xc2, 0x46, 0x20, 0x31, 0xe2, 0xa5, 0x7f, 0xe1, 0xa2, 0x1e, 0x4c, 0x85, 0xe2
	.byte 0x43, 0x51, 0xc2, 0xc2
.data
check_data5:
	.byte 0x60, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0x02, 0xff, 0x5f, 0x48, 0xdf, 0x52, 0x3e, 0x38, 0x10, 0x90, 0x2a, 0xab, 0xfe, 0x48, 0xde, 0x82
	.byte 0x01, 0x61, 0xef, 0x36
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1cac
	/* C1 */
	.octa 0xffffdffe7fffffffffffffffffffffff
	/* C2 */
	.octa 0x2038
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x800000001ff980060000000000001000
	/* C10 */
	.octa 0x20000000014740000000000000408000
	/* C14 */
	.octa 0xffffffffffffffff
	/* C22 */
	.octa 0x1000
	/* C24 */
	.octa 0x1000
	/* C29 */
	.octa 0xdc000000000100050000000000001900
	/* C30 */
	.octa 0xc000c000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x1cac
	/* C1 */
	.octa 0x2001800000000000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x800000001ff980060000000000001000
	/* C10 */
	.octa 0x20000000014740000000000000408000
	/* C14 */
	.octa 0xffffffffffffffff
	/* C16 */
	.octa 0x1cac
	/* C22 */
	.octa 0x1000
	/* C24 */
	.octa 0x1000
	/* C29 */
	.octa 0xdc000000000100050000000000001900
	/* C30 */
	.octa 0x0
initial_RDDC_EL0_value:
	.octa 0xc0000000600200000000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000300070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001900
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 144
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword initial_RDDC_EL0_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2ce4628 // CSEAL-C.C-C Cd:8 Cn:17 001:001 opc:10 0:0 Cm:14 11000010110:11000010110
	.inst 0xe2312046 // ASTUR-V.RI-B Rt:6 Rn:2 op2:00 imm9:100010010 V:1 op1:00 11100010:11100010
	.inst 0xa2e17fa5 // CASA-C.R-C Ct:5 Rn:29 11111:11111 R:0 Cs:1 1:1 L:1 1:1 10100010:10100010
	.inst 0xe2854c1e // ASTUR-C.RI-C Ct:30 Rn:0 op2:11 imm9:001010100 V:0 op1:10 11100010:11100010
	.inst 0xc2c25143 // RETR-C-C 00011:00011 Cn:10 100:100 opc:10 11000010110000100:11000010110000100
	.zero 27676
	.inst 0xc2c21160
	.zero 5068
	.inst 0x485fff02 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:24 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x383e52df // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:101 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xab2a9010 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:16 Rn:0 imm3:100 option:100 Rm:10 01011001:01011001 S:1 op:0 sf:1
	.inst 0x82de48fe // ALDRSH-R.RRB-32 Rt:30 Rn:7 opc:10 S:0 option:010 Rm:30 0:0 L:1 100000101:100000101
	.inst 0x36ef6101 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:11101100001000 b40:11101 op:0 011011:011011 b5:0
	.zero 1015788
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
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e2 // ldr c2, [x15, #2]
	.inst 0xc2400de5 // ldr c5, [x15, #3]
	.inst 0xc24011e7 // ldr c7, [x15, #4]
	.inst 0xc24015ea // ldr c10, [x15, #5]
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2401df6 // ldr c22, [x15, #7]
	.inst 0xc24021f8 // ldr c24, [x15, #8]
	.inst 0xc24025fd // ldr c29, [x15, #9]
	.inst 0xc24029fe // ldr c30, [x15, #10]
	/* Vector registers */
	mrs x15, cptr_el3
	bfc x15, #10, #1
	msr cptr_el3, x15
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851037
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	ldr x15, =initial_RDDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28b432f // msr RDDC_EL0, c15
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260316f // ldr c15, [c11, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260116f // ldr c15, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
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
	mov x11, #0xf
	and x15, x15, x11
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001eb // ldr c11, [x15, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24005eb // ldr c11, [x15, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24009eb // ldr c11, [x15, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc24011eb // ldr c11, [x15, #4]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc24015eb // ldr c11, [x15, #5]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc24019eb // ldr c11, [x15, #6]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401deb // ldr c11, [x15, #7]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24021eb // ldr c11, [x15, #8]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc24025eb // ldr c11, [x15, #9]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc24029eb // ldr c11, [x15, #10]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402deb // ldr c11, [x15, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x11, v6.d[0]
	cmp x15, x11
	b.ne comparison_fail
	ldr x15, =0x0
	mov x11, v6.d[1]
	cmp x15, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001900
	ldr x1, =check_data1
	ldr x2, =0x00001910
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d00
	ldr x1, =check_data2
	ldr x2, =0x00001d10
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f4a
	ldr x1, =check_data3
	ldr x2, =0x00001f4b
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00406c30
	ldr x1, =check_data5
	ldr x2, =0x00406c34
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00408000
	ldr x1, =check_data6
	ldr x2, =0x00408014
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
