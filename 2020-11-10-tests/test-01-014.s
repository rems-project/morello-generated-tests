.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x22, 0xfd, 0xe1, 0xa2, 0x1f, 0x98, 0x10, 0x78, 0x82, 0x4c, 0x3e, 0x02, 0x1f, 0x28, 0xbe, 0x9b
	.byte 0x07, 0xbd, 0xde, 0xc2, 0x00, 0xfe, 0x5f, 0x08, 0xe2, 0x2f, 0xa1, 0x2a, 0x41, 0x41, 0x61, 0xb8
	.byte 0xfb, 0x73, 0x64, 0x82, 0xd3, 0x89, 0xdf, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10f7
	/* C1 */
	.octa 0xffffffffffffffffffffffffffffffff
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x8000140060000000000000000
	/* C9 */
	.octa 0x1080
	/* C10 */
	.octa 0x1000
	/* C14 */
	.octa 0x400100040000000000000000
	/* C16 */
	.octa 0x1100
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffff
	/* C4 */
	.octa 0x8000140060000000000000000
	/* C9 */
	.octa 0x1080
	/* C10 */
	.octa 0x1000
	/* C14 */
	.octa 0x400100040000000000000000
	/* C16 */
	.octa 0x1100
	/* C19 */
	.octa 0x400100040000000000000000
	/* C27 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x90100000580200250000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000f00030000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005102000000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword initial_cap_values + 16
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2e1fd22 // CASAL-C.R-C Ct:2 Rn:9 11111:11111 R:1 Cs:1 1:1 L:1 1:1 10100010:10100010
	.inst 0x7810981f // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:0 10:10 imm9:100001001 0:0 opc:00 111000:111000 size:01
	.inst 0x023e4c82 // ADD-C.CIS-C Cd:2 Cn:4 imm12:111110010011 sh:0 A:0 00000010:00000010
	.inst 0x9bbe281f // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:0 Ra:10 o0:0 Rm:30 01:01 U:1 10011011:10011011
	.inst 0xc2debd07 // CSEL-C.CI-C Cd:7 Cn:8 11:11 cond:1011 Cm:30 11000010110:11000010110
	.inst 0x085ffe00 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:0 Rn:16 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x2aa12fe2 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:31 imm6:001011 Rm:1 N:1 shift:10 01010:01010 opc:01 sf:0
	.inst 0xb8614141 // ldsmax:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:10 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x826473fb // ALDR-C.RI-C Ct:27 Rn:31 op:00 imm9:001000111 L:1 1000001001:1000001001
	.inst 0xc2df89d3 // CHKSSU-C.CC-C Cd:19 Cn:14 0010:0010 opc:10 Cm:31 11000010110:11000010110
	.inst 0xc2c212e0
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b82 // ldr c2, [x28, #2]
	.inst 0xc2400f84 // ldr c4, [x28, #3]
	.inst 0xc2401389 // ldr c9, [x28, #4]
	.inst 0xc240178a // ldr c10, [x28, #5]
	.inst 0xc2401b8e // ldr c14, [x28, #6]
	.inst 0xc2401f90 // ldr c16, [x28, #7]
	/* Set up flags and system registers */
	mov x28, #0x80000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x3085103f
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032fc // ldr c28, [c23, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826012fc // ldr c28, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x23, #0xf
	and x28, x28, x23
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400397 // ldr c23, [x28, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400797 // ldr c23, [x28, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400b97 // ldr c23, [x28, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400f97 // ldr c23, [x28, #3]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401397 // ldr c23, [x28, #4]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc2401797 // ldr c23, [x28, #5]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401b97 // ldr c23, [x28, #6]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401f97 // ldr c23, [x28, #7]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2402397 // ldr c23, [x28, #8]
	.inst 0xc2d7a661 // chkeq c19, c23
	b.ne comparison_fail
	.inst 0xc2402797 // ldr c23, [x28, #9]
	.inst 0xc2d7a761 // chkeq c27, c23
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001101
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001470
	ldr x1, =check_data3
	ldr x2, =0x00001480
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
