.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x90, 0x10, 0x00, 0x00
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x41, 0x15, 0x01, 0xb8, 0x06, 0x0c, 0x9e, 0x78, 0x7f, 0x00, 0x62, 0x38, 0x3f, 0x17, 0xb0, 0xe2
	.byte 0x3e, 0xfc, 0x9f, 0x48, 0x02, 0x7c, 0x9f, 0x88, 0x2a, 0xb8, 0x7f, 0xc8, 0x52, 0x70, 0xb4, 0x82
	.byte 0x01, 0x7e, 0x7f, 0x42, 0x43, 0x33, 0xc2, 0xc2
.data
check_data7:
	.byte 0x20, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100070000000000001420
	/* C1 */
	.octa 0xc0000000082700360000000000001000
	/* C2 */
	.octa 0x1090
	/* C3 */
	.octa 0xc0000000540004010000000000001000
	/* C10 */
	.octa 0x40000000008100070000000000001080
	/* C16 */
	.octa 0x1c00
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x1203
	/* C26 */
	.octa 0x200000009007c10f0000000000400100
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100070000000000001400
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1090
	/* C3 */
	.octa 0xc0000000540004010000000000001000
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C16 */
	.octa 0x1c00
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x1203
	/* C26 */
	.octa 0x200000009007c10f0000000000400100
	/* C30 */
	.octa 0x20008000920140050000000000400029
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000120140050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600a00070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8011541 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:1 Rn:10 01:01 imm9:000010001 0:0 opc:00 111000:111000 size:10
	.inst 0x789e0c06 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:6 Rn:0 11:11 imm9:111100000 0:0 opc:10 111000:111000 size:01
	.inst 0x3862007f // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:000 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xe2b0173f // ALDUR-V.RI-S Rt:31 Rn:25 op2:01 imm9:100000001 V:1 op1:10 11100010:11100010
	.inst 0x489ffc3e // stlrh:aarch64/instrs/memory/ordered Rt:30 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x889f7c02 // stllr:aarch64/instrs/memory/ordered Rt:2 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc87fb82a // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:10 Rn:1 Rt2:01110 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x82b47052 // ASTR-R.RRB-32 Rt:18 Rn:2 opc:00 S:1 option:011 Rm:20 1:1 L:0 100000101:100000101
	.inst 0x427f7e01 // ALDARB-R.R-B Rt:1 Rn:16 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c23343 // BLRR-C-C 00011:00011 Cn:26 100:100 opc:01 11000010110000100:11000010110000100
	.zero 216
	.inst 0xc2c21120
	.zero 1048316
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e63 // ldr c3, [x19, #3]
	.inst 0xc240126a // ldr c10, [x19, #4]
	.inst 0xc2401670 // ldr c16, [x19, #5]
	.inst 0xc2401a72 // ldr c18, [x19, #6]
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc2402279 // ldr c25, [x19, #8]
	.inst 0xc240267a // ldr c26, [x19, #9]
	.inst 0xc2402a7e // ldr c30, [x19, #10]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x80
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603133 // ldr c19, [c9, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601133 // ldr c19, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400269 // ldr c9, [x19, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400669 // ldr c9, [x19, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a69 // ldr c9, [x19, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400e69 // ldr c9, [x19, #3]
	.inst 0xc2c9a461 // chkeq c3, c9
	b.ne comparison_fail
	.inst 0xc2401269 // ldr c9, [x19, #4]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc2401669 // ldr c9, [x19, #5]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401a69 // ldr c9, [x19, #6]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401e69 // ldr c9, [x19, #7]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2402269 // ldr c9, [x19, #8]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2402669 // ldr c9, [x19, #9]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2402a69 // ldr c9, [x19, #10]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2402e69 // ldr c9, [x19, #11]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2403269 // ldr c9, [x19, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x9, v31.d[0]
	cmp x19, x9
	b.ne comparison_fail
	ldr x19, =0x0
	mov x9, v31.d[1]
	cmp x19, x9
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001084
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001090
	ldr x1, =check_data2
	ldr x2, =0x00001094
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001104
	ldr x1, =check_data3
	ldr x2, =0x00001108
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001400
	ldr x1, =check_data4
	ldr x2, =0x00001404
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c00
	ldr x1, =check_data5
	ldr x2, =0x00001c01
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x00400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400100
	ldr x1, =check_data7
	ldr x2, =0x00400104
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
