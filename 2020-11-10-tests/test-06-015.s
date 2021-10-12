.section data0, #alloc, #write
	.zero 1024
	.byte 0xff, 0x02, 0x10, 0x54, 0xa4, 0xfe, 0xbf, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3056
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x07, 0x00, 0x06, 0x00, 0x00, 0x40, 0x00, 0x48
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0xa4, 0xfe, 0xbf, 0xff
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x53, 0xfc, 0x5f, 0x48, 0xb5, 0x12, 0xfe, 0xf8, 0xa1, 0x88, 0x01, 0xab, 0x5b, 0x2e, 0xc3, 0x1a
	.byte 0xdf, 0x67, 0x81, 0x5a, 0xfe, 0x11, 0xc5, 0xc2, 0x84, 0x64, 0xe1, 0xc2, 0xc0, 0xa6, 0xc2, 0xc2
.data
check_data4:
	.byte 0xe4, 0xfc, 0x9f, 0x88, 0x3d, 0x18, 0xff, 0xc2, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x10000000
	/* C2 */
	.octa 0x400080000000000000000000000610
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x48004000000600078000000000000000
	/* C5 */
	.octa 0x4000000000001000
	/* C7 */
	.octa 0x200
	/* C15 */
	.octa 0x0
	/* C21 */
	.octa 0x200
	/* C22 */
	.octa 0x204080800009000700000000004000f4
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x8000000000001000
	/* C2 */
	.octa 0x400080000000000000000000000610
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x48004000000600078000000000000000
	/* C5 */
	.octa 0x4000000000001000
	/* C7 */
	.octa 0x200
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0xffbffea4541002ff
	/* C22 */
	.octa 0x204080800009000700000000004000f4
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000100070000000000400020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002007004900fffffffff80001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x485ffc53 // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:19 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xf8fe12b5 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:21 Rn:21 00:00 opc:001 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xab0188a1 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:1 Rn:5 imm6:100010 Rm:1 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0x1ac32e5b // rorv:aarch64/instrs/integer/shift/variable Rd:27 Rn:18 op2:11 0010:0010 Rm:3 0011010110:0011010110 sf:0
	.inst 0x5a8167df // csneg:aarch64/instrs/integer/conditional/select Rd:31 Rn:30 o2:1 0:0 cond:0110 Rm:1 011010100:011010100 op:1 sf:0
	.inst 0xc2c511fe // CVTD-R.C-C Rd:30 Cn:15 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xc2e16484 // ASTR-C.RRB-C Ct:4 Rn:4 1:1 L:0 S:0 option:011 Rm:1 11000010111:11000010111
	.inst 0xc2c2a6c0 // BLRS-C.C-C 00000:00000 Cn:22 001:001 opc:01 1:1 Cm:2 11000010110:11000010110
	.zero 212
	.inst 0x889ffce4 // stlr:aarch64/instrs/memory/ordered Rt:4 Rn:7 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0xc2ff183d // CVT-C.CR-C Cd:29 Cn:1 0110:0110 0:0 0:0 Rm:31 11000010111:11000010111
	.inst 0xc2c21300
	.zero 1048320
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c1 // ldr c1, [x6, #0]
	.inst 0xc24004c2 // ldr c2, [x6, #1]
	.inst 0xc24008c3 // ldr c3, [x6, #2]
	.inst 0xc2400cc4 // ldr c4, [x6, #3]
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc24014c7 // ldr c7, [x6, #5]
	.inst 0xc24018cf // ldr c15, [x6, #6]
	.inst 0xc2401cd5 // ldr c21, [x6, #7]
	.inst 0xc24020d6 // ldr c22, [x6, #8]
	.inst 0xc24024de // ldr c30, [x6, #9]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603306 // ldr c6, [c24, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x82601306 // ldr c6, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30851035
	msr SCTLR_EL3, x6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x24, #0xf
	and x6, x6, x24
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000d8 // ldr c24, [x6, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24004d8 // ldr c24, [x6, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc24008d8 // ldr c24, [x6, #2]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400cd8 // ldr c24, [x6, #3]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc24010d8 // ldr c24, [x6, #4]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc24018d8 // ldr c24, [x6, #6]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401cd8 // ldr c24, [x6, #7]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc24020d8 // ldr c24, [x6, #8]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc24024d8 // ldr c24, [x6, #9]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc24028d8 // ldr c24, [x6, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402cd8 // ldr c24, [x6, #11]
	.inst 0xc2d8a7c1 // chkeq c30, c24
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001408
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001810
	ldr x1, =check_data2
	ldr x2, =0x00001812
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400020
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004000f4
	ldr x1, =check_data4
	ldr x2, =0x00400100
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
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
