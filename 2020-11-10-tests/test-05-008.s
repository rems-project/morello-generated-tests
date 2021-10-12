.section data0, #alloc, #write
	.zero 80
	.byte 0x01, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x88, 0x00, 0x80, 0x00, 0x20
	.zero 4000
.data
check_data0:
	.zero 16
	.byte 0x01, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x88, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x22, 0x20, 0xc0, 0x01, 0xc0
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xdf, 0x43, 0x07, 0x79, 0x22, 0x44, 0x82, 0x1a, 0xf3, 0x8b, 0xc7, 0xc2, 0xdf, 0xab, 0xc1, 0xc2
	.byte 0x30, 0x7c, 0x9f, 0xc8, 0x22, 0x1c, 0xbd, 0x34, 0x7c, 0xaa, 0xc1, 0xc2, 0x40, 0x32, 0xc4, 0xc2
.data
check_data4:
	.zero 32
.data
check_data5:
	.byte 0xc0, 0x2b, 0x49, 0xad, 0xe1, 0x7e, 0xde, 0x9b, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1070
	/* C7 */
	.octa 0x4201003e00ffffffffffe001
	/* C16 */
	.octa 0xc001c02022000000
	/* C18 */
	.octa 0x900000004002051a0000000000001040
	/* C30 */
	.octa 0x100000000000000000000001000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x1070
	/* C7 */
	.octa 0x4201003e00ffffffffffe001
	/* C16 */
	.octa 0xc001c02022000000
	/* C18 */
	.octa 0x900000004002051a0000000000001040
	/* C19 */
	.octa 0x4084003f0000000000000001
	/* C28 */
	.octa 0x4084003f0000000000000001
	/* C30 */
	.octa 0xa0008000480000000000000000400020
initial_SP_EL3_value:
	.octa 0x2004084003f0000000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000480000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000300000000000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001050
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x790743df // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:30 imm12:000111010000 opc:00 111001:111001 size:01
	.inst 0x1a824422 // csinc:aarch64/instrs/integer/conditional/select Rd:2 Rn:1 o2:1 0:0 cond:0100 Rm:2 011010100:011010100 op:0 sf:0
	.inst 0xc2c78bf3 // CHKSSU-C.CC-C Cd:19 Cn:31 0010:0010 opc:10 Cm:7 11000010110:11000010110
	.inst 0xc2c1abdf // EORFLGS-C.CR-C Cd:31 Cn:30 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0xc89f7c30 // stllr:aarch64/instrs/memory/ordered Rt:16 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x34bd1c22 // cbz:aarch64/instrs/branch/conditional/compare Rt:2 imm19:1011110100011100001 op:0 011010:011010 sf:0
	.inst 0xc2c1aa7c // EORFLGS-C.CR-C Cd:28 Cn:19 1010:1010 opc:10 Rm:1 11000010110:11000010110
	.inst 0xc2c43240 // LDPBLR-C.C-C Ct:0 Cn:18 100:100 opc:01 11000010110001000:11000010110001000
	.zero 32736
	.inst 0xad492bc0 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:30 Rt2:01010 imm7:0010010 L:1 1011010:1011010 opc:10
	.inst 0x9bde7ee1 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:1 Rn:23 Ra:11111 0:0 Rm:30 10:10 U:1 10011011:10011011
	.inst 0xc2c21300
	.zero 1015796
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a7 // ldr c7, [x21, #1]
	.inst 0xc2400ab0 // ldr c16, [x21, #2]
	.inst 0xc2400eb2 // ldr c18, [x21, #3]
	.inst 0xc24012be // ldr c30, [x21, #4]
	/* Set up flags and system registers */
	mov x21, #0x80000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851037
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603315 // ldr c21, [c24, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601315 // ldr c21, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x24, #0xf
	and x21, x21, x24
	cmp x21, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b8 // ldr c24, [x21, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24006b8 // ldr c24, [x21, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400ab8 // ldr c24, [x21, #2]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2400eb8 // ldr c24, [x21, #3]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc24012b8 // ldr c24, [x21, #4]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24016b8 // ldr c24, [x21, #5]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2401ab8 // ldr c24, [x21, #6]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc2401eb8 // ldr c24, [x21, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x24, v0.d[0]
	cmp x21, x24
	b.ne comparison_fail
	ldr x21, =0x0
	mov x24, v0.d[1]
	cmp x21, x24
	b.ne comparison_fail
	ldr x21, =0x0
	mov x24, v10.d[0]
	cmp x21, x24
	b.ne comparison_fail
	ldr x21, =0x0
	mov x24, v10.d[1]
	cmp x21, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001060
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001078
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013a0
	ldr x1, =check_data2
	ldr x2, =0x000013a2
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
	ldr x0, =0x00400140
	ldr x1, =check_data4
	ldr x2, =0x00400160
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00408000
	ldr x1, =check_data5
	ldr x2, =0x0040800c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
