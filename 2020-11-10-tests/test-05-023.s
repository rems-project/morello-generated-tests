.section data0, #alloc, #write
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00
	.zero 4064
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x81
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x88, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x02, 0x5f, 0xd6, 0x02, 0x50, 0xc1, 0xc2, 0x21, 0x28, 0xc1, 0x9a, 0xa0, 0x2b, 0xe2, 0x92
	.byte 0xce, 0x7f, 0x02, 0x08, 0xff, 0x50, 0x61, 0x38, 0xbe, 0xa8, 0xc1, 0x79, 0xc1, 0x83, 0x61, 0xa2
	.byte 0xff, 0x73, 0x7f, 0x78, 0xe8, 0x7f, 0xa2, 0x9b, 0x20, 0x12, 0xc2, 0xc2
.data
check_data4:
	.byte 0x00, 0x18
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x8802020000000000
	/* C5 */
	.octa 0x4ffee8
	/* C7 */
	.octa 0x101e
	/* C16 */
	.octa 0x400004
	/* C30 */
	.octa 0x4ffffe
final_cap_values:
	/* C0 */
	.octa 0xeea2ffffffffffff
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1
	/* C5 */
	.octa 0x4ffee8
	/* C7 */
	.octa 0x101e
	/* C8 */
	.octa 0x0
	/* C16 */
	.octa 0x400004
	/* C30 */
	.octa 0x1800
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000100050000000000000003
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd65f0200 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:16 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0xc2c15002 // CFHI-R.C-C Rd:2 Cn:0 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0x9ac12821 // asrv:aarch64/instrs/integer/shift/variable Rd:1 Rn:1 op2:10 0010:0010 Rm:1 0011010110:0011010110 sf:1
	.inst 0x92e22ba0 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:0 imm16:0001000101011101 hw:11 100101:100101 opc:00 sf:1
	.inst 0x08027fce // stxrb:aarch64/instrs/memory/exclusive/single Rt:14 Rn:30 Rt2:11111 o0:0 Rs:2 0:0 L:0 0010000:0010000 size:00
	.inst 0x386150ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:101 o3:0 Rs:1 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x79c1a8be // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:5 imm12:000001101010 opc:11 111001:111001 size:01
	.inst 0xa26183c1 // SWPL-CC.R-C Ct:1 Rn:30 100000:100000 Cs:1 1:1 R:1 A:0 10100010:10100010
	.inst 0x787f73ff // lduminh:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:31 00:00 opc:111 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x9ba27fe8 // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:8 Rn:31 Ra:31 o0:0 Rm:2 01:01 U:1 10011011:10011011
	.inst 0xc2c21220
	.zero 1048464
	.inst 0x00001800
	.zero 64
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
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400565 // ldr c5, [x11, #1]
	.inst 0xc2400967 // ldr c7, [x11, #2]
	.inst 0xc2400d70 // ldr c16, [x11, #3]
	.inst 0xc240117e // ldr c30, [x11, #4]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =initial_SP_EL3_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2c1d17f // cpy c31, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	ldr x11, =0xc
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322b // ldr c11, [c17, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x8260122b // ldr c11, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
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
	.inst 0xc2400171 // ldr c17, [x11, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400571 // ldr c17, [x11, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400971 // ldr c17, [x11, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400d71 // ldr c17, [x11, #3]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc2401171 // ldr c17, [x11, #4]
	.inst 0xc2d1a4e1 // chkeq c7, c17
	b.ne comparison_fail
	.inst 0xc2401571 // ldr c17, [x11, #5]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401971 // ldr c17, [x11, #6]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2401d71 // ldr c17, [x11, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x0000101e
	ldr x1, =check_data1
	ldr x2, =0x0000101f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001810
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
	ldr x0, =0x004fffbc
	ldr x1, =check_data4
	ldr x2, =0x004fffbe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
