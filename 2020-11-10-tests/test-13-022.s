.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0xc0
.data
check_data2:
	.byte 0xd4, 0xbf, 0x03, 0xf8, 0x01, 0x7c, 0x55, 0xe2, 0x1e, 0x10, 0xa3, 0x38, 0x00, 0x30, 0xc7, 0xc2
	.byte 0x82, 0x7c, 0xcb, 0x9b, 0x5c, 0x01, 0xde, 0xc2, 0x22, 0x76, 0xc1, 0x82, 0xf3, 0x7e, 0x1f, 0x42
	.byte 0xc8, 0x4f, 0xe6, 0x68, 0x5e, 0x7b, 0x30, 0x98, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000806000f00000000000010b1
	/* C3 */
	.octa 0xd
	/* C10 */
	.octa 0x10400000000000000000000000
	/* C17 */
	.octa 0x800000000807080f0000000000407fff
	/* C19 */
	.octa 0x4000000000000000000000000000
	/* C20 */
	.octa 0xc0000000
	/* C23 */
	.octa 0x48000000204700070000000000001000
	/* C30 */
	.octa 0x106e
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffffff
	/* C1 */
	.octa 0x1
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0xd
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x10400000000000000000000000
	/* C17 */
	.octa 0x800000000807080f0000000000407fff
	/* C19 */
	.octa 0x4000
	/* C20 */
	.octa 0xc0000000
	/* C23 */
	.octa 0x48000000204700070000000000001000
	/* C28 */
	.octa 0x1040c100000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000000000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005fff0f470000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf803bfd4 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:20 Rn:30 11:11 imm9:000111011 0:0 opc:00 111000:111000 size:11
	.inst 0xe2557c01 // ALDURSH-R.RI-32 Rt:1 Rn:0 op2:11 imm9:101010111 V:0 op1:01 11100010:11100010
	.inst 0x38a3101e // ldclrb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:0 00:00 opc:001 0:0 Rs:3 1:1 R:0 A:1 111000:111000 size:00
	.inst 0xc2c73000 // RRMASK-R.R-C Rd:0 Rn:0 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x9bcb7c82 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:2 Rn:4 Ra:11111 0:0 Rm:11 10:10 U:1 10011011:10011011
	.inst 0xc2de015c // SCBNDS-C.CR-C Cd:28 Cn:10 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0x82c17622 // ALDRSB-R.RRB-32 Rt:2 Rn:17 opc:01 S:1 option:011 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x421f7ef3 // ASTLR-C.R-C Ct:19 Rn:23 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x68e64fc8 // ldpsw:aarch64/instrs/memory/pair/general/post-idx Rt:8 Rn:30 Rt2:10011 imm7:1001100 L:1 1010001:1010001 opc:01
	.inst 0x98307b5e // ldrsw_lit:aarch64/instrs/memory/literal/general Rt:30 imm19:0011000001111011010 011000:011000 opc:10
	.inst 0xc2c212a0
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a3 // ldr c3, [x29, #1]
	.inst 0xc2400baa // ldr c10, [x29, #2]
	.inst 0xc2400fb1 // ldr c17, [x29, #3]
	.inst 0xc24013b3 // ldr c19, [x29, #4]
	.inst 0xc24017b4 // ldr c20, [x29, #5]
	.inst 0xc2401bb7 // ldr c23, [x29, #6]
	.inst 0xc2401fbe // ldr c30, [x29, #7]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30851037
	msr SCTLR_EL3, x29
	ldr x29, =0x4
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032bd // ldr c29, [c21, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x826012bd // ldr c29, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003b5 // ldr c21, [x29, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24007b5 // ldr c21, [x29, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400bb5 // ldr c21, [x29, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400fb5 // ldr c21, [x29, #3]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc24013b5 // ldr c21, [x29, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc24017b5 // ldr c21, [x29, #5]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401bb5 // ldr c21, [x29, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401fb5 // ldr c21, [x29, #7]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc24023b5 // ldr c21, [x29, #8]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc24027b5 // ldr c21, [x29, #9]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2402bb5 // ldr c21, [x29, #10]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc2402fb5 // ldr c21, [x29, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
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
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff9
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00408000
	ldr x1, =check_data3
	ldr x2, =0x00408001
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00460f8c
	ldr x1, =check_data4
	ldr x2, =0x00460f90
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
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
