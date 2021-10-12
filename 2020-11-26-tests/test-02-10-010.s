.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x0d, 0x81, 0xbf, 0x7f, 0xff, 0x0b, 0x26, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3824
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x00, 0x0d, 0x81, 0xbf, 0x7f, 0xff, 0x0b, 0x26
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x1d, 0x6c, 0x1e, 0x78, 0xa8, 0x0b, 0xdf, 0xc2, 0x35, 0x40, 0x3d, 0x78, 0x21, 0x05, 0xc0, 0xda
	.byte 0x9f, 0x11, 0x3f, 0xf8, 0xe0, 0x93, 0x81, 0xb8, 0x7f, 0x12, 0x3e, 0xf8, 0xfe, 0x7f, 0x01, 0x08
	.byte 0x9d, 0x61, 0x02, 0x9b, 0xe0, 0x2a, 0xa9, 0xb4, 0x40, 0x13, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
check_data6:
	.byte 0xfe, 0x00, 0x01, 0x08
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000180050000000000001800
	/* C1 */
	.octa 0xc0000000200100050000000000001010
	/* C12 */
	.octa 0xc00000000006000300000000000010f0
	/* C19 */
	.octa 0xc00000004fff10040000000000001100
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20000
final_cap_values:
	/* C0 */
	.octa 0x80100fe
	/* C1 */
	.octa 0x1
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0xc00000000006000300000000000010f0
	/* C19 */
	.octa 0xc00000004fff10040000000000001100
	/* C21 */
	.octa 0x0
	/* C30 */
	.octa 0x20000
initial_SP_EL3_value:
	.octa 0xc0000000500200200000000000400043
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x781e6c1d // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:29 Rn:0 11:11 imm9:111100110 0:0 opc:00 111000:111000 size:01
	.inst 0xc2df0ba8 // SEAL-C.CC-C Cd:8 Cn:29 0010:0010 opc:00 Cm:31 11000010110:11000010110
	.inst 0x783d4035 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:21 Rn:1 00:00 opc:100 0:0 Rs:29 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xdac00521 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:9 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xf83f119f // ldclr:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:12 00:00 opc:001 0:0 Rs:31 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xb88193e0 // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:000011001 0:0 opc:10 111000:111000 size:10
	.inst 0xf83e127f // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:19 00:00 opc:001 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x08017ffe // stxrb:aarch64/instrs/memory/exclusive/single Rt:30 Rn:31 Rt2:11111 o0:0 Rs:1 0:0 L:0 0010000:0010000 size:00
	.inst 0x9b02619d // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:29 Rn:12 Ra:24 o0:0 Rm:2 0011011000:0011011000 sf:1
	.inst 0xb4a92ae0 // cbz:aarch64/instrs/branch/conditional/compare Rt:0 imm19:1010100100101010111 op:0 011010:011010 sf:1
	.inst 0xc2c21340
	.zero 48
	.inst 0x080100fe
	.zero 1048480
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc240094c // ldr c12, [x10, #2]
	.inst 0xc2400d53 // ldr c19, [x10, #3]
	.inst 0xc240115d // ldr c29, [x10, #4]
	.inst 0xc240155e // ldr c30, [x10, #5]
	/* Set up flags and system registers */
	mov x10, #0x00000000
	msr nzcv, x10
	ldr x10, =initial_SP_EL3_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2c1d15f // cpy c31, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x8260134a // ldr c10, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc2c21140 // br c10
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc240015a // ldr c26, [x10, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240055a // ldr c26, [x10, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc240095a // ldr c26, [x10, #2]
	.inst 0xc2daa501 // chkeq c8, c26
	b.ne comparison_fail
	.inst 0xc2400d5a // ldr c26, [x10, #3]
	.inst 0xc2daa581 // chkeq c12, c26
	b.ne comparison_fail
	.inst 0xc240115a // ldr c26, [x10, #4]
	.inst 0xc2daa661 // chkeq c19, c26
	b.ne comparison_fail
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc2daa6a1 // chkeq c21, c26
	b.ne comparison_fail
	.inst 0xc240195a // ldr c26, [x10, #6]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001012
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f0
	ldr x1, =check_data1
	ldr x2, =0x000010f8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017e6
	ldr x1, =check_data3
	ldr x2, =0x000017e8
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
	ldr x0, =0x00400043
	ldr x1, =check_data5
	ldr x2, =0x00400044
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040005c
	ldr x1, =check_data6
	ldr x2, =0x00400060
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
