.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0x02, 0xb8, 0x68, 0xf9, 0x67, 0xb1, 0xde, 0x93, 0xc5, 0x13, 0xc7, 0xc2, 0x12, 0x24, 0xc6, 0x9a
	.byte 0x6e, 0x26, 0x2f, 0xa9, 0xe8, 0x1b, 0xf9, 0x29, 0x26, 0x94, 0x59, 0xb8, 0x3f, 0xc6, 0x3c, 0xe2
	.byte 0xe0, 0xda, 0x7f, 0x38, 0x20, 0x8b, 0xde, 0xc2, 0x40, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffc000
	/* C1 */
	.octa 0x1024
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x8000000057d400040000000000001800
	/* C19 */
	.octa 0x2010
	/* C23 */
	.octa 0x1f80
	/* C25 */
	.octa 0x2007000f0000000000000001
	/* C30 */
	.octa 0xc0700040000000000000000
final_cap_values:
	/* C0 */
	.octa 0x2007000f0000000000000001
	/* C1 */
	.octa 0xfbd
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C17 */
	.octa 0x8000000057d400040000000000001800
	/* C19 */
	.octa 0x2010
	/* C23 */
	.octa 0x1f80
	/* C25 */
	.octa 0x2007000f0000000000000001
	/* C30 */
	.octa 0xc0700040000000000000000
initial_SP_EL3_value:
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000420000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffffffff3fe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf968b802 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:0 imm12:101000101110 opc:01 111001:111001 size:11
	.inst 0x93deb167 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:7 Rn:11 imms:101100 Rm:30 0:0 N:1 00100111:00100111 sf:1
	.inst 0xc2c713c5 // RRLEN-R.R-C Rd:5 Rn:30 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x9ac62412 // lsrv:aarch64/instrs/integer/shift/variable Rd:18 Rn:0 op2:01 0010:0010 Rm:6 0011010110:0011010110 sf:1
	.inst 0xa92f266e // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:14 Rn:19 Rt2:01001 imm7:1011110 L:0 1010010:1010010 opc:10
	.inst 0x29f91be8 // ldp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:8 Rn:31 Rt2:00110 imm7:1110010 L:1 1010011:1010011 opc:00
	.inst 0xb8599426 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:1 01:01 imm9:110011001 0:0 opc:01 111000:111000 size:10
	.inst 0xe23cc63f // ALDUR-V.RI-B Rt:31 Rn:17 op2:01 imm9:111001100 V:1 op1:00 11100010:11100010
	.inst 0x387fdae0 // ldrb_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:23 10:10 S:1 option:110 Rm:31 1:1 opc:01 111000:111000 size:00
	.inst 0xc2de8b20 // CHKSSU-C.CC-C Cd:0 Cn:25 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0xc2c21140
	.zero 1048532
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
	.inst 0xc2400b09 // ldr c9, [x24, #2]
	.inst 0xc2400f0e // ldr c14, [x24, #3]
	.inst 0xc2401311 // ldr c17, [x24, #4]
	.inst 0xc2401713 // ldr c19, [x24, #5]
	.inst 0xc2401b17 // ldr c23, [x24, #6]
	.inst 0xc2401f19 // ldr c25, [x24, #7]
	.inst 0xc240231e // ldr c30, [x24, #8]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085003a
	msr SCTLR_EL3, x24
	ldr x24, =0x0
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x82603158 // ldr c24, [c10, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601158 // ldr c24, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	mov x10, #0xf
	and x24, x24, x10
	cmp x24, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc240030a // ldr c10, [x24, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240070a // ldr c10, [x24, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b0a // ldr c10, [x24, #2]
	.inst 0xc2caa441 // chkeq c2, c10
	b.ne comparison_fail
	.inst 0xc2400f0a // ldr c10, [x24, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240130a // ldr c10, [x24, #4]
	.inst 0xc2caa4c1 // chkeq c6, c10
	b.ne comparison_fail
	.inst 0xc240170a // ldr c10, [x24, #5]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc2401b0a // ldr c10, [x24, #6]
	.inst 0xc2caa521 // chkeq c9, c10
	b.ne comparison_fail
	.inst 0xc2401f0a // ldr c10, [x24, #7]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc240230a // ldr c10, [x24, #8]
	.inst 0xc2caa621 // chkeq c17, c10
	b.ne comparison_fail
	.inst 0xc240270a // ldr c10, [x24, #9]
	.inst 0xc2caa661 // chkeq c19, c10
	b.ne comparison_fail
	.inst 0xc2402b0a // ldr c10, [x24, #10]
	.inst 0xc2caa6e1 // chkeq c23, c10
	b.ne comparison_fail
	.inst 0xc2402f0a // ldr c10, [x24, #11]
	.inst 0xc2caa721 // chkeq c25, c10
	b.ne comparison_fail
	.inst 0xc240330a // ldr c10, [x24, #12]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x10, v31.d[0]
	cmp x24, x10
	b.ne comparison_fail
	ldr x24, =0x0
	mov x10, v31.d[1]
	cmp x24, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001024
	ldr x1, =check_data0
	ldr x2, =0x00001028
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001170
	ldr x1, =check_data1
	ldr x2, =0x00001178
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017cc
	ldr x1, =check_data2
	ldr x2, =0x000017cd
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f00
	ldr x1, =check_data3
	ldr x2, =0x00001f10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001f80
	ldr x1, =check_data4
	ldr x2, =0x00001f81
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fc8
	ldr x1, =check_data5
	ldr x2, =0x00001fd0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
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
