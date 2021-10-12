.section data0, #alloc, #write
	.zero 2656
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1424
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x1e, 0x7c, 0x1d, 0x22, 0xc2, 0x27, 0x57, 0xe2, 0xc9, 0xa6, 0x19, 0xf2, 0xdf, 0x73, 0x69, 0xb8
	.byte 0x3f, 0x0b, 0x42, 0x78, 0x20, 0x00, 0xc2, 0xc2, 0x5f, 0x30, 0xc0, 0xc2, 0xec, 0x2b, 0xc0, 0xc2
	.byte 0xa5, 0x67, 0xc0, 0xc2, 0x20, 0x84, 0x51, 0x79, 0x40, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x800200070000000000000000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x804
	/* C30 */
	.octa 0x800000005804019c0000000000001264
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800200070000000000000000
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x804
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x800000005804019c0000000000001264
initial_SP_EL3_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007c0430000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000001007080700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x221d7c1e // STXR-R.CR-C Ct:30 Rn:0 (1)(1)(1)(1)(1):11111 0:0 Rs:29 0:0 L:0 001000100:001000100
	.inst 0xe25727c2 // ALDURH-R.RI-32 Rt:2 Rn:30 op2:01 imm9:101110010 V:0 op1:01 11100010:11100010
	.inst 0xf219a6c9 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:9 Rn:22 imms:101001 immr:011001 N:0 100100:100100 opc:11 sf:1
	.inst 0xb86973df // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:111 o3:0 Rs:9 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x78420b3f // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:25 10:10 imm9:000100000 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2c0305f // GCLEN-R.C-C Rd:31 Cn:2 100:100 opc:001 1100001011000000:1100001011000000
	.inst 0xc2c02bec // BICFLGS-C.CR-C Cd:12 Cn:31 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0xc2c067a5 // CPYVALUE-C.C-C Cd:5 Cn:29 001:001 opc:11 0:0 Cm:0 11000010110:11000010110
	.inst 0x79518420 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:1 imm12:010001100001 opc:01 111001:111001 size:01
	.inst 0xc2c21240
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400876 // ldr c22, [x3, #2]
	.inst 0xc2400c79 // ldr c25, [x3, #3]
	.inst 0xc240107e // ldr c30, [x3, #4]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =initial_SP_EL3_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2c1d07f // cpy c31, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851037
	msr SCTLR_EL3, x3
	ldr x3, =0x4
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x82603243 // ldr c3, [c18, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601243 // ldr c3, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x18, #0xf
	and x3, x3, x18
	cmp x3, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400072 // ldr c18, [x3, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc2400472 // ldr c18, [x3, #1]
	.inst 0xc2d2a421 // chkeq c1, c18
	b.ne comparison_fail
	.inst 0xc2400872 // ldr c18, [x3, #2]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc2400c72 // ldr c18, [x3, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc2401072 // ldr c18, [x3, #4]
	.inst 0xc2d2a521 // chkeq c9, c18
	b.ne comparison_fail
	.inst 0xc2401472 // ldr c18, [x3, #5]
	.inst 0xc2d2a581 // chkeq c12, c18
	b.ne comparison_fail
	.inst 0xc2401872 // ldr c18, [x3, #6]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc2401c72 // ldr c18, [x3, #7]
	.inst 0xc2d2a721 // chkeq c25, c18
	b.ne comparison_fail
	.inst 0xc2402072 // ldr c18, [x3, #8]
	.inst 0xc2d2a7a1 // chkeq c29, c18
	b.ne comparison_fail
	.inst 0xc2402472 // ldr c18, [x3, #9]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001024
	ldr x1, =check_data0
	ldr x2, =0x00001026
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c2
	ldr x1, =check_data1
	ldr x2, =0x000010c4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011d6
	ldr x1, =check_data2
	ldr x2, =0x000011d8
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
	ldr x0, =0x00001a64
	ldr x1, =check_data4
	ldr x2, =0x00001a68
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
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
