.section data0, #alloc, #write
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.byte 0x00, 0xa0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.data
check_data2:
	.byte 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x9f, 0x62, 0x60, 0x38, 0x34, 0x7c, 0x5f, 0x22, 0xca, 0xfc, 0xdf, 0x48, 0x5f, 0x7c, 0x04, 0x48
	.byte 0xcf, 0x68, 0xa0, 0xf8, 0x08, 0x00, 0x1e, 0x7a, 0x51, 0x30, 0x20, 0xf8, 0x22, 0xfc, 0x9f, 0x08
	.byte 0xec, 0x93, 0xc5, 0xc2, 0x0f, 0x88, 0x1d, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4c00000000010005ffffffffffffa000
	/* C1 */
	.octa 0xd0000000000100050000000000001680
	/* C2 */
	.octa 0xc0000000000100050000000000001020
	/* C6 */
	.octa 0x800000004001400400000000004f4400
	/* C15 */
	.octa 0x100000
	/* C20 */
	.octa 0xc0000000000080100000000000001000
final_cap_values:
	/* C0 */
	.octa 0x4c00000000010005ffffffffffffa000
	/* C1 */
	.octa 0xd0000000000100050000000000001680
	/* C2 */
	.octa 0xc0000000000100050000000000001020
	/* C4 */
	.octa 0x1
	/* C6 */
	.octa 0x800000004001400400000000004f4400
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x1e00fe008000000000000
	/* C15 */
	.octa 0x100000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x1e00f0000000000020000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3860629f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:110 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x225f7c34 // LDXR-C.R-C Ct:20 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x48dffcca // ldarh:aarch64/instrs/memory/ordered Rt:10 Rn:6 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0x48047c5f // stxrh:aarch64/instrs/memory/exclusive/single Rt:31 Rn:2 Rt2:11111 o0:0 Rs:4 0:0 L:0 0010000:0010000 size:01
	.inst 0xf8a068cf // prfm_reg:aarch64/instrs/memory/single/general/register Rt:15 Rn:6 10:10 S:0 option:011 Rm:0 1:1 opc:10 111000:111000 size:11
	.inst 0x7a1e0008 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:8 Rn:0 000000:000000 Rm:30 11010000:11010000 S:1 op:1 sf:0
	.inst 0xf8203051 // ldset:aarch64/instrs/memory/atomicops/ld Rt:17 Rn:2 00:00 opc:011 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:11
	.inst 0x089ffc22 // stlrb:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xc2c593ec // CVTD-C.R-C Cd:12 Rn:31 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc21d880f // STR-C.RIB-C Ct:15 Rn:0 imm12:011101100010 L:0 110000100:110000100
	.inst 0xc2c212e0
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a02 // ldr c2, [x16, #2]
	.inst 0xc2400e06 // ldr c6, [x16, #3]
	.inst 0xc240120f // ldr c15, [x16, #4]
	.inst 0xc2401614 // ldr c20, [x16, #5]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f0 // ldr c16, [c23, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x826012f0 // ldr c16, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400217 // ldr c23, [x16, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400617 // ldr c23, [x16, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a17 // ldr c23, [x16, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e17 // ldr c23, [x16, #3]
	.inst 0xc2d7a481 // chkeq c4, c23
	b.ne comparison_fail
	.inst 0xc2401217 // ldr c23, [x16, #4]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2401617 // ldr c23, [x16, #5]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401a17 // ldr c23, [x16, #6]
	.inst 0xc2d7a581 // chkeq c12, c23
	b.ne comparison_fail
	.inst 0xc2401e17 // ldr c23, [x16, #7]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2402217 // ldr c23, [x16, #8]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2402617 // ldr c23, [x16, #9]
	.inst 0xc2d7a681 // chkeq c20, c23
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001620
	ldr x1, =check_data2
	ldr x2, =0x00001630
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001680
	ldr x1, =check_data3
	ldr x2, =0x00001690
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
	ldr x0, =0x004f4400
	ldr x1, =check_data5
	ldr x2, =0x004f4402
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
