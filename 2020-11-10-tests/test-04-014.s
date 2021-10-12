.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x01, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0xde, 0xb3, 0xd7, 0x42, 0xdc, 0x7e, 0x01, 0x88, 0x7e, 0xc3, 0x22, 0x22, 0xc1, 0xcd, 0xc1, 0x8a
	.byte 0x23, 0x31, 0xc7, 0xc2, 0xef, 0x9f, 0xe2, 0x02, 0x1f, 0x50, 0x62, 0x78, 0xf5, 0x7f, 0x5f, 0x48
	.byte 0xa2, 0xb7, 0x91, 0xad, 0xf1, 0x2f, 0x32, 0xb2, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001002
	/* C9 */
	.octa 0x0
	/* C16 */
	.octa 0x0
	/* C22 */
	.octa 0x40000000540104040000000000001000
	/* C27 */
	.octa 0x4c000000000100050000000000001000
	/* C29 */
	.octa 0x40000000000100050000000000001bf0
	/* C30 */
	.octa 0x90100000004200010000000000001000
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001002
	/* C2 */
	.octa 0x1
	/* C3 */
	.octa 0xffffffffffffffff
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000200b0007ffffffffffb62020
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x3ffc00003ffc000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x40000000540104040000000000001000
	/* C27 */
	.octa 0x4c000000000100050000000000001000
	/* C29 */
	.octa 0x40000000000100050000000000001e20
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000200b00070000000000409020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x42d7b3de // LDP-C.RIB-C Ct:30 Rn:30 Ct2:01100 imm7:0101111 L:1 010000101:010000101
	.inst 0x88017edc // stxr:aarch64/instrs/memory/exclusive/single Rt:28 Rn:22 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:10
	.inst 0x2222c37e // STLXP-R.CR-C Ct:30 Rn:27 Ct2:10000 1:1 Rs:2 1:1 L:0 001000100:001000100
	.inst 0x8ac1cdc1 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:14 imm6:110011 Rm:1 N:0 shift:11 01010:01010 opc:00 sf:1
	.inst 0xc2c73123 // RRMASK-R.R-C Rd:3 Rn:9 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x02e29fef // SUB-C.CIS-C Cd:15 Cn:31 imm12:100010100111 sh:1 A:1 00000010:00000010
	.inst 0x7862501f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:101 o3:0 Rs:2 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x485f7ff5 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:21 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xad91b7a2 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:2 Rn:29 Rt2:01101 imm7:0100011 L:0 1011011:1011011 opc:10
	.inst 0xb2322ff1 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:17 Rn:31 imms:001011 immr:110010 N:0 100100:100100 opc:01 sf:1
	.inst 0xc2c210e0
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400569 // ldr c9, [x11, #1]
	.inst 0xc2400970 // ldr c16, [x11, #2]
	.inst 0xc2400d76 // ldr c22, [x11, #3]
	.inst 0xc240117b // ldr c27, [x11, #4]
	.inst 0xc240157d // ldr c29, [x11, #5]
	.inst 0xc240197e // ldr c30, [x11, #6]
	/* Vector registers */
	mrs x11, cptr_el3
	bfc x11, #10, #1
	msr cptr_el3, x11
	isb
	ldr q2, =0x0
	ldr q13, =0x0
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x3085103d
	msr SCTLR_EL3, x11
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010eb // ldr c11, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400167 // ldr c7, [x11, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400567 // ldr c7, [x11, #1]
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400d67 // ldr c7, [x11, #3]
	.inst 0xc2c7a521 // chkeq c9, c7
	b.ne comparison_fail
	.inst 0xc2401167 // ldr c7, [x11, #4]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc2401567 // ldr c7, [x11, #5]
	.inst 0xc2c7a5e1 // chkeq c15, c7
	b.ne comparison_fail
	.inst 0xc2401967 // ldr c7, [x11, #6]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401d67 // ldr c7, [x11, #7]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc2402167 // ldr c7, [x11, #8]
	.inst 0xc2c7a6a1 // chkeq c21, c7
	b.ne comparison_fail
	.inst 0xc2402567 // ldr c7, [x11, #9]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc2402967 // ldr c7, [x11, #10]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402d67 // ldr c7, [x11, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2403167 // ldr c7, [x11, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x7, v2.d[0]
	cmp x11, x7
	b.ne comparison_fail
	ldr x11, =0x0
	mov x7, v2.d[1]
	cmp x11, x7
	b.ne comparison_fail
	ldr x11, =0x0
	mov x7, v13.d[0]
	cmp x11, x7
	b.ne comparison_fail
	ldr x11, =0x0
	mov x7, v13.d[1]
	cmp x11, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012f0
	ldr x1, =check_data1
	ldr x2, =0x00001310
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001e20
	ldr x1, =check_data2
	ldr x2, =0x00001e40
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
	ldr x0, =0x00409020
	ldr x1, =check_data4
	ldr x2, =0x00409022
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
