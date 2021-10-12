.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x41, 0x32, 0x28, 0xdf, 0xf7, 0xc5, 0x38, 0xc1, 0x26, 0x3f, 0xca, 0x9f, 0xfb, 0xa5, 0x9b
	.byte 0xe1, 0x27, 0xc0, 0x9a, 0x02, 0x2b, 0xdd, 0xc2, 0xfd, 0x95, 0x10, 0x38, 0x9f, 0x42, 0xa0, 0x38
	.byte 0xdd, 0x03, 0xf6, 0xf8, 0x5f, 0xb7, 0x5d, 0x8b, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000060000b920000000000002000
	/* C15 */
	.octa 0x40000000000100070000000000001000
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000000500070000000000001000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x81
	/* C30 */
	.octa 0xc0000000000100070000000000001001
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x4000000060000b920000000000002000
	/* C15 */
	.octa 0x40000000000100070000000000000f09
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000000500070000000000001000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000000100070000000000001060
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200140050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x28324100 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:0 Rn:8 Rt2:10000 imm7:1100100 L:0 1010000:1010000 opc:00
	.inst 0x38c5f7df // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:001011111 0:0 opc:11 111000:111000 size:00
	.inst 0xca3f26c1 // eon:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:22 imm6:001001 Rm:31 N:1 shift:00 01010:01010 opc:10 sf:1
	.inst 0x9ba5fb9f // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:28 Ra:30 o0:1 Rm:5 01:01 U:1 10011011:10011011
	.inst 0x9ac027e1 // lsrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:31 op2:01 0010:0010 Rm:0 0011010110:0011010110 sf:1
	.inst 0xc2dd2b02 // BICFLGS-C.CR-C Cd:2 Cn:24 1010:1010 opc:00 Rm:29 11000010110:11000010110
	.inst 0x381095fd // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:15 01:01 imm9:100001001 0:0 opc:00 111000:111000 size:00
	.inst 0x38a0429f // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:20 00:00 opc:100 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xf8f603dd // ldadd:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:30 00:00 opc:000 0:0 Rs:22 1:1 R:1 A:1 111000:111000 size:11
	.inst 0x8b5db75f // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:31 Rn:26 imm6:101101 Rm:29 0:0 shift:01 01011:01011 S:0 op:0 sf:1
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c8 // ldr c8, [x14, #1]
	.inst 0xc24009cf // ldr c15, [x14, #2]
	.inst 0xc2400dd0 // ldr c16, [x14, #3]
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc24015d6 // ldr c22, [x14, #5]
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2401ddd // ldr c29, [x14, #7]
	.inst 0xc24021de // ldr c30, [x14, #8]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x8260116e // ldr c14, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cb // ldr c11, [x14, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc24005cb // ldr c11, [x14, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc24009cb // ldr c11, [x14, #2]
	.inst 0xc2cba441 // chkeq c2, c11
	b.ne comparison_fail
	.inst 0xc2400dcb // ldr c11, [x14, #3]
	.inst 0xc2cba501 // chkeq c8, c11
	b.ne comparison_fail
	.inst 0xc24011cb // ldr c11, [x14, #4]
	.inst 0xc2cba5e1 // chkeq c15, c11
	b.ne comparison_fail
	.inst 0xc24015cb // ldr c11, [x14, #5]
	.inst 0xc2cba601 // chkeq c16, c11
	b.ne comparison_fail
	.inst 0xc24019cb // ldr c11, [x14, #6]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc2401dcb // ldr c11, [x14, #7]
	.inst 0xc2cba6c1 // chkeq c22, c11
	b.ne comparison_fail
	.inst 0xc24021cb // ldr c11, [x14, #8]
	.inst 0xc2cba701 // chkeq c24, c11
	b.ne comparison_fail
	.inst 0xc24025cb // ldr c11, [x14, #9]
	.inst 0xc2cba7a1 // chkeq c29, c11
	b.ne comparison_fail
	.inst 0xc24029cb // ldr c11, [x14, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
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
	ldr x0, =0x00001060
	ldr x1, =check_data1
	ldr x2, =0x00001068
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f90
	ldr x1, =check_data2
	ldr x2, =0x00001f98
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
