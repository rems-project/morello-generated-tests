.section data0, #alloc, #write
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x14, 0x7b, 0x22, 0x72, 0x61, 0x03, 0xae, 0xc2, 0x81, 0x32, 0xc2, 0xc2, 0xfe, 0x07, 0x49, 0x78
	.byte 0x28, 0x7c, 0x56, 0x78, 0xa1, 0x6a, 0xfe, 0x78, 0xfc, 0xa5, 0xac, 0x10, 0x4f, 0x1c, 0x8d, 0x38
	.byte 0x7e, 0x19, 0x49, 0xe2, 0xe0, 0x3c, 0x89, 0xb8, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0x00, 0x40
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x407f2d
	/* C7 */
	.octa 0x1f65
	/* C11 */
	.octa 0x80000000000100050000000000407f6b
	/* C14 */
	.octa 0x7f
	/* C21 */
	.octa 0x408000
	/* C24 */
	.octa 0x40800000
	/* C27 */
	.octa 0x400040000000000000401f80
final_cap_values:
	/* C0 */
	.octa 0xffffffffc2c2c2c2
	/* C1 */
	.octa 0xffffc2c2
	/* C2 */
	.octa 0x407ffe
	/* C7 */
	.octa 0x1ff8
	/* C8 */
	.octa 0xc2c2
	/* C11 */
	.octa 0x80000000000100050000000000407f6b
	/* C14 */
	.octa 0x7f
	/* C15 */
	.octa 0xffffffffffffffc2
	/* C20 */
	.octa 0x40800000
	/* C21 */
	.octa 0x408000
	/* C24 */
	.octa 0x40800000
	/* C27 */
	.octa 0x400040000000000000401f80
	/* C28 */
	.octa 0x358cd4
	/* C30 */
	.octa 0xffffffffffffc2c2
initial_SP_EL3_value:
	.octa 0x4063d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x72227b14 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:20 Rn:24 imms:011110 immr:100010 N:0 100100:100100 opc:11 sf:0
	.inst 0xc2ae0361 // ADD-C.CRI-C Cd:1 Cn:27 imm3:000 option:000 Rm:14 11000010101:11000010101
	.inst 0xc2c23281 // CHKTGD-C-C 00001:00001 Cn:20 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x784907fe // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:31 01:01 imm9:010010000 0:0 opc:01 111000:111000 size:01
	.inst 0x78567c28 // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:8 Rn:1 11:11 imm9:101100111 0:0 opc:01 111000:111000 size:01
	.inst 0x78fe6aa1 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:21 10:10 S:0 option:011 Rm:30 1:1 opc:11 111000:111000 size:01
	.inst 0x10aca5fc // ADR-C.I-C Rd:28 immhi:010110010100101111 P:1 10000:10000 immlo:00 op:0
	.inst 0x388d1c4f // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:15 Rn:2 11:11 imm9:011010001 0:0 opc:10 111000:111000 size:00
	.inst 0xe249197e // ALDURSH-R.RI-64 Rt:30 Rn:11 op2:10 imm9:010010001 V:0 op1:01 11100010:11100010
	.inst 0xb8893ce0 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:7 11:11 imm9:010010011 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c210a0
	.zero 7992
	.inst 0xc2c20000
	.zero 17512
	.inst 0x00004000
	.zero 7208
	.inst 0x00c2c2c2
	.zero 16384
	.inst 0x0000c2c2
	.zero 999420
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c2 // ldr c2, [x6, #0]
	.inst 0xc24004c7 // ldr c7, [x6, #1]
	.inst 0xc24008cb // ldr c11, [x6, #2]
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc24010d5 // ldr c21, [x6, #4]
	.inst 0xc24014d8 // ldr c24, [x6, #5]
	.inst 0xc24018db // ldr c27, [x6, #6]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =initial_SP_EL3_value
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0xc2c1d0df // cpy c31, c6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x3085003a
	msr SCTLR_EL3, x6
	ldr x6, =0x8
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a6 // ldr c6, [c5, #3]
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	.inst 0x826010a6 // ldr c6, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
	isb
	/* Check processor flags */
	mrs x6, nzcv
	ubfx x6, x6, #28, #4
	mov x5, #0xf
	and x6, x6, x5
	cmp x6, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000c5 // ldr c5, [x6, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc24004c5 // ldr c5, [x6, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc24008c5 // ldr c5, [x6, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400cc5 // ldr c5, [x6, #3]
	.inst 0xc2c5a4e1 // chkeq c7, c5
	b.ne comparison_fail
	.inst 0xc24010c5 // ldr c5, [x6, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc24014c5 // ldr c5, [x6, #5]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc24018c5 // ldr c5, [x6, #6]
	.inst 0xc2c5a5c1 // chkeq c14, c5
	b.ne comparison_fail
	.inst 0xc2401cc5 // ldr c5, [x6, #7]
	.inst 0xc2c5a5e1 // chkeq c15, c5
	b.ne comparison_fail
	.inst 0xc24020c5 // ldr c5, [x6, #8]
	.inst 0xc2c5a681 // chkeq c20, c5
	b.ne comparison_fail
	.inst 0xc24024c5 // ldr c5, [x6, #9]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc24028c5 // ldr c5, [x6, #10]
	.inst 0xc2c5a701 // chkeq c24, c5
	b.ne comparison_fail
	.inst 0xc2402cc5 // ldr c5, [x6, #11]
	.inst 0xc2c5a761 // chkeq c27, c5
	b.ne comparison_fail
	.inst 0xc24030c5 // ldr c5, [x6, #12]
	.inst 0xc2c5a781 // chkeq c28, c5
	b.ne comparison_fail
	.inst 0xc24034c5 // ldr c5, [x6, #13]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ff8
	ldr x1, =check_data0
	ldr x2, =0x00001ffc
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
	ldr x0, =0x00401f66
	ldr x1, =check_data2
	ldr x2, =0x00401f68
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004063d0
	ldr x1, =check_data3
	ldr x2, =0x004063d2
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00407ffc
	ldr x1, =check_data4
	ldr x2, =0x00407fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040c000
	ldr x1, =check_data5
	ldr x2, =0x0040c002
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr DDC_EL3, c6
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
