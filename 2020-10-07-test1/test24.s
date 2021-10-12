.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x87, 0xff, 0x72, 0x29, 0xd3, 0x13, 0xc0, 0xc2, 0x80, 0xa3, 0xb6, 0xe2, 0xba, 0x17, 0x12, 0x6a
	.byte 0xc2, 0x83, 0x1d, 0xf8, 0x42, 0x0c, 0xc0, 0xc2, 0xc2, 0x03, 0xbe, 0x9b, 0xa1, 0x3c, 0x16, 0x29
	.byte 0x0a, 0x8c, 0x3f, 0x9b, 0xdc, 0x17, 0x75, 0x82, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000600211ec000000000000113c
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x7ffffff
	/* C28 */
	.octa 0x80000000000080080000000000002020
	/* C29 */
	.octa 0x1f
	/* C30 */
	.octa 0x40000000000500030000000000001050
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x40000000600211ec000000000000113c
	/* C7 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C18 */
	.octa 0x7ffffff
	/* C19 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1f
	/* C30 */
	.octa 0x40000000000500030000000000001050
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fd0003a00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2972ff87 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:7 Rn:28 Rt2:11111 imm7:1100101 L:1 1010010:1010010 opc:00
	.inst 0xc2c013d3 // GCBASE-R.C-C Rd:19 Cn:30 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xe2b6a380 // ASTUR-V.RI-S Rt:0 Rn:28 op2:00 imm9:101101010 V:1 op1:10 11100010:11100010
	.inst 0x6a1217ba // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:26 Rn:29 imm6:000101 Rm:18 N:0 shift:00 01010:01010 opc:11 sf:0
	.inst 0xf81d83c2 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:30 00:00 imm9:111011000 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c00c42 // CSEL-C.CI-C Cd:2 Cn:2 11:11 cond:0000 Cm:0 11000010110:11000010110
	.inst 0x9bbe03c2 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:30 Ra:0 o0:0 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x29163ca1 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:1 Rn:5 Rt2:01111 imm7:0101100 L:0 1010010:1010010 opc:00
	.inst 0x9b3f8c0a // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:10 Rn:0 Ra:3 o0:1 Rm:31 01:01 U:0 10011011:10011011
	.inst 0x827517dc // ALDRB-R.RI-B Rt:28 Rn:30 op:01 imm9:101010001 L:1 1000001001:1000001001
	.inst 0xc2c210c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x21, cptr_el3
	orr x21, x21, #0x200
	msr cptr_el3, x21
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a1 // ldr c1, [x21, #0]
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa5 // ldr c5, [x21, #2]
	.inst 0xc2400eaf // ldr c15, [x21, #3]
	.inst 0xc24012b2 // ldr c18, [x21, #4]
	.inst 0xc24016bc // ldr c28, [x21, #5]
	.inst 0xc2401abd // ldr c29, [x21, #6]
	.inst 0xc2401ebe // ldr c30, [x21, #7]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d5 // ldr c21, [c6, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826010d5 // ldr c21, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x6, #0xf
	and x21, x21, x6
	cmp x21, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a6 // ldr c6, [x21, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24006a6 // ldr c6, [x21, #1]
	.inst 0xc2c6a4a1 // chkeq c5, c6
	b.ne comparison_fail
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400ea6 // ldr c6, [x21, #3]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc24012a6 // ldr c6, [x21, #4]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc24016a6 // ldr c6, [x21, #5]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401aa6 // ldr c6, [x21, #6]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2401ea6 // ldr c6, [x21, #7]
	.inst 0xc2c6a781 // chkeq c28, c6
	b.ne comparison_fail
	.inst 0xc24022a6 // ldr c6, [x21, #8]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc24026a6 // ldr c6, [x21, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x6, v0.d[0]
	cmp x21, x6
	b.ne comparison_fail
	ldr x21, =0x0
	mov x6, v0.d[1]
	cmp x21, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x00001030
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011db
	ldr x1, =check_data1
	ldr x2, =0x000011dc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011ec
	ldr x1, =check_data2
	ldr x2, =0x000011f4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fb4
	ldr x1, =check_data3
	ldr x2, =0x00001fbc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fc4
	ldr x1, =check_data4
	ldr x2, =0x00001fc8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
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
