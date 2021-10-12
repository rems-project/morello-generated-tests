.section data0, #alloc, #write
	.zero 2048
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x01, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xff, 0xff
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x6c, 0x84, 0xc3, 0xe2, 0xd1, 0xff, 0xdf, 0xc8, 0x5f, 0x78, 0x3f, 0xb8, 0x3e, 0x30, 0x7e, 0xf8
	.byte 0x86, 0xff, 0x02, 0x22, 0x62, 0x25, 0x1b, 0x91, 0x5e, 0xa7, 0x0e, 0x38, 0x5f, 0x10, 0xa0, 0x78
	.byte 0x29, 0x80, 0x20, 0xa2, 0x20, 0xa0, 0xce, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1c000000000000000000000000000
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1600
	/* C3 */
	.octa 0x800000005f0004540000000000001bd0
	/* C6 */
	.octa 0x4000000000000000000000000000
	/* C11 */
	.octa 0x113b
	/* C26 */
	.octa 0x1050
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1804
	/* C3 */
	.octa 0x800000005f0004540000000000001bd0
	/* C6 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x1000
	/* C11 */
	.octa 0x113b
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C26 */
	.octa 0x113a
	/* C28 */
	.octa 0x1000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004030c1020000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd80000006002000000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2c3846c // ALDUR-R.RI-64 Rt:12 Rn:3 op2:01 imm9:000111000 V:0 op1:11 11100010:11100010
	.inst 0xc8dfffd1 // ldar:aarch64/instrs/memory/ordered Rt:17 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:11
	.inst 0xb83f785f // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:31 Rn:2 10:10 S:1 option:011 Rm:31 1:1 opc:00 111000:111000 size:10
	.inst 0xf87e303e // ldset:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:1 00:00 opc:011 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:11
	.inst 0x2202ff86 // STLXR-R.CR-C Ct:6 Rn:28 (1)(1)(1)(1)(1):11111 1:1 Rs:2 0:0 L:0 001000100:001000100
	.inst 0x911b2562 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:11 imm12:011011001001 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x380ea75e // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:26 01:01 imm9:011101010 0:0 opc:00 111000:111000 size:00
	.inst 0x78a0105f // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:2 00:00 opc:001 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xa2208029 // SWP-CC.R-C Ct:9 Rn:1 100000:100000 Cs:0 1:1 R:0 A:0 10100010:10100010
	.inst 0xc2cea020 // CLRPERM-C.CR-C Cd:0 Cn:1 000:000 1:1 10:10 Rm:14 11000010110:11000010110
	.inst 0xc2c21280
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2400e63 // ldr c3, [x19, #3]
	.inst 0xc2401266 // ldr c6, [x19, #4]
	.inst 0xc240166b // ldr c11, [x19, #5]
	.inst 0xc2401a7a // ldr c26, [x19, #6]
	.inst 0xc2401e7c // ldr c28, [x19, #7]
	.inst 0xc240227e // ldr c30, [x19, #8]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851037
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603293 // ldr c19, [c20, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601293 // ldr c19, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400274 // ldr c20, [x19, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400674 // ldr c20, [x19, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a74 // ldr c20, [x19, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400e74 // ldr c20, [x19, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2d4a521 // chkeq c9, c20
	b.ne comparison_fail
	.inst 0xc2401a74 // ldr c20, [x19, #6]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2402274 // ldr c20, [x19, #8]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2402674 // ldr c20, [x19, #9]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2402a74 // ldr c20, [x19, #10]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402e74 // ldr c20, [x19, #11]
	.inst 0xc2d4a7c1 // chkeq c30, c20
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
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001051
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001600
	ldr x1, =check_data2
	ldr x2, =0x00001604
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001804
	ldr x1, =check_data3
	ldr x2, =0x00001806
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001c08
	ldr x1, =check_data4
	ldr x2, =0x00001c10
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
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
