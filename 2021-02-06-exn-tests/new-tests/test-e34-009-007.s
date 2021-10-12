.section text0, #alloc, #execinstr
test_start:
	.inst 0x385e8408 // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:8 Rn:0 01:01 imm9:111101000 0:0 opc:01 111000:111000 size:00
	.inst 0x429c840a // STP-C.RIB-C Ct:10 Rn:0 Ct2:00001 imm7:0111001 L:0 010000101:010000101
	.inst 0x88df7ffd // ldlar:aarch64/instrs/memory/ordered Rt:29 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:10
	.inst 0xf2417fbf // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:31 Rn:29 imms:011111 immr:000001 N:1 100100:100100 opc:11 sf:1
	.inst 0x3d4a988d // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:13 Rn:4 imm12:001010100110 opc:01 111101:111101 size:00
	.zero 1004
	.inst 0xba5e134e // ccmn_reg:aarch64/instrs/integer/conditional/compare/register nzcv:1110 0:0 Rn:26 00:00 cond:0001 Rm:30 111010010:111010010 op:0 sf:1
	.inst 0x0807ffc2 // stlxrb:aarch64/instrs/memory/exclusive/single Rt:2 Rn:30 Rt2:11111 o0:1 Rs:7 0:0 L:0 0010000:0010000 size:00
	.inst 0x9b2f825f // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:18 Ra:0 o0:1 Rm:15 01:01 U:0 10011011:10011011
	.inst 0x386c53ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:12 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xd4000001
	.zero 64492
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
	ldr x0, =vector_table_el1
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc288c001 // msr CVBAR_EL1, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	msr ttbr0_el1, x0
	mov x0, #0xff
	msr mair_el3, x0
	msr mair_el1, x0
	ldr x0, =0x0d003519
	msr tcr_el3, x0
	ldr x0, =0x0000320000803519 // No cap effects, inner shareable, normal, outer write-back read-allocate write-allocate cacheable
	msr tcr_el1, x0
	isb
	tlbi alle3
	tlbi alle1
	dsb sy
	ldr x0, =0x30851035
	msr sctlr_el3, x0
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
	ldr x3, =initial_cap_values
	.inst 0xc2400060 // ldr c0, [x3, #0]
	.inst 0xc2400461 // ldr c1, [x3, #1]
	.inst 0xc2400864 // ldr c4, [x3, #2]
	.inst 0xc2400c6a // ldr c10, [x3, #3]
	.inst 0xc240106c // ldr c12, [x3, #4]
	.inst 0xc240147e // ldr c30, [x3, #5]
	/* Set up flags and system registers */
	ldr x3, =0x4000000
	msr SPSR_EL3, x3
	ldr x3, =initial_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc2884103 // msr CSP_EL0, c3
	ldr x3, =initial_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc28c4103 // msr CSP_EL1, c3
	ldr x3, =0x200
	msr CPTR_EL3, x3
	ldr x3, =0x30d5d99f
	msr SCTLR_EL1, x3
	ldr x3, =0x3c0000
	msr CPACR_EL1, x3
	ldr x3, =0x0
	msr S3_0_C1_C2_2, x3 // CCTLR_EL1
	ldr x3, =0x80000000
	msr HCR_EL2, x3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826011a3 // ldr c3, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc28e4023 // msr CELR_EL3, c3
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30851035
	msr SCTLR_EL3, x3
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x3, =final_cap_values
	.inst 0xc240006d // ldr c13, [x3, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240046d // ldr c13, [x3, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240086d // ldr c13, [x3, #2]
	.inst 0xc2cda481 // chkeq c4, c13
	b.ne comparison_fail
	.inst 0xc2400c6d // ldr c13, [x3, #3]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc240106d // ldr c13, [x3, #4]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240146d // ldr c13, [x3, #5]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240186d // ldr c13, [x3, #6]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc2401c6d // ldr c13, [x3, #7]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc240206d // ldr c13, [x3, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check system registers */
	ldr x3, =final_SP_EL0_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298410d // mrs c13, CSP_EL0
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	ldr x3, =final_SP_EL1_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc29c410d // mrs c13, CSP_EL1
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	ldr x3, =final_PCC_value
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0xc298402d // mrs c13, CELR_EL1
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x13, 0x80
	orr x3, x3, x13
	ldr x13, =0x920000ab
	cmp x13, x3
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
	ldr x0, =0x00001548
	ldr x1, =check_data1
	ldr x2, =0x00001549
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000018c0
	ldr x1, =check_data2
	ldr x2, =0x000018e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400014
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
	/* Done print message */
	/* turn off MMU */
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b003 // cvtp c3, x0
	.inst 0xc2df4063 // scvalue c3, c3, x31
	.inst 0xc28b4123 // msr DDC_EL3, c3
	ldr x3, =0x30850030
	msr SCTLR_EL3, x3
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x08, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x08, 0x84, 0x5e, 0x38, 0x0a, 0x84, 0x9c, 0x42, 0xfd, 0x7f, 0xdf, 0x88, 0xbf, 0x7f, 0x41, 0xf2
	.byte 0x8d, 0x98, 0x4a, 0x3d
.data
check_data4:
	.byte 0x4e, 0x13, 0x5e, 0xba, 0xc2, 0xff, 0x07, 0x08, 0x5f, 0x82, 0x2f, 0x9b, 0xff, 0x53, 0x6c, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc8000000000700070000000000001548
	/* C1 */
	.octa 0x20800
	/* C4 */
	.octa 0x106
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x0
	/* C30 */
	.octa 0x40000000600004000000000000001000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc8000000000700070000000000001530
	/* C1 */
	.octa 0x20800
	/* C4 */
	.octa 0x106
	/* C7 */
	.octa 0x1
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x0
	/* C29 */
	.octa 0x20800
	/* C30 */
	.octa 0x40000000600004000000000000001000
initial_SP_EL0_value:
	.octa 0x800000004000000400000000000018d0
initial_SP_EL1_value:
	.octa 0xc0000000510001020000000000001000
initial_VBAR_EL1_value:
	.octa 0x20008000400200190000000040400001
final_SP_EL0_value:
	.octa 0x800000004000000400000000000018d0
final_SP_EL1_value:
	.octa 0xc0000000510001020000000000001000
final_PCC_value:
	.octa 0x20008000400200190000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000398000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword initial_SP_EL0_value
	.dword initial_SP_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_SP_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000018c0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000018d0
	.dword 0
esr_el1_dump_address:
	.dword 0

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
	b finish
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

.section vector_table_el1, #alloc, #execinstr
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02000063 // add c3, c3, #0
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02020063 // add c3, c3, #128
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02040063 // add c3, c3, #256
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02060063 // add c3, c3, #384
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02080063 // add c3, c3, #512
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x020a0063 // add c3, c3, #640
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x020c0063 // add c3, c3, #768
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x020e0063 // add c3, c3, #896
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02100063 // add c3, c3, #1024
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02120063 // add c3, c3, #1152
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02140063 // add c3, c3, #1280
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02160063 // add c3, c3, #1408
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x02180063 // add c3, c3, #1536
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x021a0063 // add c3, c3, #1664
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x021c0063 // add c3, c3, #1792
	.inst 0xc2c21060 // br c3
	.balign 128
	ldr x3, =esr_el1_dump_address
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x82600da3 // ldr x3, [c13, #0]
	cbnz x3, #28
	mrs x3, ESR_EL1
	.inst 0x82400da3 // str x3, [c13, #0]
	ldr x3, =0x40400414
	mrs x13, ELR_EL1
	sub x3, x3, x13
	cbnz x3, #8
	smc 0
	ldr x3, =initial_VBAR_EL1_value
	.inst 0xc2c5b06d // cvtp c13, x3
	.inst 0xc2c341ad // scvalue c13, c13, x3
	.inst 0x826001a3 // ldr c3, [c13, #0]
	.inst 0x021e0063 // add c3, c3, #1920
	.inst 0xc2c21060 // br c3

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
