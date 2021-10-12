.section data0, #alloc, #write
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x10, 0x00
.data
check_data1:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x41, 0x4b, 0xca, 0x38, 0x01, 0x60, 0xb2, 0x78, 0xc0, 0x33, 0x22, 0xf8, 0xe0, 0x03, 0xc0, 0xda
	.byte 0x61, 0x7c, 0x83, 0xe2, 0xc2, 0x33, 0x77, 0x78, 0x86, 0x32, 0xc7, 0xc2, 0x3e, 0xf0, 0xc0, 0xc2
	.byte 0x2a, 0x01, 0xc9, 0xc2, 0x80, 0x31, 0xc2, 0xc2
.data
check_data5:
	.byte 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x2
	/* C3 */
	.octa 0x40000000400000260000000000000fe9
	/* C9 */
	.octa 0x100010000000000000000
	/* C12 */
	.octa 0x20008000040784170000000000400200
	/* C18 */
	.octa 0x10
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x1d00
	/* C30 */
	.octa 0x1820
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x2
	/* C2 */
	.octa 0x2
	/* C3 */
	.octa 0x40000000400000260000000000000fe9
	/* C6 */
	.octa 0xffffffffffffffff
	/* C9 */
	.octa 0x100010000000000000000
	/* C10 */
	.octa 0x400000000000000000000000
	/* C12 */
	.octa 0x20008000040784170000000000400200
	/* C18 */
	.octa 0x10
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C26 */
	.octa 0x1d00
	/* C30 */
	.octa 0x20008000800100070000000000400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000020140050080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38ca4b41 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:26 10:10 imm9:010100100 0:0 opc:11 111000:111000 size:00
	.inst 0x78b26001 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:0 00:00 opc:110 0:0 Rs:18 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xf82233c0 // ldset:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:30 00:00 opc:011 0:0 Rs:2 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xdac003e0 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:0 Rn:31 101101011000000000000:101101011000000000000 sf:1
	.inst 0xe2837c61 // ASTUR-C.RI-C Ct:1 Rn:3 op2:11 imm9:000110111 V:0 op1:10 11100010:11100010
	.inst 0x787733c2 // ldseth:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:30 00:00 opc:011 0:0 Rs:23 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c73286 // RRMASK-R.R-C Rd:6 Rn:20 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c0f03e // GCTYPE-R.C-C Rd:30 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xc2c9012a // SCBNDS-C.CR-C Cd:10 Cn:9 000:000 opc:00 0:0 Rm:9 11000010110:11000010110
	.inst 0xc2c23180 // BLR-C-C 00000:00000 Cn:12 100:100 opc:01 11000010110000100:11000010110000100
	.zero 472
	.inst 0xc2c21320
	.zero 1048060
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400903 // ldr c3, [x8, #2]
	.inst 0xc2400d09 // ldr c9, [x8, #3]
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc2401512 // ldr c18, [x8, #5]
	.inst 0xc2401914 // ldr c20, [x8, #6]
	.inst 0xc2401d17 // ldr c23, [x8, #7]
	.inst 0xc240211a // ldr c26, [x8, #8]
	.inst 0xc240251e // ldr c30, [x8, #9]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x80
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603328 // ldr c8, [c25, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601328 // ldr c8, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400119 // ldr c25, [x8, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400519 // ldr c25, [x8, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400919 // ldr c25, [x8, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400d19 // ldr c25, [x8, #3]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2401119 // ldr c25, [x8, #4]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2401519 // ldr c25, [x8, #5]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401919 // ldr c25, [x8, #6]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401d19 // ldr c25, [x8, #7]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2402119 // ldr c25, [x8, #8]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc2402519 // ldr c25, [x8, #9]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402919 // ldr c25, [x8, #10]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2402d19 // ldr c25, [x8, #11]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2403119 // ldr c25, [x8, #12]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001820
	ldr x1, =check_data2
	ldr x2, =0x00001828
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001da4
	ldr x1, =check_data3
	ldr x2, =0x00001da5
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400200
	ldr x1, =check_data5
	ldr x2, =0x00400204
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
