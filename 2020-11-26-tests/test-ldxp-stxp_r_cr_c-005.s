.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xc3, 0x4f, 0x53, 0xe2, 0x40, 0x52, 0x6e, 0x82, 0x69, 0x73, 0x7f, 0x22, 0x41, 0x00, 0xde, 0xc2
	.byte 0x1f, 0x05, 0xa1, 0xb6
.data
check_data5:
	.byte 0x83, 0x04, 0x20, 0x22, 0x3f, 0xd0, 0xc0, 0xc2, 0x7e, 0xfe, 0xbd, 0x48, 0xdf, 0x83, 0xa1, 0xb8
	.byte 0x1e, 0xa5, 0x88, 0x90, 0x40, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x800100030000000000000000
	/* C4 */
	.octa 0x40000000000100050000000000001200
	/* C18 */
	.octa 0x9b0
	/* C19 */
	.octa 0xc0000000000500040000000000001000
	/* C27 */
	.octa 0x90000000000100050000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000000100050000000000001100
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0xd10000000000000000000000
	/* C2 */
	.octa 0x800100030000000000000000
	/* C3 */
	.octa 0x0
	/* C4 */
	.octa 0x40000000000100050000000000001200
	/* C9 */
	.octa 0x1000000000000000000000000
	/* C18 */
	.octa 0x9b0
	/* C19 */
	.octa 0xc0000000000500040000000000001000
	/* C27 */
	.octa 0x90000000000100050000000000001000
	/* C28 */
	.octa 0x101800000000000000000000000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200080000000c00000000000118a2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x90100000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2534fc3 // ALDURSH-R.RI-32 Rt:3 Rn:30 op2:11 imm9:100110100 V:0 op1:01 11100010:11100010
	.inst 0x826e5240 // ALDR-C.RI-C Ct:0 Rn:18 op:00 imm9:011100101 L:1 1000001001:1000001001
	.inst 0x227f7369 // 0x227f7369
	.inst 0xc2de0041 // SCBNDS-C.CR-C Cd:1 Cn:2 000:000 opc:00 0:0 Rm:30 11000010110:11000010110
	.inst 0xb6a1051f // tbz:aarch64/instrs/branch/conditional/test Rt:31 imm14:00100000101000 b40:10100 op:0 011011:011011 b5:1
	.zero 8348
	.inst 0x22200483 // 0x22200483
	.inst 0xc2c0d03f // GCPERM-R.C-C Rd:31 Cn:1 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x48bdfe7e // cash:aarch64/instrs/memory/atomicops/cas/single Rt:30 Rn:19 11111:11111 o0:1 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0xb8a183df // swp:aarch64/instrs/memory/atomicops/swp Rt:31 Rn:30 100000:100000 Rs:1 1:1 R:0 A:1 111000:111000 size:10
	.inst 0x9088a51e // ADRP-C.I-C Rd:30 immhi:000100010100101000 P:1 10000:10000 immlo:00 op:1
	.inst 0xc2c21340
	.zero 1040184
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
	ldr x12, =initial_cap_values
	.inst 0xc2400182 // ldr c2, [x12, #0]
	.inst 0xc2400584 // ldr c4, [x12, #1]
	.inst 0xc2400992 // ldr c18, [x12, #2]
	.inst 0xc2400d93 // ldr c19, [x12, #3]
	.inst 0xc240119b // ldr c27, [x12, #4]
	.inst 0xc240159d // ldr c29, [x12, #5]
	.inst 0xc240199e // ldr c30, [x12, #6]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260334c // ldr c12, [c26, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260134c // ldr c12, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc240019a // ldr c26, [x12, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240059a // ldr c26, [x12, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240099a // ldr c26, [x12, #2]
	.inst 0xc2daa441 // chkeq c2, c26
	b.ne comparison_fail
	.inst 0xc2400d9a // ldr c26, [x12, #3]
	.inst 0xc2daa461 // chkeq c3, c26
	b.ne comparison_fail
	.inst 0xc240119a // ldr c26, [x12, #4]
	.inst 0xc2daa481 // chkeq c4, c26
	b.ne comparison_fail
	.inst 0xc240159a // ldr c26, [x12, #5]
	.inst 0xc2daa521 // chkeq c9, c26
	b.ne comparison_fail
	.inst 0xc240199a // ldr c26, [x12, #6]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc2401d9a // ldr c26, [x12, #7]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc240219a // ldr c26, [x12, #8]
	.inst 0xc2daa761 // chkeq c27, c26
	b.ne comparison_fail
	.inst 0xc240259a // ldr c26, [x12, #9]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc240299a // ldr c26, [x12, #10]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc2402d9a // ldr c26, [x12, #11]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001034
	ldr x1, =check_data1
	ldr x2, =0x00001036
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001104
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
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004020b0
	ldr x1, =check_data5
	ldr x2, =0x004020c8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
