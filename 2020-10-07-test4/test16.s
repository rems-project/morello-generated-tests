.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x40, 0xd2, 0xda, 0x82, 0x21, 0x54, 0x7b, 0xe2, 0xe2, 0x4b, 0x89, 0xe2, 0xe1, 0x87, 0x76, 0x82
	.byte 0x69, 0x83, 0x5a, 0x31, 0x10, 0x63, 0xde, 0xc2, 0x77, 0xc8, 0x0d, 0xf8, 0x1f, 0x6f, 0xc8, 0xd8
	.byte 0x61, 0xab, 0xde, 0xc2, 0xc2, 0x53, 0xbd, 0xe2, 0x60, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 1
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1f2f
	/* C3 */
	.octa 0x40000000000100050000000000001f14
	/* C18 */
	.octa 0x4efffe
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x800000140150040000000000f10
	/* C26 */
	.octa 0x10000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x102b
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x40000000000100050000000000001f14
	/* C9 */
	.octa 0x6a0000
	/* C16 */
	.octa 0x80000014015004000000000102b
	/* C18 */
	.octa 0x4efffe
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x800000140150040000000000f10
	/* C26 */
	.octa 0x10000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x102b
initial_SP_EL3_value:
	.octa 0x4817f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82dad240 // ALDRB-R.RRB-B Rt:0 Rn:18 opc:00 S:1 option:110 Rm:26 0:0 L:1 100000101:100000101
	.inst 0xe27b5421 // ALDUR-V.RI-H Rt:1 Rn:1 op2:01 imm9:110110101 V:1 op1:01 11100010:11100010
	.inst 0xe2894be2 // ALDURSW-R.RI-64 Rt:2 Rn:31 op2:10 imm9:010010100 V:0 op1:10 11100010:11100010
	.inst 0x827687e1 // ALDRB-R.RI-B Rt:1 Rn:31 op:01 imm9:101101000 L:1 1000001001:1000001001
	.inst 0x315a8369 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:9 Rn:27 imm12:011010100000 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xc2de6310 // SCOFF-C.CR-C Cd:16 Cn:24 000:000 opc:11 0:0 Rm:30 11000010110:11000010110
	.inst 0xf80dc877 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:23 Rn:3 10:10 imm9:011011100 0:0 opc:00 111000:111000 size:11
	.inst 0xd8c86f1f // prfm_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1100100001101111000 011000:011000 opc:11
	.inst 0xc2deab61 // EORFLGS-C.CR-C Cd:1 Cn:27 1010:1010 opc:10 Rm:30 11000010110:11000010110
	.inst 0xe2bd53c2 // ASTUR-V.RI-S Rt:2 Rn:30 op2:00 imm9:111010101 V:1 op1:10 11100010:11100010
	.inst 0xc2c21260
	.zero 1048532
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
	.inst 0xc2400101 // ldr c1, [x8, #0]
	.inst 0xc2400503 // ldr c3, [x8, #1]
	.inst 0xc2400912 // ldr c18, [x8, #2]
	.inst 0xc2400d17 // ldr c23, [x8, #3]
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc240151a // ldr c26, [x8, #5]
	.inst 0xc240191b // ldr c27, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30850032
	msr SCTLR_EL3, x8
	ldr x8, =0x0
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82603268 // ldr c8, [c19, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x82601268 // ldr c8, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	mov x19, #0xf
	and x8, x8, x19
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400113 // ldr c19, [x8, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400513 // ldr c19, [x8, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400913 // ldr c19, [x8, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400d13 // ldr c19, [x8, #3]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2401113 // ldr c19, [x8, #4]
	.inst 0xc2d3a521 // chkeq c9, c19
	b.ne comparison_fail
	.inst 0xc2401513 // ldr c19, [x8, #5]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401913 // ldr c19, [x8, #6]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2401d13 // ldr c19, [x8, #7]
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	.inst 0xc2402113 // ldr c19, [x8, #8]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc2402513 // ldr c19, [x8, #9]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402913 // ldr c19, [x8, #10]
	.inst 0xc2d3a761 // chkeq c27, c19
	b.ne comparison_fail
	.inst 0xc2402d13 // ldr c19, [x8, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x19, v1.d[0]
	cmp x8, x19
	b.ne comparison_fail
	ldr x8, =0x0
	mov x19, v1.d[1]
	cmp x8, x19
	b.ne comparison_fail
	ldr x8, =0x0
	mov x19, v2.d[0]
	cmp x8, x19
	b.ne comparison_fail
	ldr x8, =0x0
	mov x19, v2.d[1]
	cmp x8, x19
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
	ldr x0, =0x00001ee4
	ldr x1, =check_data1
	ldr x2, =0x00001ee6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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
	ldr x0, =0x00481884
	ldr x1, =check_data4
	ldr x2, =0x00481888
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00481958
	ldr x1, =check_data5
	ldr x2, =0x00481959
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
