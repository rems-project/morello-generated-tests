.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xbf, 0x0e, 0xdf, 0x9a, 0x20, 0x64, 0x6b, 0x82, 0x34, 0x81, 0x60, 0xa2, 0x20, 0xb0, 0xc0, 0xc2
	.byte 0xc2, 0xab, 0xa6, 0x9b, 0xc0, 0x3a, 0x47, 0xf0, 0x3f, 0xd0, 0x83, 0xf8, 0x61, 0x05, 0x65, 0xe2
	.byte 0x00, 0xe8, 0xdc, 0xc2, 0x1f, 0x49, 0xcb, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8000000000000000004fff48
	/* C8 */
	.octa 0x800000000000000000000000
	/* C9 */
	.octa 0xc010000060c104020000000000001000
	/* C11 */
	.octa 0x4000800000000000000000001f14
final_cap_values:
	/* C1 */
	.octa 0x8000000000000000004fff48
	/* C8 */
	.octa 0x800000000000000000000000
	/* C9 */
	.octa 0xc010000060c104020000000000001000
	/* C11 */
	.octa 0x4000800000000000000000001f14
	/* C20 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000180050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000000010007000200037fc00201
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9adf0ebf // sdiv:aarch64/instrs/integer/arithmetic/div Rd:31 Rn:21 o1:1 00001:00001 Rm:31 0011010110:0011010110 sf:1
	.inst 0x826b6420 // ALDRB-R.RI-B Rt:0 Rn:1 op:01 imm9:010110110 L:1 1000001001:1000001001
	.inst 0xa2608134 // SWPL-CC.R-C Ct:20 Rn:9 100000:100000 Cs:0 1:1 R:1 A:0 10100010:10100010
	.inst 0xc2c0b020 // GCSEAL-R.C-C Rd:0 Cn:1 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x9ba6abc2 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:30 Ra:10 o0:1 Rm:6 01:01 U:1 10011011:10011011
	.inst 0xf0473ac0 // ADRDP-C.ID-C Rd:0 immhi:100011100111010110 P:0 10000:10000 immlo:11 op:1
	.inst 0xf883d03f // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:1 00:00 imm9:000111101 0:0 opc:10 111000:111000 size:11
	.inst 0xe2650561 // ALDUR-V.RI-H Rt:1 Rn:11 op2:01 imm9:001010000 V:1 op1:01 11100010:11100010
	.inst 0xc2dce800 // CTHI-C.CR-C Cd:0 Cn:0 1010:1010 opc:11 Rm:28 11000010110:11000010110
	.inst 0xc2cb491f // UNSEAL-C.CC-C Cd:31 Cn:8 0010:0010 opc:01 Cm:11 11000010110:11000010110
	.inst 0xc2c212c0
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a1 // ldr c1, [x5, #0]
	.inst 0xc24004a8 // ldr c8, [x5, #1]
	.inst 0xc24008a9 // ldr c9, [x5, #2]
	.inst 0xc2400cab // ldr c11, [x5, #3]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30851035
	msr SCTLR_EL3, x5
	ldr x5, =0x4
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c5 // ldr c5, [c22, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x826012c5 // ldr c5, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	.inst 0xc24000b6 // ldr c22, [x5, #0]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24004b6 // ldr c22, [x5, #1]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc24008b6 // ldr c22, [x5, #2]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2400cb6 // ldr c22, [x5, #3]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc24010b6 // ldr c22, [x5, #4]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x5, =0x0
	mov x22, v1.d[0]
	cmp x5, x22
	b.ne comparison_fail
	ldr x5, =0x0
	mov x22, v1.d[1]
	cmp x5, x22
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
	ldr x0, =0x00001f64
	ldr x1, =check_data1
	ldr x2, =0x00001f66
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data3
	ldr x2, =0x004fffff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
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
