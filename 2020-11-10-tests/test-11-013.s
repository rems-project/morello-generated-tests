.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x1f, 0x00, 0x22, 0x78, 0xf3, 0xff, 0x5f, 0x22, 0x01, 0x29, 0xcb, 0xc2, 0xdf, 0x32, 0x21, 0x78
	.byte 0xe2, 0x77, 0x14, 0xb1, 0x21, 0x5c, 0x8c, 0x13, 0xc2, 0x63, 0x34, 0xe2, 0xaa, 0x22, 0x77, 0xe2
	.byte 0x01, 0x89, 0xc2, 0xc2, 0xca, 0x43, 0x71, 0x38, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1040
	/* C2 */
	.octa 0x0
	/* C8 */
	.octa 0x400000000070000000000000000
	/* C17 */
	.octa 0x0
	/* C21 */
	.octa 0x4000000000070c070000000000001900
	/* C22 */
	.octa 0x1700
	/* C30 */
	.octa 0x400000006000000700000000000012c0
final_cap_values:
	/* C0 */
	.octa 0x1040
	/* C1 */
	.octa 0x400000000070000000000000000
	/* C2 */
	.octa 0x151d
	/* C8 */
	.octa 0x400000000070000000000000000
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C21 */
	.octa 0x4000000000070c070000000000001900
	/* C22 */
	.octa 0x1700
	/* C30 */
	.octa 0x400000006000000700000000000012c0
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000403000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000b000100fffffffff4f001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7822001f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:000 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x225ffff3 // LDAXR-C.R-C Ct:19 Rn:31 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xc2cb2901 // BICFLGS-C.CR-C Cd:1 Cn:8 1010:1010 opc:00 Rm:11 11000010110:11000010110
	.inst 0x782132df // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:011 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xb11477e2 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:31 imm12:010100011101 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x138c5c21 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:1 Rn:1 imms:010111 Rm:12 0:0 N:0 00100111:00100111 sf:0
	.inst 0xe23463c2 // ASTUR-V.RI-B Rt:2 Rn:30 op2:00 imm9:101000110 V:1 op1:00 11100010:11100010
	.inst 0xe27722aa // ASTUR-V.RI-H Rt:10 Rn:21 op2:00 imm9:101110010 V:1 op1:01 11100010:11100010
	.inst 0xc2c28901 // CHKSSU-C.CC-C Cd:1 Cn:8 0010:0010 opc:10 Cm:2 11000010110:11000010110
	.inst 0x387143ca // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:10 Rn:30 00:00 opc:100 0:0 Rs:17 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2c210c0
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400702 // ldr c2, [x24, #1]
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2400f11 // ldr c17, [x24, #3]
	.inst 0xc2401315 // ldr c21, [x24, #4]
	.inst 0xc2401716 // ldr c22, [x24, #5]
	.inst 0xc2401b1e // ldr c30, [x24, #6]
	/* Vector registers */
	mrs x24, cptr_el3
	bfc x24, #10, #1
	msr cptr_el3, x24
	isb
	ldr q2, =0x0
	ldr q10, =0x0
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103f
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d8 // ldr c24, [c6, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x826010d8 // ldr c24, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x6, #0xf
	and x24, x24, x6
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400306 // ldr c6, [x24, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400706 // ldr c6, [x24, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400b06 // ldr c6, [x24, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400f06 // ldr c6, [x24, #3]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc2401306 // ldr c6, [x24, #4]
	.inst 0xc2c6a541 // chkeq c10, c6
	b.ne comparison_fail
	.inst 0xc2401706 // ldr c6, [x24, #5]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401b06 // ldr c6, [x24, #6]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401f06 // ldr c6, [x24, #7]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2402306 // ldr c6, [x24, #8]
	.inst 0xc2c6a6c1 // chkeq c22, c6
	b.ne comparison_fail
	.inst 0xc2402706 // ldr c6, [x24, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x24, =0x0
	mov x6, v2.d[0]
	cmp x24, x6
	b.ne comparison_fail
	ldr x24, =0x0
	mov x6, v2.d[1]
	cmp x24, x6
	b.ne comparison_fail
	ldr x24, =0x0
	mov x6, v10.d[0]
	cmp x24, x6
	b.ne comparison_fail
	ldr x24, =0x0
	mov x6, v10.d[1]
	cmp x24, x6
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001206
	ldr x1, =check_data2
	ldr x2, =0x00001207
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000012c0
	ldr x1, =check_data3
	ldr x2, =0x000012c1
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001700
	ldr x1, =check_data4
	ldr x2, =0x00001702
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001872
	ldr x1, =check_data5
	ldr x2, =0x00001874
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
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
