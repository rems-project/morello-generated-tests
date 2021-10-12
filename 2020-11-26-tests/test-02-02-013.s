.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0xf8, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x00, 0xf8
.data
check_data5:
	.byte 0xfd, 0xa3, 0x8b, 0xf8, 0xfd, 0x58, 0x01, 0x78, 0x01, 0x30, 0xc2, 0xc2, 0xaf, 0xa2, 0x5e, 0x7a
	.byte 0x39, 0x2c, 0x2c, 0x62, 0x9f, 0x52, 0x34, 0x38, 0xa0, 0xdb, 0x73, 0x38, 0xbe, 0x2f, 0x70, 0x82
	.byte 0x20, 0x80, 0xfd, 0xb8, 0x3f, 0xfc, 0x5f, 0x22, 0x00, 0x12, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd81000005aa408c40000000000001800
	/* C7 */
	.octa 0x40000000400411840000000000001fe1
	/* C11 */
	.octa 0xc000000000000000000000000000
	/* C19 */
	.octa 0xffbe1f3f
	/* C20 */
	.octa 0xc0000000000300070000000000001000
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x800000003ffb0007000000000041f800
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xd81000005aa408c40000000000001800
	/* C7 */
	.octa 0x40000000400411840000000000001fe1
	/* C11 */
	.octa 0xc000000000000000000000000000
	/* C19 */
	.octa 0xffbe1f3f
	/* C20 */
	.octa 0xc0000000000300070000000000001000
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x800000003ffb0007000000000041f800
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000050020009000000000041e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf88ba3fd // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:31 00:00 imm9:010111010 0:0 opc:10 111000:111000 size:11
	.inst 0x780158fd // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:7 10:10 imm9:000010101 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c23001 // CHKTGD-C-C 00001:00001 Cn:0 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x7a5ea2af // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1111 0:0 Rn:21 00:00 cond:1010 Rm:30 111010010:111010010 op:1 sf:0
	.inst 0x622c2c39 // STNP-C.RIB-C Ct:25 Rn:1 Ct2:01011 imm7:1011000 L:0 011000100:011000100
	.inst 0x3834529f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:101 o3:0 Rs:20 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x3873dba0 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:29 10:10 S:1 option:110 Rm:19 1:1 opc:01 111000:111000 size:00
	.inst 0x82702fbe // ALDR-R.RI-64 Rt:30 Rn:29 op:11 imm9:100000010 L:1 1000001001:1000001001
	.inst 0xb8fd8020 // swp:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:1 100000:100000 Rs:29 1:1 R:1 A:1 111000:111000 size:10
	.inst 0x225ffc3f // LDAXR-C.R-C Ct:31 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc2c21200
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400927 // ldr c7, [x9, #2]
	.inst 0xc2400d2b // ldr c11, [x9, #3]
	.inst 0xc2401133 // ldr c19, [x9, #4]
	.inst 0xc2401534 // ldr c20, [x9, #5]
	.inst 0xc2401939 // ldr c25, [x9, #6]
	.inst 0xc2401d3d // ldr c29, [x9, #7]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30851037
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603209 // ldr c9, [c16, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601209 // ldr c9, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	.inst 0xc2400130 // ldr c16, [x9, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400530 // ldr c16, [x9, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400930 // ldr c16, [x9, #2]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2400d30 // ldr c16, [x9, #3]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401130 // ldr c16, [x9, #4]
	.inst 0xc2d0a661 // chkeq c19, c16
	b.ne comparison_fail
	.inst 0xc2401530 // ldr c16, [x9, #5]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401930 // ldr c16, [x9, #6]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401d30 // ldr c16, [x9, #7]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402130 // ldr c16, [x9, #8]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x00001580
	ldr x1, =check_data1
	ldr x2, =0x000015a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000173f
	ldr x1, =check_data2
	ldr x2, =0x00001740
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff6
	ldr x1, =check_data4
	ldr x2, =0x00001ff8
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
	ldr x0, =0x00420010
	ldr x1, =check_data6
	ldr x2, =0x00420018
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
