.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0xfe, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x80
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x81, 0x12, 0xc2, 0x00
.data
check_data3:
	.byte 0x01, 0x32, 0xc1, 0xc2, 0x01, 0x74, 0x7f, 0xc8, 0xdf, 0x21, 0x61, 0x78, 0xb2, 0xe3, 0x46, 0x78
	.byte 0x3e, 0x7c, 0x1f, 0x08, 0xe0, 0xfb, 0x74, 0x82, 0xbf, 0x7f, 0x56, 0x9b, 0xdf, 0x63, 0x6b, 0x38
	.byte 0x5f, 0x26, 0xc7, 0x1a, 0xdf, 0xde, 0x39, 0x28, 0x80, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xfe, 0xff, 0x4f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x48, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x437fa0
	/* C11 */
	.octa 0x80
	/* C14 */
	.octa 0x1800
	/* C22 */
	.octa 0x2000
	/* C23 */
	.octa 0xc21281
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x4ffffe
	/* C11 */
	.octa 0x80
	/* C14 */
	.octa 0x1800
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x2000
	/* C23 */
	.octa 0xc21281
	/* C29 */
	.octa 0x444802
	/* C30 */
	.octa 0x1000
initial_SP_EL3_value:
	.octa 0x80000000000100050000000000407ab0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c13201 // GCFLGS-R.C-C Rd:1 Cn:16 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0xc87f7401 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:0 Rt2:11101 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x786121df // steorh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:14 00:00 opc:010 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x7846e3b2 // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:29 00:00 imm9:001101110 0:0 opc:01 111000:111000 size:01
	.inst 0x081f7c3e // stxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:1 Rt2:11111 o0:0 Rs:31 0:0 L:0 0010000:0010000 size:00
	.inst 0x8274fbe0 // ALDR-R.RI-32 Rt:0 Rn:31 op:10 imm9:101001111 L:1 1000001001:1000001001
	.inst 0x9b567fbf // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:31 Rn:29 Ra:11111 0:0 Rm:22 10:10 U:0 10011011:10011011
	.inst 0x386b63df // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:110 o3:0 Rs:11 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x1ac7265f // lsrv:aarch64/instrs/integer/shift/variable Rd:31 Rn:18 op2:01 0010:0010 Rm:7 0011010110:0011010110 sf:0
	.inst 0x2839dedf // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:31 Rn:22 Rt2:10111 imm7:1110011 L:0 1010000:1010000 opc:00
	.inst 0xc2c21280
	.zero 229236
	.inst 0x004ffffe
	.zero 4
	.inst 0x00444802
	.zero 819284
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
	.inst 0xc240070b // ldr c11, [x24, #1]
	.inst 0xc2400b0e // ldr c14, [x24, #2]
	.inst 0xc2400f16 // ldr c22, [x24, #3]
	.inst 0xc2401317 // ldr c23, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =initial_SP_EL3_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2c1d31f // cpy c31, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x3085103d
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82603298 // ldr c24, [c20, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601298 // ldr c24, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400314 // ldr c20, [x24, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400714 // ldr c20, [x24, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400b14 // ldr c20, [x24, #2]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2400f14 // ldr c20, [x24, #3]
	.inst 0xc2d4a5c1 // chkeq c14, c20
	b.ne comparison_fail
	.inst 0xc2401314 // ldr c20, [x24, #4]
	.inst 0xc2d4a641 // chkeq c18, c20
	b.ne comparison_fail
	.inst 0xc2401714 // ldr c20, [x24, #5]
	.inst 0xc2d4a6c1 // chkeq c22, c20
	b.ne comparison_fail
	.inst 0xc2401b14 // ldr c20, [x24, #6]
	.inst 0xc2d4a6e1 // chkeq c23, c20
	b.ne comparison_fail
	.inst 0xc2401f14 // ldr c20, [x24, #7]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2402314 // ldr c20, [x24, #8]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001802
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fcc
	ldr x1, =check_data2
	ldr x2, =0x00001fd4
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
	ldr x0, =0x00407fec
	ldr x1, =check_data4
	ldr x2, =0x00407ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00437fa0
	ldr x1, =check_data5
	ldr x2, =0x00437fb0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00444870
	ldr x1, =check_data6
	ldr x2, =0x00444872
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004ffffe
	ldr x1, =check_data7
	ldr x2, =0x004fffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
