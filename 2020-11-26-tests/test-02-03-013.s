.section data0, #alloc, #write
	.zero 2048
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1888
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data2:
	.byte 0x01
.data
check_data3:
	.byte 0x23, 0xd1, 0xc1, 0xc2, 0x10, 0x00, 0xc0, 0x5a, 0x1f, 0x72, 0x2e, 0x38, 0x18, 0x90, 0xc4, 0xc2
	.byte 0xee, 0x72, 0x28, 0x38, 0x32, 0x24, 0x88, 0xb8, 0x3f, 0x60, 0x7e, 0x38, 0xc1, 0xea, 0x42, 0x38
	.byte 0x1f, 0x7c, 0x35, 0x9b, 0x6f, 0x58, 0xef, 0xc2, 0x40, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x14
	/* C8 */
	.octa 0x80
	/* C9 */
	.octa 0x4001000000ffffffffffe000
	/* C14 */
	.octa 0x8
	/* C15 */
	.octa 0x1000000000000000
	/* C22 */
	.octa 0x402011
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0xc
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xc2
	/* C3 */
	.octa 0x4001000000ffffffffffe000
	/* C8 */
	.octa 0x80
	/* C9 */
	.octa 0x4001000000ffffffffffe000
	/* C14 */
	.octa 0x1
	/* C15 */
	.octa 0x400100001000000000000000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0xffffffffc2c2c2c2
	/* C22 */
	.octa 0x402011
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0xc
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20808000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000406001f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1d123 // CPY-C.C-C Cd:3 Cn:9 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0x5ac00010 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:16 Rn:0 101101011000000000000:101101011000000000000 sf:0
	.inst 0x382e721f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:111 o3:0 Rs:14 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xc2c49018 // STCT-R.R-_ Rt:24 Rn:0 100:100 opc:00 11000010110001001:11000010110001001
	.inst 0x382872ee // lduminb:aarch64/instrs/memory/atomicops/ld Rt:14 Rn:23 00:00 opc:111 0:0 Rs:8 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xb8882432 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:18 Rn:1 01:01 imm9:010000010 0:0 opc:10 111000:111000 size:10
	.inst 0x387e603f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x3842eac1 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:22 10:10 imm9:000101110 0:0 opc:01 111000:111000 size:00
	.inst 0x9b357c1f // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:31 o0:0 Rm:21 01:01 U:0 10011011:10011011
	.inst 0xc2ef586f // CVTZ-C.CR-C Cd:15 Cn:3 0110:0110 1:1 0:0 Rm:15 11000010111:11000010111
	.inst 0xc2c21040
	.zero 14352
	.inst 0xc2000000
	.zero 1034176
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400988 // ldr c8, [x12, #2]
	.inst 0xc2400d89 // ldr c9, [x12, #3]
	.inst 0xc240118e // ldr c14, [x12, #4]
	.inst 0xc240158f // ldr c15, [x12, #5]
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2401d97 // ldr c23, [x12, #7]
	.inst 0xc2402198 // ldr c24, [x12, #8]
	.inst 0xc240259e // ldr c30, [x12, #9]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x4
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260304c // ldr c12, [c2, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260104c // ldr c12, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2c2a461 // chkeq c3, c2
	b.ne comparison_fail
	.inst 0xc2400d82 // ldr c2, [x12, #3]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc2401182 // ldr c2, [x12, #4]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc2401582 // ldr c2, [x12, #5]
	.inst 0xc2c2a5c1 // chkeq c14, c2
	b.ne comparison_fail
	.inst 0xc2401982 // ldr c2, [x12, #6]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401d82 // ldr c2, [x12, #7]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2402182 // ldr c2, [x12, #8]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc2402582 // ldr c2, [x12, #9]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2402982 // ldr c2, [x12, #10]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc2402d82 // ldr c2, [x12, #11]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2403182 // ldr c2, [x12, #12]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001800
	ldr x1, =check_data0
	ldr x2, =0x00001801
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001814
	ldr x1, =check_data1
	ldr x2, =0x00001818
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001896
	ldr x1, =check_data2
	ldr x2, =0x00001897
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
	ldr x0, =0x0040383f
	ldr x1, =check_data4
	ldr x2, =0x00403840
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
