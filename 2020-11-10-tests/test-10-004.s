.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x82, 0x31, 0x3f, 0xb8, 0xe0, 0x1b, 0xd3, 0xc2, 0x78, 0x7e, 0x00, 0xb8, 0xe0, 0xb3, 0x82, 0xab
	.byte 0x40, 0x51, 0xc2, 0xc2
.data
check_data4:
	.byte 0x24, 0x16, 0x7b, 0xac, 0x99, 0xbb, 0x1b, 0x38, 0x20, 0x58, 0x27, 0x88, 0xc2, 0xff, 0x5f, 0xc8
	.byte 0x06, 0x00, 0x10, 0xda, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 32
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4ffff0
	/* C10 */
	.octa 0x20008000000100050000000000400100
	/* C12 */
	.octa 0x1300
	/* C17 */
	.octa 0x4a00c0
	/* C19 */
	.octa 0x1229
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x2012
	/* C30 */
	.octa 0x4ffff0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4ffff0
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x1
	/* C10 */
	.octa 0x20008000000100050000000000400100
	/* C12 */
	.octa 0x1300
	/* C17 */
	.octa 0x4a00c0
	/* C19 */
	.octa 0x1230
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C28 */
	.octa 0x2012
	/* C30 */
	.octa 0x4ffff0
initial_SP_EL3_value:
	.octa 0x2247a2260000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb83f3182 // ldset:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:12 00:00 opc:011 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:10
	.inst 0xc2d31be0 // ALIGND-C.CI-C Cd:0 Cn:31 0110:0110 U:0 imm6:100110 11000010110:11000010110
	.inst 0xb8007e78 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:24 Rn:19 11:11 imm9:000000111 0:0 opc:00 111000:111000 size:10
	.inst 0xab82b3e0 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:31 imm6:101100 Rm:2 0:0 shift:10 01011:01011 S:1 op:0 sf:1
	.inst 0xc2c25140 // RET-C-C 00000:00000 Cn:10 100:100 opc:10 11000010110000100:11000010110000100
	.zero 236
	.inst 0xac7b1624 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:4 Rn:17 Rt2:00101 imm7:1110110 L:1 1011000:1011000 opc:10
	.inst 0x381bbb99 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:25 Rn:28 10:10 imm9:110111011 0:0 opc:00 111000:111000 size:00
	.inst 0x88275820 // stxp:aarch64/instrs/memory/exclusive/pair Rt:0 Rn:1 Rt2:10110 o0:0 Rs:7 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0xc85fffc2 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:2 Rn:30 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0xda100006 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:6 Rn:0 000000:000000 Rm:16 11010000:11010000 S:0 op:1 sf:1
	.inst 0xc2c213a0
	.zero 1048296
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
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc240048a // ldr c10, [x4, #1]
	.inst 0xc240088c // ldr c12, [x4, #2]
	.inst 0xc2400c91 // ldr c17, [x4, #3]
	.inst 0xc2401093 // ldr c19, [x4, #4]
	.inst 0xc2401498 // ldr c24, [x4, #5]
	.inst 0xc2401899 // ldr c25, [x4, #6]
	.inst 0xc2401c9c // ldr c28, [x4, #7]
	.inst 0xc240209e // ldr c30, [x4, #8]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_SP_EL3_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30851037
	msr SCTLR_EL3, x4
	ldr x4, =0x0
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033a4 // ldr c4, [c29, #3]
	.inst 0xc28b4124 // msr DDC_EL3, c4
	isb
	.inst 0x826013a4 // ldr c4, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x29, #0xf
	and x4, x4, x29
	cmp x4, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240009d // ldr c29, [x4, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240049d // ldr c29, [x4, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc240089d // ldr c29, [x4, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400c9d // ldr c29, [x4, #3]
	.inst 0xc2dda4e1 // chkeq c7, c29
	b.ne comparison_fail
	.inst 0xc240109d // ldr c29, [x4, #4]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc240149d // ldr c29, [x4, #5]
	.inst 0xc2dda581 // chkeq c12, c29
	b.ne comparison_fail
	.inst 0xc240189d // ldr c29, [x4, #6]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc2401c9d // ldr c29, [x4, #7]
	.inst 0xc2dda661 // chkeq c19, c29
	b.ne comparison_fail
	.inst 0xc240209d // ldr c29, [x4, #8]
	.inst 0xc2dda701 // chkeq c24, c29
	b.ne comparison_fail
	.inst 0xc240249d // ldr c29, [x4, #9]
	.inst 0xc2dda721 // chkeq c25, c29
	b.ne comparison_fail
	.inst 0xc240289d // ldr c29, [x4, #10]
	.inst 0xc2dda781 // chkeq c28, c29
	b.ne comparison_fail
	.inst 0xc2402c9d // ldr c29, [x4, #11]
	.inst 0xc2dda7c1 // chkeq c30, c29
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x29, v4.d[0]
	cmp x4, x29
	b.ne comparison_fail
	ldr x4, =0x0
	mov x29, v4.d[1]
	cmp x4, x29
	b.ne comparison_fail
	ldr x4, =0x0
	mov x29, v5.d[0]
	cmp x4, x29
	b.ne comparison_fail
	ldr x4, =0x0
	mov x29, v5.d[1]
	cmp x4, x29
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001230
	ldr x1, =check_data0
	ldr x2, =0x00001234
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001300
	ldr x1, =check_data1
	ldr x2, =0x00001304
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fcd
	ldr x1, =check_data2
	ldr x2, =0x00001fce
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400100
	ldr x1, =check_data4
	ldr x2, =0x00400118
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004a0020
	ldr x1, =check_data5
	ldr x2, =0x004a0040
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffff0
	ldr x1, =check_data6
	ldr x2, =0x004ffff8
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
