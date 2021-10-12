.section data0, #alloc, #write
	.byte 0x10, 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x20, 0x7c, 0x5f, 0x42, 0xde, 0x8b, 0xdd, 0xc2, 0xf0, 0x83, 0xff, 0xa2, 0x3f, 0xd7, 0x76, 0xe2
	.byte 0x7d, 0xf9, 0x7a, 0x28, 0x53, 0x41, 0x6e, 0xf2, 0x1e, 0x04, 0x32, 0x4b, 0xff, 0x63, 0x7c, 0x38
	.byte 0xfd, 0x7f, 0xa4, 0x08, 0xe3, 0x60, 0xe1, 0xb8, 0x00, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1100
	/* C4 */
	.octa 0xff
	/* C7 */
	.octa 0xc00000000087000e0000000000001000
	/* C10 */
	.octa 0x7fffc0000
	/* C11 */
	.octa 0x800000004001421c0000000000404400
	/* C25 */
	.octa 0x2001
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x200000080000000000001000
	/* C30 */
	.octa 0x100030000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1100
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0xc00000000087000e0000000000001000
	/* C10 */
	.octa 0x7fffc0000
	/* C11 */
	.octa 0x800000004001421c0000000000404400
	/* C16 */
	.octa 0x40800010
	/* C19 */
	.octa 0x7fffc0000
	/* C25 */
	.octa 0x2001
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000000500030000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x901000004f840f8c00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425f7c20 // ALDAR-C.R-C Ct:0 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2dd8bde // CHKSSU-C.CC-C Cd:30 Cn:30 0010:0010 opc:10 Cm:29 11000010110:11000010110
	.inst 0xa2ff83f0 // SWPAL-CC.R-C Ct:16 Rn:31 100000:100000 Cs:31 1:1 R:1 A:1 10100010:10100010
	.inst 0xe276d73f // ALDUR-V.RI-H Rt:31 Rn:25 op2:01 imm9:101101101 V:1 op1:01 11100010:11100010
	.inst 0x287af97d // ldnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:29 Rn:11 Rt2:11110 imm7:1110101 L:1 1010000:1010000 opc:00
	.inst 0xf26e4153 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:19 Rn:10 imms:010000 immr:101110 N:1 100100:100100 opc:11 sf:1
	.inst 0x4b32041e // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:0 imm3:001 option:000 Rm:18 01011001:01011001 S:0 op:1 sf:0
	.inst 0x387c63ff // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:28 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x08a47ffd // casb:aarch64/instrs/memory/atomicops/cas/single Rt:29 Rn:31 11111:11111 o0:0 Rs:4 1:1 L:0 0010001:0010001 size:00
	.inst 0xb8e160e3 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:7 00:00 opc:110 0:0 Rs:1 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xc2c21300
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
	ldr x27, =initial_cap_values
	.inst 0xc2400361 // ldr c1, [x27, #0]
	.inst 0xc2400764 // ldr c4, [x27, #1]
	.inst 0xc2400b67 // ldr c7, [x27, #2]
	.inst 0xc2400f6a // ldr c10, [x27, #3]
	.inst 0xc240136b // ldr c11, [x27, #4]
	.inst 0xc2401779 // ldr c25, [x27, #5]
	.inst 0xc2401b7c // ldr c28, [x27, #6]
	.inst 0xc2401f7d // ldr c29, [x27, #7]
	.inst 0xc240237e // ldr c30, [x27, #8]
	/* Set up flags and system registers */
	mov x27, #0x00000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x3085103d
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260331b // ldr c27, [c24, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x8260131b // ldr c27, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x24, #0xf
	and x27, x27, x24
	cmp x27, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400378 // ldr c24, [x27, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400778 // ldr c24, [x27, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400b78 // ldr c24, [x27, #2]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400f78 // ldr c24, [x27, #3]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2401378 // ldr c24, [x27, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401778 // ldr c24, [x27, #5]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc2401b78 // ldr c24, [x27, #6]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc2401f78 // ldr c24, [x27, #7]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2402378 // ldr c24, [x27, #8]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402778 // ldr c24, [x27, #9]
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	.inst 0xc2402b78 // ldr c24, [x27, #10]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2402f78 // ldr c24, [x27, #11]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x27, =0x0
	mov x24, v31.d[0]
	cmp x27, x24
	b.ne comparison_fail
	ldr x27, =0x0
	mov x24, v31.d[1]
	cmp x27, x24
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
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001110
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f6e
	ldr x1, =check_data2
	ldr x2, =0x00001f70
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
	ldr x0, =0x004043d4
	ldr x1, =check_data4
	ldr x2, =0x004043dc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
