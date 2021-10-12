.section data0, #alloc, #write
	.zero 3392
	.byte 0x40, 0xec, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x86, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 672
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x86, 0x02
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 8
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x3d, 0x80, 0xb2, 0x78, 0xdc, 0xd7, 0x86, 0x29, 0xdf, 0x23, 0x11, 0xd1, 0x16, 0x7c, 0x3f, 0x42
	.byte 0x41, 0x31, 0xc7, 0xc2, 0x8f, 0x69, 0x7d, 0xa2, 0xbc, 0xd3, 0xc5, 0xc2, 0xa0, 0x60, 0x7e, 0x78
	.byte 0x0b, 0x10, 0xbf, 0x78, 0x81, 0xe3, 0xf3, 0xc2, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000000017001e0000000000001000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x10
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffffffff1400
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x244
final_cap_values:
	/* C0 */
	.octa 0x286
	/* C1 */
	.octa 0xc00000005fc91d400000000000010980
	/* C5 */
	.octa 0x10
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0xffffffffffff1400
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0xc00000005fc91d400000000000010980
	/* C29 */
	.octa 0xec40
	/* C30 */
	.octa 0x278
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000240100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fc91d4000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78b2803d // swph:aarch64/instrs/memory/atomicops/swp Rt:29 Rn:1 100000:100000 Rs:18 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x2986d7dc // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:28 Rn:30 Rt2:10101 imm7:0001101 L:0 1010011:1010011 opc:00
	.inst 0xd11123df // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:30 imm12:010001001000 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x423f7c16 // ASTLRB-R.R-B Rt:22 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xc2c73141 // RRMASK-R.R-C Rd:1 Rn:10 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xa27d698f // LDR-C.RRB-C Ct:15 Rn:12 10:10 S:0 option:011 Rm:29 1:1 opc:01 10100010:10100010
	.inst 0xc2c5d3bc // CVTDZ-C.R-C Cd:28 Rn:29 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x787e60a0 // ldumaxh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:5 00:00 opc:110 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x78bf100b // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:11 Rn:0 00:00 opc:001 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2f3e381 // BICFLGS-C.CI-C Cd:1 Cn:28 0:0 00:00 imm8:10011111 11000010111:11000010111
	.inst 0xc2c21100
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
	ldr x4, =initial_cap_values
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400885 // ldr c5, [x4, #2]
	.inst 0xc2400c8a // ldr c10, [x4, #3]
	.inst 0xc240108c // ldr c12, [x4, #4]
	.inst 0xc2401492 // ldr c18, [x4, #5]
	.inst 0xc2401895 // ldr c21, [x4, #6]
	.inst 0xc2401c96 // ldr c22, [x4, #7]
	.inst 0xc240209c // ldr c28, [x4, #8]
	.inst 0xc240249e // ldr c30, [x4, #9]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	ldr x4, =0x4
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603104 // ldr c4, [c8, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x82601104 // ldr c4, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400088 // ldr c8, [x4, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400488 // ldr c8, [x4, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400888 // ldr c8, [x4, #2]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc2401088 // ldr c8, [x4, #4]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401488 // ldr c8, [x4, #5]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc2401888 // ldr c8, [x4, #6]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401c88 // ldr c8, [x4, #7]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2402088 // ldr c8, [x4, #8]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2402488 // ldr c8, [x4, #9]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2402888 // ldr c8, [x4, #10]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2402c88 // ldr c8, [x4, #11]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2403088 // ldr c8, [x4, #12]
	.inst 0xc2c8a7c1 // chkeq c30, c8
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
	ldr x0, =0x00001d40
	ldr x1, =check_data1
	ldr x2, =0x00001d42
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d50
	ldr x1, =check_data2
	ldr x2, =0x00001d52
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d80
	ldr x1, =check_data3
	ldr x2, =0x00001d90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fb8
	ldr x1, =check_data4
	ldr x2, =0x00001fc0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc6
	ldr x1, =check_data5
	ldr x2, =0x00001fc8
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
