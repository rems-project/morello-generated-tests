.section text0, #alloc, #execinstr
test_start:
	.inst 0x926a8420 // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:0 Rn:1 imms:100001 immr:101010 N:1 100100:100100 opc:00 sf:1
	.inst 0x694fe3e0 // ldpsw:aarch64/instrs/memory/pair/general/offset Rt:0 Rn:31 Rt2:11000 imm7:0011111 L:1 1010010:1010010 opc:01
	.inst 0x826ca00c // ALDR-C.RI-C Ct:12 Rn:0 op:00 imm9:011001010 L:1 1000001001:1000001001
	.inst 0x8299e21e // ASTRB-R.RRB-B Rt:30 Rn:16 opc:00 S:0 option:111 Rm:25 0:0 L:0 100000101:100000101
	.inst 0x88007fbf // stxr:aarch64/instrs/memory/exclusive/single Rt:31 Rn:29 Rt2:11111 o0:0 Rs:0 0:0 L:0 0010000:0010000 size:10
	.zero 1004
	.inst 0x9b3dfbcf // smsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:15 Rn:30 Ra:30 o0:1 Rm:29 01:01 U:0 10011011:10011011
	.inst 0x08dffc41 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:2 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x82c1709e // ALDRB-R.RRB-B Rt:30 Rn:4 opc:00 S:1 option:011 Rm:1 0:0 L:1 100000101:100000101
	.inst 0x2c925a3d // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:29 Rn:17 Rt2:10110 imm7:0100100 L:0 1011001:1011001 opc:00
	.inst 0xd4000001
	.zero 64488
	.inst 0x00ff0000
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e2 // ldr c2, [x23, #0]
	.inst 0xc24006e4 // ldr c4, [x23, #1]
	.inst 0xc2400af0 // ldr c16, [x23, #2]
	.inst 0xc2400ef1 // ldr c17, [x23, #3]
	.inst 0xc24012f9 // ldr c25, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	.inst 0xc2401afe // ldr c30, [x23, #6]
	/* Vector registers */
	mrs x23, cptr_el3
	bfc x23, #10, #1
	msr cptr_el3, x23
	isb
	ldr q22, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =initial_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884117 // msr CSP_EL0, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0x3c0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x4
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =initial_DDC_EL1_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc28c4137 // msr DDC_EL1, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x82601277 // ldr c23, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
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
	.inst 0xc24002f3 // ldr c19, [x23, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24006f3 // ldr c19, [x23, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400af3 // ldr c19, [x23, #2]
	.inst 0xc2d3a441 // chkeq c2, c19
	b.ne comparison_fail
	.inst 0xc2400ef3 // ldr c19, [x23, #3]
	.inst 0xc2d3a481 // chkeq c4, c19
	b.ne comparison_fail
	.inst 0xc24012f3 // ldr c19, [x23, #4]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc24016f3 // ldr c19, [x23, #5]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2401af3 // ldr c19, [x23, #6]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2401ef3 // ldr c19, [x23, #7]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc24022f3 // ldr c19, [x23, #8]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc24026f3 // ldr c19, [x23, #9]
	.inst 0xc2d3a721 // chkeq c25, c19
	b.ne comparison_fail
	.inst 0xc2402af3 // ldr c19, [x23, #10]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2402ef3 // ldr c19, [x23, #11]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x19, v22.d[0]
	cmp x23, x19
	b.ne comparison_fail
	ldr x23, =0x0
	mov x19, v22.d[1]
	cmp x23, x19
	b.ne comparison_fail
	ldr x23, =0x0
	mov x19, v29.d[0]
	cmp x23, x19
	b.ne comparison_fail
	ldr x23, =0x0
	mov x19, v29.d[1]
	cmp x23, x19
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984113 // mrs c19, CSP_EL0
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a6e1 // chkeq c23, c19
	b.ne comparison_fail
	ldr x23, =esr_el1_dump_address
	ldr x23, [x23]
	mov x19, 0x80
	orr x23, x23, x19
	ldr x19, =0x920000ea
	cmp x19, x23
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
	ldr x0, =0x0000103c
	ldr x1, =check_data1
	ldr x2, =0x00001044
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fe
	ldr x1, =check_data2
	ldr x2, =0x000017ff
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001de0
	ldr x1, =check_data3
	ldr x2, =0x00001df0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040fffe
	ldr x1, =check_data7
	ldr x2, =0x4040ffff
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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

.section data0, #alloc, #write
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.zero 8
.data
check_data1:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x20, 0x84, 0x6a, 0x92, 0xe0, 0xe3, 0x4f, 0x69, 0x0c, 0xa0, 0x6c, 0x82, 0x1e, 0xe2, 0x99, 0x82
	.byte 0xbf, 0x7f, 0x00, 0x88
.data
check_data6:
	.byte 0xcf, 0xfb, 0x3d, 0x9b, 0x41, 0xfc, 0xdf, 0x08, 0x9e, 0x70, 0xc1, 0x82, 0x3d, 0x5a, 0x92, 0x2c
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.byte 0xff

.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4040fffe
	/* C4 */
	.octa 0x800000000001000500000000000016ff
	/* C16 */
	.octa 0xfff
	/* C17 */
	.octa 0x1000
	/* C25 */
	.octa 0xebf
	/* C29 */
	.octa 0x400000007ff03fe1f5041007fffffffd
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0xff
	/* C2 */
	.octa 0x4040fffe
	/* C4 */
	.octa 0x800000000001000500000000000016ff
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0xfff
	/* C17 */
	.octa 0x1090
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0xebf
	/* C29 */
	.octa 0x400000007ff03fe1f5041007fffffffd
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x80000000000300070000000000000fc0
initial_DDC_EL0_value:
	.octa 0xc0000000400101400000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004414001d0000000040400000
final_SP_EL0_value:
	.octa 0x80000000000300070000000000000fc0
final_PCC_value:
	.octa 0x200080004414001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001de0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001de0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001ff0
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600e77 // ldr x23, [c19, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400e77 // str x23, [c19, #0]
	ldr x23, =0x40400414
	mrs x19, ELR_EL1
	sub x23, x23, x19
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f3 // cvtp c19, x23
	.inst 0xc2d74273 // scvalue c19, c19, x23
	.inst 0x82600277 // ldr c23, [c19, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
