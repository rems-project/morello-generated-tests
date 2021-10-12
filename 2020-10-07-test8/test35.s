.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6d, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x01
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xee, 0xa8, 0xed, 0xc2, 0x00, 0xdc, 0x99, 0x82, 0x0e, 0xfa, 0x0b, 0xa2, 0xe2, 0x33, 0x96, 0xda
	.byte 0x3f, 0x7c, 0xdf, 0x08, 0x82, 0xd8, 0x0d, 0xb0, 0xc2, 0xc5, 0x21, 0xeb, 0xa4, 0x8a, 0x1b, 0x1b
	.byte 0x00, 0x00, 0x5f, 0xd6
.data
check_data4:
	.byte 0xa2, 0x4d, 0x1a, 0x38, 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x100
	/* C1 */
	.octa 0x800000000007a00f000000000040c000
	/* C7 */
	.octa 0x20000000000000000000000000
	/* C13 */
	.octa 0x4000000000010007000000000000111c
	/* C16 */
	.octa 0x40000000000020000000000000000410
	/* C25 */
	.octa 0x7c0
final_cap_values:
	/* C0 */
	.octa 0x100
	/* C1 */
	.octa 0x800000000007a00f000000000040c000
	/* C2 */
	.octa 0x6cffffffff7e8000
	/* C7 */
	.octa 0x20000000000000000000000000
	/* C13 */
	.octa 0x400000000001000700000000000010c0
	/* C14 */
	.octa 0x20000000006d00000000000000
	/* C16 */
	.octa 0x40000000000020000000000000000410
	/* C25 */
	.octa 0x7c0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004002000400fffffffffff000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2eda8ee // ORRFLGS-C.CI-C Cd:14 Cn:7 0:0 01:01 imm8:01101101 11000010111:11000010111
	.inst 0x8299dc00 // ASTRH-R.RRB-32 Rt:0 Rn:0 opc:11 S:1 option:110 Rm:25 0:0 L:0 100000101:100000101
	.inst 0xa20bfa0e // STTR-C.RIB-C Ct:14 Rn:16 10:10 imm9:010111111 0:0 opc:00 10100010:10100010
	.inst 0xda9633e2 // csinv:aarch64/instrs/integer/conditional/select Rd:2 Rn:31 o2:0 0:0 cond:0011 Rm:22 011010100:011010100 op:1 sf:1
	.inst 0x08df7c3f // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:1 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb00dd882 // ADRP-C.I-C Rd:2 immhi:000110111011000100 P:0 10000:10000 immlo:01 op:1
	.inst 0xeb21c5c2 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:2 Rn:14 imm3:001 option:110 Rm:1 01011001:01011001 S:1 op:1 sf:1
	.inst 0x1b1b8aa4 // msub:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:4 Rn:21 Ra:2 o0:1 Rm:27 0011011000:0011011000 sf:0
	.inst 0xd65f0000 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:0 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 220
	.inst 0x381a4da2 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:13 11:11 imm9:110100100 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c21180
	.zero 1048312
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x8, cptr_el3
	orr x8, x8, #0x200
	msr cptr_el3, x8
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400907 // ldr c7, [x8, #2]
	.inst 0xc2400d0d // ldr c13, [x8, #3]
	.inst 0xc2401110 // ldr c16, [x8, #4]
	.inst 0xc2401519 // ldr c25, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	ldr x8, =0x8
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603188 // ldr c8, [c12, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601188 // ldr c8, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x12, #0xf
	and x8, x8, x12
	cmp x8, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240010c // ldr c12, [x8, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240050c // ldr c12, [x8, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400d0c // ldr c12, [x8, #3]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240110c // ldr c12, [x8, #4]
	.inst 0xc2cca5a1 // chkeq c13, c12
	b.ne comparison_fail
	.inst 0xc240150c // ldr c12, [x8, #5]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc240190c // ldr c12, [x8, #6]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc2401d0c // ldr c12, [x8, #7]
	.inst 0xc2cca721 // chkeq c25, c12
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c1
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400024
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400100
	ldr x1, =check_data4
	ldr x2, =0x00400108
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040c000
	ldr x1, =check_data5
	ldr x2, =0x0040c001
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
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

	.balign 128
vector_table:
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
