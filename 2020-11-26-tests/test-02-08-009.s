.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0xde, 0x00, 0x40, 0x00
.data
check_data1:
	.byte 0x00, 0x30
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x80
.data
check_data5:
	.byte 0x1e, 0xc0, 0x0c, 0x39, 0x1d, 0x60, 0x7d, 0x78, 0xd5, 0x3f, 0x34, 0xc8, 0x3f, 0xcc, 0xd5, 0x38
	.byte 0x00, 0xa0, 0xae, 0xe2, 0xe0, 0x73, 0xc2, 0xc2, 0xcc, 0xed, 0x9d, 0x82, 0x32, 0x81, 0x65, 0xa2
	.byte 0xc8, 0x52, 0xdf, 0x82, 0x93, 0x81, 0x61, 0xb8, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
check_data7:
	.zero 16
.data
check_data8:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000400410000000000000001006
	/* C1 */
	.octa 0x80000000100700c70000000000400182
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x1080
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x4000000000470047ffffffffffffe000
	/* C22 */
	.octa 0x80000000000500470000000000400c05
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000000c0000000000000400580
final_cap_values:
	/* C0 */
	.octa 0xc0000000400410000000000000001006
	/* C1 */
	.octa 0x80000000100700c700000000004000de
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x1080
	/* C12 */
	.octa 0x1000
	/* C14 */
	.octa 0x4000000000470047ffffffffffffe000
	/* C18 */
	.octa 0x800000000000000000000000
	/* C19 */
	.octa 0x1000
	/* C20 */
	.octa 0x1
	/* C22 */
	.octa 0x80000000000500470000000000400c05
	/* C29 */
	.octa 0x3000
	/* C30 */
	.octa 0x400000000000c0000000000000400580
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000003782070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xdc0000006102000400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x390cc01e // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:0 imm12:001100110000 opc:00 111001:111001 size:00
	.inst 0x787d601d // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:110 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc8343fd5 // stxp:aarch64/instrs/memory/exclusive/pair Rt:21 Rn:30 Rt2:01111 o0:0 Rs:20 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x38d5cc3f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:1 11:11 imm9:101011100 0:0 opc:11 111000:111000 size:00
	.inst 0xe2aea000 // ASTUR-V.RI-S Rt:0 Rn:0 op2:00 imm9:011101010 V:1 op1:10 11100010:11100010
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0x829dedcc // ASTRH-R.RRB-32 Rt:12 Rn:14 opc:11 S:0 option:111 Rm:29 0:0 L:0 100000101:100000101
	.inst 0xa2658132 // SWPL-CC.R-C Ct:18 Rn:9 100000:100000 Cs:5 1:1 R:1 A:0 10100010:10100010
	.inst 0x82df52c8 // ALDRB-R.RRB-B Rt:8 Rn:22 opc:00 S:1 option:010 Rm:31 0:0 L:1 100000101:100000101
	.inst 0xb8618193 // swp:aarch64/instrs/memory/atomicops/swp Rt:19 Rn:12 100000:100000 Rs:1 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xc2c211a0
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b85 // ldr c5, [x28, #2]
	.inst 0xc2400f89 // ldr c9, [x28, #3]
	.inst 0xc240138c // ldr c12, [x28, #4]
	.inst 0xc240178e // ldr c14, [x28, #5]
	.inst 0xc2401b96 // ldr c22, [x28, #6]
	.inst 0xc2401f9d // ldr c29, [x28, #7]
	.inst 0xc240239e // ldr c30, [x28, #8]
	/* Vector registers */
	mrs x28, cptr_el3
	bfc x28, #10, #1
	msr cptr_el3, x28
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031bc // ldr c28, [c13, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826011bc // ldr c28, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038d // ldr c13, [x28, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240078d // ldr c13, [x28, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400b8d // ldr c13, [x28, #2]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc2400f8d // ldr c13, [x28, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240138d // ldr c13, [x28, #4]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc240178d // ldr c13, [x28, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc2401b8d // ldr c13, [x28, #6]
	.inst 0xc2cda5c1 // chkeq c14, c13
	b.ne comparison_fail
	.inst 0xc2401f8d // ldr c13, [x28, #7]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240238d // ldr c13, [x28, #8]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc240278d // ldr c13, [x28, #9]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc2402b8d // ldr c13, [x28, #10]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc2402f8d // ldr c13, [x28, #11]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240338d // ldr c13, [x28, #12]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x13, v0.d[0]
	cmp x28, x13
	b.ne comparison_fail
	ldr x28, =0x0
	mov x13, v0.d[1]
	cmp x28, x13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001090
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010f0
	ldr x1, =check_data3
	ldr x2, =0x000010f4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001336
	ldr x1, =check_data4
	ldr x2, =0x00001337
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
	ldr x0, =0x004000de
	ldr x1, =check_data6
	ldr x2, =0x004000df
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400580
	ldr x1, =check_data7
	ldr x2, =0x00400590
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400c05
	ldr x1, =check_data8
	ldr x2, =0x00400c06
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
