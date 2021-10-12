.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x15, 0x43, 0xd4, 0xe2, 0xeb, 0xef, 0xea, 0x22, 0xaf, 0x35, 0x59, 0x38, 0xa0, 0xfa, 0x2a, 0xf8
	.byte 0x3f, 0x63, 0x20, 0x38, 0xe1, 0x54, 0x55, 0x10, 0xd1, 0xf7, 0xde, 0x82, 0x11, 0x30, 0xc7, 0xc2
	.byte 0xff, 0xf3, 0x3b, 0x88, 0xf0, 0x03, 0x16, 0x7a, 0x80, 0x10, 0xc2, 0xc2
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C10 */
	.octa 0x200
	/* C13 */
	.octa 0x8000000000010007000000000043ffde
	/* C21 */
	.octa 0x40000000600204010000000000000000
	/* C24 */
	.octa 0x1584
	/* C25 */
	.octa 0xc0000000000100050000000000001400
	/* C30 */
	.octa 0x816
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x200080000021400500000000004aaab0
	/* C10 */
	.octa 0x200
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x8000000000010007000000000043ff71
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0xffffffffffffffff
	/* C21 */
	.octa 0x40000000600204010000000000000000
	/* C24 */
	.octa 0x1584
	/* C25 */
	.octa 0xc0000000000100050000000000001400
	/* C27 */
	.octa 0x1
	/* C30 */
	.octa 0x816
initial_SP_EL3_value:
	.octa 0xd0100000400407f100000000000012b0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000002140050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000001107008700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000012b0
	.dword 0x00000000000012c0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d44315 // ASTUR-R.RI-64 Rt:21 Rn:24 op2:00 imm9:101000100 V:0 op1:11 11100010:11100010
	.inst 0x22eaefeb // LDP-CC.RIAW-C Ct:11 Rn:31 Ct2:11011 imm7:1010101 L:1 001000101:001000101
	.inst 0x385935af // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:15 Rn:13 01:01 imm9:110010011 0:0 opc:01 111000:111000 size:00
	.inst 0xf82afaa0 // str_reg_gen:aarch64/instrs/memory/single/general/register Rt:0 Rn:21 10:10 S:1 option:111 Rm:10 1:1 opc:00 111000:111000 size:11
	.inst 0x3820633f // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:25 00:00 opc:110 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x105554e1 // ADR-C.I-C Rd:1 immhi:101010101010100111 P:0 10000:10000 immlo:00 op:0
	.inst 0x82def7d1 // ALDRSB-R.RRB-32 Rt:17 Rn:30 opc:01 S:1 option:111 Rm:30 0:0 L:1 100000101:100000101
	.inst 0xc2c73011 // RRMASK-R.R-C Rd:17 Rn:0 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0x883bf3ff // stlxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:31 Rt2:11100 o0:1 Rs:27 1:1 L:0 0010000:0010000 sz:0 1:1
	.inst 0x7a1603f0 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:16 Rn:31 000000:000000 Rm:22 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2c21080
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc240068a // ldr c10, [x20, #1]
	.inst 0xc2400a8d // ldr c13, [x20, #2]
	.inst 0xc2400e95 // ldr c21, [x20, #3]
	.inst 0xc2401298 // ldr c24, [x20, #4]
	.inst 0xc2401699 // ldr c25, [x20, #5]
	.inst 0xc2401a9e // ldr c30, [x20, #6]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =initial_SP_EL3_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2c1d29f // cpy c31, c20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x4
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82603094 // ldr c20, [c4, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601094 // ldr c20, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400284 // ldr c4, [x20, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400684 // ldr c4, [x20, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc2400a84 // ldr c4, [x20, #2]
	.inst 0xc2c4a541 // chkeq c10, c4
	b.ne comparison_fail
	.inst 0xc2400e84 // ldr c4, [x20, #3]
	.inst 0xc2c4a561 // chkeq c11, c4
	b.ne comparison_fail
	.inst 0xc2401284 // ldr c4, [x20, #4]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc2401684 // ldr c4, [x20, #5]
	.inst 0xc2c4a5e1 // chkeq c15, c4
	b.ne comparison_fail
	.inst 0xc2401a84 // ldr c4, [x20, #6]
	.inst 0xc2c4a621 // chkeq c17, c4
	b.ne comparison_fail
	.inst 0xc2401e84 // ldr c4, [x20, #7]
	.inst 0xc2c4a6a1 // chkeq c21, c4
	b.ne comparison_fail
	.inst 0xc2402284 // ldr c4, [x20, #8]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2402684 // ldr c4, [x20, #9]
	.inst 0xc2c4a721 // chkeq c25, c4
	b.ne comparison_fail
	.inst 0xc2402a84 // ldr c4, [x20, #10]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402e84 // ldr c4, [x20, #11]
	.inst 0xc2c4a7c1 // chkeq c30, c4
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
	ldr x0, =0x000010ac
	ldr x1, =check_data1
	ldr x2, =0x000010ad
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012b0
	ldr x1, =check_data2
	ldr x2, =0x000012d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001400
	ldr x1, =check_data3
	ldr x2, =0x00001401
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001548
	ldr x1, =check_data4
	ldr x2, =0x00001550
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0043ffde
	ldr x1, =check_data6
	ldr x2, =0x0043ffdf
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
