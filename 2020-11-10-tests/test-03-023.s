.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xff, 0xff
.data
check_data3:
	.byte 0x20, 0x6a, 0xd6, 0xc2, 0x04, 0xf7, 0x78, 0xb1, 0xe6, 0xcf, 0xe9, 0x2d, 0x0e, 0x13, 0x53, 0xba
	.byte 0x9f, 0x3c, 0x60, 0xea, 0x1f, 0x12, 0x7a, 0x78, 0xe1, 0xd0, 0xc5, 0xc2, 0xff, 0x05, 0xcb, 0xc2
	.byte 0xfa, 0x94, 0x3e, 0x50, 0xdf, 0x07, 0x1b, 0xfc, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0xb027
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0xc0000000000100050000000000001ffc
	/* C17 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0xffffffffff1c3000
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000000100050000000000001000
final_cap_values:
	/* C1 */
	.octa 0x8007d05f00177e900000807f
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0xb027
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C16 */
	.octa 0xc0000000000100050000000000001ffc
	/* C17 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0xffffffffff1c3000
	/* C26 */
	.octa 0x200080005e440000000000000047d2be
	/* C30 */
	.octa 0x40000000000100050000000000000fb0
initial_SP_EL3_value:
	.octa 0x800000000001000700000000000011b8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080005e4400000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8007d05f00177e9000008000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d66a20 // ORRFLGS-C.CR-C Cd:0 Cn:17 1010:1010 opc:01 Rm:22 11000010110:11000010110
	.inst 0xb178f704 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:4 Rn:24 imm12:111000111101 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x2de9cfe6 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:6 Rn:31 Rt2:10011 imm7:1010011 L:1 1011011:1011011 opc:00
	.inst 0xba53130e // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:24 00:00 cond:0001 Rm:19 111010010:111010010 op:0 sf:1
	.inst 0xea603c9f // bics:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:4 imm6:001111 Rm:0 N:1 shift:01 01010:01010 opc:11 sf:1
	.inst 0x787a121f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:16 00:00 opc:001 o3:0 Rs:26 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c5d0e1 // CVTDZ-C.R-C Cd:1 Rn:7 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2cb05ff // BUILD-C.C-C Cd:31 Cn:15 001:001 opc:00 0:0 Cm:11 11000010110:11000010110
	.inst 0x503e94fa // ADR-C.I-C Rd:26 immhi:011111010010100111 P:0 10000:10000 immlo:10 op:0
	.inst 0xfc1b07df // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:31 Rn:30 01:01 imm9:110110000 0:0 opc:00 111100:111100 size:11
	.inst 0xc2c21040
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
	ldr x12, =initial_cap_values
	.inst 0xc2400187 // ldr c7, [x12, #0]
	.inst 0xc240058b // ldr c11, [x12, #1]
	.inst 0xc240098f // ldr c15, [x12, #2]
	.inst 0xc2400d90 // ldr c16, [x12, #3]
	.inst 0xc2401191 // ldr c17, [x12, #4]
	.inst 0xc2401598 // ldr c24, [x12, #5]
	.inst 0xc240199a // ldr c26, [x12, #6]
	.inst 0xc2401d9e // ldr c30, [x12, #7]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q31, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_SP_EL3_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851037
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
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x2, #0xf
	and x12, x12, x2
	cmp x12, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400582 // ldr c2, [x12, #1]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400982 // ldr c2, [x12, #2]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc2400d82 // ldr c2, [x12, #3]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc2401182 // ldr c2, [x12, #4]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401582 // ldr c2, [x12, #5]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401982 // ldr c2, [x12, #6]
	.inst 0xc2c2a621 // chkeq c17, c2
	b.ne comparison_fail
	.inst 0xc2401d82 // ldr c2, [x12, #7]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2402182 // ldr c2, [x12, #8]
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	.inst 0xc2402582 // ldr c2, [x12, #9]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x2, v6.d[0]
	cmp x12, x2
	b.ne comparison_fail
	ldr x12, =0x0
	mov x2, v6.d[1]
	cmp x12, x2
	b.ne comparison_fail
	ldr x12, =0x0
	mov x2, v19.d[0]
	cmp x12, x2
	b.ne comparison_fail
	ldr x12, =0x0
	mov x2, v19.d[1]
	cmp x12, x2
	b.ne comparison_fail
	ldr x12, =0x0
	mov x2, v31.d[0]
	cmp x12, x2
	b.ne comparison_fail
	ldr x12, =0x0
	mov x2, v31.d[1]
	cmp x12, x2
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
	ldr x0, =0x00001104
	ldr x1, =check_data1
	ldr x2, =0x0000110c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
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
