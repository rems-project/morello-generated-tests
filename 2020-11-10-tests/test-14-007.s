.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 10
.data
check_data3:
	.byte 0xe2, 0x33, 0xc3, 0x4a, 0x7f, 0xbf, 0x36, 0xe2, 0x03, 0x06, 0x80, 0x9a, 0xb2, 0x89, 0x1e, 0x1b
	.byte 0x5f, 0x87, 0xbe, 0x9b, 0x62, 0xe6, 0x66, 0xd1, 0xc7, 0xfc, 0x9f, 0x88, 0x9f, 0xe2, 0xd2, 0x29
	.byte 0x82, 0x1d, 0xc9, 0x68, 0x41, 0xf1, 0x64, 0xe2, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x1048
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x40000000000100050000000000001fad
	/* C12 */
	.octa 0x1ff4
	/* C20 */
	.octa 0x141c
	/* C27 */
	.octa 0x80000000000100050000000000447a55
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C6 */
	.octa 0x1048
	/* C7 */
	.octa 0x0
	/* C10 */
	.octa 0x40000000000100050000000000001fad
	/* C12 */
	.octa 0x203c
	/* C20 */
	.octa 0x14b0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x80000000000100050000000000447a55
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x4ac333e2 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:31 imm6:001100 Rm:3 N:0 shift:11 01010:01010 opc:10 sf:0
	.inst 0xe236bf7f // ALDUR-V.RI-Q Rt:31 Rn:27 op2:11 imm9:101101011 V:1 op1:00 11100010:11100010
	.inst 0x9a800603 // csinc:aarch64/instrs/integer/conditional/select Rd:3 Rn:16 o2:1 0:0 cond:0000 Rm:0 011010100:011010100 op:0 sf:1
	.inst 0x1b1e89b2 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:18 Rn:13 Ra:2 o0:1 Rm:30 0011011000:0011011000 sf:0
	.inst 0x9bbe875f // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:26 Ra:1 o0:1 Rm:30 01:01 U:1 10011011:10011011
	.inst 0xd166e662 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:19 imm12:100110111001 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x889ffcc7 // stlr:aarch64/instrs/memory/ordered Rt:7 Rn:6 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:10
	.inst 0x29d2e29f // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:20 Rt2:11000 imm7:0100101 L:1 1010011:1010011 opc:00
	.inst 0x68c91d82 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:2 Rn:12 Rt2:00111 imm7:0010010 L:1 1010001:1010001 opc:01
	.inst 0xe264f141 // ASTUR-V.RI-H Rt:1 Rn:10 op2:00 imm9:001001111 V:1 op1:01 11100010:11100010
	.inst 0xc2c212a0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400106 // ldr c6, [x8, #0]
	.inst 0xc2400507 // ldr c7, [x8, #1]
	.inst 0xc240090a // ldr c10, [x8, #2]
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc2401114 // ldr c20, [x8, #4]
	.inst 0xc240151b // ldr c27, [x8, #5]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x8, #0x40000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a8 // ldr c8, [c21, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826012a8 // ldr c8, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x21, #0x4
	and x8, x8, x21
	cmp x8, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400115 // ldr c21, [x8, #0]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400515 // ldr c21, [x8, #1]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2400915 // ldr c21, [x8, #2]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2400d15 // ldr c21, [x8, #3]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401115 // ldr c21, [x8, #4]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401515 // ldr c21, [x8, #5]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2401915 // ldr c21, [x8, #6]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2401d15 // ldr c21, [x8, #7]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x21, v1.d[0]
	cmp x8, x21
	b.ne comparison_fail
	ldr x8, =0x0
	mov x21, v1.d[1]
	cmp x8, x21
	b.ne comparison_fail
	ldr x8, =0x0
	mov x21, v31.d[0]
	cmp x8, x21
	b.ne comparison_fail
	ldr x8, =0x0
	mov x21, v31.d[1]
	cmp x8, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001048
	ldr x1, =check_data0
	ldr x2, =0x0000104c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000014b0
	ldr x1, =check_data1
	ldr x2, =0x000014b8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff4
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x004479c0
	ldr x1, =check_data4
	ldr x2, =0x004479d0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
