.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0xbf, 0x7c, 0xf3, 0x2b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0xbe, 0x7c, 0xf3, 0x2b
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xbf, 0x03, 0x1f, 0x1a, 0x1e, 0xc0, 0xbf, 0x78, 0x67, 0x0b, 0xde, 0xc2, 0xd4, 0x5b, 0xe1, 0xc2
	.byte 0x1f, 0x50, 0x75, 0x38, 0x0c, 0x10, 0xae, 0xb8, 0xfd, 0xbb, 0x9d, 0xe2, 0xe1, 0xa7, 0x8d, 0x28
	.byte 0xbd, 0xab, 0x0a, 0x1b, 0x94, 0x90, 0xc5, 0xc2, 0x60, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1001
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000000000
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C21 */
	.octa 0xbe
	/* C27 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1001
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000000000
	/* C7 */
	.octa 0x3e5f800000000000000000000000
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x2bf37cbe
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000520000030080000000000003
	/* C21 */
	.octa 0xbe
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x7cbf
initial_SP_EL3_value:
	.octa 0x80000000502000040000000000001025
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000520000030000000000000004
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1a1f03bf // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:29 000000:000000 Rm:31 11010000:11010000 S:0 op:0 sf:0
	.inst 0x78bfc01e // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:30 Rn:0 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0xc2de0b67 // SEAL-C.CC-C Cd:7 Cn:27 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0xc2e15bd4 // CVTZ-C.CR-C Cd:20 Cn:30 0110:0110 1:1 0:0 Rm:1 11000010111:11000010111
	.inst 0x3875501f // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:101 o3:0 Rs:21 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xb8ae100c // ldclr:aarch64/instrs/memory/atomicops/ld Rt:12 Rn:0 00:00 opc:001 0:0 Rs:14 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xe29dbbfd // ALDURSW-R.RI-64 Rt:29 Rn:31 op2:10 imm9:111011011 V:0 op1:10 11100010:11100010
	.inst 0x288da7e1 // stp_gen:aarch64/instrs/memory/pair/general/post-idx Rt:1 Rn:31 Rt2:01001 imm7:0011011 L:0 1010001:1010001 opc:00
	.inst 0x1b0aabbd // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:29 Ra:10 o0:1 Rm:10 0011011000:0011011000 sf:0
	.inst 0xc2c59094 // CVTD-C.R-C Cd:20 Rn:4 100:100 opc:00 11000010110001011:11000010110001011
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a44 // ldr c4, [x18, #2]
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc240124e // ldr c14, [x18, #4]
	.inst 0xc2401655 // ldr c21, [x18, #5]
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x11, =pcc_return_ddc_capabilities
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0x82603172 // ldr c18, [c11, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x82601172 // ldr c18, [c11, #1]
	.inst 0x8260216b // ldr c11, [c11, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc240024b // ldr c11, [x18, #0]
	.inst 0xc2cba401 // chkeq c0, c11
	b.ne comparison_fail
	.inst 0xc240064b // ldr c11, [x18, #1]
	.inst 0xc2cba421 // chkeq c1, c11
	b.ne comparison_fail
	.inst 0xc2400a4b // ldr c11, [x18, #2]
	.inst 0xc2cba481 // chkeq c4, c11
	b.ne comparison_fail
	.inst 0xc2400e4b // ldr c11, [x18, #3]
	.inst 0xc2cba4e1 // chkeq c7, c11
	b.ne comparison_fail
	.inst 0xc240124b // ldr c11, [x18, #4]
	.inst 0xc2cba521 // chkeq c9, c11
	b.ne comparison_fail
	.inst 0xc240164b // ldr c11, [x18, #5]
	.inst 0xc2cba581 // chkeq c12, c11
	b.ne comparison_fail
	.inst 0xc2401a4b // ldr c11, [x18, #6]
	.inst 0xc2cba5c1 // chkeq c14, c11
	b.ne comparison_fail
	.inst 0xc2401e4b // ldr c11, [x18, #7]
	.inst 0xc2cba681 // chkeq c20, c11
	b.ne comparison_fail
	.inst 0xc240224b // ldr c11, [x18, #8]
	.inst 0xc2cba6a1 // chkeq c21, c11
	b.ne comparison_fail
	.inst 0xc240264b // ldr c11, [x18, #9]
	.inst 0xc2cba761 // chkeq c27, c11
	b.ne comparison_fail
	.inst 0xc2402a4b // ldr c11, [x18, #10]
	.inst 0xc2cba7c1 // chkeq c30, c11
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
	ldr x0, =0x00001028
	ldr x1, =check_data1
	ldr x2, =0x00001030
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
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
