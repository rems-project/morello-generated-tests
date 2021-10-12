.section data0, #alloc, #write
	.zero 256
	.byte 0x02, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x82, 0x10, 0x00, 0x00
.data
check_data3:
	.byte 0x9f, 0x30, 0x6f, 0x78, 0x1a, 0xff, 0x5f, 0xc8, 0xc0, 0x31, 0xe2, 0x78, 0x5e, 0x74, 0x76, 0x71
	.byte 0xe2, 0xfe, 0x5f, 0x22, 0x44, 0x00, 0xc0, 0x5a, 0x9e, 0xfe, 0x49, 0x78, 0xf2, 0xff, 0x3f, 0x42
	.byte 0x0c, 0xe4, 0x8f, 0xe2, 0x2e, 0x7e, 0xb3, 0x9b, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80
	/* C4 */
	.octa 0xc00000004002000a0000000000001000
	/* C14 */
	.octa 0xc0000000000600070000000000001100
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x800000000001000700000000003fff61
	/* C23 */
	.octa 0x90100000520700070000000000001040
	/* C24 */
	.octa 0x800000005802100a00000000004413f0
final_cap_values:
	/* C0 */
	.octa 0x1002
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C12 */
	.octa 0x1082
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000000100070000000000400000
	/* C23 */
	.octa 0x90100000520700070000000000001040
	/* C24 */
	.octa 0x800000005802100a00000000004413f0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x309f
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000200040000000000018600
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x786f309f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:4 00:00 opc:011 o3:0 Rs:15 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc85fff1a // ldaxr:aarch64/instrs/memory/exclusive/single Rt:26 Rn:24 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
	.inst 0x78e231c0 // ldseth:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:14 00:00 opc:011 0:0 Rs:2 1:1 R:1 A:1 111000:111000 size:01
	.inst 0x7176745e // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:2 imm12:110110011101 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x225ffee2 // LDAXR-C.R-C Ct:2 Rn:23 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x5ac00044 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:4 Rn:2 101101011000000000000:101101011000000000000 sf:0
	.inst 0x7849fe9e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:20 11:11 imm9:010011111 0:0 opc:01 111000:111000 size:01
	.inst 0x423ffff2 // ASTLR-R.R-32 Rt:18 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.inst 0xe28fe40c // ALDUR-R.RI-32 Rt:12 Rn:0 op2:01 imm9:011111110 V:0 op1:10 11100010:11100010
	.inst 0x9bb37e2e // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:14 Rn:17 Ra:31 o0:0 Rm:19 01:01 U:1 10011011:10011011
	.inst 0xc2c210c0
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
	ldr x11, =initial_cap_values
	.inst 0xc2400162 // ldr c2, [x11, #0]
	.inst 0xc2400564 // ldr c4, [x11, #1]
	.inst 0xc240096e // ldr c14, [x11, #2]
	.inst 0xc2400d6f // ldr c15, [x11, #3]
	.inst 0xc2401172 // ldr c18, [x11, #4]
	.inst 0xc2401574 // ldr c20, [x11, #5]
	.inst 0xc2401977 // ldr c23, [x11, #6]
	.inst 0xc2401d78 // ldr c24, [x11, #7]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x3085103f
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030cb // ldr c11, [c6, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826010cb // ldr c11, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x6, #0xf
	and x11, x11, x6
	cmp x11, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400166 // ldr c6, [x11, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400566 // ldr c6, [x11, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400966 // ldr c6, [x11, #2]
	.inst 0xc2c6a481 // chkeq c4, c6
	b.ne comparison_fail
	.inst 0xc2400d66 // ldr c6, [x11, #3]
	.inst 0xc2c6a581 // chkeq c12, c6
	b.ne comparison_fail
	.inst 0xc2401166 // ldr c6, [x11, #4]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401566 // ldr c6, [x11, #5]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2401966 // ldr c6, [x11, #6]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2401d66 // ldr c6, [x11, #7]
	.inst 0xc2c6a6e1 // chkeq c23, c6
	b.ne comparison_fail
	.inst 0xc2402166 // ldr c6, [x11, #8]
	.inst 0xc2c6a701 // chkeq c24, c6
	b.ne comparison_fail
	.inst 0xc2402566 // ldr c6, [x11, #9]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402966 // ldr c6, [x11, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001104
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
	ldr x0, =0x004413f0
	ldr x1, =check_data4
	ldr x2, =0x004413f8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
