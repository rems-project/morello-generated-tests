.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data8:
	.byte 0xf4, 0xd1, 0xc6, 0xc2, 0xc3, 0x4a, 0x63, 0x38, 0x74, 0x01, 0xfd, 0x38, 0xa7, 0x9d, 0x45, 0x82
	.byte 0xff, 0xef, 0xb7, 0x82, 0xb9, 0x3a, 0x16, 0xa2, 0x55, 0xef, 0xde, 0x82, 0xe0, 0x0b, 0xb3, 0xa9
	.byte 0xdf, 0xff, 0x1d, 0x48, 0xe5, 0x8b, 0xae, 0x37, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x290
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C13 */
	.octa 0x40000000000000100000000000001018
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C21 */
	.octa 0x2820
	/* C22 */
	.octa 0x1704
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x8000000060040009fffffffffffffffc
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1c00
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C11 */
	.octa 0x1000
	/* C13 */
	.octa 0x40000000000000100000000000001018
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x1704
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C26 */
	.octa 0x8000000060040009fffffffffffffffc
	/* C29 */
	.octa 0x1
	/* C30 */
	.octa 0x1c00
initial_SP_EL3_value:
	.octa 0x4000000060100a940000000000001480
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000610000040000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword initial_cap_values + 176
	.dword initial_cap_values + 192
	.dword final_cap_values + 96
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c6d1f4 // CLRPERM-C.CI-C Cd:20 Cn:15 100:100 perm:110 1100001011000110:1100001011000110
	.inst 0x38634ac3 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:3 Rn:22 10:10 S:0 option:010 Rm:3 1:1 opc:01 111000:111000 size:00
	.inst 0x38fd0174 // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:11 00:00 opc:000 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x82459da7 // ASTR-R.RI-64 Rt:7 Rn:13 op:11 imm9:001011001 L:0 1000001001:1000001001
	.inst 0x82b7efff // ASTR-V.RRB-S Rt:31 Rn:31 opc:11 S:0 option:111 Rm:23 1:1 L:0 100000101:100000101
	.inst 0xa2163ab9 // STTR-C.RIB-C Ct:25 Rn:21 10:10 imm9:101100011 0:0 opc:00 10100010:10100010
	.inst 0x82deef55 // ALDRH-R.RRB-32 Rt:21 Rn:26 opc:11 S:0 option:111 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xa9b30be0 // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:0 Rn:31 Rt2:00010 imm7:1100110 L:0 1010011:1010011 opc:10
	.inst 0x481dffdf // stlxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:30 Rt2:11111 o0:1 Rs:29 0:0 L:0 0010000:0010000 size:01
	.inst 0x37ae8be5 // tbnz:aarch64/instrs/branch/conditional/test Rt:5 imm14:11010001011111 b40:10101 op:1 011011:011011 b5:0
	.inst 0xc2c211c0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400502 // ldr c2, [x8, #1]
	.inst 0xc2400903 // ldr c3, [x8, #2]
	.inst 0xc2400d05 // ldr c5, [x8, #3]
	.inst 0xc2401107 // ldr c7, [x8, #4]
	.inst 0xc240150b // ldr c11, [x8, #5]
	.inst 0xc240190d // ldr c13, [x8, #6]
	.inst 0xc2401d0f // ldr c15, [x8, #7]
	.inst 0xc2402115 // ldr c21, [x8, #8]
	.inst 0xc2402516 // ldr c22, [x8, #9]
	.inst 0xc2402917 // ldr c23, [x8, #10]
	.inst 0xc2402d19 // ldr c25, [x8, #11]
	.inst 0xc240311a // ldr c26, [x8, #12]
	.inst 0xc240351d // ldr c29, [x8, #13]
	.inst 0xc240391e // ldr c30, [x8, #14]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103f
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c8 // ldr c8, [c14, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826011c8 // ldr c8, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	.inst 0xc240010e // ldr c14, [x8, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240050e // ldr c14, [x8, #1]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc240090e // ldr c14, [x8, #2]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc2400d0e // ldr c14, [x8, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc240110e // ldr c14, [x8, #4]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc240150e // ldr c14, [x8, #5]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc240190e // ldr c14, [x8, #6]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc2401d0e // ldr c14, [x8, #7]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc240210e // ldr c14, [x8, #8]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc240250e // ldr c14, [x8, #9]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc240290e // ldr c14, [x8, #10]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2402d0e // ldr c14, [x8, #11]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240310e // ldr c14, [x8, #12]
	.inst 0xc2cea721 // chkeq c25, c14
	b.ne comparison_fail
	.inst 0xc240350e // ldr c14, [x8, #13]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc240390e // ldr c14, [x8, #14]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc2403d0e // ldr c14, [x8, #15]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x14, v31.d[0]
	cmp x8, x14
	b.ne comparison_fail
	ldr x8, =0x0
	mov x14, v31.d[1]
	cmp x8, x14
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
	ldr x0, =0x000012e0
	ldr x1, =check_data1
	ldr x2, =0x000012e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013b0
	ldr x1, =check_data2
	ldr x2, =0x000013c0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001480
	ldr x1, =check_data3
	ldr x2, =0x00001484
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001994
	ldr x1, =check_data4
	ldr x2, =0x00001995
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001bfc
	ldr x1, =check_data5
	ldr x2, =0x00001bfe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001c00
	ldr x1, =check_data6
	ldr x2, =0x00001c02
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00001e50
	ldr x1, =check_data7
	ldr x2, =0x00001e60
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00400000
	ldr x1, =check_data8
	ldr x2, =0x0040002c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
