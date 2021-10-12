.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x0e, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x03
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xde, 0x03, 0x19, 0x9a, 0xbf, 0x02, 0x25, 0x78, 0x1d, 0x90, 0xc0, 0xc2, 0x20, 0xcc, 0xd0, 0x38
	.byte 0x3e, 0xfe, 0x9f, 0x08, 0xf0, 0x23, 0x01, 0x02, 0xa0, 0x43, 0xe1, 0x78, 0xc8, 0x2b, 0x77, 0x28
	.byte 0xd4, 0x50, 0xaa, 0xe2, 0xdf, 0x77, 0xf8, 0x69, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xff
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000580100c2000000000000101b
	/* C17 */
	.octa 0xf
	/* C21 */
	.octa 0x1
	/* C25 */
	.octa 0x100
	/* C30 */
	.octa 0x3
final_cap_values:
	/* C0 */
	.octa 0xe
	/* C1 */
	.octa 0xb
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x40000000580100c2000000000000101b
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C16 */
	.octa 0x40000740050082200000000050
	/* C17 */
	.octa 0xf
	/* C21 */
	.octa 0x1
	/* C25 */
	.octa 0x100
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc3
initial_SP_EL3_value:
	.octa 0x40000740050082200000000008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004202c7020000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400010010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a1903de // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:30 000000:000000 Rm:25 11010000:11010000 S:0 op:0 sf:1
	.inst 0x782502bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:5 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c0901d // GCTAG-R.C-C Rd:29 Cn:0 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0x38d0cc20 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:1 11:11 imm9:100001100 0:0 opc:11 111000:111000 size:00
	.inst 0x089ffe3e // stlrb:aarch64/instrs/memory/ordered Rt:30 Rn:17 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x020123f0 // 0x020123f0
	.inst 0x78e143a0 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:29 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x28772bc8 // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:8 Rn:30 Rt2:01010 imm7:1101110 L:1 1010000:1010000 opc:00
	.inst 0xe2aa50d4 // ASTUR-V.RI-S Rt:20 Rn:6 op2:00 imm9:010100101 V:1 op1:10 11100010:11100010
	.inst 0x69f877df // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:30 Rt2:11101 imm7:1110000 L:1 1010011:1010011 opc:01
	.inst 0xc2c21160
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
	.inst 0xc2400a85 // ldr c5, [x20, #2]
	.inst 0xc2400e86 // ldr c6, [x20, #3]
	.inst 0xc2401291 // ldr c17, [x20, #4]
	.inst 0xc2401695 // ldr c21, [x20, #5]
	.inst 0xc2401a99 // ldr c25, [x20, #6]
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q20, =0x0
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603174 // ldr c20, [c11, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601174 // ldr c20, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x11, #0x2
	and x20, x20, x11
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc240028b // ldr c11, [x20, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240068b // ldr c11, [x20, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a8b // ldr c11, [x20, #2]
	.inst 0xc2cba4a1 // chkeq c5, c11
	b.ne comparison_fail
	.inst 0xc2400e8b // ldr c11, [x20, #3]
	.inst 0xc2cba4c1 // chkeq c6, c11
	b.ne comparison_fail
	.inst 0xc240128b // ldr c11, [x20, #4]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc240168b // ldr c11, [x20, #5]
	.inst 0xc2cba541 // chkeq c10, c11
	b.ne comparison_fail
	.inst 0xc2401a8b // ldr c11, [x20, #6]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc2401e8b // ldr c11, [x20, #7]
	.inst 0xc2cba621 // chkeq c17, c11
	b.ne comparison_fail
	.inst 0xc240228b // ldr c11, [x20, #8]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240268b // ldr c11, [x20, #9]
	.inst 0xc2cba721 // chkeq c25, c11
	b.ne comparison_fail
	.inst 0xc2402a8b // ldr c11, [x20, #10]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc2402e8b // ldr c11, [x20, #11]
	.inst 0xc2cba7c1 // chkeq c30, c11
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x0
	mov x11, v20.d[0]
	cmp x20, x11
	b.ne comparison_fail
	ldr x20, =0x0
	mov x11, v20.d[1]
	cmp x20, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x0000100d
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001010
	ldr x1, =check_data2
	ldr x2, =0x00001011
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010bc
	ldr x1, =check_data3
	ldr x2, =0x000010cc
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
