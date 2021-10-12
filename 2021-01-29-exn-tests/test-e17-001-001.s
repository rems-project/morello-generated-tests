.section text0, #alloc, #execinstr
test_start:
	.inst 0x08df7fd4 // ldlarb:aarch64/instrs/memory/ordered Rt:20 Rn:30 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xb87b835a // swp:aarch64/instrs/memory/atomicops/swp Rt:26 Rn:26 100000:100000 Rs:27 1:1 R:1 A:0 111000:111000 size:10
	.inst 0x826e50b4 // ALDR-C.RI-C Ct:20 Rn:5 op:00 imm9:011100101 L:1 1000001001:1000001001
	.inst 0x7818c3df // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:30 00:00 imm9:110001100 0:0 opc:00 111000:111000 size:01
	.inst 0x423f7fac // ASTLRB-R.R-B Rt:12 Rn:29 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 1:1 L:0 010000100:010000100
	.zero 1004
	.inst 0xf82010df // stclr:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x5a9fc57d // csneg:aarch64/instrs/integer/conditional/select Rd:29 Rn:11 o2:1 0:0 cond:1100 Rm:31 011010100:011010100 op:1 sf:0
	.inst 0xc2e89b1f // SUBS-R.CC-C Rd:31 Cn:24 100110:100110 Cm:8 11000010111:11000010111
	.inst 0x38530c5f // ldrb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:2 11:11 imm9:100110000 0:0 opc:01 111000:111000 size:00
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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400522 // ldr c2, [x9, #1]
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2400d26 // ldr c6, [x9, #3]
	.inst 0xc2401128 // ldr c8, [x9, #4]
	.inst 0xc2401538 // ldr c24, [x9, #5]
	.inst 0xc240193a // ldr c26, [x9, #6]
	.inst 0xc2401d3b // ldr c27, [x9, #7]
	.inst 0xc240213d // ldr c29, [x9, #8]
	.inst 0xc240253e // ldr c30, [x9, #9]
	/* Set up flags and system registers */
	ldr x9, =0x40000000
	msr SPSR_EL3, x9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x0
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x0
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884129 // msr DDC_EL0, c9
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x82601089 // ldr c9, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x4, #0xf
	and x9, x9, x4
	cmp x9, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400124 // ldr c4, [x9, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc2400524 // ldr c4, [x9, #1]
	.inst 0xc2c4a441 // chkeq c2, c4
	b.ne comparison_fail
	.inst 0xc2400924 // ldr c4, [x9, #2]
	.inst 0xc2c4a4a1 // chkeq c5, c4
	b.ne comparison_fail
	.inst 0xc2400d24 // ldr c4, [x9, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc2401124 // ldr c4, [x9, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc2401524 // ldr c4, [x9, #5]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2401924 // ldr c4, [x9, #6]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc2401d24 // ldr c4, [x9, #7]
	.inst 0xc2c4a741 // chkeq c26, c4
	b.ne comparison_fail
	.inst 0xc2402124 // ldr c4, [x9, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc2402524 // ldr c4, [x9, #9]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc2402924 // ldr c4, [x9, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a521 // chkeq c9, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x9, 0x83
	orr x4, x4, x9
	ldr x9, =0x920000eb
	cmp x9, x4
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
	ldr x0, =0x00001680
	ldr x1, =check_data1
	ldr x2, =0x00001684
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000180c
	ldr x1, =check_data2
	ldr x2, =0x0000180e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001880
	ldr x1, =check_data3
	ldr x2, =0x00001881
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400014
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408ef0
	ldr x1, =check_data6
	ldr x2, =0x40408f00
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
	/* Done print message */
	/* turn off MMU */
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x00, 0x00, 0x02, 0x02, 0xff, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x02, 0x02, 0xff, 0x00, 0x00, 0xff
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xd4, 0x7f, 0xdf, 0x08, 0x5a, 0x83, 0x7b, 0xb8, 0xb4, 0x50, 0x6e, 0x82, 0xdf, 0xc3, 0x18, 0x78
	.byte 0xac, 0x7f, 0x3f, 0x42
.data
check_data5:
	.byte 0xdf, 0x10, 0x20, 0xf8, 0x7d, 0xc5, 0x9f, 0x5a, 0x1f, 0x9b, 0xe8, 0xc2, 0x5f, 0x0c, 0x53, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 16
.data
check_data7:
	.zero 1

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x404100ce
	/* C5 */
	.octa 0x801000003a89000600000000404080a0
	/* C6 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x1680
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x80000000000000
	/* C30 */
	.octa 0x1880
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C2 */
	.octa 0x4040fffe
	/* C5 */
	.octa 0x801000003a89000600000000404080a0
	/* C6 */
	.octa 0x1000
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1880
initial_DDC_EL0_value:
	.octa 0xc0000000000180050000000000000001
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004420c81d0000000040400000
final_PCC_value:
	.octa 0x200080004420c81d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600c89 // ldr x9, [c4, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400c89 // str x9, [c4, #0]
	ldr x9, =0x40400414
	mrs x4, ELR_EL1
	sub x9, x9, x4
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b124 // cvtp c4, x9
	.inst 0xc2c94084 // scvalue c4, c4, x9
	.inst 0x82600089 // ldr c9, [c4, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
