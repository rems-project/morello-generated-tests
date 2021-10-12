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
	ldr x8, =initial_cap_values
	.inst 0xc2400102 // ldr c2, [x8, #0]
	.inst 0xc2400504 // ldr c4, [x8, #1]
	.inst 0xc2400910 // ldr c16, [x8, #2]
	.inst 0xc2400d11 // ldr c17, [x8, #3]
	.inst 0xc2401119 // ldr c25, [x8, #4]
	.inst 0xc240151d // ldr c29, [x8, #5]
	.inst 0xc240191e // ldr c30, [x8, #6]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q22, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =initial_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884108 // msr CSP_EL0, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0x1c0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x4
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =initial_DDC_EL1_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc28c4128 // msr DDC_EL1, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601368 // ldr c8, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc240011b // ldr c27, [x8, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240051b // ldr c27, [x8, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240091b // ldr c27, [x8, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400d1b // ldr c27, [x8, #3]
	.inst 0xc2dba481 // chkeq c4, c27
	b.ne comparison_fail
	.inst 0xc240111b // ldr c27, [x8, #4]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc240151b // ldr c27, [x8, #5]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc240191b // ldr c27, [x8, #6]
	.inst 0xc2dba601 // chkeq c16, c27
	b.ne comparison_fail
	.inst 0xc2401d1b // ldr c27, [x8, #7]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc240211b // ldr c27, [x8, #8]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240251b // ldr c27, [x8, #9]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc240291b // ldr c27, [x8, #10]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2402d1b // ldr c27, [x8, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x27, v22.d[0]
	cmp x8, x27
	b.ne comparison_fail
	ldr x8, =0x0
	mov x27, v22.d[1]
	cmp x8, x27
	b.ne comparison_fail
	ldr x8, =0x0
	mov x27, v29.d[0]
	cmp x8, x27
	b.ne comparison_fail
	ldr x8, =0x0
	mov x27, v29.d[1]
	cmp x8, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298411b // mrs c27, CSP_EL0
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x27, 0x80
	orr x8, x8, x27
	ldr x27, =0x920000e1
	cmp x27, x8
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
	ldr x0, =0x00001042
	ldr x1, =check_data1
	ldr x2, =0x00001043
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001060
	ldr x1, =check_data2
	ldr x2, =0x00001061
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0000108c
	ldr x1, =check_data3
	ldr x2, =0x00001094
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001210
	ldr x1, =check_data4
	ldr x2, =0x00001211
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001fe0
	ldr x1, =check_data5
	ldr x2, =0x00001ff0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 96
	.byte 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x13, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x0f
.data
check_data3:
	.byte 0x40, 0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 16
.data
check_data6:
	.byte 0x20, 0x84, 0x6a, 0x92, 0xe0, 0xe3, 0x4f, 0x69, 0x0c, 0xa0, 0x6c, 0x82, 0x1e, 0xe2, 0x99, 0x82
	.byte 0xbf, 0x7f, 0x00, 0x88
.data
check_data7:
	.byte 0xcf, 0xfb, 0x3d, 0x9b, 0x41, 0xfc, 0xdf, 0x08, 0x9e, 0x70, 0xc1, 0x82, 0x3d, 0x5a, 0x92, 0x2c
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1060
	/* C4 */
	.octa 0x800000006004080a0000000000001201
	/* C16 */
	.octa 0xb34
	/* C17 */
	.octa 0x1000
	/* C25 */
	.octa 0x50e
	/* C29 */
	.octa 0x40000000408180020000000000008002
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1340
	/* C1 */
	.octa 0xf
	/* C2 */
	.octa 0x1060
	/* C4 */
	.octa 0x800000006004080a0000000000001201
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C16 */
	.octa 0xb34
	/* C17 */
	.octa 0x1090
	/* C24 */
	.octa 0x0
	/* C25 */
	.octa 0x50e
	/* C29 */
	.octa 0x40000000408180020000000000008002
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x80000000000080080000000000001010
initial_DDC_EL0_value:
	.octa 0xc0000000001900070080000000000001
initial_DDC_EL1_value:
	.octa 0xc00000000007000b0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004414001d0000000040400000
final_SP_EL0_value:
	.octa 0x80000000000080080000000000001010
final_PCC_value:
	.octa 0x200080004414001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000080788430000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
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
	.dword 0x0000000000001fe0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001040
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600f68 // ldr x8, [c27, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f68 // str x8, [c27, #0]
	ldr x8, =0x40400414
	mrs x27, ELR_EL1
	sub x8, x8, x27
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b11b // cvtp c27, x8
	.inst 0xc2c8437b // scvalue c27, c27, x8
	.inst 0x82600368 // ldr c8, [c27, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
