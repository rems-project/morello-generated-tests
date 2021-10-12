.section data0, #alloc, #write
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3552
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 512
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x42
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x40, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02
	.byte 0x20, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.byte 0xb7, 0x9d, 0xdf, 0xc2, 0x0b, 0x13, 0xab, 0xa9, 0xdf, 0x03, 0x79, 0xb8, 0x3d, 0xe8, 0xdf, 0xc2
	.byte 0xc7, 0xff, 0x11, 0x48, 0x9e, 0x93, 0x2f, 0x2b, 0x5d, 0xf2, 0x05, 0x82, 0x2d, 0xf2, 0x5e, 0x54
	.byte 0xbb, 0xa0, 0xde, 0x69, 0x00, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0x01, 0xf1, 0xd3, 0xc2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x200000000000020
	/* C5 */
	.octa 0x1004
	/* C8 */
	.octa 0x9010000000070fff0000000000001c00
	/* C11 */
	.octa 0x4000000080000000
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0x1f30
	/* C25 */
	.octa 0x41ffffe0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C4 */
	.octa 0x200000000000020
	/* C5 */
	.octa 0x10f8
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x4000000080000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x1
	/* C24 */
	.octa 0x1de0
	/* C25 */
	.octa 0x41ffffe0
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xa00080008063000700000000004bde64
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0xa0008000006300070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001df0
	.dword initial_cap_values + 32
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2df9db7 // CSEL-C.CI-C Cd:23 Cn:13 11:11 cond:1001 Cm:31 11000010110:11000010110
	.inst 0xa9ab130b // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:11 Rn:24 Rt2:00100 imm7:1010110 L:0 1010011:1010011 opc:10
	.inst 0xb87903df // stadd:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:25 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0xc2dfe83d // CTHI-C.CR-C Cd:29 Cn:1 1010:1010 opc:11 Rm:31 11000010110:11000010110
	.inst 0x4811ffc7 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:7 Rn:30 Rt2:11111 o0:1 Rs:17 0:0 L:0 0010000:0010000 size:01
	.inst 0x2b2f939e // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:28 imm3:100 option:100 Rm:15 01011001:01011001 S:1 op:0 sf:0
	.inst 0x8205f25d // LDR-C.I-C Ct:29 imm17:00010111110010010 1000001000:1000001000
	.inst 0x545ef22d // b_cond:aarch64/instrs/branch/conditional/cond cond:1101 0:0 imm19:0101111011110010001 01010100:01010100
	.inst 0x69dea0bb // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:27 Rn:5 Rt2:01000 imm7:0111101 L:1 1010011:1010011 opc:01
	.inst 0xc2c21200
	.zero 777784
	.inst 0xc2d3f101 // BLR-CI-C 1:1 0000:0000 Cn:8 100:100 imm7:0011111 110000101101:110000101101
	.zero 270748
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
	ldr x3, =initial_cap_values
	.inst 0xc2400064 // ldr c4, [x3, #0]
	.inst 0xc2400465 // ldr c5, [x3, #1]
	.inst 0xc2400868 // ldr c8, [x3, #2]
	.inst 0xc2400c6b // ldr c11, [x3, #3]
	.inst 0xc240106f // ldr c15, [x3, #4]
	.inst 0xc2401478 // ldr c24, [x3, #5]
	.inst 0xc2401879 // ldr c25, [x3, #6]
	.inst 0xc2401c7c // ldr c28, [x3, #7]
	.inst 0xc240207e // ldr c30, [x3, #8]
	/* Set up flags and system registers */
	mov x3, #0x00000000
	msr nzcv, x3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	ldr x3, =0x80
	msr S3_6_C1_C2_2, x3 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603203 // ldr c3, [c16, #3]
	.inst 0xc28b4123 // msr DDC_EL3, c3
	isb
	.inst 0x82601203 // ldr c3, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc2c21060 // br c3
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* Check processor flags */
	mrs x3, nzcv
	ubfx x3, x3, #28, #4
	mov x16, #0xf
	and x3, x3, x16
	cmp x3, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc2400070 // ldr c16, [x3, #0]
	.inst 0xc2d0a481 // chkeq c4, c16
	b.ne comparison_fail
	.inst 0xc2400470 // ldr c16, [x3, #1]
	.inst 0xc2d0a4a1 // chkeq c5, c16
	b.ne comparison_fail
	.inst 0xc2400870 // ldr c16, [x3, #2]
	.inst 0xc2d0a501 // chkeq c8, c16
	b.ne comparison_fail
	.inst 0xc2400c70 // ldr c16, [x3, #3]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401070 // ldr c16, [x3, #4]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401470 // ldr c16, [x3, #5]
	.inst 0xc2d0a621 // chkeq c17, c16
	b.ne comparison_fail
	.inst 0xc2401870 // ldr c16, [x3, #6]
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	.inst 0xc2401c70 // ldr c16, [x3, #7]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2402070 // ldr c16, [x3, #8]
	.inst 0xc2d0a761 // chkeq c27, c16
	b.ne comparison_fail
	.inst 0xc2402470 // ldr c16, [x3, #9]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402870 // ldr c16, [x3, #10]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402c70 // ldr c16, [x3, #11]
	.inst 0xc2d0a7c1 // chkeq c30, c16
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
	ldr x0, =0x000010f8
	ldr x1, =check_data1
	ldr x2, =0x00001100
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001de0
	ldr x1, =check_data2
	ldr x2, =0x00001e00
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x00400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0042f930
	ldr x1, =check_data4
	ldr x2, =0x0042f940
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004bde60
	ldr x1, =check_data5
	ldr x2, =0x004bde64
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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
