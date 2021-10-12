.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xaf, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x92, 0x00, 0x12, 0x80, 0x12, 0x00, 0x12, 0x80, 0x12
	.byte 0xc2, 0x12, 0xc2, 0x12, 0x80, 0x12, 0x80, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x7d, 0x00, 0x00, 0x18, 0x00, 0x00, 0xdc, 0x00
.data
check_data3:
	.byte 0xb7, 0xe7, 0x0d, 0xb1, 0x25, 0x04, 0xd6, 0xc2, 0x00, 0x7c, 0x7f, 0x42, 0x4a, 0xd0, 0x80, 0x9a
	.byte 0x1f, 0x20, 0x32, 0xf8, 0xe0, 0x13, 0xb8, 0x78, 0x1e, 0x11, 0x13, 0xa2, 0x3d, 0xfc, 0xdf, 0x08
	.byte 0xdc, 0x5a, 0xe1, 0xc2, 0x30, 0x34, 0xa1, 0x22, 0x80, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000004004480400000000004f7fff
	/* C1 */
	.octa 0x400000000000000000000000b50
	/* C8 */
	.octa 0xccf
	/* C13 */
	.octa 0xc280128012c212c2
	/* C16 */
	.octa 0x128012001280120092c2000000000000
	/* C18 */
	.octa 0xaf000000000000
	/* C22 */
	.octa 0x24007000002fffe040040
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x8000000000000000
	/* C30 */
	.octa 0xdc00001800007d0000080000000000
final_cap_values:
	/* C0 */
	.octa 0xff00
	/* C1 */
	.octa 0x770
	/* C5 */
	.octa 0xb50
	/* C8 */
	.octa 0xccf
	/* C13 */
	.octa 0xc280128012c212c2
	/* C16 */
	.octa 0x128012001280120092c2000000000000
	/* C18 */
	.octa 0xaf000000000000
	/* C22 */
	.octa 0x24007000002fffe040040
	/* C23 */
	.octa 0x8000000000000379
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x24007ff40000000000b50
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xdc00001800007d0000080000000000
initial_SP_EL3_value:
	.octa 0x8
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004030c1040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000001007080600fffffffffff060
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 144
	.dword final_cap_values + 64
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb10de7b7 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:23 Rn:29 imm12:001101111001 sh:0 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xc2d60425 // BUILD-C.C-C Cd:5 Cn:1 001:001 opc:00 0:0 Cm:22 11000010110:11000010110
	.inst 0x427f7c00 // ALDARB-R.R-B Rt:0 Rn:0 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0x9a80d04a // csel:aarch64/instrs/integer/conditional/select Rd:10 Rn:2 o2:0 0:0 cond:1101 Rm:0 011010100:011010100 op:0 sf:1
	.inst 0xf832201f // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:010 o3:0 Rs:18 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x78b813e0 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:001 0:0 Rs:24 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xa213111e // STUR-C.RI-C Ct:30 Rn:8 00:00 imm9:100110001 0:0 opc:00 10100010:10100010
	.inst 0x08dffc3d // ldarb:aarch64/instrs/memory/ordered Rt:29 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2e15adc // CVTZ-C.CR-C Cd:28 Cn:22 0110:0110 1:1 0:0 Rm:1 11000010111:11000010111
	.inst 0x22a13430 // STP-CC.RIAW-C Ct:16 Rn:1 Ct2:01101 imm7:1000010 L:0 001000101:001000101
	.inst 0xc2c21280
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a68 // ldr c8, [x19, #2]
	.inst 0xc2400e6d // ldr c13, [x19, #3]
	.inst 0xc2401270 // ldr c16, [x19, #4]
	.inst 0xc2401672 // ldr c18, [x19, #5]
	.inst 0xc2401a76 // ldr c22, [x19, #6]
	.inst 0xc2401e78 // ldr c24, [x19, #7]
	.inst 0xc240227d // ldr c29, [x19, #8]
	.inst 0xc240267e // ldr c30, [x19, #9]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =initial_SP_EL3_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2c1d27f // cpy c31, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	ldr x19, =0x4
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603293 // ldr c19, [c20, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x82601293 // ldr c19, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x20, #0xf
	and x19, x19, x20
	cmp x19, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400274 // ldr c20, [x19, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400674 // ldr c20, [x19, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a74 // ldr c20, [x19, #2]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400e74 // ldr c20, [x19, #3]
	.inst 0xc2d4a501 // chkeq c8, c20
	b.ne comparison_fail
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc2d4a5a1 // chkeq c13, c20
	b.ne comparison_fail
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2d4a601 // chkeq c16, c20
	b.ne comparison_fail
	.inst 0xc2401a74 // ldr c20, [x19, #6]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2402274 // ldr c20, [x19, #8]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2402674 // ldr c20, [x19, #9]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2402a74 // ldr c20, [x19, #10]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402e74 // ldr c20, [x19, #11]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2403274 // ldr c20, [x19, #12]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000100a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001b50
	ldr x1, =check_data1
	ldr x2, =0x00001b70
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c00
	ldr x1, =check_data2
	ldr x2, =0x00001c10
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
	ldr x0, =0x004f7fff
	ldr x1, =check_data4
	ldr x2, =0x004f8000
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
