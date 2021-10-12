.section text0, #alloc, #execinstr
test_start:
	.inst 0xe296a67e // ALDUR-R.RI-32 Rt:30 Rn:19 op2:01 imm9:101101010 V:0 op1:10 11100010:11100010
	.inst 0x78bfc152 // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:18 Rn:10 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x489ffc3f // stlrh:aarch64/instrs/memory/ordered Rt:31 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x7c464009 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:9 Rn:0 00:00 imm9:001100100 0:0 opc:01 111100:111100 size:01
	.inst 0x7a568bc6 // ccmp_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0110 0:0 Rn:30 10:10 cond:1000 imm5:10110 111010010:111010010 op:1 sf:0
	.inst 0xb8ab7101 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:8 00:00 opc:111 0:0 Rs:11 1:1 R:0 A:1 111000:111000 size:10
	.inst 0xc2c25282 // RETS-C-C 00010:00010 Cn:20 100:100 opc:10 11000010110000100:11000010110000100
	.zero 49124
	.inst 0xc2c51029 // CVTD-R.C-C Rd:9 Cn:1 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x386e50bf // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:101 o3:0 Rs:14 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xd4000001
	.zero 16372
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b85 // ldr c5, [x28, #2]
	.inst 0xc2400f88 // ldr c8, [x28, #3]
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc240178b // ldr c11, [x28, #5]
	.inst 0xc2401b8e // ldr c14, [x28, #6]
	.inst 0xc2401f93 // ldr c19, [x28, #7]
	.inst 0xc2402394 // ldr c20, [x28, #8]
	/* Set up flags and system registers */
	ldr x28, =0x4000000
	msr SPSR_EL3, x28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0x3c0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x0
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260137c // ldr c28, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x27, #0xf
	and x28, x28, x27
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240039b // ldr c27, [x28, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240079b // ldr c27, [x28, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b9b // ldr c27, [x28, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400f9b // ldr c27, [x28, #3]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240139b // ldr c27, [x28, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240179b // ldr c27, [x28, #5]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401f9b // ldr c27, [x28, #7]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240239b // ldr c27, [x28, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240279b // ldr c27, [x28, #9]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2402b9b // ldr c27, [x28, #10]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc2402f9b // ldr c27, [x28, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x27, v9.d[0]
	cmp x28, x27
	b.ne comparison_fail
	ldr x28, =0x0
	mov x27, v9.d[1]
	cmp x28, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000116c
	ldr x1, =check_data0
	ldr x2, =0x00001170
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001402
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001b28
	ldr x1, =check_data2
	ldr x2, =0x00001b2a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x4040001c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040c000
	ldr x1, =check_data5
	ldr x2, =0x4040c00c
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
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x7e, 0xa6, 0x96, 0xe2, 0x52, 0xc1, 0xbf, 0x78, 0x3f, 0xfc, 0x9f, 0x48, 0x09, 0x40, 0x46, 0x7c
	.byte 0xc6, 0x8b, 0x56, 0x7a, 0x01, 0x71, 0xab, 0xb8, 0x82, 0x52, 0xc2, 0xc2
.data
check_data5:
	.byte 0x29, 0x10, 0xc5, 0xc2, 0xbf, 0x50, 0x6e, 0x38, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f98
	/* C1 */
	.octa 0x40000000000300070000000000001b28
	/* C5 */
	.octa 0x1ffe
	/* C8 */
	.octa 0xc0000000000100050000000000001ff8
	/* C10 */
	.octa 0x80000000000100050000000000001400
	/* C11 */
	.octa 0x80000000
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x1202
	/* C20 */
	.octa 0x200080008007801f000000004040c000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f98
	/* C1 */
	.octa 0x1
	/* C5 */
	.octa 0x1ffe
	/* C8 */
	.octa 0xc0000000000100050000000000001ff8
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000000100050000000000001400
	/* C11 */
	.octa 0x80000000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1202
	/* C20 */
	.octa 0x200080008007801f000000004040c000
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000007801f000000004040c00c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001b20
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x82600f7c // ldr x28, [c27, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400f7c // str x28, [c27, #0]
	ldr x28, =0x4040c00c
	mrs x27, ELR_EL1
	sub x28, x28, x27
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b39b // cvtp c27, x28
	.inst 0xc2dc437b // scvalue c27, c27, x28
	.inst 0x8260037c // ldr c28, [c27, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
