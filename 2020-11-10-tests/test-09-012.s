.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0xf8, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x02, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00
.data
check_data1:
	.byte 0xf8, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x00, 0x02, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x1f, 0xfc, 0x5f, 0x48, 0x4f, 0x30, 0xc7, 0xc2, 0x35, 0x64, 0xc3, 0xc2, 0x46, 0xe8, 0xed, 0xc2
	.byte 0x42, 0x60, 0x7f, 0xb8, 0x01, 0xf0, 0xdf, 0xc2
.data
check_data5:
	.byte 0x3e, 0xeb, 0x69, 0xb4, 0x49, 0xa3, 0xcc, 0xc2, 0x33, 0xe4, 0xc2, 0xac, 0x5f, 0x13, 0x61, 0xb8
	.byte 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x901000000021c0050000000000001020
	/* C1 */
	.octa 0x400000000000010a0
	/* C2 */
	.octa 0x2000000000000000000000ff0
	/* C26 */
	.octa 0x800000000000000000000ff4
final_cap_values:
	/* C0 */
	.octa 0x901000000021c0050000000000001020
	/* C1 */
	.octa 0x10f0
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x2000000006f00000000000ff0
	/* C9 */
	.octa 0x800000000000000000000ff4
	/* C15 */
	.octa 0xffffffffffffffff
	/* C26 */
	.octa 0x800000000000000000000ff4
	/* C30 */
	.octa 0x20008000804500060000000000400018
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004500060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000000b7001700ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x485ffc1f // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:0 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2c7304f // RRMASK-R.R-C Rd:15 Rn:2 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c36435 // CPYVALUE-C.C-C Cd:21 Cn:1 001:001 opc:11 0:0 Cm:3 11000010110:11000010110
	.inst 0xc2ede846 // ORRFLGS-C.CI-C Cd:6 Cn:2 0:0 01:01 imm8:01101111 11000010111:11000010111
	.inst 0xb87f6042 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:2 00:00 opc:110 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xc2dff001 // BLR-CI-C 1:1 0000:0000 Cn:0 100:100 imm7:1111111 110000101101:110000101101
	.zero 224
	.inst 0xb469eb3e // cbz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:0110100111101011001 op:0 011010:011010 sf:1
	.inst 0xc2cca349 // CLRPERM-C.CR-C Cd:9 Cn:26 000:000 1:1 10:10 Rm:12 11000010110:11000010110
	.inst 0xacc2e433 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:19 Rn:1 Rt2:11001 imm7:0000101 L:1 1011001:1011001 opc:10
	.inst 0xb861135f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:26 00:00 opc:001 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2c21200
	.zero 1048308
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f9a // ldr c26, [x28, #3]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30851037
	msr SCTLR_EL3, x28
	ldr x28, =0x84
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x8260321c // ldr c28, [c16, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260121c // ldr c28, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400390 // ldr c16, [x28, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400790 // ldr c16, [x28, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400b90 // ldr c16, [x28, #2]
	.inst 0xc2d0a441 // chkeq c2, c16
	b.ne comparison_fail
	.inst 0xc2400f90 // ldr c16, [x28, #3]
	.inst 0xc2d0a4c1 // chkeq c6, c16
	b.ne comparison_fail
	.inst 0xc2401390 // ldr c16, [x28, #4]
	.inst 0xc2d0a521 // chkeq c9, c16
	b.ne comparison_fail
	.inst 0xc2401790 // ldr c16, [x28, #5]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401b90 // ldr c16, [x28, #6]
	.inst 0xc2d0a741 // chkeq c26, c16
	b.ne comparison_fail
	.inst 0xc2401f90 // ldr c16, [x28, #7]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x16, v19.d[0]
	cmp x28, x16
	b.ne comparison_fail
	ldr x28, =0x0
	mov x16, v19.d[1]
	cmp x28, x16
	b.ne comparison_fail
	ldr x28, =0x0
	mov x16, v25.d[0]
	cmp x28, x16
	b.ne comparison_fail
	ldr x28, =0x0
	mov x16, v25.d[1]
	cmp x28, x16
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
	ldr x2, =0x00001020
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001032
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000010b0
	ldr x1, =check_data3
	ldr x2, =0x000010d0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004000f8
	ldr x1, =check_data5
	ldr x2, =0x0040010c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
