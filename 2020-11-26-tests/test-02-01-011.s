.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x53, 0x0f
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0x34, 0xc2, 0xbf, 0x78, 0x3f, 0x2b, 0x10, 0xf8, 0xfe, 0x1b, 0xc9, 0xc2, 0x21, 0xd0, 0x4c, 0xe2
	.byte 0xa5, 0xf3, 0xc5, 0xc2, 0xdf, 0x9a, 0xf9, 0xc2, 0x16, 0x0a, 0xa8, 0xb9, 0x3e, 0x7c, 0x9f, 0x08
	.byte 0xca, 0x8b, 0x46, 0x6c, 0xa7, 0x2b, 0x74, 0xd1, 0x60, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000500040000000000000f53
	/* C16 */
	.octa 0xffffffffffffe4f8
	/* C17 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x103e
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x40000000000500040000000000000f53
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xffffffffff2f6000
	/* C16 */
	.octa 0xffffffffffffe4f8
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C25 */
	.octa 0x103e
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc00180010000000000000000
initial_SP_EL3_value:
	.octa 0xc00180010000000000010001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004081c0840000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000004606100000fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78bfc234 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:20 Rn:17 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xf8102b3f // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:25 10:10 imm9:100000010 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c91bfe // ALIGND-C.CI-C Cd:30 Cn:31 0110:0110 U:0 imm6:010010 11000010110:11000010110
	.inst 0xe24cd021 // ASTURH-R.RI-32 Rt:1 Rn:1 op2:00 imm9:011001101 V:0 op1:01 11100010:11100010
	.inst 0xc2c5f3a5 // CVTPZ-C.R-C Cd:5 Rn:29 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2f99adf // SUBS-R.CC-C Rd:31 Cn:22 100110:100110 Cm:25 11000010111:11000010111
	.inst 0xb9a80a16 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:16 imm12:101000000010 opc:10 111001:111001 size:10
	.inst 0x089f7c3e // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x6c468bca // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:10 Rn:30 Rt2:00010 imm7:0001101 L:1 1011000:1011000 opc:01
	.inst 0xd1742ba7 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:7 Rn:29 imm12:110100001010 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xc2c21360
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005f0 // ldr c16, [x15, #1]
	.inst 0xc24009f1 // ldr c17, [x15, #2]
	.inst 0xc2400df6 // ldr c22, [x15, #3]
	.inst 0xc24011f9 // ldr c25, [x15, #4]
	.inst 0xc24015fd // ldr c29, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	ldr x15, =0x4
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260336f // ldr c15, [c27, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260136f // ldr c15, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x27, #0xf
	and x15, x15, x27
	cmp x15, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fb // ldr c27, [x15, #0]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc24005fb // ldr c27, [x15, #1]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc24009fb // ldr c27, [x15, #2]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc2400dfb // ldr c27, [x15, #3]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc24011fb // ldr c27, [x15, #4]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc24015fb // ldr c27, [x15, #5]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc24019fb // ldr c27, [x15, #6]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc2401dfb // ldr c27, [x15, #7]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc24021fb // ldr c27, [x15, #8]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc24025fb // ldr c27, [x15, #9]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x15, =0x0
	mov x27, v2.d[0]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v2.d[1]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v10.d[0]
	cmp x15, x27
	b.ne comparison_fail
	ldr x15, =0x0
	mov x27, v10.d[1]
	cmp x15, x27
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
	ldr x2, =0x00001022
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001068
	ldr x1, =check_data2
	ldr x2, =0x00001078
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d00
	ldr x1, =check_data3
	ldr x2, =0x00001d04
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f40
	ldr x1, =check_data4
	ldr x2, =0x00001f48
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f53
	ldr x1, =check_data5
	ldr x2, =0x00001f54
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
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
