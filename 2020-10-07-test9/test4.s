.section data0, #alloc, #write
	.zero 1920
	.byte 0x00, 0x00, 0xfc, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2160
.data
check_data0:
	.byte 0xfc, 0x1f
.data
check_data1:
	.byte 0xfc, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x00, 0x41, 0xc3, 0xc2, 0x61, 0xf9, 0xfa, 0x10, 0xe2, 0x27, 0x58, 0xe2, 0x1e, 0xc0, 0xd6, 0xc2
	.byte 0xa0, 0x00, 0x1f, 0xd6
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xd6, 0x0a, 0x99, 0xb8, 0x5a, 0xfc, 0xdf, 0x48
	.byte 0x8c, 0xc5, 0xfe, 0x82, 0xe2, 0xa7, 0x1a, 0xf8, 0xca, 0x01, 0x00, 0x1a, 0x20, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x8001
	/* C5 */
	.octa 0x401008
	/* C8 */
	.octa 0x400240110040000000008001
	/* C12 */
	.octa 0x80000000000300070000000000401000
	/* C22 */
	.octa 0x400160
final_cap_values:
	/* C0 */
	.octa 0x400240110000000000008001
	/* C1 */
	.octa 0x3f5f30
	/* C2 */
	.octa 0x1ffc
	/* C3 */
	.octa 0x8001
	/* C5 */
	.octa 0x401008
	/* C8 */
	.octa 0x400240110040000000008001
	/* C12 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000400000010000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c34100 // SCVALUE-C.CR-C Cd:0 Cn:8 000:000 opc:10 0:0 Rm:3 11000010110:11000010110
	.inst 0x10faf961 // ADR-C.I-C Rd:1 immhi:111101011111001011 P:1 10000:10000 immlo:00 op:0
	.inst 0xe25827e2 // ALDURH-R.RI-32 Rt:2 Rn:31 op2:01 imm9:110000010 V:0 op1:01 11100010:11100010
	.inst 0xc2d6c01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:22 11000010110:11000010110
	.inst 0xd61f00a0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:5 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 4084
	.inst 0xb8990ad6 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:22 Rn:22 10:10 imm9:110010000 0:0 opc:10 111000:111000 size:10
	.inst 0x48dffc5a // ldarh:aarch64/instrs/memory/ordered Rt:26 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x82fec58c // ALDR-R.RRB-64 Rt:12 Rn:12 opc:01 S:0 option:110 Rm:30 1:1 L:1 100000101:100000101
	.inst 0xf81aa7e2 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:31 01:01 imm9:110101010 0:0 opc:00 111000:111000 size:11
	.inst 0x1a0001ca // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:10 Rn:14 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c21320
	.zero 1044448
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x24, cptr_el3
	orr x24, x24, #0x200
	msr cptr_el3, x24
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
	ldr x24, =initial_cap_values
	.inst 0xc2400303 // ldr c3, [x24, #0]
	.inst 0xc2400705 // ldr c5, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f0c // ldr c12, [x24, #3]
	.inst 0xc2401316 // ldr c22, [x24, #4]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82603338 // ldr c24, [c25, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601338 // ldr c24, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x25, #0xf
	and x24, x24, x25
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400319 // ldr c25, [x24, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400719 // ldr c25, [x24, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400b19 // ldr c25, [x24, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400f19 // ldr c25, [x24, #3]
	.inst 0xc2d9a461 // chkeq c3, c25
	b.ne comparison_fail
	.inst 0xc2401319 // ldr c25, [x24, #4]
	.inst 0xc2d9a4a1 // chkeq c5, c25
	b.ne comparison_fail
	.inst 0xc2401719 // ldr c25, [x24, #5]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401b19 // ldr c25, [x24, #6]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401f19 // ldr c25, [x24, #7]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc2402319 // ldr c25, [x24, #8]
	.inst 0xc2d9a741 // chkeq c26, c25
	b.ne comparison_fail
	.inst 0xc2402719 // ldr c25, [x24, #9]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001782
	ldr x1, =check_data0
	ldr x2, =0x00001784
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001808
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
	ldr x2, =0x00400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004000f0
	ldr x1, =check_data4
	ldr x2, =0x004000f4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401000
	ldr x1, =check_data5
	ldr x2, =0x00401020
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
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
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
