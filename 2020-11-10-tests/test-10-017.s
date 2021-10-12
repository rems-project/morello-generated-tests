.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xc1, 0x4f, 0x20, 0x92, 0x5f, 0x68, 0x9e, 0xe2, 0xe3, 0x28, 0x82, 0xe2, 0x5f, 0xda, 0x5b, 0xa2
	.byte 0x48, 0xb8, 0x50, 0x39, 0x22, 0x18, 0xe2, 0xc2, 0xe5, 0xbb, 0x0b, 0xc2, 0xc3, 0x9c, 0x1d, 0x31
	.byte 0xf9, 0xb8, 0x22, 0x22, 0xdf, 0x33, 0x3e, 0xf8, 0x20, 0x11, 0xc2, 0xc2
.data
check_data6:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x800000005c3000020000000000001800
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x4c000000080701070000000000001000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x9000000000df84070000000000500000
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0xc0000000000700070000000000001000
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C2 */
	.octa 0x1
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x4c000000080701070000000000001000
	/* C8 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x9000000000df84070000000000500000
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0xc0000000000700070000000000001000
initial_SP_EL3_value:
	.octa 0x4c00000000070b6ffffffffffffff020
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005ff10802000000000000c001
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
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x92204fc1 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:30 imms:010011 immr:100000 N:0 100100:100100 opc:00 sf:1
	.inst 0xe29e685f // ALDURSW-R.RI-64 Rt:31 Rn:2 op2:10 imm9:111100110 V:0 op1:10 11100010:11100010
	.inst 0xe28228e3 // ALDURSW-R.RI-64 Rt:3 Rn:7 op2:10 imm9:000100010 V:0 op1:10 11100010:11100010
	.inst 0xa25bda5f // LDTR-C.RIB-C Ct:31 Rn:18 10:10 imm9:110111101 0:0 opc:01 10100010:10100010
	.inst 0x3950b848 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:8 Rn:2 imm12:010000101110 opc:01 111001:111001 size:00
	.inst 0xc2e21822 // CVT-C.CR-C Cd:2 Cn:1 0110:0110 0:0 0:0 Rm:2 11000010111:11000010111
	.inst 0xc20bbbe5 // STR-C.RIB-C Ct:5 Rn:31 imm12:001011101110 L:0 110000100:110000100
	.inst 0x311d9cc3 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:3 Rn:6 imm12:011101100111 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0x2222b8f9 // STLXP-R.CR-C Ct:25 Rn:7 Ct2:01110 1:1 Rs:2 1:1 L:0 001000100:001000100
	.inst 0xf83e33df // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:011 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c21120
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e2 // ldr c2, [x23, #0]
	.inst 0xc24006e5 // ldr c5, [x23, #1]
	.inst 0xc2400ae7 // ldr c7, [x23, #2]
	.inst 0xc2400eee // ldr c14, [x23, #3]
	.inst 0xc24012f2 // ldr c18, [x23, #4]
	.inst 0xc24016f9 // ldr c25, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_SP_EL3_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x3085103f
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603137 // ldr c23, [c9, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601137 // ldr c23, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e9 // ldr c9, [x23, #0]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc24006e9 // ldr c9, [x23, #1]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400ae9 // ldr c9, [x23, #2]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400ee9 // ldr c9, [x23, #3]
	.inst 0xc2c9a4e1 // chkeq c7, c9
	b.ne comparison_fail
	.inst 0xc24012e9 // ldr c9, [x23, #4]
	.inst 0xc2c9a501 // chkeq c8, c9
	b.ne comparison_fail
	.inst 0xc24016e9 // ldr c9, [x23, #5]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401ae9 // ldr c9, [x23, #6]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401ee9 // ldr c9, [x23, #7]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc24022e9 // ldr c9, [x23, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
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
	ldr x0, =0x00001824
	ldr x1, =check_data1
	ldr x2, =0x00001828
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001c2e
	ldr x1, =check_data2
	ldr x2, =0x00001c2f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f00
	ldr x1, =check_data3
	ldr x2, =0x00001f10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe8
	ldr x1, =check_data4
	ldr x2, =0x00001fec
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
	ldr x0, =0x004ffbd0
	ldr x1, =check_data6
	ldr x2, =0x004ffbe0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
