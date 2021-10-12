.section data0, #alloc, #write
	.zero 2048
	.byte 0x34, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2016
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x0c, 0x00, 0x40, 0x00
.data
check_data2:
	.byte 0x34, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x90, 0xfc, 0x5f, 0x08, 0x7c, 0x28, 0x7f, 0x22, 0x80, 0x03, 0x3f, 0xd6
.data
check_data5:
	.byte 0x1e, 0xd8, 0x57, 0x82, 0xfe, 0x22, 0x94, 0x78, 0x5f, 0x01, 0x3d, 0xf8, 0xf1, 0xdf, 0x7f, 0xc8
	.byte 0x3e, 0x20, 0xde, 0xc2, 0xc2, 0x11, 0xc2, 0xc2
.data
check_data6:
	.byte 0x0b, 0xc1, 0x41, 0xfa, 0xe0, 0x10, 0xc2, 0xc2
.data
check_data7:
	.zero 2
.data
check_data8:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000c0c
	/* C1 */
	.octa 0x400000000000000000000000
	/* C3 */
	.octa 0x1800
	/* C4 */
	.octa 0x4ffffe
	/* C14 */
	.octa 0x20008000800100050000000000400080
	/* C23 */
	.octa 0x50009a
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000000c0c
	/* C1 */
	.octa 0x400000000000000000000000
	/* C3 */
	.octa 0x1800
	/* C4 */
	.octa 0x4ffffe
	/* C10 */
	.octa 0x1000
	/* C14 */
	.octa 0x20008000800100050000000000400080
	/* C16 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C28 */
	.octa 0x400034
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000000000000000000
initial_SP_EL3_value:
	.octa 0x1fe0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001007c8070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0000000000080080000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword 0x0000000000001810
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x085ffc90 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:16 Rn:4 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0x227f287c // LDXP-C.R-C Ct:28 Rn:3 Ct2:01010 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xd63f0380 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:28 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 40
	.inst 0x8257d81e // ASTR-R.RI-32 Rt:30 Rn:0 op:10 imm9:101111101 L:0 1000001001:1000001001
	.inst 0x789422fe // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:23 00:00 imm9:101000010 0:0 opc:10 111000:111000 size:01
	.inst 0xf83d015f // ldadd:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:10 00:00 opc:000 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xc87fdff1 // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:17 Rn:31 Rt2:10111 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xc2de203e // SCBNDSE-C.CR-C Cd:30 Cn:1 000:000 opc:01 0:0 Rm:30 11000010110:11000010110
	.inst 0xc2c211c2 // BRS-C-C 00010:00010 Cn:14 100:100 opc:00 11000010110000100:11000010110000100
	.zero 52
	.inst 0xfa41c10b // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1011 0:0 Rn:8 00:00 cond:1100 Rm:1 111010010:111010010 op:1 sf:1
	.inst 0xc2c210e0
	.zero 1048440
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
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400843 // ldr c3, [x2, #2]
	.inst 0xc2400c44 // ldr c4, [x2, #3]
	.inst 0xc240104e // ldr c14, [x2, #4]
	.inst 0xc2401457 // ldr c23, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	ldr x2, =0x0
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030e2 // ldr c2, [c7, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x826010e2 // ldr c2, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0x3
	and x2, x2, x7
	cmp x2, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400047 // ldr c7, [x2, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400447 // ldr c7, [x2, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400847 // ldr c7, [x2, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400c47 // ldr c7, [x2, #3]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2401047 // ldr c7, [x2, #4]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc2401447 // ldr c7, [x2, #5]
	.inst 0xc2c7a5c1 // chkeq c14, c7
	b.ne comparison_fail
	.inst 0xc2401847 // ldr c7, [x2, #6]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401c47 // ldr c7, [x2, #7]
	.inst 0xc2c7a621 // chkeq c17, c7
	b.ne comparison_fail
	.inst 0xc2402047 // ldr c7, [x2, #8]
	.inst 0xc2c7a6e1 // chkeq c23, c7
	b.ne comparison_fail
	.inst 0xc2402447 // ldr c7, [x2, #9]
	.inst 0xc2c7a781 // chkeq c28, c7
	b.ne comparison_fail
	.inst 0xc2402847 // ldr c7, [x2, #10]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402c47 // ldr c7, [x2, #11]
	.inst 0xc2c7a7c1 // chkeq c30, c7
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001204
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001820
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001fe0
	ldr x1, =check_data3
	ldr x2, =0x00001ff0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400034
	ldr x1, =check_data5
	ldr x2, =0x0040004c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x00400088
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004fffdc
	ldr x1, =check_data7
	ldr x2, =0x004fffde
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x004ffffe
	ldr x1, =check_data8
	ldr x2, =0x004fffff
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
