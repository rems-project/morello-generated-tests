.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x80, 0x00, 0x00
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 3
.data
check_data3:
	.byte 0x9e, 0xe1, 0xd2, 0xc2, 0x7e, 0xb2, 0xc5, 0xc2, 0xef, 0xdb, 0x03, 0xe2, 0xe1, 0xff, 0xdf, 0x48
	.byte 0x46, 0x1c, 0xd2, 0x39, 0xad, 0xbb, 0x7f, 0x22, 0xc1, 0x21, 0xe2, 0xc2, 0xc0, 0xbb, 0x53, 0x51
	.byte 0x9b, 0xcb, 0x4f, 0x78, 0x47, 0x41, 0x7e, 0x78, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x80000000000100060000000000001b77
	/* C10 */
	.octa 0xc0000000000100050000000000001ffc
	/* C12 */
	.octa 0x3fff800000000000000000000000
	/* C19 */
	.octa 0xffffffffe00000
	/* C28 */
	.octa 0x80000000000100050000000000001f00
	/* C29 */
	.octa 0x80100000400000020000000000001000
final_cap_values:
	/* C0 */
	.octa 0xff912000
	/* C1 */
	.octa 0x101800000000000000000000000
	/* C2 */
	.octa 0x80000000000100060000000000001b77
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x8001
	/* C10 */
	.octa 0xc0000000000100050000000000001ffc
	/* C12 */
	.octa 0x3fff800000000000000000000000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x101800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C19 */
	.octa 0xffffffffe00000
	/* C27 */
	.octa 0x8001
	/* C28 */
	.octa 0x80000000000100050000000000001f00
	/* C29 */
	.octa 0x80100000400000020000000000001000
	/* C30 */
	.octa 0x200080001006000f00ffffffffe00000
initial_SP_EL3_value:
	.octa 0x80000000000200070000000000001ff2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000600020010000000000408001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 192
	.dword final_cap_values + 208
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d2e19e // SCFLGS-C.CR-C Cd:30 Cn:12 111000:111000 Rm:18 11000010110:11000010110
	.inst 0xc2c5b27e // CVTP-C.R-C Cd:30 Rn:19 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xe203dbef // ALDURSB-R.RI-64 Rt:15 Rn:31 op2:10 imm9:000111101 V:0 op1:00 11100010:11100010
	.inst 0x48dfffe1 // ldarh:aarch64/instrs/memory/ordered Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x39d21c46 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:6 Rn:2 imm12:010010000111 opc:11 111001:111001 size:00
	.inst 0x227fbbad // LDAXP-C.R-C Ct:13 Rn:29 Ct2:01110 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2e221c1 // BICFLGS-C.CI-C Cd:1 Cn:14 0:0 00:00 imm8:00010001 11000010111:11000010111
	.inst 0x5153bbc0 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:30 imm12:010011101110 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0x784fcb9b // ldtrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:28 10:10 imm9:011111100 0:0 opc:01 111000:111000 size:01
	.inst 0x787e4147 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:10 00:00 opc:100 0:0 Rs:30 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2c212c0
	.zero 1048532
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x8, =initial_cap_values
	.inst 0xc2400102 // ldr c2, [x8, #0]
	.inst 0xc240050a // ldr c10, [x8, #1]
	.inst 0xc240090c // ldr c12, [x8, #2]
	.inst 0xc2400d13 // ldr c19, [x8, #3]
	.inst 0xc240111c // ldr c28, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032c8 // ldr c8, [c22, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826012c8 // ldr c8, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400116 // ldr c22, [x8, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400516 // ldr c22, [x8, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400916 // ldr c22, [x8, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400d16 // ldr c22, [x8, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401116 // ldr c22, [x8, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401516 // ldr c22, [x8, #5]
	.inst 0xc2d6a541 // chkeq c10, c22
	b.ne comparison_fail
	.inst 0xc2401916 // ldr c22, [x8, #6]
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	.inst 0xc2401d16 // ldr c22, [x8, #7]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2402116 // ldr c22, [x8, #8]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2402516 // ldr c22, [x8, #9]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2402916 // ldr c22, [x8, #10]
	.inst 0xc2d6a661 // chkeq c19, c22
	b.ne comparison_fail
	.inst 0xc2402d16 // ldr c22, [x8, #11]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2403116 // ldr c22, [x8, #12]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2403516 // ldr c22, [x8, #13]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2403916 // ldr c22, [x8, #14]
	.inst 0xc2d6a7c1 // chkeq c30, c22
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
	ldr x0, =0x00001ff2
	ldr x1, =check_data1
	ldr x2, =0x00001ff4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00404030
	ldr x1, =check_data4
	ldr x2, =0x00404031
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
