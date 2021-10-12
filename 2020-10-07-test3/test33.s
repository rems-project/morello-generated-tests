.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xca, 0x30, 0x02, 0x54, 0x09, 0xa8, 0x94, 0x38, 0x35, 0xe4, 0x8b, 0x5a, 0x9e, 0x7e, 0x7f, 0x42
	.byte 0x1f, 0xe0, 0x54, 0x78, 0x20, 0x00, 0x1f, 0xd6
.data
check_data1:
	.byte 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2
.data
check_data5:
	.byte 0x3f, 0x59, 0x94, 0x98, 0x43, 0xc0, 0x88, 0xf9, 0xf4, 0xf3, 0xc5, 0xc2, 0xfe, 0xe1, 0x32, 0x6b
	.byte 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x401000
	/* C1 */
	.octa 0x4e0000
	/* C20 */
	.octa 0x8000000000078003000000000049fffe
final_cap_values:
	/* C0 */
	.octa 0x401000
	/* C1 */
	.octa 0x4e0000
	/* C9 */
	.octa 0xffffffffffffffc2
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x4e0000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa00080000f0640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x540230ca // b_cond:aarch64/instrs/branch/conditional/cond cond:1010 0:0 imm19:0000001000110000110 01010100:01010100
	.inst 0x3894a809 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:0 10:10 imm9:101001010 0:0 opc:10 111000:111000 size:00
	.inst 0x5a8be435 // csneg:aarch64/instrs/integer/conditional/select Rd:21 Rn:1 o2:1 0:0 cond:1110 Rm:11 011010100:011010100 op:1 sf:0
	.inst 0x427f7e9e // ALDARB-R.R-B Rt:30 Rn:20 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x7854e01f // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:0 00:00 imm9:101001110 0:0 opc:01 111000:111000 size:01
	.inst 0xd61f0020 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 3888
	.inst 0x00c20000
	.inst 0xc2c20000
	.zero 31700
	.inst 0xc2c2c2c2
	.zero 619732
	.inst 0x00c20000
	.zero 262144
	.inst 0x9894593f // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:31 imm19:1001010001011001001 011000:011000 opc:10
	.inst 0xf988c043 // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:3 Rn:2 imm12:001000110000 opc:10 111001:111001 size:11
	.inst 0xc2c5f3f4 // CVTPZ-C.R-C Cd:20 Rn:31 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x6b32e1fe // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:15 imm3:000 option:111 Rm:18 01011001:01011001 S:1 op:1 sf:0
	.inst 0xc2c21060
	.zero 131052
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
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b14 // ldr c20, [x24, #2]
	/* Set up flags and system registers */
	mov x24, #0x80000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82603078 // ldr c24, [c3, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601078 // ldr c24, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400303 // ldr c3, [x24, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400703 // ldr c3, [x24, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400b03 // ldr c3, [x24, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400f03 // ldr c3, [x24, #3]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2401303 // ldr c3, [x24, #4]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00400000
	ldr x1, =check_data0
	ldr x2, =0x00400018
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400f4a
	ldr x1, =check_data1
	ldr x2, =0x00400f4b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400f4e
	ldr x1, =check_data2
	ldr x2, =0x00400f50
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00408b24
	ldr x1, =check_data3
	ldr x2, =0x00408b28
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0049fffe
	ldr x1, =check_data4
	ldr x2, =0x0049ffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004e0000
	ldr x1, =check_data5
	ldr x2, =0x004e0014
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
