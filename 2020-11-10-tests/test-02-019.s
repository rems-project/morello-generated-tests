.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xc2, 0x52, 0xc2, 0xc2
.data
check_data6:
	.byte 0x00, 0x20, 0x8d, 0x1a, 0xe2, 0xff, 0x0f, 0x48, 0x18, 0xd8, 0x1b, 0x70, 0x5e, 0xa0, 0x08, 0x12
	.byte 0x20, 0x84, 0x0c, 0x6d, 0xde, 0xcb, 0x2a, 0xd1, 0xe8, 0xb0, 0x00, 0xb8, 0xe0, 0xd3, 0x0b, 0xe2
	.byte 0x3f, 0x31, 0x75, 0x78, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1858
	/* C7 */
	.octa 0xff5
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x18d4
	/* C13 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x20008000800100070000000000400080
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1858
	/* C7 */
	.octa 0xff5
	/* C8 */
	.octa 0x0
	/* C9 */
	.octa 0x18d4
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x1
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x20008000800100070000000000400080
	/* C24 */
	.octa 0x437b8b
initial_SP_EL3_value:
	.octa 0x40000000000100050000000000001a40
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000080080000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c252c2 // RETS-C-C 00010:00010 Cn:22 100:100 opc:10 11000010110000100:11000010110000100
	.zero 124
	.inst 0x1a8d2000 // csel:aarch64/instrs/integer/conditional/select Rd:0 Rn:0 o2:0 0:0 cond:0010 Rm:13 011010100:011010100 op:0 sf:0
	.inst 0x480fffe2 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:31 Rt2:11111 o0:1 Rs:15 0:0 L:0 0010000:0010000 size:01
	.inst 0x701bd818 // ADR-C.I-C Rd:24 immhi:001101111011000000 P:0 10000:10000 immlo:11 op:0
	.inst 0x1208a05e // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:2 imms:101000 immr:001000 N:0 100100:100100 opc:00 sf:0
	.inst 0x6d0c8420 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:1 Rt2:00001 imm7:0011001 L:0 1011010:1011010 opc:01
	.inst 0xd12acbde // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:30 imm12:101010110010 sh:0 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0xb800b0e8 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:8 Rn:7 00:00 imm9:000001011 0:0 opc:00 111000:111000 size:10
	.inst 0xe20bd3e0 // ASTURB-R.RI-32 Rt:0 Rn:31 op2:00 imm9:010111101 V:0 op1:00 11100010:11100010
	.inst 0x7875313f // stseth:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:011 o3:0 Rs:21 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c21380
	.zero 1048408
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400747 // ldr c7, [x26, #1]
	.inst 0xc2400b48 // ldr c8, [x26, #2]
	.inst 0xc2400f49 // ldr c9, [x26, #3]
	.inst 0xc240134d // ldr c13, [x26, #4]
	.inst 0xc2401755 // ldr c21, [x26, #5]
	.inst 0xc2401b56 // ldr c22, [x26, #6]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q0, =0x0
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =initial_SP_EL3_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2c1d35f // cpy c31, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	ldr x26, =0x8
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260339a // ldr c26, [c28, #3]
	.inst 0xc28b413a // msr DDC_EL3, c26
	isb
	.inst 0x8260139a // ldr c26, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x28, #0x2
	and x26, x26, x28
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240035c // ldr c28, [x26, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240075c // ldr c28, [x26, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400b5c // ldr c28, [x26, #2]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc2400f5c // ldr c28, [x26, #3]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240135c // ldr c28, [x26, #4]
	.inst 0xc2dca521 // chkeq c9, c28
	b.ne comparison_fail
	.inst 0xc240175c // ldr c28, [x26, #5]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc2401b5c // ldr c28, [x26, #6]
	.inst 0xc2dca5e1 // chkeq c15, c28
	b.ne comparison_fail
	.inst 0xc2401f5c // ldr c28, [x26, #7]
	.inst 0xc2dca6a1 // chkeq c21, c28
	b.ne comparison_fail
	.inst 0xc240235c // ldr c28, [x26, #8]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc240275c // ldr c28, [x26, #9]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x28, v0.d[0]
	cmp x26, x28
	b.ne comparison_fail
	ldr x26, =0x0
	mov x28, v0.d[1]
	cmp x26, x28
	b.ne comparison_fail
	ldr x26, =0x0
	mov x28, v1.d[0]
	cmp x26, x28
	b.ne comparison_fail
	ldr x26, =0x0
	mov x28, v1.d[1]
	cmp x26, x28
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
	ldr x0, =0x000018d4
	ldr x1, =check_data1
	ldr x2, =0x000018d6
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001920
	ldr x1, =check_data2
	ldr x2, =0x00001930
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a40
	ldr x1, =check_data3
	ldr x2, =0x00001a42
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001afd
	ldr x1, =check_data4
	ldr x2, =0x00001afe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x004000a8
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
