.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x7f, 0x00, 0x04, 0x00, 0x00, 0xda, 0x22, 0x00, 0x00, 0x00, 0xfb, 0xdb
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xa2, 0xff, 0xb3, 0xc8, 0x05, 0x7b, 0xb1, 0xd2, 0xe2, 0xe4, 0x1d, 0xa2, 0xff, 0x87, 0x87, 0xda
	.byte 0x22, 0x90, 0xc1, 0xc2, 0xe1, 0x3f, 0x3d, 0xc8, 0x1f, 0xb8, 0x0a, 0x12, 0x22, 0xfc, 0x15, 0x48
	.byte 0xe1, 0x9b, 0x46, 0x38, 0x9a, 0xfb, 0x05, 0x78, 0x60, 0x10, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x401001
	/* C1 */
	.octa 0x150e
	/* C2 */
	.octa 0xdbfb00000022da000004007f00000000
	/* C7 */
	.octa 0x1000
	/* C19 */
	.octa 0x37c2c01e3d3e6fdd
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xff5
	/* C29 */
	.octa 0x400010
final_cap_values:
	/* C0 */
	.octa 0x401001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x150e
	/* C5 */
	.octa 0x8bd80000
	/* C7 */
	.octa 0xde0
	/* C19 */
	.octa 0xc83d3fe1c2c19022
	/* C21 */
	.octa 0x1
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0xff5
	/* C29 */
	.octa 0x1
initial_SP_EL3_value:
	.octa 0x1d80
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200000080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000003be10005000000000e0080c1
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
	.inst 0xc8b3ffa2 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:2 Rn:29 11111:11111 o0:1 Rs:19 1:1 L:0 0010001:0010001 size:11
	.inst 0xd2b17b05 // movz:aarch64/instrs/integer/ins-ext/insert/movewide Rd:5 imm16:1000101111011000 hw:01 100101:100101 opc:10 sf:1
	.inst 0xa21de4e2 // STR-C.RIAW-C Ct:2 Rn:7 01:01 imm9:111011110 0:0 opc:00 10100010:10100010
	.inst 0xda8787ff // csneg:aarch64/instrs/integer/conditional/select Rd:31 Rn:31 o2:1 0:0 cond:1000 Rm:7 011010100:011010100 op:1 sf:1
	.inst 0xc2c19022 // CLRTAG-C.C-C Cd:2 Cn:1 100:100 opc:00 11000010110000011:11000010110000011
	.inst 0xc83d3fe1 // stxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:31 Rt2:01111 o0:0 Rs:29 1:1 L:0 0010000:0010000 sz:1 1:1
	.inst 0x120ab81f // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:0 imms:101110 immr:001010 N:0 100100:100100 opc:00 sf:0
	.inst 0x4815fc22 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:1 Rt2:11111 o0:1 Rs:21 0:0 L:0 0010000:0010000 size:01
	.inst 0x38469be1 // ldtrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:31 10:10 imm9:001101001 0:0 opc:01 111000:111000 size:00
	.inst 0x7805fb9a // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:26 Rn:28 10:10 imm9:001011111 0:0 opc:00 111000:111000 size:01
	.inst 0xc2c21060
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a1 // ldr c1, [x13, #1]
	.inst 0xc24009a2 // ldr c2, [x13, #2]
	.inst 0xc2400da7 // ldr c7, [x13, #3]
	.inst 0xc24011b3 // ldr c19, [x13, #4]
	.inst 0xc24015ba // ldr c26, [x13, #5]
	.inst 0xc24019bc // ldr c28, [x13, #6]
	.inst 0xc2401dbd // ldr c29, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x60000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	ldr x13, =0x4
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306d // ldr c13, [c3, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260106d // ldr c13, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x3, #0x6
	and x13, x13, x3
	cmp x13, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc24011a3 // ldr c3, [x13, #4]
	.inst 0xc2c3a4e1 // chkeq c7, c3
	b.ne comparison_fail
	.inst 0xc24015a3 // ldr c3, [x13, #5]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc24019a3 // ldr c3, [x13, #6]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc2401da3 // ldr c3, [x13, #7]
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	.inst 0xc24021a3 // ldr c3, [x13, #8]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc24025a3 // ldr c3, [x13, #9]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001054
	ldr x1, =check_data1
	ldr x2, =0x00001056
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000150e
	ldr x1, =check_data2
	ldr x2, =0x00001510
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d80
	ldr x1, =check_data3
	ldr x2, =0x00001d90
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
	ldr x0, =0x0040106a
	ldr x1, =check_data5
	ldr x2, =0x0040106b
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
