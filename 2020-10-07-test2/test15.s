.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xe0, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x00, 0x16, 0x4a, 0x82, 0xc0, 0xff, 0x7f, 0x42, 0x5f, 0x35, 0x03, 0xd5, 0x63, 0x8b, 0x31, 0x29
	.byte 0x1e, 0x30, 0xc1, 0xc2, 0x5e, 0x01, 0x1e, 0xfa, 0x20, 0x68, 0xde, 0xc2, 0x1f, 0x17, 0xe1, 0xb5
	.byte 0xe0, 0x47, 0xa1, 0x82, 0x01, 0xa0, 0xef, 0xc2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xfe0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x1
	/* C16 */
	.octa 0x1010
	/* C27 */
	.octa 0x40000000400200040000000000001100
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xfe0
	/* C1 */
	.octa 0xfe0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x0
	/* C10 */
	.octa 0x1
	/* C16 */
	.octa 0x1010
	/* C27 */
	.octa 0x40000000400200040000000000001100
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x20
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100000100000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000580a084100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x824a1600 // ASTRB-R.RI-B Rt:0 Rn:16 op:01 imm9:010100001 L:0 1000001001:1000001001
	.inst 0x427fffc0 // ALDAR-R.R-32 Rt:0 Rn:30 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xd503355f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:0101 11010101000000110011:11010101000000110011
	.inst 0x29318b63 // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:3 Rn:27 Rt2:00010 imm7:1100011 L:0 1010010:1010010 opc:00
	.inst 0xc2c1301e // GCFLGS-R.C-C Rd:30 Cn:0 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xfa1e015e // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:30 Rn:10 000000:000000 Rm:30 11010000:11010000 S:1 op:1 sf:1
	.inst 0xc2de6820 // ORRFLGS-C.CR-C Cd:0 Cn:1 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0xb5e1171f // cbnz:aarch64/instrs/branch/conditional/compare Rt:31 imm19:1110000100010111000 op:1 011010:011010 sf:1
	.inst 0x82a147e0 // ASTR-R.RRB-64 Rt:0 Rn:31 opc:01 S:0 option:010 Rm:1 1:1 L:0 100000101:100000101
	.inst 0xc2efa001 // BICFLGS-C.CI-C Cd:1 Cn:0 0:0 00:00 imm8:01111101 11000010111:11000010111
	.inst 0xc2c211c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2400f43 // ldr c3, [x26, #3]
	.inst 0xc240134a // ldr c10, [x26, #4]
	.inst 0xc2401750 // ldr c16, [x26, #5]
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2401f5e // ldr c30, [x26, #7]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850038
	msr SCTLR_EL3, x26
	ldr x26, =0x0
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031da // ldr c26, [c14, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x826011da // ldr c26, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x14, #0xf
	and x26, x26, x14
	cmp x26, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240034e // ldr c14, [x26, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240074e // ldr c14, [x26, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400b4e // ldr c14, [x26, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400f4e // ldr c14, [x26, #3]
	.inst 0xc2cea461 // chkeq c3, c14
	b.ne comparison_fail
	.inst 0xc240134e // ldr c14, [x26, #4]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc240174e // ldr c14, [x26, #5]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc2401b4e // ldr c14, [x26, #6]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc2401f4e // ldr c14, [x26, #7]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000108c
	ldr x1, =check_data1
	ldr x2, =0x00001094
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010b1
	ldr x1, =check_data2
	ldr x2, =0x000010b2
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
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
