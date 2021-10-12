.section data0, #alloc, #write
	.byte 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 736
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x01, 0x00, 0x00
	.zero 1280
	.byte 0x00, 0x00, 0x01, 0x80, 0x00, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x01, 0x01
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x08, 0x01, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0x01, 0x80, 0x00, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x33, 0x7e, 0x5f, 0x42, 0xc2, 0x8b, 0xc0, 0xc2, 0x02, 0x88, 0x5c, 0xb2, 0x31, 0x43, 0x3e, 0x78
	.byte 0xf2, 0xa3, 0x7f, 0x88, 0x01, 0xfc, 0xb1, 0xc8, 0xd3, 0x04, 0x0d, 0x78, 0x0a, 0x7c, 0x7f, 0xc8
	.byte 0x2f, 0xc8, 0x22, 0x38, 0xf6, 0x31, 0xc7, 0xc2, 0x20, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000000000000000000001800
	/* C1 */
	.octa 0x40000000200020000000000000000001
	/* C6 */
	.octa 0x40000000520200040000000000001004
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x12f0
	/* C25 */
	.octa 0xc0000000008000000000000000001000
	/* C30 */
	.octa 0x100010000000000000000
final_cap_values:
	/* C0 */
	.octa 0xc0000000000000000000000000001800
	/* C1 */
	.octa 0x40000000200020000000000000000001
	/* C2 */
	.octa 0xfffffff00000187f
	/* C6 */
	.octa 0x400000005202000400000000000010d4
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x101010080010000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x101010080010000
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x108800000000000000000000000
	/* C22 */
	.octa 0xffffffffffffffff
	/* C25 */
	.octa 0xc0000000008000000000000000001000
	/* C30 */
	.octa 0x100010000000000000000
initial_SP_EL3_value:
	.octa 0x800000007000a04a000000000040a080
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90000000540400020000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000012f0
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x425f7e33 // ALDAR-C.R-C Ct:19 Rn:17 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0xc2c08bc2 // CHKSSU-C.CC-C Cd:2 Cn:30 0010:0010 opc:10 Cm:0 11000010110:11000010110
	.inst 0xb25c8802 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:0 imms:100010 immr:011100 N:1 100100:100100 opc:01 sf:1
	.inst 0x783e4331 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:25 00:00 opc:100 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x887fa3f2 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:18 Rn:31 Rt2:01000 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xc8b1fc01 // cas:aarch64/instrs/memory/atomicops/cas/single Rt:1 Rn:0 11111:11111 o0:1 Rs:17 1:1 L:0 0010001:0010001 size:11
	.inst 0x780d04d3 // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:19 Rn:6 01:01 imm9:011010000 0:0 opc:00 111000:111000 size:01
	.inst 0xc87f7c0a // ldxp:aarch64/instrs/memory/exclusive/pair Rt:10 Rn:0 Rt2:11111 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x3822c82f // strb_reg:aarch64/instrs/memory/single/general/register Rt:15 Rn:1 10:10 S:0 option:110 Rm:2 1:1 opc:00 111000:111000 size:00
	.inst 0xc2c731f6 // RRMASK-R.R-C Rd:22 Rn:15 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c21120
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
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba6 // ldr c6, [x29, #2]
	.inst 0xc2400faf // ldr c15, [x29, #3]
	.inst 0xc24013b1 // ldr c17, [x29, #4]
	.inst 0xc24017b9 // ldr c25, [x29, #5]
	.inst 0xc2401bbe // ldr c30, [x29, #6]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_SP_EL3_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x3085103d
	msr SCTLR_EL3, x29
	ldr x29, =0x0
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260313d // ldr c29, [c9, #3]
	.inst 0xc28b413d // msr DDC_EL3, c29
	isb
	.inst 0x8260113d // ldr c29, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr DDC_EL3, c29
	ldr x29, =0x30851035
	msr SCTLR_EL3, x29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x9, #0xf
	and x29, x29, x9
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003a9 // ldr c9, [x29, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc24007a9 // ldr c9, [x29, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400ba9 // ldr c9, [x29, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400fa9 // ldr c9, [x29, #3]
	.inst 0xc2c9a4c1 // chkeq c6, c9
	b.ne comparison_fail
	.inst 0xc24013a9 // ldr c9, [x29, #4]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc24017a9 // ldr c9, [x29, #5]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2401ba9 // ldr c9, [x29, #6]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401fa9 // ldr c9, [x29, #7]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc24023a9 // ldr c9, [x29, #8]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc24027a9 // ldr c9, [x29, #9]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2402ba9 // ldr c9, [x29, #10]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402fa9 // ldr c9, [x29, #11]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc24033a9 // ldr c9, [x29, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012f0
	ldr x1, =check_data2
	ldr x2, =0x00001300
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001880
	ldr x1, =check_data4
	ldr x2, =0x00001881
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040a080
	ldr x1, =check_data6
	ldr x2, =0x0040a088
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
