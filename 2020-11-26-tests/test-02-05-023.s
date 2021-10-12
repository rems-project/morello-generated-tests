.section data0, #alloc, #write
	.zero 4064
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 16
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x1d, 0x61, 0x1d, 0x33, 0xdf, 0x31, 0xc5, 0xc2, 0xbd, 0x58, 0x1c, 0x9b, 0x5b, 0x5d, 0x2e, 0xe2
	.byte 0xa5, 0x06, 0x3e, 0x4b, 0xe0, 0x63, 0x3e, 0x4b, 0xd5, 0xc3, 0xbf, 0x78, 0xe8, 0x0d, 0xc0, 0x1a
	.byte 0xfe, 0xfa, 0x78, 0xc2, 0x9f, 0xfe, 0x10, 0x22, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x4c171b
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x400000000001000500000000004fffe0
	/* C23 */
	.octa 0x9010000000050007ffffffffffff3c00
	/* C30 */
	.octa 0x8000000000010005000000000046d8fc
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x4c171b
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x1
	/* C20 */
	.octa 0x400000000001000500000000004fffe0
	/* C21 */
	.octa 0xc2c2
	/* C23 */
	.octa 0x9010000000050007ffffffffffff3c00
	/* C30 */
	.octa 0xc2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
initial_SP_EL3_value:
	.octa 0x46d8fc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x331d611d // bfm:aarch64/instrs/integer/bitfield Rd:29 Rn:8 imms:011000 immr:011101 N:0 100110:100110 opc:01 sf:0
	.inst 0xc2c531df // CVTP-R.C-C Rd:31 Cn:14 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x9b1c58bd // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:5 Ra:22 o0:0 Rm:28 0011011000:0011011000 sf:1
	.inst 0xe22e5d5b // ALDUR-V.RI-Q Rt:27 Rn:10 op2:11 imm9:011100101 V:1 op1:00 11100010:11100010
	.inst 0x4b3e06a5 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:5 Rn:21 imm3:001 option:000 Rm:30 01011001:01011001 S:0 op:1 sf:0
	.inst 0x4b3e63e0 // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:0 Rn:31 imm3:000 option:011 Rm:30 01011001:01011001 S:0 op:1 sf:0
	.inst 0x78bfc3d5 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:21 Rn:30 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x1ac00de8 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:8 Rn:15 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:0
	.inst 0xc278fafe // LDR-C.RIB-C Ct:30 Rn:23 imm12:111000111110 L:1 110000100:110000100
	.inst 0x2210fe9f // STLXR-R.CR-C Ct:31 Rn:20 (1)(1)(1)(1)(1):11111 1:1 Rs:16 0:0 L:0 001000100:001000100
	.inst 0xc2c210e0
	.zero 448720
	.inst 0x0000c2c2
	.zero 343808
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 255952
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 16
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
	.inst 0xc24001aa // ldr c10, [x13, #0]
	.inst 0xc24005ae // ldr c14, [x13, #1]
	.inst 0xc24009b4 // ldr c20, [x13, #2]
	.inst 0xc2400db7 // ldr c23, [x13, #3]
	.inst 0xc24011be // ldr c30, [x13, #4]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ed // ldr c13, [c7, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826010ed // ldr c13, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xf
	and x13, x13, x7
	cmp x13, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a7 // ldr c7, [x13, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005a7 // ldr c7, [x13, #1]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24009a7 // ldr c7, [x13, #2]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2400da7 // ldr c7, [x13, #3]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc24011a7 // ldr c7, [x13, #4]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc24015a7 // ldr c7, [x13, #5]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc24019a7 // ldr c7, [x13, #6]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2401da7 // ldr c7, [x13, #7]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc24021a7 // ldr c7, [x13, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0xc2c2c2c2c2c2c2c2
	mov x7, v27.d[0]
	cmp x13, x7
	b.ne comparison_fail
	ldr x13, =0xc2c2c2c2c2c2c2c2
	mov x7, v27.d[1]
	cmp x13, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001ff0
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
	ldr x0, =0x0046d8fc
	ldr x1, =check_data2
	ldr x2, =0x0046d8fe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004c1800
	ldr x1, =check_data3
	ldr x2, =0x004c1810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004fffe0
	ldr x1, =check_data4
	ldr x2, =0x004ffff0
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
