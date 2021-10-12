.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x66
.data
check_data4:
	.byte 0xc5, 0xaf, 0x93, 0x78, 0xe1, 0x87, 0xde, 0xc2, 0xfd, 0x99, 0x07, 0x38, 0x20, 0x67, 0x46, 0x78
	.byte 0xd4, 0x7f, 0xc0, 0x9b, 0x9e, 0x10, 0x0d, 0x52, 0xc1, 0x2b, 0x04, 0xe2, 0x1e, 0x20, 0xdf, 0xc2
	.byte 0xf9, 0xa0, 0x1b, 0xe2, 0x42, 0x33, 0xc4, 0xc2
.data
check_data5:
	.byte 0x40, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0xb7ffbc
	/* C7 */
	.octa 0x2040
	/* C15 */
	.octa 0x40000000400300060000000000001000
	/* C25 */
	.octa 0x800000000000c0000000000000001000
	/* C26 */
	.octa 0x90000000000100050000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x8000000000008008000000000000200a
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0xb7ffbc
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x2040
	/* C15 */
	.octa 0x40000000400300060000000000001000
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x800000000000c0000000000000001066
	/* C26 */
	.octa 0x90000000000100050000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000300050000000000400029
initial_SP_EL3_value:
	.octa 0xc878c3b0000000000908001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7893afc5 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:5 Rn:30 11:11 imm9:100111010 0:0 opc:10 111000:111000 size:01
	.inst 0xc2de87e1 // CHKSS-_.CC-C 00001:00001 Cn:31 001:001 opc:00 1:1 Cm:30 11000010110:11000010110
	.inst 0x380799fd // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:29 Rn:15 10:10 imm9:001111001 0:0 opc:00 111000:111000 size:00
	.inst 0x78466720 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:25 01:01 imm9:001100110 0:0 opc:01 111000:111000 size:01
	.inst 0x9bc07fd4 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:20 Rn:30 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0x520d109e // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:4 imms:000100 immr:001101 N:0 100100:100100 opc:10 sf:0
	.inst 0xe2042bc1 // ALDURSB-R.RI-64 Rt:1 Rn:30 op2:10 imm9:001000010 V:0 op1:00 11100010:11100010
	.inst 0xc2df201e // SCBNDSE-C.CR-C Cd:30 Cn:0 000:000 opc:01 0:0 Rm:31 11000010110:11000010110
	.inst 0xe21ba0f9 // ASTURB-R.RI-32 Rt:25 Rn:7 op2:00 imm9:110111010 V:0 op1:00 11100010:11100010
	.inst 0xc2c43342 // LDPBLR-C.C-C Ct:2 Cn:26 100:100 opc:01 11000010110001000:11000010110001000
	.zero 4056
	.inst 0xc2c21140
	.zero 1044476
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2400527 // ldr c7, [x9, #1]
	.inst 0xc240092f // ldr c15, [x9, #2]
	.inst 0xc2400d39 // ldr c25, [x9, #3]
	.inst 0xc240113a // ldr c26, [x9, #4]
	.inst 0xc240153d // ldr c29, [x9, #5]
	.inst 0xc240193e // ldr c30, [x9, #6]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603149 // ldr c9, [c10, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x82601149 // ldr c9, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x10, #0xf
	and x9, x9, x10
	cmp x9, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc240012a // ldr c10, [x9, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240052a // ldr c10, [x9, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc240092a // ldr c10, [x9, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400d2a // ldr c10, [x9, #3]
	.inst 0xc2caa481 // chkeq c4, c10
	b.ne comparison_fail
	.inst 0xc240112a // ldr c10, [x9, #4]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240152a // ldr c10, [x9, #5]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240192a // ldr c10, [x9, #6]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc2401d2a // ldr c10, [x9, #7]
	.inst 0xc2caa681 // chkeq c20, c10
	b.ne comparison_fail
	.inst 0xc240212a // ldr c10, [x9, #8]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240252a // ldr c10, [x9, #9]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc240292a // ldr c10, [x9, #10]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2402d2a // ldr c10, [x9, #11]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001079
	ldr x1, =check_data1
	ldr x2, =0x0000107a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f44
	ldr x1, =check_data2
	ldr x2, =0x00001f46
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffa
	ldr x1, =check_data3
	ldr x2, =0x00001ffb
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401000
	ldr x1, =check_data5
	ldr x2, =0x00401004
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
