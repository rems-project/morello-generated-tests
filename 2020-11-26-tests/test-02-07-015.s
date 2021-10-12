.section data0, #alloc, #write
	.zero 352
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3728
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x9d, 0xa8, 0xf4, 0xc2, 0x9e, 0x43, 0xfd, 0x38, 0x5e, 0xd0, 0xc0, 0xc2, 0x5d, 0xfe, 0x7f, 0x42
	.byte 0x40, 0x01, 0x9e, 0x02, 0x67, 0x84, 0x00, 0xa2, 0x35, 0x80, 0xdd, 0xc2, 0x7f, 0x7e, 0x5f, 0x08
	.byte 0x3f, 0x4d, 0xdc, 0x38, 0xfa, 0x2b, 0xc0, 0xc2, 0x20, 0x13, 0xc2, 0xc2
.data
check_data3:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x40000000048700090000000000001000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x800000003f57e39f0000000000480004
	/* C10 */
	.octa 0x10000180050002400000000000
	/* C18 */
	.octa 0x448068
	/* C19 */
	.octa 0x80000000400200220000000000001000
	/* C28 */
	.octa 0xc0000000584400400000000000001160
final_cap_values:
	/* C0 */
	.octa 0x100001800500023ffffffff880
	/* C3 */
	.octa 0x40000000048700090000000000001080
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x800000003f57e39f000000000047ffc8
	/* C10 */
	.octa 0x10000180050002400000000000
	/* C18 */
	.octa 0x448068
	/* C19 */
	.octa 0x80000000400200220000000000001000
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xc0000000584400400000000000001160
	/* C29 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000000478057000000000044a001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2f4a89d // ORRFLGS-C.CI-C Cd:29 Cn:4 0:0 01:01 imm8:10100101 11000010111:11000010111
	.inst 0x38fd439e // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:28 00:00 opc:100 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:00
	.inst 0xc2c0d05e // GCPERM-R.C-C Rd:30 Cn:2 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x427ffe5d // ALDAR-R.R-32 Rt:29 Rn:18 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x029e0140 // SUB-C.CIS-C Cd:0 Cn:10 imm12:011110000000 sh:0 A:1 00000010:00000010
	.inst 0xa2008467 // STR-C.RIAW-C Ct:7 Rn:3 01:01 imm9:000001000 0:0 opc:00 10100010:10100010
	.inst 0xc2dd8035 // SCTAG-C.CR-C Cd:21 Cn:1 000:000 0:0 10:10 Rm:29 11000010110:11000010110
	.inst 0x085f7e7f // ldxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:19 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x38dc4d3f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:9 11:11 imm9:111000100 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c02bfa // BICFLGS-C.CR-C Cd:26 Cn:31 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0xc2c21320
	.zero 294972
	.inst 0x00000001
	.zero 753556
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a3 // ldr c3, [x5, #0]
	.inst 0xc24004a4 // ldr c4, [x5, #1]
	.inst 0xc24008a7 // ldr c7, [x5, #2]
	.inst 0xc2400ca9 // ldr c9, [x5, #3]
	.inst 0xc24010aa // ldr c10, [x5, #4]
	.inst 0xc24014b2 // ldr c18, [x5, #5]
	.inst 0xc24018b3 // ldr c19, [x5, #6]
	.inst 0xc2401cbc // ldr c28, [x5, #7]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x0
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603325 // ldr c5, [c25, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601325 // ldr c5, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b9 // ldr c25, [x5, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24004b9 // ldr c25, [x5, #1]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc24008b9 // ldr c25, [x5, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400cb9 // ldr c25, [x5, #3]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc24010b9 // ldr c25, [x5, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc24014b9 // ldr c25, [x5, #5]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc24018b9 // ldr c25, [x5, #6]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2401cb9 // ldr c25, [x5, #7]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc24020b9 // ldr c25, [x5, #8]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc24024b9 // ldr c25, [x5, #9]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc24028b9 // ldr c25, [x5, #10]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001160
	ldr x1, =check_data1
	ldr x2, =0x00001161
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
	ldr x0, =0x00448068
	ldr x1, =check_data3
	ldr x2, =0x0044806c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0047ffc8
	ldr x1, =check_data4
	ldr x2, =0x0047ffc9
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
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
