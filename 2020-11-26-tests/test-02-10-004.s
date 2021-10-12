.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xc1, 0xdc, 0x52, 0xa2, 0x92, 0x41, 0x4a, 0x79, 0x9e, 0x3e, 0x14, 0x31, 0xa0, 0xb3, 0xc5, 0xc2
	.byte 0x7d, 0xda, 0x7e, 0x78, 0x3e, 0x48, 0x20, 0x2b, 0xe2, 0x31, 0xc2, 0xc2, 0x7e, 0x68, 0x96, 0x38
	.byte 0xee, 0x57, 0x16, 0x78, 0x42, 0x8b, 0x09, 0xe2, 0x60, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 3
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x80000000000100050000000000500098
	/* C6 */
	.octa 0x4e0e00
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x2000800040010009000000000040001d
	/* C19 */
	.octa 0x4ffffc
	/* C20 */
	.octa 0xfffffaf1
	/* C26 */
	.octa 0x403f66
	/* C29 */
	.octa 0x7fffffffff0020
final_cap_values:
	/* C0 */
	.octa 0x200080000007000700800000003f0020
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x80000000000100050000000000500098
	/* C6 */
	.octa 0x4e00d0
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x2000800040010009000000000040001d
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x4ffffc
	/* C20 */
	.octa 0xfffffaf1
	/* C26 */
	.octa 0x403f66
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000000007000500000000000017f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa252dcc1 // LDR-C.RIBW-C Ct:1 Rn:6 11:11 imm9:100101101 0:0 opc:01 10100010:10100010
	.inst 0x794a4192 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:18 Rn:12 imm12:001010010000 opc:01 111001:111001 size:01
	.inst 0x31143e9e // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:20 imm12:010100001111 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xc2c5b3a0 // CVTP-C.R-C Cd:0 Rn:29 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x787eda7d // ldrh_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:19 10:10 S:1 option:110 Rm:30 1:1 opc:01 111000:111000 size:01
	.inst 0x2b20483e // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:1 imm3:010 option:010 Rm:0 01011001:01011001 S:1 op:0 sf:0
	.inst 0xc2c231e2 // BLRS-C-C 00010:00010 Cn:15 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x3896687e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:3 10:10 imm9:101100110 0:0 opc:10 111000:111000 size:00
	.inst 0x781657ee // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:14 Rn:31 01:01 imm9:101100101 0:0 opc:00 111000:111000 size:01
	.inst 0xe2098b42 // ALDURSB-R.RI-64 Rt:2 Rn:26 op2:10 imm9:010011000 V:0 op1:00 11100010:11100010
	.inst 0xc2c21160
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e3 // ldr c3, [x7, #0]
	.inst 0xc24004e6 // ldr c6, [x7, #1]
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc24010ef // ldr c15, [x7, #4]
	.inst 0xc24014f3 // ldr c19, [x7, #5]
	.inst 0xc24018f4 // ldr c20, [x7, #6]
	.inst 0xc2401cfa // ldr c26, [x7, #7]
	.inst 0xc24020fd // ldr c29, [x7, #8]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x3085103f
	msr SCTLR_EL3, x7
	ldr x7, =0x8
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603167 // ldr c7, [c11, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601167 // ldr c7, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x11, #0xf
	and x7, x7, x11
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000eb // ldr c11, [x7, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24004eb // ldr c11, [x7, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24008eb // ldr c11, [x7, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400ceb // ldr c11, [x7, #3]
	.inst 0xc2cba461 // chkeq c3, c11
	b.ne comparison_fail
	.inst 0xc24010eb // ldr c11, [x7, #4]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc24014eb // ldr c11, [x7, #5]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc24018eb // ldr c11, [x7, #6]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401ceb // ldr c11, [x7, #7]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc24020eb // ldr c11, [x7, #8]
	.inst 0xc2cba641 // chkeq c18, c11
	b.ne comparison_fail
	.inst 0xc24024eb // ldr c11, [x7, #9]
	.inst 0xc2cba661 // chkeq c19, c11
	b.ne comparison_fail
	.inst 0xc24028eb // ldr c11, [x7, #10]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2402ceb // ldr c11, [x7, #11]
	.inst 0xc2cba741 // chkeq c26, c11
	b.ne comparison_fail
	.inst 0xc24030eb // ldr c11, [x7, #12]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24034eb // ldr c11, [x7, #13]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001520
	ldr x1, =check_data0
	ldr x2, =0x00001522
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017f0
	ldr x1, =check_data1
	ldr x2, =0x000017f2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00403ffe
	ldr x1, =check_data3
	ldr x2, =0x00403fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004e00d0
	ldr x1, =check_data4
	ldr x2, =0x004e00e0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
