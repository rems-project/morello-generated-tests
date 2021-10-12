.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xf9, 0x10
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0xdf, 0x83, 0xff, 0xf8, 0xff, 0x98, 0x3a, 0x37, 0x3e, 0x2a, 0xdf, 0xc2, 0x22, 0x20, 0xab, 0x2c
	.byte 0xff, 0x42, 0x69, 0x38, 0x0f, 0x00, 0x21, 0x9b, 0xfd, 0xf5, 0x3b, 0x79, 0xbf, 0xb3, 0x50, 0xe2
	.byte 0xa3, 0x90, 0xa8, 0xe2, 0x17, 0x70, 0xc0, 0xc2, 0xc0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x700030000091eaa9e2f76
	/* C1 */
	.octa 0x1c00
	/* C5 */
	.octa 0x40000000600200340000000000001057
	/* C9 */
	.octa 0x80
	/* C17 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0x1040
	/* C29 */
	.octa 0x400000000007001700000000000010f9
	/* C30 */
	.octa 0x1020
final_cap_values:
	/* C0 */
	.octa 0x700030000091eaa9e2f76
	/* C1 */
	.octa 0x1b58
	/* C5 */
	.octa 0x40000000600200340000000000001057
	/* C9 */
	.octa 0x80
	/* C15 */
	.octa 0xfffffffffffff206
	/* C17 */
	.octa 0x3fff800000000000000000000000
	/* C23 */
	.octa 0xfffffffffffe2f76
	/* C29 */
	.octa 0x400000000007001700000000000010f9
	/* C30 */
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000480000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005c1100100000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8ff83df // swp:aarch64/instrs/memory/atomicops/swp Rt:31 Rn:30 100000:100000 Rs:31 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x373a98ff // tbnz:aarch64/instrs/branch/conditional/test Rt:31 imm14:01010011000111 b40:00111 op:1 011011:011011 b5:0
	.inst 0xc2df2a3e // BICFLGS-C.CR-C Cd:30 Cn:17 1010:1010 opc:00 Rm:31 11000010110:11000010110
	.inst 0x2cab2022 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:2 Rn:1 Rt2:01000 imm7:1010110 L:0 1011001:1011001 opc:00
	.inst 0x386942ff // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:100 o3:0 Rs:9 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x9b21000f // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:15 Rn:0 Ra:0 o0:0 Rm:1 01:01 U:0 10011011:10011011
	.inst 0x793bf5fd // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:15 imm12:111011111101 opc:00 111001:111001 size:01
	.inst 0xe250b3bf // ASTURH-R.RI-32 Rt:31 Rn:29 op2:00 imm9:100001011 V:0 op1:01 11100010:11100010
	.inst 0xe2a890a3 // ASTUR-V.RI-S Rt:3 Rn:5 op2:00 imm9:010001001 V:1 op1:10 11100010:11100010
	.inst 0xc2c07017 // GCOFF-R.C-C Rd:23 Cn:0 100:100 opc:011 1100001011000000:1100001011000000
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2400f29 // ldr c9, [x25, #3]
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc2401737 // ldr c23, [x25, #5]
	.inst 0xc2401b3d // ldr c29, [x25, #6]
	.inst 0xc2401f3e // ldr c30, [x25, #7]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q2, =0x0
	ldr q3, =0x0
	ldr q8, =0x0
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851037
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d9 // ldr c25, [c22, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826012d9 // ldr c25, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400336 // ldr c22, [x25, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400736 // ldr c22, [x25, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b36 // ldr c22, [x25, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400f36 // ldr c22, [x25, #3]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401336 // ldr c22, [x25, #4]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401b36 // ldr c22, [x25, #6]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2401f36 // ldr c22, [x25, #7]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402336 // ldr c22, [x25, #8]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x22, v2.d[0]
	cmp x25, x22
	b.ne comparison_fail
	ldr x25, =0x0
	mov x22, v2.d[1]
	cmp x25, x22
	b.ne comparison_fail
	ldr x25, =0x0
	mov x22, v3.d[0]
	cmp x25, x22
	b.ne comparison_fail
	ldr x25, =0x0
	mov x22, v3.d[1]
	cmp x25, x22
	b.ne comparison_fail
	ldr x25, =0x0
	mov x22, v8.d[0]
	cmp x25, x22
	b.ne comparison_fail
	ldr x25, =0x0
	mov x22, v8.d[1]
	cmp x25, x22
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
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001020
	ldr x1, =check_data2
	ldr x2, =0x00001028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001040
	ldr x1, =check_data3
	ldr x2, =0x00001041
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010e0
	ldr x1, =check_data4
	ldr x2, =0x000010e4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001c00
	ldr x1, =check_data5
	ldr x2, =0x00001c08
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
