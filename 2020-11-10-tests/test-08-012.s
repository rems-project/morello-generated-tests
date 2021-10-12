.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 1
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x1b, 0x60, 0x2f, 0xe2, 0x53, 0x94, 0x4a, 0x02, 0x33, 0xf9, 0x8e, 0xe2, 0xdf, 0xdb, 0x53, 0x69
	.byte 0xdb, 0xcb, 0x46, 0xf8, 0x5f, 0x61, 0xa8, 0xa9, 0xe7, 0x83, 0x62, 0xb8, 0xbe, 0x7d, 0xc2, 0x9b
	.byte 0xe4, 0x29, 0x7f, 0xc8, 0x62, 0x3f, 0x65, 0x92, 0xa0, 0x12, 0xc2, 0xc2
.data
check_data7:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000400000020000000000001c14
	/* C2 */
	.octa 0x2000180040000000000000000
	/* C9 */
	.octa 0x800000000807010a0000000000411001
	/* C10 */
	.octa 0x2100
	/* C15 */
	.octa 0x1000
	/* C24 */
	.octa 0x0
	/* C30 */
	.octa 0x1a04
final_cap_values:
	/* C0 */
	.octa 0x40000000400000020000000000001c14
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x800000000807010a0000000000411001
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x1000
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1ea0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000780000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600000010000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe22f601b // ASTUR-V.RI-B Rt:27 Rn:0 op2:00 imm9:011110110 V:1 op1:00 11100010:11100010
	.inst 0x024a9453 // ADD-C.CIS-C Cd:19 Cn:2 imm12:001010100101 sh:1 A:0 00000010:00000010
	.inst 0xe28ef933 // ALDURSW-R.RI-64 Rt:19 Rn:9 op2:10 imm9:011101111 V:0 op1:10 11100010:11100010
	.inst 0x6953dbdf // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:30 Rt2:10110 imm7:0100111 L:1 1010010:1010010 opc:01
	.inst 0xf846cbdb // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:27 Rn:30 10:10 imm9:001101100 0:0 opc:01 111000:111000 size:11
	.inst 0xa9a8615f // stp_gen:aarch64/instrs/memory/pair/general/pre-idx Rt:31 Rn:10 Rt2:11000 imm7:1010000 L:0 1010011:1010011 opc:10
	.inst 0xb86283e7 // swp:aarch64/instrs/memory/atomicops/swp Rt:7 Rn:31 100000:100000 Rs:2 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x9bc27dbe // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:13 Ra:11111 0:0 Rm:2 10:10 U:1 10011011:10011011
	.inst 0xc87f29e4 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:4 Rn:15 Rt2:01010 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0x92653f62 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:27 imms:001111 immr:100101 N:1 100100:100100 opc:00 sf:1
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400642 // ldr c2, [x18, #1]
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2400e4a // ldr c10, [x18, #3]
	.inst 0xc240124f // ldr c15, [x18, #4]
	.inst 0xc2401658 // ldr c24, [x18, #5]
	.inst 0xc2401a5e // ldr c30, [x18, #6]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q27, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =initial_SP_EL3_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2c1d25f // cpy c31, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x0
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b2 // ldr c18, [c21, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826012b2 // ldr c18, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400255 // ldr c21, [x18, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400655 // ldr c21, [x18, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400a55 // ldr c21, [x18, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400e55 // ldr c21, [x18, #3]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401255 // ldr c21, [x18, #4]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc2401655 // ldr c21, [x18, #5]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401a55 // ldr c21, [x18, #6]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401e55 // ldr c21, [x18, #7]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2402255 // ldr c21, [x18, #8]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402655 // ldr c21, [x18, #9]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2402a55 // ldr c21, [x18, #10]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402e55 // ldr c21, [x18, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x21, v27.d[0]
	cmp x18, x21
	b.ne comparison_fail
	ldr x18, =0x0
	mov x21, v27.d[1]
	cmp x18, x21
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
	ldr x0, =0x00001a70
	ldr x1, =check_data1
	ldr x2, =0x00001a78
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001aa0
	ldr x1, =check_data2
	ldr x2, =0x00001aa8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d0a
	ldr x1, =check_data3
	ldr x2, =0x00001d0b
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ea0
	ldr x1, =check_data4
	ldr x2, =0x00001ea4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001f80
	ldr x1, =check_data5
	ldr x2, =0x00001f90
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004110f0
	ldr x1, =check_data7
	ldr x2, =0x004110f4
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
