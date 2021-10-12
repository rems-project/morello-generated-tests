.section data0, #alloc, #write
	.byte 0x84, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xd4, 0x56, 0xc1, 0x82, 0x3e, 0x05, 0xd7, 0xc2, 0xa5, 0x37, 0xb3, 0xe2, 0x20, 0x40, 0x3e, 0x38
	.byte 0x21, 0xa1, 0x01, 0xc2, 0xdf, 0x33, 0x7d, 0xb8, 0x3d, 0xfc, 0x9f, 0xc8, 0x2a, 0x02, 0x6e, 0x78
	.byte 0xe0, 0x9b, 0xff, 0xc2, 0xc6, 0x37, 0x56, 0x38, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x4000000000000000000800
	/* C9 */
	.octa 0x400020020000000000000800
	/* C14 */
	.octa 0xdf3b
	/* C17 */
	.octa 0x800
	/* C22 */
	.octa 0x800000000005001700000000003ff880
	/* C23 */
	.octa 0x100030000000000000000
	/* C29 */
	.octa 0x800000005ffc0f7c00000000000020c5
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4000000000000000000800
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x400020020000000000000800
	/* C10 */
	.octa 0x20c5
	/* C14 */
	.octa 0xdf3b
	/* C17 */
	.octa 0x800
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x800000000005001700000000003ff880
	/* C23 */
	.octa 0x100030000000000000000
	/* C29 */
	.octa 0x800000005ffc0f7c00000000000020c5
	/* C30 */
	.octa 0x763
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc00000000070807000000000000c4c7
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82c156d4 // ALDRSB-R.RRB-32 Rt:20 Rn:22 opc:01 S:1 option:010 Rm:1 0:0 L:1 100000101:100000101
	.inst 0xc2d7053e // BUILD-C.C-C Cd:30 Cn:9 001:001 opc:00 0:0 Cm:23 11000010110:11000010110
	.inst 0xe2b337a5 // ALDUR-V.RI-S Rt:5 Rn:29 op2:01 imm9:100110011 V:1 op1:10 11100010:11100010
	.inst 0x383e4020 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:1 00:00 opc:100 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xc201a121 // STR-C.RIB-C Ct:1 Rn:9 imm12:000001101000 L:0 110000100:110000100
	.inst 0xb87d33df // ldset:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:30 00:00 opc:011 0:0 Rs:29 1:1 R:1 A:0 111000:111000 size:10
	.inst 0xc89ffc3d // stlr:aarch64/instrs/memory/ordered Rt:29 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:11
	.inst 0x786e022a // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:10 Rn:17 00:00 opc:000 0:0 Rs:14 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xc2ff9be0 // SUBS-R.CC-C Rd:0 Cn:31 100110:100110 Cm:31 11000010111:11000010111
	.inst 0x385637c6 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:6 Rn:30 01:01 imm9:101100011 0:0 opc:01 111000:111000 size:00
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
	ldr x2, =initial_cap_values
	.inst 0xc2400041 // ldr c1, [x2, #0]
	.inst 0xc2400449 // ldr c9, [x2, #1]
	.inst 0xc240084e // ldr c14, [x2, #2]
	.inst 0xc2400c51 // ldr c17, [x2, #3]
	.inst 0xc2401056 // ldr c22, [x2, #4]
	.inst 0xc2401457 // ldr c23, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032a2 // ldr c2, [c21, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x826012a2 // ldr c2, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x21, #0xf
	and x2, x2, x21
	cmp x2, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400055 // ldr c21, [x2, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400455 // ldr c21, [x2, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400855 // ldr c21, [x2, #2]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc2400c55 // ldr c21, [x2, #3]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401055 // ldr c21, [x2, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401455 // ldr c21, [x2, #5]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401855 // ldr c21, [x2, #6]
	.inst 0xc2d5a621 // chkeq c17, c21
	b.ne comparison_fail
	.inst 0xc2401c55 // ldr c21, [x2, #7]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2402055 // ldr c21, [x2, #8]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402455 // ldr c21, [x2, #9]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2402855 // ldr c21, [x2, #10]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402c55 // ldr c21, [x2, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x21, v5.d[0]
	cmp x2, x21
	b.ne comparison_fail
	ldr x2, =0x0
	mov x21, v5.d[1]
	cmp x2, x21
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
	ldr x0, =0x00001680
	ldr x1, =check_data1
	ldr x2, =0x00001690
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff8
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
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
	ldr x0, =0x00400080
	ldr x1, =check_data4
	ldr x2, =0x00400081
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
