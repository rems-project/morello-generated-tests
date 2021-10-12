.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 80
	.byte 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2048
	.byte 0x04, 0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1920
.data
check_data0:
	.byte 0x29, 0x90, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x04, 0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0xc0, 0x02, 0x1e, 0x3a, 0x83, 0x7d, 0xdf, 0x9b, 0xde, 0xff, 0x47, 0xe2, 0x3f, 0x7c, 0xa1, 0xa2
	.byte 0x9f, 0x73, 0x3f, 0x38, 0xe1, 0x5b, 0x1a, 0x78, 0x00, 0xd5, 0xfd, 0xc2, 0xff, 0x43, 0x69, 0x38
	.byte 0xbe, 0x7f, 0x5f, 0x22, 0x87, 0x73, 0x27, 0xb8, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0100000400100080000000000001870
	/* C7 */
	.octa 0x80000000
	/* C8 */
	.octa 0xfffffffffffea000
	/* C9 */
	.octa 0x0
	/* C22 */
	.octa 0xffc05000
	/* C28 */
	.octa 0xc000000060000c3c0000000000001008
	/* C29 */
	.octa 0x90100000002600010000000000001700
	/* C30 */
	.octa 0x404029
final_cap_values:
	/* C0 */
	.octa 0x9029
	/* C1 */
	.octa 0x2104
	/* C3 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0xfffffffffffea000
	/* C9 */
	.octa 0x0
	/* C22 */
	.octa 0xffc05000
	/* C28 */
	.octa 0xc000000060000c3c0000000000001008
	/* C29 */
	.octa 0x90100000002600010000000000001700
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0xc0000000510100000000000000001063
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000180010880000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000003000700ffe00000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001700
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3a1e02c0 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:22 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0x9bdf7d83 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:3 Rn:12 Ra:11111 0:0 Rm:31 10:10 U:1 10011011:10011011
	.inst 0xe247ffde // ALDURSH-R.RI-32 Rt:30 Rn:30 op2:11 imm9:001111111 V:0 op1:01 11100010:11100010
	.inst 0xa2a17c3f // CAS-C.R-C Ct:31 Rn:1 11111:11111 R:0 Cs:1 1:1 L:0 1:1 10100010:10100010
	.inst 0x383f739f // stuminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:28 00:00 opc:111 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x781a5be1 // sttrh:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:31 10:10 imm9:110100101 0:0 opc:00 111000:111000 size:01
	.inst 0xc2fdd500 // ASTR-C.RRB-C Ct:0 Rn:8 1:1 L:0 S:1 option:110 Rm:29 11000010111:11000010111
	.inst 0x386943ff // stsmaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:100 o3:0 Rs:9 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0x225f7fbe // LDXR-C.R-C Ct:30 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xb8277387 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:7 Rn:28 00:00 opc:111 0:0 Rs:7 1:1 R:0 A:0 111000:111000 size:10
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a1 // ldr c1, [x13, #0]
	.inst 0xc24005a7 // ldr c7, [x13, #1]
	.inst 0xc24009a8 // ldr c8, [x13, #2]
	.inst 0xc2400da9 // ldr c9, [x13, #3]
	.inst 0xc24011b6 // ldr c22, [x13, #4]
	.inst 0xc24015bc // ldr c28, [x13, #5]
	.inst 0xc24019bd // ldr c29, [x13, #6]
	.inst 0xc2401dbe // ldr c30, [x13, #7]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032ad // ldr c13, [c21, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x826012ad // ldr c13, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x21, #0xf
	and x13, x13, x21
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b5 // ldr c21, [x13, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005b5 // ldr c21, [x13, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009b5 // ldr c21, [x13, #2]
	.inst 0xc2d5a461 // chkeq c3, c21
	b.ne comparison_fail
	.inst 0xc2400db5 // ldr c21, [x13, #3]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc24011b5 // ldr c21, [x13, #4]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc24015b5 // ldr c21, [x13, #5]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc24019b5 // ldr c21, [x13, #6]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2401db5 // ldr c21, [x13, #7]
	.inst 0xc2d5a781 // chkeq c28, c21
	b.ne comparison_fail
	.inst 0xc24021b5 // ldr c21, [x13, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc24025b5 // ldr c21, [x13, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001063
	ldr x1, =check_data1
	ldr x2, =0x00001064
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001700
	ldr x1, =check_data2
	ldr x2, =0x00001710
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001870
	ldr x1, =check_data3
	ldr x2, =0x00001880
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
	ldr x0, =0x004040a8
	ldr x1, =check_data5
	ldr x2, =0x004040aa
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
