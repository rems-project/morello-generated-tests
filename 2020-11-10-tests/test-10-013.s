.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x08, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x40, 0xc5, 0xb1, 0xb7, 0x06, 0xa8, 0x41, 0xeb, 0x01, 0x01, 0x7d, 0x38, 0xdf, 0x13, 0x41, 0x38
	.byte 0x00, 0x85, 0xff, 0xca, 0x9c, 0x0e, 0x19, 0x62, 0xbf, 0x6a, 0x0a, 0x82, 0xe2, 0xdb, 0x76, 0x82
	.byte 0xe7, 0x50, 0xc1, 0xc2, 0x9a, 0xaf, 0x92, 0x34, 0xa0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0x800010000000000000000000000
	/* C8 */
	.octa 0xc0000000580008020000000000001210
	/* C20 */
	.octa 0x4c0000005b8100010000000000001020
	/* C26 */
	.octa 0xffffffff
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000100710070000000000001000
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffedef
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x800010000000000000000000000
	/* C8 */
	.octa 0xc0000000580008020000000000001210
	/* C20 */
	.octa 0x4c0000005b8100010000000000001020
	/* C26 */
	.octa 0xffffffff
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000100710070000000000001000
initial_SP_EL3_value:
	.octa 0x1050
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0108000100610070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000261800600e0000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb7b1c540 // tbnz:aarch64/instrs/branch/conditional/test Rt:0 imm14:00111000101010 b40:10110 op:1 011011:011011 b5:1
	.inst 0xeb41a806 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:6 Rn:0 imm6:101010 Rm:1 0:0 shift:01 01011:01011 S:1 op:1 sf:1
	.inst 0x387d0101 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:8 00:00 opc:000 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x384113df // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:000010001 0:0 opc:01 111000:111000 size:00
	.inst 0xcaff8500 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:8 imm6:100001 Rm:31 N:1 shift:11 01010:01010 opc:10 sf:1
	.inst 0x62190e9c // STNP-C.RIB-C Ct:28 Rn:20 Ct2:00011 imm7:0110010 L:0 011000100:011000100
	.inst 0x820a6abf // LDR-C.I-C Ct:31 imm17:00101001101010101 1000001000:1000001000
	.inst 0x8276dbe2 // ALDR-R.RI-32 Rt:2 Rn:31 op:10 imm9:101101101 L:1 1000001001:1000001001
	.inst 0xc2c150e7 // CFHI-R.C-C Rd:7 Cn:7 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x3492af9a // cbz:aarch64/instrs/branch/conditional/compare Rt:26 imm19:1001001010101111100 op:0 011010:011010 sf:0
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400643 // ldr c3, [x18, #1]
	.inst 0xc2400a48 // ldr c8, [x18, #2]
	.inst 0xc2400e54 // ldr c20, [x18, #3]
	.inst 0xc240125a // ldr c26, [x18, #4]
	.inst 0xc240165c // ldr c28, [x18, #5]
	.inst 0xc2401a5d // ldr c29, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851037
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031b2 // ldr c18, [c13, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826011b2 // ldr c18, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024d // ldr c13, [x18, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240064d // ldr c13, [x18, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc2400a4d // ldr c13, [x18, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400e4d // ldr c13, [x18, #3]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240164d // ldr c13, [x18, #5]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc2401a4d // ldr c13, [x18, #6]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc2401e4d // ldr c13, [x18, #7]
	.inst 0xc2cda781 // chkeq c28, c13
	b.ne comparison_fail
	.inst 0xc240224d // ldr c13, [x18, #8]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240264d // ldr c13, [x18, #9]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001011
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001210
	ldr x1, =check_data1
	ldr x2, =0x00001211
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001340
	ldr x1, =check_data2
	ldr x2, =0x00001360
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001604
	ldr x1, =check_data3
	ldr x2, =0x00001608
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
	ldr x0, =0x00453560
	ldr x1, =check_data5
	ldr x2, =0x00453570
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
