.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 1
.data
check_data7:
	.byte 0x51, 0x15, 0x5e, 0x82, 0xb9, 0x72, 0x51, 0x78, 0x3f, 0x48, 0xd1, 0xc2, 0xde, 0xbd, 0x18, 0xe2
	.byte 0xee, 0x53, 0xad, 0xe2, 0x28, 0x80, 0xa0, 0xf8, 0x00, 0xe8, 0xcd, 0xc2, 0x6a, 0x80, 0xbe, 0x37
	.byte 0x80, 0x47, 0xef, 0xe2, 0xa2, 0x01, 0xc1, 0x78, 0xa0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1000
	/* C10 */
	.octa 0x4000000058000a120000000000001000
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x80000000000710070000000000001802
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x1209
	/* C28 */
	.octa 0x8000000050f010010000000000000ff4
final_cap_values:
	/* C0 */
	.octa 0x10000000000000000000
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x4000000058000a120000000000001000
	/* C13 */
	.octa 0x1000
	/* C14 */
	.octa 0x80000000000710070000000000001802
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C21 */
	.octa 0x1209
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x8000000050f010010000000000000ff4
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x400000000007000f000000000000100b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000518a00120000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x825e1551 // ASTRB-R.RI-B Rt:17 Rn:10 op:01 imm9:111100001 L:0 1000001001:1000001001
	.inst 0x785172b9 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:21 00:00 imm9:100010111 0:0 opc:01 111000:111000 size:01
	.inst 0xc2d1483f // UNSEAL-C.CC-C Cd:31 Cn:1 0010:0010 opc:01 Cm:17 11000010110:11000010110
	.inst 0xe218bdde // ALDURSB-R.RI-32 Rt:30 Rn:14 op2:11 imm9:110001011 V:0 op1:00 11100010:11100010
	.inst 0xe2ad53ee // ASTUR-V.RI-S Rt:14 Rn:31 op2:00 imm9:011010101 V:1 op1:10 11100010:11100010
	.inst 0xf8a08028 // swp:aarch64/instrs/memory/atomicops/swp Rt:8 Rn:1 100000:100000 Rs:0 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xc2cde800 // CTHI-C.CR-C Cd:0 Cn:0 1010:1010 opc:11 Rm:13 11000010110:11000010110
	.inst 0x37be806a // tbnz:aarch64/instrs/branch/conditional/test Rt:10 imm14:11010000000011 b40:10111 op:1 011011:011011 b5:0
	.inst 0xe2ef4780 // ALDUR-V.RI-D Rt:0 Rn:28 op2:01 imm9:011110100 V:1 op1:11 11100010:11100010
	.inst 0x78c101a2 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:13 00:00 imm9:000010000 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c210a0
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a8a // ldr c10, [x20, #2]
	.inst 0xc2400e8d // ldr c13, [x20, #3]
	.inst 0xc240128e // ldr c14, [x20, #4]
	.inst 0xc2401691 // ldr c17, [x20, #5]
	.inst 0xc2401a95 // ldr c21, [x20, #6]
	.inst 0xc2401e9c // ldr c28, [x20, #7]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q14, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851037
	msr SCTLR_EL3, x20
	ldr x20, =0x0
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030b4 // ldr c20, [c5, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x826010b4 // ldr c20, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400285 // ldr c5, [x20, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400685 // ldr c5, [x20, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400e85 // ldr c5, [x20, #3]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401285 // ldr c5, [x20, #4]
	.inst 0xc2c5a541 // chkeq c10, c5
	b.ne comparison_fail
	.inst 0xc2401685 // ldr c5, [x20, #5]
	.inst 0xc2c5a5a1 // chkeq c13, c5
	b.ne comparison_fail
	.inst 0xc2401a85 // ldr c5, [x20, #6]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401e85 // ldr c5, [x20, #7]
	.inst 0xc2c5a621 // chkeq c17, c5
	b.ne comparison_fail
	.inst 0xc2402285 // ldr c5, [x20, #8]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402685 // ldr c5, [x20, #9]
	.inst 0xc2c5a721 // chkeq c25, c5
	b.ne comparison_fail
	.inst 0xc2402a85 // ldr c5, [x20, #10]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc2402e85 // ldr c5, [x20, #11]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x5, v0.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v0.d[1]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v14.d[0]
	cmp x20, x5
	b.ne comparison_fail
	ldr x20, =0x0
	mov x5, v14.d[1]
	cmp x20, x5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010e0
	ldr x1, =check_data2
	ldr x2, =0x000010e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010e8
	ldr x1, =check_data3
	ldr x2, =0x000010f0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001120
	ldr x1, =check_data4
	ldr x2, =0x00001122
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000011e1
	ldr x1, =check_data5
	ldr x2, =0x000011e2
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0000178d
	ldr x1, =check_data6
	ldr x2, =0x0000178e
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
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
