.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x40, 0x00, 0x40
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x3e, 0x44, 0xdf, 0xc2, 0x5e, 0xc8, 0x9f, 0x82, 0xeb, 0xaa, 0x7f, 0x88, 0x40, 0xe8, 0x21, 0x78
	.byte 0xf1, 0x7f, 0xff, 0xa2, 0xbf, 0x9c, 0x95, 0xe2, 0xff, 0x2d, 0xde, 0x9a, 0xc2, 0xfe, 0x1f, 0x42
	.byte 0xb4, 0x01, 0xa0, 0x9b, 0xc0, 0x4f, 0x80, 0x82, 0xa0, 0x13, 0xc2, 0xc2
.data
check_data5:
	.byte 0x08, 0x10
.data
check_data6:
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x01
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffc00090
	/* C2 */
	.octa 0x40004000000600170000000000401000
	/* C5 */
	.octa 0x2007
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C22 */
	.octa 0x48000000000100050000000000001000
	/* C23 */
	.octa 0x80000000000300070000000000001ff0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffc00090
	/* C2 */
	.octa 0x40004000000600170000000000401000
	/* C5 */
	.octa 0x2007
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x48000000000100050000000000001000
	/* C23 */
	.octa 0x80000000000300070000000000001ff0
	/* C30 */
	.octa 0x1008
initial_SP_EL3_value:
	.octa 0xd80000000001000500000000004fc8e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000180010080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000800
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df443e // CSEAL-C.C-C Cd:30 Cn:1 001:001 opc:10 0:0 Cm:31 11000010110:11000010110
	.inst 0x829fc85e // ALDRSH-R.RRB-64 Rt:30 Rn:2 opc:10 S:0 option:110 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x887faaeb // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:11 Rn:23 Rt2:01010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0x7821e840 // strh_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:2 10:10 S:0 option:111 Rm:1 1:1 opc:00 111000:111000 size:01
	.inst 0xa2ff7ff1 // CASA-C.R-C Ct:17 Rn:31 11111:11111 R:0 Cs:31 1:1 L:1 1:1 10100010:10100010
	.inst 0xe2959cbf // ASTUR-C.RI-C Ct:31 Rn:5 op2:11 imm9:101011001 V:0 op1:10 11100010:11100010
	.inst 0x9ade2dff // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:15 op2:11 0010:0010 Rm:30 0011010110:0011010110 sf:1
	.inst 0x421ffec2 // STLR-C.R-C Ct:2 Rn:22 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x9ba001b4 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:20 Rn:13 Ra:0 o0:0 Rm:0 01:01 U:1 10011011:10011011
	.inst 0x82804fc0 // ASTRH-R.RRB-32 Rt:0 Rn:30 opc:11 S:0 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xc2c213a0
	.zero 4052
	.inst 0x00001008
	.zero 1030364
	.inst 0x01010101
	.inst 0x01000001
	.zero 4
	.inst 0x01000101
	.zero 14096
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2400f25 // ldr c5, [x25, #3]
	.inst 0xc2401331 // ldr c17, [x25, #4]
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2401b37 // ldr c23, [x25, #6]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x29, =pcc_return_ddc_capabilities
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0x826033b9 // ldr c25, [c29, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826013b9 // ldr c25, [c29, #1]
	.inst 0x826023bd // ldr c29, [c29, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x29, #0xf
	and x25, x25, x29
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc240033d // ldr c29, [x25, #0]
	.inst 0xc2dda401 // chkeq c0, c29
	b.ne comparison_fail
	.inst 0xc240073d // ldr c29, [x25, #1]
	.inst 0xc2dda421 // chkeq c1, c29
	b.ne comparison_fail
	.inst 0xc2400b3d // ldr c29, [x25, #2]
	.inst 0xc2dda441 // chkeq c2, c29
	b.ne comparison_fail
	.inst 0xc2400f3d // ldr c29, [x25, #3]
	.inst 0xc2dda4a1 // chkeq c5, c29
	b.ne comparison_fail
	.inst 0xc240133d // ldr c29, [x25, #4]
	.inst 0xc2dda541 // chkeq c10, c29
	b.ne comparison_fail
	.inst 0xc240173d // ldr c29, [x25, #5]
	.inst 0xc2dda561 // chkeq c11, c29
	b.ne comparison_fail
	.inst 0xc2401b3d // ldr c29, [x25, #6]
	.inst 0xc2dda621 // chkeq c17, c29
	b.ne comparison_fail
	.inst 0xc2401f3d // ldr c29, [x25, #7]
	.inst 0xc2dda681 // chkeq c20, c29
	b.ne comparison_fail
	.inst 0xc240233d // ldr c29, [x25, #8]
	.inst 0xc2dda6c1 // chkeq c22, c29
	b.ne comparison_fail
	.inst 0xc240273d // ldr c29, [x25, #9]
	.inst 0xc2dda6e1 // chkeq c23, c29
	b.ne comparison_fail
	.inst 0xc2402b3d // ldr c29, [x25, #10]
	.inst 0xc2dda7c1 // chkeq c30, c29
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
	ldr x0, =0x00001090
	ldr x1, =check_data1
	ldr x2, =0x00001092
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f60
	ldr x1, =check_data2
	ldr x2, =0x00001f70
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	ldr x0, =0x00401000
	ldr x1, =check_data5
	ldr x2, =0x00401002
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004fc8e0
	ldr x1, =check_data6
	ldr x2, =0x004fc8f0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
