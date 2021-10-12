.section data0, #alloc, #write
	.byte 0x84, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
	.byte 0xbe, 0x1f, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x3e
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x80
.data
check_data4:
	.byte 0x80
.data
check_data5:
	.byte 0xbe, 0x1f, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.byte 0xa1, 0x83, 0x02, 0xe2, 0xa1, 0xbc, 0x29, 0xe2, 0x41, 0x7e, 0x9f, 0x08, 0xd6, 0x0f, 0x04, 0xe2
	.byte 0x91, 0x7d, 0x5f, 0x48, 0xbf, 0x5d, 0x9e, 0xb8, 0x7f, 0x00, 0x7e, 0x38, 0x1e, 0x70, 0x7e, 0xf8
	.byte 0xbd, 0x33, 0xbb, 0xb8, 0xff, 0xb1, 0xc5, 0xc2, 0x40, 0x10, 0xc2, 0xc2
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
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x80
	/* C3 */
	.octa 0xc0000000000100050000000000001000
	/* C5 */
	.octa 0x4003e5
	/* C12 */
	.octa 0x80000000000100050000000000400002
	/* C13 */
	.octa 0x8000000000010007000000000000144b
	/* C15 */
	.octa 0x80000000010000
	/* C18 */
	.octa 0x40000000000100050000000000001fbe
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xc00000000001000500000000000017f8
	/* C30 */
	.octa 0x403fba
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x80
	/* C3 */
	.octa 0xc0000000000100050000000000001000
	/* C5 */
	.octa 0x4003e5
	/* C12 */
	.octa 0x80000000000100050000000000400002
	/* C13 */
	.octa 0x80000000000100070000000000001430
	/* C15 */
	.octa 0x80000000010000
	/* C17 */
	.octa 0xe202
	/* C18 */
	.octa 0x40000000000100050000000000001fbe
	/* C22 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x201fbe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword initial_cap_values + 144
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe20283a1 // ASTURB-R.RI-32 Rt:1 Rn:29 op2:00 imm9:000101000 V:0 op1:00 11100010:11100010
	.inst 0xe229bca1 // ALDUR-V.RI-Q Rt:1 Rn:5 op2:11 imm9:010011011 V:1 op1:00 11100010:11100010
	.inst 0x089f7e41 // stllrb:aarch64/instrs/memory/ordered Rt:1 Rn:18 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xe2040fd6 // ALDURSB-R.RI-32 Rt:22 Rn:30 op2:11 imm9:001000000 V:0 op1:00 11100010:11100010
	.inst 0x485f7d91 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:17 Rn:12 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xb89e5dbf // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:13 11:11 imm9:111100101 0:0 opc:10 111000:111000 size:10
	.inst 0x387e007f // staddb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:3 00:00 opc:000 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xf87e701e // ldumin:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:111 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xb8bb33bd // ldset:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:29 00:00 opc:011 0:0 Rs:27 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xc2c5b1ff // CVTP-C.R-C Cd:31 Rn:15 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2c21040
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a63 // ldr c3, [x19, #2]
	.inst 0xc2400e65 // ldr c5, [x19, #3]
	.inst 0xc240126c // ldr c12, [x19, #4]
	.inst 0xc240166d // ldr c13, [x19, #5]
	.inst 0xc2401a6f // ldr c15, [x19, #6]
	.inst 0xc2401e72 // ldr c18, [x19, #7]
	.inst 0xc240227b // ldr c27, [x19, #8]
	.inst 0xc240267d // ldr c29, [x19, #9]
	.inst 0xc2402a7e // ldr c30, [x19, #10]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x8
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82603053 // ldr c19, [c2, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601053 // ldr c19, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	.inst 0xc2400262 // ldr c2, [x19, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400e62 // ldr c2, [x19, #3]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2401262 // ldr c2, [x19, #4]
	.inst 0xc2c2a581 // chkeq c12, c2
	b.ne comparison_fail
	.inst 0xc2401662 // ldr c2, [x19, #5]
	.inst 0xc2c2a5a1 // chkeq c13, c2
	b.ne comparison_fail
	.inst 0xc2401a62 // ldr c2, [x19, #6]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401e62 // ldr c2, [x19, #7]
	.inst 0xc2c2a621 // chkeq c17, c2
	b.ne comparison_fail
	.inst 0xc2402262 // ldr c2, [x19, #8]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc2402662 // ldr c2, [x19, #9]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2402a62 // ldr c2, [x19, #10]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc2402e62 // ldr c2, [x19, #11]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2403262 // ldr c2, [x19, #12]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x2, v1.d[0]
	cmp x19, x2
	b.ne comparison_fail
	ldr x19, =0x0
	mov x2, v1.d[1]
	cmp x19, x2
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
	ldr x0, =0x00001430
	ldr x1, =check_data1
	ldr x2, =0x00001434
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017f8
	ldr x1, =check_data2
	ldr x2, =0x000017fc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001820
	ldr x1, =check_data3
	ldr x2, =0x00001821
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fbe
	ldr x1, =check_data4
	ldr x2, =0x00001fbf
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff0
	ldr x1, =check_data5
	ldr x2, =0x00001ff8
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
	ldr x0, =0x00400480
	ldr x1, =check_data7
	ldr x2, =0x00400490
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00403ffa
	ldr x1, =check_data8
	ldr x2, =0x00403ffb
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
