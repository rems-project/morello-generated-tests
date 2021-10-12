.section data0, #alloc, #write
	.zero 3968
	.byte 0x22, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 8
.data
check_data7:
	.byte 0xc5, 0x0f, 0x90, 0x3c, 0xfd, 0x5f, 0x70, 0x62, 0xdf, 0x7c, 0x1d, 0xc8, 0x18, 0xfc, 0x5f, 0x22
	.byte 0xff, 0x53, 0x65, 0xb8, 0x20, 0x17, 0xc0, 0xda, 0xff, 0x03, 0x57, 0xe2, 0xc3, 0x77, 0x5a, 0x69
	.byte 0xff, 0x43, 0x80, 0x5a, 0xbb, 0x14, 0xc0, 0x5a, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1b00
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1000
	/* C30 */
	.octa 0x2000
final_cap_values:
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x1f
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1f00
initial_SP_EL3_value:
	.octa 0x40000000400008f40000000000001f80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000600020000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000005fdc042100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001b00
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3c900fc5 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:5 Rn:30 11:11 imm9:100000000 0:0 opc:10 111100:111100 size:00
	.inst 0x62705ffd // LDNP-C.RIB-C Ct:29 Rn:31 Ct2:10111 imm7:1100000 L:1 011000100:011000100
	.inst 0xc81d7cdf // stxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:6 Rt2:11111 o0:0 Rs:29 0:0 L:0 0010000:0010000 size:11
	.inst 0x225ffc18 // LDAXR-C.R-C Ct:24 Rn:0 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xb86553ff // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:5 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xdac01720 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:0 Rn:25 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xe25703ff // ASTURH-R.RI-32 Rt:31 Rn:31 op2:00 imm9:101110000 V:0 op1:01 11100010:11100010
	.inst 0x695a77c3 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:3 Rn:30 Rt2:11101 imm7:0110100 L:1 1010010:1010010 opc:01
	.inst 0x5a8043ff // csinv:aarch64/instrs/integer/conditional/select Rd:31 Rn:31 o2:0 0:0 cond:0100 Rm:0 011010100:011010100 op:1 sf:0
	.inst 0x5ac014bb // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:27 Rn:5 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c21340
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
	.inst 0xc24005c5 // ldr c5, [x14, #1]
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2400dde // ldr c30, [x14, #3]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q5, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085103d
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334e // ldr c14, [c26, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260134e // ldr c14, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x26, #0x8
	and x14, x14, x26
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001da // ldr c26, [x14, #0]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc24005da // ldr c26, [x14, #1]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc24009da // ldr c26, [x14, #2]
	.inst 0xc2daa4c1 // chkeq c6, c26
	b.ne comparison_fail
	.inst 0xc2400dda // ldr c26, [x14, #3]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc24011da // ldr c26, [x14, #4]
	.inst 0xc2daa701 // chkeq c24, c26
	b.ne comparison_fail
	.inst 0xc24015da // ldr c26, [x14, #5]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2401dda // ldr c26, [x14, #7]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x26, v5.d[0]
	cmp x14, x26
	b.ne comparison_fail
	ldr x14, =0x0
	mov x26, v5.d[1]
	cmp x14, x26
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
	ldr x0, =0x00001b00
	ldr x1, =check_data1
	ldr x2, =0x00001b10
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d80
	ldr x1, =check_data2
	ldr x2, =0x00001da0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ef0
	ldr x1, =check_data3
	ldr x2, =0x00001ef2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f00
	ldr x1, =check_data4
	ldr x2, =0x00001f10
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f80
	ldr x1, =check_data5
	ldr x2, =0x00001f84
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fd0
	ldr x1, =check_data6
	ldr x2, =0x00001fd8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
