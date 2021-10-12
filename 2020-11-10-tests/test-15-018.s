.section data0, #alloc, #write
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0x00, 0x00
	.zero 2096
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 1920
.data
check_data0:
	.byte 0xc2, 0xc2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xe4, 0x8b, 0x6d, 0x82, 0x20, 0x22, 0x29, 0xd8, 0x2a, 0x30, 0x7f, 0xc8, 0xbf, 0xb3, 0xc0, 0xc2
	.byte 0x20, 0x68, 0x94, 0x38, 0xde, 0x7f, 0x5f, 0x48, 0x00, 0xf0, 0xc5, 0xc2, 0xad, 0x32, 0xc7, 0xc2
	.byte 0x39, 0xb2, 0xc0, 0xc2, 0x1f, 0x53, 0x20, 0x38, 0x80, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000001870
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0xc0000000000100050000000000001ffe
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x8000000000010005000000000000103c
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000100050000000000001870
	/* C4 */
	.octa 0xc2c2c2c2
	/* C10 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C12 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C13 */
	.octa 0xffffffffffffffff
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0xc0000000000100050000000000001ffe
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc2c2
initial_SP_EL3_value:
	.octa 0x434090
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000780060000000000440001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x826d8be4 // ALDR-R.RI-32 Rt:4 Rn:31 op:10 imm9:011011000 L:1 1000001001:1000001001
	.inst 0xd8292220 // prfm_lit:aarch64/instrs/memory/literal/general Rt:0 imm19:0010100100100010001 011000:011000 opc:11
	.inst 0xc87f302a // ldxp:aarch64/instrs/memory/exclusive/pair Rt:10 Rn:1 Rt2:01100 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2c0b3bf // GCSEAL-R.C-C Rd:31 Cn:29 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x38946820 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:0 Rn:1 10:10 imm9:101000110 0:0 opc:10 111000:111000 size:00
	.inst 0x485f7fde // ldxrh:aarch64/instrs/memory/exclusive/single Rt:30 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2c5f000 // CVTPZ-C.R-C Cd:0 Rn:0 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c732ad // RRMASK-R.R-C Rd:13 Rn:21 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c0b239 // GCSEAL-R.C-C Rd:25 Cn:17 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x3820531f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:24 00:00 opc:101 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c21380
	.zero 213956
	.inst 0xc2c2c2c2
	.zero 834572
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
	.inst 0xc24005f1 // ldr c17, [x15, #1]
	.inst 0xc24009f5 // ldr c21, [x15, #2]
	.inst 0xc2400df8 // ldr c24, [x15, #3]
	.inst 0xc24011fd // ldr c29, [x15, #4]
	.inst 0xc24015fe // ldr c30, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_SP_EL3_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x3085103d
	msr SCTLR_EL3, x15
	ldr x15, =0x0
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338f // ldr c15, [c28, #3]
	.inst 0xc28b412f // msr DDC_EL3, c15
	isb
	.inst 0x8260138f // ldr c15, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001fc // ldr c28, [x15, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24005fc // ldr c28, [x15, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24009fc // ldr c28, [x15, #2]
	.inst 0xc2dca481 // chkeq c4, c28
	b.ne comparison_fail
	.inst 0xc2400dfc // ldr c28, [x15, #3]
	.inst 0xc2dca541 // chkeq c10, c28
	b.ne comparison_fail
	.inst 0xc24011fc // ldr c28, [x15, #4]
	.inst 0xc2dca581 // chkeq c12, c28
	b.ne comparison_fail
	.inst 0xc24015fc // ldr c28, [x15, #5]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc24019fc // ldr c28, [x15, #6]
	.inst 0xc2dca621 // chkeq c17, c28
	b.ne comparison_fail
	.inst 0xc2401dfc // ldr c28, [x15, #7]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc24021fc // ldr c28, [x15, #8]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24025fc // ldr c28, [x15, #9]
	.inst 0xc2dca721 // chkeq c25, c28
	b.ne comparison_fail
	.inst 0xc24029fc // ldr c28, [x15, #10]
	.inst 0xc2dca7a1 // chkeq c29, c28
	b.ne comparison_fail
	.inst 0xc2402dfc // ldr c28, [x15, #11]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000103c
	ldr x1, =check_data0
	ldr x2, =0x0000103e
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000017b6
	ldr x1, =check_data1
	ldr x2, =0x000017b7
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001870
	ldr x1, =check_data2
	ldr x2, =0x00001880
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
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
	ldr x0, =0x004343f0
	ldr x1, =check_data5
	ldr x2, =0x004343f4
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
