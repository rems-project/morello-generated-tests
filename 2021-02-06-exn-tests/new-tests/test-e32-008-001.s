.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2fad0a0 // ASTUR-V.RI-D Rt:0 Rn:5 op2:00 imm9:110101101 V:1 op1:11 11100010:11100010
	.inst 0xc2c0280f // BICFLGS-C.CR-C Cd:15 Cn:0 1010:1010 opc:00 Rm:0 11000010110:11000010110
	.inst 0x9ba087c0 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:0 Rn:30 Ra:1 o0:1 Rm:0 01:01 U:1 10011011:10011011
	.inst 0x79f66840 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:2 imm12:110110011010 opc:11 111001:111001 size:01
	.inst 0xd4adb042 // dcps2:aarch64/instrs/system/exceptions/debug/exception LL:10 000:000 imm16:0110110110000010 11010100101:11010100101
	.zero 1004
	.inst 0xc2c053f3 // GCVALUE-R.C-C Rd:19 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xe29ac09e // ASTUR-R.RI-32 Rt:30 Rn:4 op2:00 imm9:110101100 V:0 op1:10 11100010:11100010
	.inst 0xa25603c0 // LDUR-C.RI-C Ct:0 Rn:30 00:00 imm9:101100000 0:0 opc:01 10100010:10100010
	.inst 0x78fedb96 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:22 Rn:28 10:10 S:1 option:110 Rm:30 1:1 opc:11 111000:111000 size:01
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2400dc5 // ldr c5, [x14, #3]
	.inst 0xc24011dc // ldr c28, [x14, #4]
	.inst 0xc24015de // ldr c30, [x14, #5]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q0, =0x40000000
	/* Set up flags and system registers */
	ldr x14, =0x4000000
	msr SPSR_EL3, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x4
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =initial_DDC_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c412e // msr DDC_EL1, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x18, =pcc_return_ddc_capabilities
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0x8260124e // ldr c14, [c18, #1]
	.inst 0x82602252 // ldr c18, [c18, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d2 // ldr c18, [x14, #0]
	.inst 0xc2d2a401 // chkeq c0, c18
	b.ne comparison_fail
	.inst 0xc24005d2 // ldr c18, [x14, #1]
	.inst 0xc2d2a441 // chkeq c2, c18
	b.ne comparison_fail
	.inst 0xc24009d2 // ldr c18, [x14, #2]
	.inst 0xc2d2a481 // chkeq c4, c18
	b.ne comparison_fail
	.inst 0xc2400dd2 // ldr c18, [x14, #3]
	.inst 0xc2d2a4a1 // chkeq c5, c18
	b.ne comparison_fail
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc2d2a5e1 // chkeq c15, c18
	b.ne comparison_fail
	.inst 0xc24015d2 // ldr c18, [x14, #5]
	.inst 0xc2d2a6c1 // chkeq c22, c18
	b.ne comparison_fail
	.inst 0xc24019d2 // ldr c18, [x14, #6]
	.inst 0xc2d2a781 // chkeq c28, c18
	b.ne comparison_fail
	.inst 0xc2401dd2 // ldr c18, [x14, #7]
	.inst 0xc2d2a7c1 // chkeq c30, c18
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x40000000
	mov x18, v0.d[0]
	cmp x14, x18
	b.ne comparison_fail
	ldr x14, =0x0
	mov x18, v0.d[1]
	cmp x14, x18
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984032 // mrs c18, CELR_EL1
	.inst 0xc2d2a5c1 // chkeq c14, c18
	b.ne comparison_fail
	ldr x14, =esr_el1_dump_address
	ldr x14, [x14]
	ldr x18, =0x2000000
	cmp x18, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001f60
	ldr x1, =check_data0
	ldr x2, =0x00001f70
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fb0
	ldr x1, =check_data1
	ldr x2, =0x00001fb4
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fc8
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
	ldr x0, =0x404043fe
	ldr x1, =check_data5
	ldr x2, =0x40404400
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40409000
	ldr x1, =check_data6
	ldr x2, =0x40409002
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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

.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x00, 0x20, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0xa0, 0xd0, 0xfa, 0xe2, 0x0f, 0x28, 0xc0, 0xc2, 0xc0, 0x87, 0xa0, 0x9b, 0x40, 0x68, 0xf6, 0x79
	.byte 0x42, 0xb0, 0xad, 0xd4
.data
check_data4:
	.byte 0xf3, 0x53, 0xc0, 0xc2, 0x9e, 0xc0, 0x9a, 0xe2, 0xc0, 0x03, 0x56, 0xa2, 0x96, 0xdb, 0xfe, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 2
.data
check_data6:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C2 */
	.octa 0x800000004000800100000000404074cc
	/* C4 */
	.octa 0x2004
	/* C5 */
	.octa 0x2013
	/* C28 */
	.octa 0x800000000003000600000000404003fe
	/* C30 */
	.octa 0x80100000000700060000000000002000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x800000004000800100000000404074cc
	/* C4 */
	.octa 0x2004
	/* C5 */
	.octa 0x2013
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C28 */
	.octa 0x800000000003000600000000404003fe
	/* C30 */
	.octa 0x80100000000700060000000000002000
initial_DDC_EL0_value:
	.octa 0x400000002a010007002200219000e000
initial_DDC_EL1_value:
	.octa 0x40000000008001000000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800d01d0000000040400001
final_PCC_value:
	.octa 0x200080004800d01d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000e2540070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001f60
	.dword 0x0000000000001fb0
	.dword 0x0000000000001fc0
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x82600e4e // ldr x14, [c18, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400e4e // str x14, [c18, #0]
	ldr x14, =0x40400414
	mrs x18, ELR_EL1
	sub x14, x14, x18
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d2 // cvtp c18, x14
	.inst 0xc2ce4252 // scvalue c18, c18, x14
	.inst 0x8260024e // ldr c14, [c18, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
