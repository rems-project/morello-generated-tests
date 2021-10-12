.section data0, #alloc, #write
	.byte 0x00, 0x5f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
	.byte 0x00, 0x00, 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3984
.data
check_data0:
	.byte 0x5f
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x82
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x3e, 0x4b, 0xcd, 0xc2, 0x9e, 0x88, 0xde, 0x38, 0x4d, 0xc0, 0x3f, 0xa2, 0xe1, 0x90, 0x5c, 0x78
	.byte 0xa0, 0x53, 0x33, 0x38, 0x7f, 0x94, 0xc8, 0xb0, 0x40, 0x21, 0x6a, 0x38, 0x0a, 0x54, 0x15, 0x29
	.byte 0xe1, 0xcb, 0x85, 0xe2, 0x61, 0x93, 0x16, 0x98, 0x60, 0x13, 0xc2, 0xc2
.data
check_data8:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0xf
	/* C4 */
	.octa 0x1000
	/* C7 */
	.octa 0x1002
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000000000000000000000000
	/* C29 */
	.octa 0x61
final_cap_values:
	/* C0 */
	.octa 0x5f
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xf
	/* C4 */
	.octa 0x1000
	/* C7 */
	.octa 0x1002
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C25 */
	.octa 0x1000000000000000000000000000
	/* C29 */
	.octa 0x61
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000580208140000000000000fa8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080001c1900070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005ff1100100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2cd4b3e // UNSEAL-C.CC-C Cd:30 Cn:25 0010:0010 opc:01 Cm:13 11000010110:11000010110
	.inst 0x38de889e // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:4 10:10 imm9:111101000 0:0 opc:11 111000:111000 size:00
	.inst 0xa23fc04d // LDAPR-C.R-C Ct:13 Rn:2 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x785c90e1 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:7 00:00 imm9:111001001 0:0 opc:01 111000:111000 size:01
	.inst 0x383353a0 // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:29 00:00 opc:101 0:0 Rs:19 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xb0c8947f // ADRP-C.IP-C Rd:31 immhi:100100010010100011 P:1 10000:10000 immlo:01 op:1
	.inst 0x386a2140 // ldeorb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:10 00:00 opc:010 0:0 Rs:10 1:1 R:1 A:0 111000:111000 size:00
	.inst 0x2915540a // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:10 Rn:0 Rt2:10101 imm7:0101010 L:0 1010010:1010010 opc:00
	.inst 0xe285cbe1 // ALDURSW-R.RI-64 Rt:1 Rn:31 op2:10 imm9:001011100 V:0 op1:10 11100010:11100010
	.inst 0x98169361 // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:1 imm19:0001011010010011011 011000:011000 opc:10
	.inst 0xc2c21360
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
	.inst 0xc2400242 // ldr c2, [x18, #0]
	.inst 0xc2400644 // ldr c4, [x18, #1]
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc240124d // ldr c13, [x18, #4]
	.inst 0xc2401653 // ldr c19, [x18, #5]
	.inst 0xc2401a55 // ldr c21, [x18, #6]
	.inst 0xc2401e59 // ldr c25, [x18, #7]
	.inst 0xc240225d // ldr c29, [x18, #8]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0xc
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82603372 // ldr c18, [c27, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601372 // ldr c18, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
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
	.inst 0xc240025b // ldr c27, [x18, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240065b // ldr c27, [x18, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a5b // ldr c27, [x18, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400e5b // ldr c27, [x18, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240125b // ldr c27, [x18, #4]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240165b // ldr c27, [x18, #5]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc2401e5b // ldr c27, [x18, #7]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc240225b // ldr c27, [x18, #8]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc240265b // ldr c27, [x18, #9]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2402a5b // ldr c27, [x18, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402e5b // ldr c27, [x18, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001001
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001008
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001010
	ldr x1, =check_data2
	ldr x2, =0x00001020
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001062
	ldr x1, =check_data3
	ldr x2, =0x00001063
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001108
	ldr x1, =check_data4
	ldr x2, =0x00001110
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fcc
	ldr x1, =check_data5
	ldr x2, =0x00001fce
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fe9
	ldr x1, =check_data6
	ldr x2, =0x00001fea
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0042d290
	ldr x1, =check_data8
	ldr x2, =0x0042d294
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
