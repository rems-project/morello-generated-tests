.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0xe0, 0x57, 0x0c, 0x38, 0x0e, 0x90, 0xc0, 0xc2, 0x40, 0x01, 0x3f, 0xd6
.data
check_data2:
	.byte 0xc0, 0x93, 0x84, 0xf8, 0xed, 0x2f, 0xc0, 0x1a, 0xe2, 0x8a, 0x2c, 0xb0, 0x3d, 0xfc, 0x7f, 0x42
	.byte 0x84, 0x05, 0xc1, 0xc2, 0x41, 0x44, 0xc2, 0xc2, 0xc2, 0x0c, 0x19, 0xe2, 0x80, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000004d004700000000004ffff0
	/* C6 */
	.octa 0x8000000000010005000000000050006e
	/* C10 */
	.octa 0x100
	/* C12 */
	.octa 0x4000300070000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x5915d000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x300070000000000000000
	/* C6 */
	.octa 0x8000000000010005000000000050006e
	/* C10 */
	.octa 0x100
	/* C12 */
	.octa 0x4000300070000000000000000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc
initial_SP_EL3_value:
	.octa 0x1ffe
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400010000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x380c57e0 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:31 01:01 imm9:011000101 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c0900e // GCTAG-R.C-C Rd:14 Cn:0 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xd63f0140 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:10 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 244
	.inst 0xf88493c0 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:30 00:00 imm9:001001001 0:0 opc:10 111000:111000 size:11
	.inst 0x1ac02fed // rorv:aarch64/instrs/integer/shift/variable Rd:13 Rn:31 op2:11 0010:0010 Rm:0 0011010110:0011010110 sf:0
	.inst 0xb02c8ae2 // ADRDP-C.ID-C Rd:2 immhi:010110010001010111 P:0 10000:10000 immlo:01 op:1
	.inst 0x427ffc3d // ALDAR-R.R-32 Rt:29 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c10584 // BUILD-C.C-C Cd:4 Cn:12 001:001 opc:00 0:0 Cm:1 11000010110:11000010110
	.inst 0xc2c24441 // CSEAL-C.C-C Cd:1 Cn:2 001:001 opc:10 0:0 Cm:2 11000010110:11000010110
	.inst 0xe2190cc2 // ALDURSB-R.RI-32 Rt:2 Rn:6 op2:11 imm9:110010000 V:0 op1:00 11100010:11100010
	.inst 0xc2c21280
	.zero 1048288
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x5, cptr_el3
	orr x5, x5, #0x200
	msr cptr_el3, x5
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
	ldr x5, =initial_cap_values
	.inst 0xc24000a0 // ldr c0, [x5, #0]
	.inst 0xc24004a1 // ldr c1, [x5, #1]
	.inst 0xc24008a6 // ldr c6, [x5, #2]
	.inst 0xc2400caa // ldr c10, [x5, #3]
	.inst 0xc24010ac // ldr c12, [x5, #4]
	/* Set up flags and system registers */
	mov x5, #0x00000000
	msr nzcv, x5
	ldr x5, =initial_SP_EL3_value
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0xc2c1d0bf // cpy c31, c5
	ldr x5, =0x200
	msr CPTR_EL3, x5
	ldr x5, =0x30850030
	msr SCTLR_EL3, x5
	ldr x5, =0x8
	msr S3_6_C1_C2_2, x5 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603285 // ldr c5, [c20, #3]
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	.inst 0x82601285 // ldr c5, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c210a0 // br c5
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
	isb
	/* Check processor flags */
	mrs x5, nzcv
	ubfx x5, x5, #28, #4
	mov x20, #0xf
	and x5, x5, x20
	cmp x5, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x5, =final_cap_values
	.inst 0xc24000b4 // ldr c20, [x5, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc24004b4 // ldr c20, [x5, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc24008b4 // ldr c20, [x5, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400cb4 // ldr c20, [x5, #3]
	.inst 0xc2d4a481 // chkeq c4, c20
	b.ne comparison_fail
	.inst 0xc24010b4 // ldr c20, [x5, #4]
	.inst 0xc2d4a4c1 // chkeq c6, c20
	b.ne comparison_fail
	.inst 0xc24014b4 // ldr c20, [x5, #5]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc24018b4 // ldr c20, [x5, #6]
	.inst 0xc2d4a581 // chkeq c12, c20
	b.ne comparison_fail
	.inst 0xc2401cb4 // ldr c20, [x5, #7]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc24020b4 // ldr c20, [x5, #8]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc24024b4 // ldr c20, [x5, #9]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc24028b4 // ldr c20, [x5, #10]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffe
	ldr x1, =check_data0
	ldr x2, =0x00001fff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040000c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400100
	ldr x1, =check_data2
	ldr x2, =0x00400120
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004ffff0
	ldr x1, =check_data3
	ldr x2, =0x004ffff4
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b005 // cvtp c5, x0
	.inst 0xc2df40a5 // scvalue c5, c5, x31
	.inst 0xc28b4125 // msr DDC_EL3, c5
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
