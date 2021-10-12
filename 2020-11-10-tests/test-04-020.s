.section data0, #alloc, #write
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xff, 0x33, 0x3e, 0x38, 0x22, 0xfe, 0x5f, 0x22, 0xfd, 0x07, 0x22, 0x9b, 0x40, 0xd2, 0xc0, 0xc2
	.byte 0xf0, 0xa3, 0xd0, 0xc2, 0x89, 0x72, 0x18, 0x10, 0x2f, 0x88, 0xde, 0xc2, 0x22, 0x04, 0x7a, 0x82
	.byte 0x1b, 0xe1, 0x0e, 0xbd, 0xe7, 0xf3, 0xc0, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x25002d0000000000400001
	/* C8 */
	.octa 0x40000000000100050000000000001118
	/* C17 */
	.octa 0x90000000000700070000000000001010
	/* C30 */
	.octa 0x100030000000000000000
final_cap_values:
	/* C1 */
	.octa 0x25002d0000000000400001
	/* C2 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x40000000000100050000000000001118
	/* C9 */
	.octa 0x20008000440100000000000000430e64
	/* C15 */
	.octa 0x25002d0000000000400001
	/* C17 */
	.octa 0x90000000000700070000000000001010
	/* C29 */
	.octa 0x400001
	/* C30 */
	.octa 0x100030000000000000000
initial_SP_EL3_value:
	.octa 0xc00000000807040600000000000012d0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000440100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000000000c0000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x383e33ff // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:011 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x225ffe22 // LDAXR-C.R-C Ct:2 Rn:17 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x9b2207fd // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:31 Ra:1 o0:0 Rm:2 01:01 U:0 10011011:10011011
	.inst 0xc2c0d240 // GCPERM-R.C-C Rd:0 Cn:18 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0xc2d0a3f0 // CLRPERM-C.CR-C Cd:16 Cn:31 000:000 1:1 10:10 Rm:16 11000010110:11000010110
	.inst 0x10187289 // ADR-C.I-C Rd:9 immhi:001100001110010100 P:0 10000:10000 immlo:00 op:0
	.inst 0xc2de882f // CHKSSU-C.CC-C Cd:15 Cn:1 0010:0010 opc:10 Cm:30 11000010110:11000010110
	.inst 0x827a0422 // ALDRB-R.RI-B Rt:2 Rn:1 op:01 imm9:110100000 L:1 1000001001:1000001001
	.inst 0xbd0ee11b // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:27 Rn:8 imm12:001110111000 opc:00 111101:111101 size:10
	.inst 0xc2c0f3e7 // GCTYPE-R.C-C Rd:7 Cn:31 100:100 opc:111 1100001011000000:1100001011000000
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c8 // ldr c8, [x14, #1]
	.inst 0xc24009d1 // ldr c17, [x14, #2]
	.inst 0xc2400dde // ldr c30, [x14, #3]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q27, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085103f
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030ce // ldr c14, [c6, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826010ce // ldr c14, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x6, #0xf
	and x14, x14, x6
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c6 // ldr c6, [x14, #0]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24005c6 // ldr c6, [x14, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc2c6a501 // chkeq c8, c6
	b.ne comparison_fail
	.inst 0xc24011c6 // ldr c6, [x14, #4]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc24015c6 // ldr c6, [x14, #5]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc24019c6 // ldr c6, [x14, #6]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc2401dc6 // ldr c6, [x14, #7]
	.inst 0xc2c6a7a1 // chkeq c29, c6
	b.ne comparison_fail
	.inst 0xc24021c6 // ldr c6, [x14, #8]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x6, v27.d[0]
	cmp x14, x6
	b.ne comparison_fail
	ldr x14, =0x0
	mov x6, v27.d[1]
	cmp x14, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000012d0
	ldr x1, =check_data1
	ldr x2, =0x000012d1
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
	ldr x0, =0x004001a1
	ldr x1, =check_data4
	ldr x2, =0x004001a2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
