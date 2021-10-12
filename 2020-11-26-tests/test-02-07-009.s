.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x01, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x80
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x99, 0xf3, 0x56, 0x78, 0x41, 0x33, 0x56, 0x38, 0xdf, 0x01, 0x39, 0x78, 0xa1, 0x0f, 0x34, 0x6d
	.byte 0xe0, 0xfd, 0xdf, 0xc8, 0x3e, 0x10, 0xc0, 0x5a, 0xe0, 0xd3, 0xff, 0x82, 0x5c, 0x58, 0xa1, 0x22
	.byte 0xea, 0x7c, 0x0f, 0x78, 0xb9, 0xa9, 0x03, 0xa2, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4c000000000100070000000000001000
	/* C7 */
	.octa 0x40000000000100070000000000001001
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000400408010000000000000e00
	/* C14 */
	.octa 0xc0000000400100020000000000001000
	/* C15 */
	.octa 0x80000000100140050000000000001ed8
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000087002a000000000000109e
	/* C28 */
	.octa 0x80004000000000000000000000001401
	/* C29 */
	.octa 0x40000000400000010000000000001400
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x4c000000000100070000000000000c20
	/* C7 */
	.octa 0x400000000001000700000000000010f8
	/* C10 */
	.octa 0x0
	/* C13 */
	.octa 0x40000000400408010000000000000e00
	/* C14 */
	.octa 0xc0000000400100020000000000001000
	/* C15 */
	.octa 0x80000000100140050000000000001ed8
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000087002a000000000000109e
	/* C28 */
	.octa 0x80004000000000000000000000001401
	/* C29 */
	.octa 0x40000000400000010000000000001400
	/* C30 */
	.octa 0x20
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000208020000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7856f399 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:28 00:00 imm9:101101111 0:0 opc:01 111000:111000 size:01
	.inst 0x38563341 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:26 00:00 imm9:101100011 0:0 opc:01 111000:111000 size:00
	.inst 0x783901df // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:14 00:00 opc:000 o3:0 Rs:25 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x6d340fa1 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:1 Rn:29 Rt2:00011 imm7:1101000 L:0 1011010:1011010 opc:01
	.inst 0xc8dffde0 // ldar:aarch64/instrs/memory/ordered Rt:0 Rn:15 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0x5ac0103e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:1 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x82ffd3e0 // ALDR-R.RRB-32 Rt:0 Rn:31 opc:00 S:1 option:110 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x22a1585c // STP-CC.RIAW-C Ct:28 Rn:2 Ct2:10110 imm7:1000010 L:0 001000101:001000101
	.inst 0x780f7cea // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:10 Rn:7 11:11 imm9:011110111 0:0 opc:00 111000:111000 size:01
	.inst 0xa203a9b9 // STTR-C.RIB-C Ct:25 Rn:13 10:10 imm9:000111010 0:0 opc:00 10100010:10100010
	.inst 0xc2c21080
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
	ldr x24, =initial_cap_values
	.inst 0xc2400302 // ldr c2, [x24, #0]
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2400f0d // ldr c13, [x24, #3]
	.inst 0xc240130e // ldr c14, [x24, #4]
	.inst 0xc240170f // ldr c15, [x24, #5]
	.inst 0xc2401b16 // ldr c22, [x24, #6]
	.inst 0xc2401f1a // ldr c26, [x24, #7]
	.inst 0xc240231c // ldr c28, [x24, #8]
	.inst 0xc240271d // ldr c29, [x24, #9]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q1, =0x0
	ldr q3, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603098 // ldr c24, [c4, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601098 // ldr c24, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400304 // ldr c4, [x24, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400704 // ldr c4, [x24, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400b04 // ldr c4, [x24, #2]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400f04 // ldr c4, [x24, #3]
	.inst 0xc2c4a4e1 // chkeq c7, c4
	b.ne comparison_fail
	.inst 0xc2401304 // ldr c4, [x24, #4]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc2401704 // ldr c4, [x24, #5]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401b04 // ldr c4, [x24, #6]
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	.inst 0xc2401f04 // ldr c4, [x24, #7]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2402304 // ldr c4, [x24, #8]
	.inst 0xc2c4a6c1 // chkeq c22, c4
	b.ne comparison_fail
	.inst 0xc2402704 // ldr c4, [x24, #9]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2402b04 // ldr c4, [x24, #10]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402f04 // ldr c4, [x24, #11]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	.inst 0xc2403304 // ldr c4, [x24, #12]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2403704 // ldr c4, [x24, #13]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x4, v1.d[0]
	cmp x24, x4
	b.ne comparison_fail
	ldr x24, =0x0
	mov x4, v1.d[1]
	cmp x24, x4
	b.ne comparison_fail
	ldr x24, =0x0
	mov x4, v3.d[0]
	cmp x24, x4
	b.ne comparison_fail
	ldr x24, =0x0
	mov x4, v3.d[1]
	cmp x24, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f8
	ldr x1, =check_data1
	ldr x2, =0x000010fa
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011a0
	ldr x1, =check_data2
	ldr x2, =0x000011b0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001340
	ldr x1, =check_data3
	ldr x2, =0x00001350
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001370
	ldr x1, =check_data4
	ldr x2, =0x00001372
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ed8
	ldr x1, =check_data5
	ldr x2, =0x00001ee0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
