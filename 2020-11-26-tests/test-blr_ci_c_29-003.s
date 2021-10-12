.section data0, #alloc, #write
	.byte 0x51, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x01, 0x00, 0x80, 0x00, 0x20
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00
.data
check_data0:
	.byte 0x51, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x01, 0x01, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xf5, 0x87, 0x02, 0x78, 0x1e, 0xfc, 0xbf, 0xa2, 0xbc, 0x77, 0xbd, 0x9b, 0xe0, 0xfd, 0xe7, 0x08
	.byte 0xfe, 0x33, 0x55, 0xe2, 0xa1, 0x33, 0xd0, 0xc2
.data
check_data5:
	.byte 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x1e, 0x6c, 0x4a, 0x78, 0x3d, 0x51, 0xc1, 0xc2, 0x1f, 0x41, 0x6a, 0x38, 0x1e, 0x88, 0x0e, 0x9b
	.byte 0x20, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc81000000007000f0000000000400040
	/* C7 */
	.octa 0xff
	/* C8 */
	.octa 0xc0000000000100050000000000001ffe
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0xc00000000001000500000000004ffffe
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x90100001d02000040000000000000ff0
	/* C30 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0xc81000000007000f00000000004000e6
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xc0000000000100050000000000001ffe
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0xc00000000001000500000000004ffffe
	/* C21 */
	.octa 0x0
	/* C28 */
	.octa 0xfe10f0
initial_SP_EL3_value:
	.octa 0x40000000200300070000000000001100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400000010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x780287f5 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:21 Rn:31 01:01 imm9:000101000 0:0 opc:00 111000:111000 size:01
	.inst 0xa2bffc1e // CASL-C.R-C Ct:30 Rn:0 11111:11111 R:1 Cs:31 1:1 L:0 1:1 10100010:10100010
	.inst 0x9bbd77bc // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:28 Rn:29 Ra:29 o0:0 Rm:29 01:01 U:1 10011011:10011011
	.inst 0x08e7fde0 // casb:aarch64/instrs/memory/atomicops/cas/single Rt:0 Rn:15 11111:11111 o0:1 Rs:7 1:1 L:1 0010001:0010001 size:00
	.inst 0xe25533fe // ASTURH-R.RI-32 Rt:30 Rn:31 op2:00 imm9:101010011 V:0 op1:01 11100010:11100010
	.inst 0xc2d033a1 // 0xc2d033a1
	.zero 40
	.inst 0x01010101
	.inst 0x01000000
	.inst 0x01010101
	.inst 0x01010101
	.inst 0x784a6c1e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:30 Rn:0 11:11 imm9:010100110 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c1513d // CFHI-R.C-C Rd:29 Cn:9 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x386a411f // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:8 00:00 opc:100 o3:0 Rs:10 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x9b0e881e // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:30 Rn:0 Ra:2 o0:1 Rm:14 0011011000:0011011000 sf:1
	.inst 0xc2c21320
	.zero 1048476
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400707 // ldr c7, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc240130f // ldr c15, [x24, #4]
	.inst 0xc2401715 // ldr c21, [x24, #5]
	.inst 0xc2401b1d // ldr c29, [x24, #6]
	.inst 0xc2401f1e // ldr c30, [x24, #7]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851037
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603338 // ldr c24, [c25, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601338 // ldr c24, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400319 // ldr c25, [x24, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400719 // ldr c25, [x24, #1]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc2400b19 // ldr c25, [x24, #2]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2400f19 // ldr c25, [x24, #3]
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	.inst 0xc2401319 // ldr c25, [x24, #4]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401719 // ldr c25, [x24, #5]
	.inst 0xc2d9a6a1 // chkeq c21, c25
	b.ne comparison_fail
	.inst 0xc2401b19 // ldr c25, [x24, #6]
	.inst 0xc2d9a781 // chkeq c28, c25
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
	ldr x0, =0x0000107c
	ldr x1, =check_data1
	ldr x2, =0x0000107e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400018
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400040
	ldr x1, =check_data5
	ldr x2, =0x00400064
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004000e6
	ldr x1, =check_data6
	ldr x2, =0x004000e8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffe
	ldr x1, =check_data7
	ldr x2, =0x004fffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
