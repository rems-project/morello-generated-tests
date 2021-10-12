.section text0, #alloc, #execinstr
test_start:
	.inst 0x9a090380 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:0 Rn:28 000000:000000 Rm:9 11010000:11010000 S:0 op:0 sf:1
	.inst 0x489ffd0c // stlrh:aarch64/instrs/memory/ordered Rt:12 Rn:8 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c667a1 // CPYVALUE-C.C-C Cd:1 Cn:29 001:001 opc:11 0:0 Cm:6 11000010110:11000010110
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x829dc2e0 // ASTRB-R.RRB-B Rt:0 Rn:23 opc:00 S:0 option:110 Rm:29 0:0 L:0 100000101:100000101
	.zero 1004
	.inst 0x387d53ff // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xda81a5fd // csneg:aarch64/instrs/integer/conditional/select Rd:29 Rn:15 o2:1 0:0 cond:1010 Rm:1 011010100:011010100 op:1 sf:1
	.inst 0x22d5e3fd // LDP-CC.RIAW-C Ct:29 Rn:31 Ct2:11000 imm7:0101011 L:1 001000101:001000101
	.inst 0x386012ff // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:001 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:00
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
	ldr x10, =initial_cap_values
	.inst 0xc2400146 // ldr c6, [x10, #0]
	.inst 0xc2400548 // ldr c8, [x10, #1]
	.inst 0xc2400949 // ldr c9, [x10, #2]
	.inst 0xc2400d4c // ldr c12, [x10, #3]
	.inst 0xc2401157 // ldr c23, [x10, #4]
	.inst 0xc240155c // ldr c28, [x10, #5]
	.inst 0xc240195d // ldr c29, [x10, #6]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
	ldr x10, =initial_SP_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c410a // msr CSP_EL1, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =initial_DDC_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c412a // msr DDC_EL1, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132a // ldr c10, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* Check processor flags */
	mrs x10, nzcv
	ubfx x10, x10, #28, #4
	mov x25, #0xf
	and x10, x10, x25
	cmp x10, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400159 // ldr c25, [x10, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc2400559 // ldr c25, [x10, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400959 // ldr c25, [x10, #2]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc2400d59 // ldr c25, [x10, #3]
	.inst 0xc2d9a501 // chkeq c8, c25
	b.ne comparison_fail
	.inst 0xc2401159 // ldr c25, [x10, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc2401559 // ldr c25, [x10, #5]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401959 // ldr c25, [x10, #6]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc2401d59 // ldr c25, [x10, #7]
	.inst 0xc2d9a701 // chkeq c24, c25
	b.ne comparison_fail
	.inst 0xc2402159 // ldr c25, [x10, #8]
	.inst 0xc2d9a781 // chkeq c28, c25
	b.ne comparison_fail
	.inst 0xc2402559 // ldr c25, [x10, #9]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	ldr x10, =final_SP_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc29c4119 // mrs c25, CSP_EL1
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a541 // chkeq c10, c25
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x25, 0x80
	orr x10, x10, x25
	ldr x25, =0x920000e9
	cmp x25, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001e70
	ldr x1, =check_data0
	ldr x2, =0x00001e90
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001efc
	ldr x1, =check_data1
	ldr x2, =0x00001efe
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 3696
	.byte 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 368
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x00
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 16
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xff
.data
check_data3:
	.byte 0x80, 0x03, 0x09, 0x9a, 0x0c, 0xfd, 0x9f, 0x48, 0xa1, 0x67, 0xc6, 0xc2, 0xe1, 0x13, 0xc2, 0xc2
	.byte 0xe0, 0xc2, 0x9d, 0x82
.data
check_data4:
	.byte 0xff, 0x53, 0x7d, 0x38, 0xfd, 0xa5, 0x81, 0xda, 0xfd, 0xe3, 0xd5, 0x22, 0xff, 0x12, 0x60, 0x38
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x80000000000000
	/* C8 */
	.octa 0x1efc
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C23 */
	.octa 0x800000000000000000001ffe
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x4001400100a0051880010001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400140010080000000000000
	/* C6 */
	.octa 0x80000000000000
	/* C8 */
	.octa 0x1efc
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C23 */
	.octa 0x800000000000000000001ffe
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x1
initial_SP_EL0_value:
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x1e70
initial_DDC_EL0_value:
	.octa 0x40000000000100050000000000000001
initial_DDC_EL1_value:
	.octa 0xd0100000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800001d0000000040400000
final_SP_EL0_value:
	.octa 0x0
final_SP_EL1_value:
	.octa 0x2120
final_PCC_value:
	.octa 0x200080004800001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001e70
	.dword 0x0000000000001e80
	.dword 0x0000000000001ef0
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x82600f2a // ldr x10, [c25, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400f2a // str x10, [c25, #0]
	ldr x10, =0x40400414
	mrs x25, ELR_EL1
	sub x10, x10, x25
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b159 // cvtp c25, x10
	.inst 0xc2ca4339 // scvalue c25, c25, x10
	.inst 0x8260032a // ldr c10, [c25, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
