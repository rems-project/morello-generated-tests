.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xfc
.data
check_data5:
	.byte 0xf2, 0xfc, 0x9f, 0x48, 0xd1, 0x2b, 0xdf, 0x9a, 0x10, 0xfc, 0x01, 0x22, 0x3c, 0x33, 0x43, 0xf8
	.byte 0x7e, 0x37, 0x48, 0x82, 0x59, 0x40, 0x4b, 0xf8, 0x54, 0xc0, 0xe2, 0x34, 0xbf, 0x21, 0x2c, 0x78
	.byte 0xad, 0x33, 0x02, 0xe2, 0x58, 0x7f, 0xd2, 0x9b, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000
	/* C2 */
	.octa 0x1f04
	/* C7 */
	.octa 0x1840
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x16fc
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xffffffff
	/* C25 */
	.octa 0x1f45
	/* C27 */
	.octa 0x40000000000100050000000000001f7b
	/* C29 */
	.octa 0x40000000000100050000000000001fdb
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400000
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x1f04
	/* C7 */
	.octa 0x1840
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x16fc
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0xffffffff
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000100050000000000001f7b
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x40000000000100050000000000001fdb
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 144
	.dword initial_cap_values + 160
	.dword final_cap_values + 96
	.dword final_cap_values + 192
	.dword final_cap_values + 224
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x489ffcf2 // stlrh:aarch64/instrs/memory/ordered Rt:18 Rn:7 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x9adf2bd1 // asrv:aarch64/instrs/integer/shift/variable Rd:17 Rn:30 op2:10 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x2201fc10 // STLXR-R.CR-C Ct:16 Rn:0 (1)(1)(1)(1)(1):11111 1:1 Rs:1 0:0 L:0 001000100:001000100
	.inst 0xf843333c // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:28 Rn:25 00:00 imm9:000110011 0:0 opc:01 111000:111000 size:11
	.inst 0x8248377e // ASTRB-R.RI-B Rt:30 Rn:27 op:01 imm9:010000011 L:0 1000001001:1000001001
	.inst 0xf84b4059 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:25 Rn:2 00:00 imm9:010110100 0:0 opc:01 111000:111000 size:11
	.inst 0x34e2c054 // cbz:aarch64/instrs/branch/conditional/compare Rt:20 imm19:1110001011000000010 op:0 011010:011010 sf:0
	.inst 0x782c21bf // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:13 00:00 opc:010 o3:0 Rs:12 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xe20233ad // ASTURB-R.RI-32 Rt:13 Rn:29 op2:00 imm9:000100011 V:0 op1:00 11100010:11100010
	.inst 0x9bd27f58 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:24 Rn:26 Ra:11111 0:0 Rm:18 10:10 U:1 10011011:10011011
	.inst 0xc2c21140
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c2 // ldr c2, [x22, #1]
	.inst 0xc2400ac7 // ldr c7, [x22, #2]
	.inst 0xc2400ecc // ldr c12, [x22, #3]
	.inst 0xc24012cd // ldr c13, [x22, #4]
	.inst 0xc24016d0 // ldr c16, [x22, #5]
	.inst 0xc2401ad2 // ldr c18, [x22, #6]
	.inst 0xc2401ed4 // ldr c20, [x22, #7]
	.inst 0xc24022d9 // ldr c25, [x22, #8]
	.inst 0xc24026db // ldr c27, [x22, #9]
	.inst 0xc2402add // ldr c29, [x22, #10]
	.inst 0xc2402ede // ldr c30, [x22, #11]
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603156 // ldr c22, [c10, #3]
	.inst 0xc28b4136 // msr DDC_EL3, c22
	isb
	.inst 0x82601156 // ldr c22, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002ca // ldr c10, [x22, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc24006ca // ldr c10, [x22, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400aca // ldr c10, [x22, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400eca // ldr c10, [x22, #3]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc2caa581 // chkeq c12, c10
	b.ne comparison_fail
	.inst 0xc24016ca // ldr c10, [x22, #5]
	.inst 0xc2caa5a1 // chkeq c13, c10
	b.ne comparison_fail
	.inst 0xc2401aca // ldr c10, [x22, #6]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc2401eca // ldr c10, [x22, #7]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc24022ca // ldr c10, [x22, #8]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc24026ca // ldr c10, [x22, #9]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc2402aca // ldr c10, [x22, #10]
	.inst 0xc2caa701 // chkeq c24, c10
	b.ne comparison_fail
	.inst 0xc2402eca // ldr c10, [x22, #11]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc24032ca // ldr c10, [x22, #12]
	.inst 0xc2caa761 // chkeq c27, c10
	b.ne comparison_fail
	.inst 0xc24036ca // ldr c10, [x22, #13]
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	.inst 0xc2403aca // ldr c10, [x22, #14]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2403eca // ldr c10, [x22, #15]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000016fc
	ldr x1, =check_data0
	ldr x2, =0x000016fe
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001840
	ldr x1, =check_data1
	ldr x2, =0x00001842
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f78
	ldr x1, =check_data2
	ldr x2, =0x00001f80
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb8
	ldr x1, =check_data3
	ldr x2, =0x00001fc0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
