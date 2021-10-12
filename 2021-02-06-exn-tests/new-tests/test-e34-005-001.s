.section text0, #alloc, #execinstr
test_start:
	.inst 0x9b207c32 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:18 Rn:1 Ra:31 o0:0 Rm:0 01:01 U:0 10011011:10011011
	.inst 0x383e4080 // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:4 00:00 opc:100 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x9a805120 // csel:aarch64/instrs/integer/conditional/select Rd:0 Rn:9 o2:0 0:0 cond:0101 Rm:0 011010100:011010100 op:0 sf:1
	.inst 0x71202c21 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:1 imm12:100000001011 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xdc42aaea // ldr_lit_fpsimd:aarch64/instrs/memory/literal/simdfp Rt:10 imm19:0100001010101010111 011100:011100 opc:11
	.zero 2028
	.inst 0xb82d6032 // ldumax:aarch64/instrs/memory/atomicops/ld Rt:18 Rn:1 00:00 opc:110 0:0 Rs:13 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x9a1d03fd // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:29 Rn:31 000000:000000 Rm:29 11010000:11010000 S:0 op:0 sf:1
	.inst 0xd4000001
	.zero 39924
	.inst 0x39f327b6 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:22 Rn:29 imm12:110011001001 opc:11 111001:111001 size:00
	.inst 0xc2c412a7 // LDPBR-C.C-C Ct:7 Cn:21 100:100 opc:00 11000010110001000:11000010110001000
	.zero 23544
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
	ldr x11, =initial_cap_values
	.inst 0xc2400161 // ldr c1, [x11, #0]
	.inst 0xc2400564 // ldr c4, [x11, #1]
	.inst 0xc240096d // ldr c13, [x11, #2]
	.inst 0xc2400d75 // ldr c21, [x11, #3]
	.inst 0xc240117d // ldr c29, [x11, #4]
	.inst 0xc240157e // ldr c30, [x11, #5]
	/* Set up flags and system registers */
	ldr x11, =0x0
	msr SPSR_EL3, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0xc0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011cb // ldr c11, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x14, #0xf
	and x11, x11, x14
	cmp x11, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016e // ldr c14, [x11, #0]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc240056e // ldr c14, [x11, #1]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc240096e // ldr c14, [x11, #2]
	.inst 0xc2cea4e1 // chkeq c7, c14
	b.ne comparison_fail
	.inst 0xc2400d6e // ldr c14, [x11, #3]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc240116e // ldr c14, [x11, #4]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc240156e // ldr c14, [x11, #5]
	.inst 0xc2cea6a1 // chkeq c21, c14
	b.ne comparison_fail
	.inst 0xc240196e // ldr c14, [x11, #6]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2401d6e // ldr c14, [x11, #7]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc240216e // ldr c14, [x11, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	ldr x14, =0x2000000
	cmp x14, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001005
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f00
	ldr x1, =check_data2
	ldr x2, =0x00001f01
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
	ldr x0, =0x40400800
	ldr x1, =check_data4
	ldr x2, =0x4040080c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040a400
	ldr x1, =check_data5
	ldr x2, =0x4040a408
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 256
	.byte 0x00, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3808
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x08, 0x00
.data
check_data1:
	.zero 16
	.byte 0x00, 0x08, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0x32, 0x7c, 0x20, 0x9b, 0x80, 0x40, 0x3e, 0x38, 0x20, 0x51, 0x80, 0x9a, 0x21, 0x2c, 0x20, 0x71
	.byte 0xea, 0xaa, 0x42, 0xdc
.data
check_data4:
	.byte 0x32, 0x60, 0x2d, 0xb8, 0xfd, 0x03, 0x1d, 0x9a, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.byte 0xb6, 0x27, 0xf3, 0x39, 0xa7, 0x12, 0xc4, 0xc2

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x180b
	/* C4 */
	.octa 0x0
	/* C13 */
	.octa 0x8000000
	/* C21 */
	.octa 0x9010000000470e970000000000001100
	/* C29 */
	.octa 0x1237
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x1000
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x8000000
	/* C18 */
	.octa 0x1
	/* C21 */
	.octa 0x9010000000470e970000000000001100
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x1238
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000540110040000000000000000
initial_DDC_EL1_value:
	.octa 0xc00000000007000700ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x2000800068008c0a000000004040a000
final_PCC_value:
	.octa 0x2000800000008008000000004040080c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000418900000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword 0x0000000000001110
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001100
	.dword 0x0000000000001110
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x82600dcb // ldr x11, [c14, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400dcb // str x11, [c14, #0]
	ldr x11, =0x4040080c
	mrs x14, ELR_EL1
	sub x11, x11, x14
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b16e // cvtp c14, x11
	.inst 0xc2cb41ce // scvalue c14, c14, x11
	.inst 0x826001cb // ldr c11, [c14, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
