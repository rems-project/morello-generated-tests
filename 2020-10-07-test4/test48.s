.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x5e, 0x04, 0xee, 0x68, 0x01, 0xd0, 0xc5, 0xc2, 0x2c, 0xf4, 0x08, 0xe2, 0x48, 0x5b, 0xca, 0xd2
	.byte 0x0f, 0xb0, 0xc0, 0xc2, 0x01, 0x08, 0xc5, 0x9a, 0x62, 0x29, 0xe5, 0x2a, 0x7f, 0x8f, 0x19, 0xf0
	.byte 0x7e, 0xf1, 0xab, 0xe2, 0x0b, 0x78, 0xde, 0x38, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x402010
	/* C2 */
	.octa 0x4041fc
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x40000000000100050000000000000fb9
final_cap_values:
	/* C0 */
	.octa 0x402010
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffffff
	/* C5 */
	.octa 0x0
	/* C8 */
	.octa 0x52da00000000
	/* C11 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x68ee045e // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:30 Rn:2 Rt2:00001 imm7:1011100 L:1 1010001:1010001 opc:01
	.inst 0xc2c5d001 // CVTDZ-C.R-C Cd:1 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xe208f42c // ALDURB-R.RI-32 Rt:12 Rn:1 op2:01 imm9:010001111 V:0 op1:00 11100010:11100010
	.inst 0xd2ca5b48 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:8 imm16:0101001011011010 hw:10 100101:100101 opc:10 sf:1
	.inst 0xc2c0b00f // GCSEAL-R.C-C Rd:15 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0x9ac50801 // udiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:0 o1:0 00001:00001 Rm:5 0011010110:0011010110 sf:1
	.inst 0x2ae52962 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:2 Rn:11 imm6:001010 Rm:5 N:1 shift:11 01010:01010 opc:01 sf:0
	.inst 0xf0198f7f // ADRDP-C.ID-C Rd:31 immhi:001100110001111011 P:0 10000:10000 immlo:11 op:1
	.inst 0xe2abf17e // ASTUR-V.RI-S Rt:30 Rn:11 op2:00 imm9:010111111 V:1 op1:10 11100010:11100010
	.inst 0x38de780b // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:11 Rn:0 10:10 imm9:111100111 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c210e0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae5 // ldr c5, [x23, #2]
	.inst 0xc2400eeb // ldr c11, [x23, #3]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q30, =0x0
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030f7 // ldr c23, [c7, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826010f7 // ldr c23, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e7 // ldr c7, [x23, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24006e7 // ldr c7, [x23, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400ee7 // ldr c7, [x23, #3]
	.inst 0xc2c7a4a1 // chkeq c5, c7
	b.ne comparison_fail
	.inst 0xc24012e7 // ldr c7, [x23, #4]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc24016e7 // ldr c7, [x23, #5]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401ae7 // ldr c7, [x23, #6]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401ee7 // ldr c7, [x23, #7]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc24022e7 // ldr c7, [x23, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x7, v30.d[0]
	cmp x23, x7
	b.ne comparison_fail
	ldr x23, =0x0
	mov x7, v30.d[1]
	cmp x23, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001078
	ldr x1, =check_data0
	ldr x2, =0x0000107c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00401ff7
	ldr x1, =check_data2
	ldr x2, =0x00401ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040209f
	ldr x1, =check_data3
	ldr x2, =0x004020a0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004041fc
	ldr x1, =check_data4
	ldr x2, =0x00404204
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
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
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
