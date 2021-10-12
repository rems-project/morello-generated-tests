.section data0, #alloc, #write
	.zero 1536
	.byte 0x80, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2544
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x80, 0x00, 0x40, 0x00
.data
check_data4:
	.byte 0x5f, 0xf0, 0xc0, 0xc2, 0xba, 0x7e, 0x9f, 0x08, 0x89, 0x2a, 0xcf, 0x78, 0xf6, 0x07, 0x63, 0xaa
	.byte 0x41, 0xbc, 0x4f, 0xb8, 0xe2, 0x6d, 0x95, 0x42, 0x93, 0x9b, 0xef, 0xc2, 0x26, 0xb0, 0xc5, 0xc2
	.byte 0x28, 0x6c, 0x58, 0x38, 0x02, 0x1c, 0xc2, 0xc2, 0x80, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1505
	/* C15 */
	.octa 0x1030
	/* C20 */
	.octa 0x1000
	/* C21 */
	.octa 0x12f8
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x1030
final_cap_values:
	/* C1 */
	.octa 0x400006
	/* C2 */
	.octa 0x1600
	/* C6 */
	.octa 0x20008000200100060000000000400080
	/* C8 */
	.octa 0x9f
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x1030
	/* C19 */
	.octa 0x0
	/* C20 */
	.octa 0x1000
	/* C21 */
	.octa 0x12f8
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x1030
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc80000000005000700ffffffe0000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c0f05f // GCTYPE-R.C-C Rd:31 Cn:2 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x089f7eba // stllrb:aarch64/instrs/memory/ordered Rt:26 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x78cf2a89 // ldtrsh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:9 Rn:20 10:10 imm9:011110010 0:0 opc:11 111000:111000 size:01
	.inst 0xaa6307f6 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:22 Rn:31 imm6:000001 Rm:3 N:1 shift:01 01010:01010 opc:01 sf:1
	.inst 0xb84fbc41 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:2 11:11 imm9:011111011 0:0 opc:01 111000:111000 size:10
	.inst 0x42956de2 // STP-C.RIB-C Ct:2 Rn:15 Ct2:11011 imm7:0101010 L:0 010000101:010000101
	.inst 0xc2ef9b93 // SUBS-R.CC-C Rd:19 Cn:28 100110:100110 Cm:15 11000010111:11000010111
	.inst 0xc2c5b026 // CVTP-C.R-C Cd:6 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x38586c28 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:8 Rn:1 11:11 imm9:110000110 0:0 opc:01 111000:111000 size:00
	.inst 0xc2c21c02 // CSEL-C.CI-C Cd:2 Cn:0 11:11 cond:0001 Cm:2 11000010110:11000010110
	.inst 0xc2c21080
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c2 // ldr c2, [x14, #0]
	.inst 0xc24005cf // ldr c15, [x14, #1]
	.inst 0xc24009d4 // ldr c20, [x14, #2]
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc24011da // ldr c26, [x14, #4]
	.inst 0xc24015db // ldr c27, [x14, #5]
	.inst 0xc24019dc // ldr c28, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	ldr x14, =0x8
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260308e // ldr c14, [c4, #3]
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	.inst 0x8260108e // ldr c14, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x4, #0xf
	and x14, x14, x4
	cmp x14, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2400dc4 // ldr c4, [x14, #3]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24011c4 // ldr c4, [x14, #4]
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	.inst 0xc24015c4 // ldr c4, [x14, #5]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc24019c4 // ldr c4, [x14, #6]
	.inst 0xc2c4a661 // chkeq c19, c4
	b.ne comparison_fail
	.inst 0xc2401dc4 // ldr c4, [x14, #7]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc24021c4 // ldr c4, [x14, #8]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc24025c4 // ldr c4, [x14, #9]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc24029c4 // ldr c4, [x14, #10]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402dc4 // ldr c4, [x14, #11]
	.inst 0xc2c4a781 // chkeq c28, c4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f2
	ldr x1, =check_data0
	ldr x2, =0x000010f4
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012d0
	ldr x1, =check_data1
	ldr x2, =0x000012f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012f8
	ldr x1, =check_data2
	ldr x2, =0x000012f9
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001600
	ldr x1, =check_data3
	ldr x2, =0x00001604
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr ddc_el3, c14
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
