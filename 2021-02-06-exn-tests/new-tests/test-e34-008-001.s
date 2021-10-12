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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b45 // ldr c5, [x26, #2]
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc240134a // ldr c10, [x26, #4]
	.inst 0xc240174b // ldr c11, [x26, #5]
	.inst 0xc2401b4e // ldr c14, [x26, #6]
	.inst 0xc2401f53 // ldr c19, [x26, #7]
	.inst 0xc2402354 // ldr c20, [x26, #8]
	/* Set up flags and system registers */
	ldr x26, =0x24000000
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x0
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260137a // ldr c26, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x27, #0xf
	and x26, x26, x27
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240035b // ldr c27, [x26, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240075b // ldr c27, [x26, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b5b // ldr c27, [x26, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400f5b // ldr c27, [x26, #3]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240135b // ldr c27, [x26, #4]
	.inst 0xc2dba521 // chkeq c9, c27
	b.ne comparison_fail
	.inst 0xc240175b // ldr c27, [x26, #5]
	.inst 0xc2dba541 // chkeq c10, c27
	b.ne comparison_fail
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc2401f5b // ldr c27, [x26, #7]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240235b // ldr c27, [x26, #8]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240275b // ldr c27, [x26, #9]
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	.inst 0xc2402b5b // ldr c27, [x26, #10]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc2402f5b // ldr c27, [x26, #11]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x27, v9.d[0]
	cmp x26, x27
	b.ne comparison_fail
	ldr x26, =0x0
	mov x27, v9.d[1]
	cmp x26, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba741 // chkeq c26, c27
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
	ldr x0, =0x00001200
	ldr x1, =check_data1
	ldr x2, =0x00001202
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000126c
	ldr x1, =check_data2
	ldr x2, =0x00001270
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000014ac
	ldr x1, =check_data3
	ldr x2, =0x000014b0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017fc
	ldr x1, =check_data4
	ldr x2, =0x000017fe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x4040001c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040c000
	ldr x1, =check_data7
	ldr x2, =0x4040c00c
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
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 592
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
	.zero 3472
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x01, 0x00, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0x7e, 0xa6, 0x96, 0xe2, 0x52, 0xc1, 0xbf, 0x78, 0x3f, 0xfc, 0x9f, 0x48, 0x09, 0x40, 0x46, 0x7c
	.byte 0xc6, 0x8b, 0x56, 0x7a, 0x01, 0x71, 0xab, 0xb8, 0x82, 0x52, 0xc2, 0xc2
.data
check_data7:
	.byte 0x29, 0x10, 0xc5, 0xc2, 0xbf, 0x50, 0x6e, 0x38, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f98
	/* C1 */
	.octa 0x400000000000c0000000000000001200
	/* C5 */
	.octa 0xc0000000100200020000000000001000
	/* C8 */
	.octa 0xc000000000010005000000000000126c
	/* C10 */
	.octa 0x800000000001000500000000000017fc
	/* C11 */
	.octa 0x80000000
	/* C14 */
	.octa 0x0
	/* C19 */
	.octa 0x1542
	/* C20 */
	.octa 0x200080000007c007000000004040c001
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001f98
	/* C1 */
	.octa 0x1
	/* C5 */
	.octa 0xc0000000100200020000000000001000
	/* C8 */
	.octa 0xc000000000010005000000000000126c
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x800000000001000500000000000017fc
	/* C11 */
	.octa 0x80000000
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x1542
	/* C20 */
	.octa 0x200080000007c007000000004040c001
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000007c007000000004040c00c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000201c0050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
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
	.dword initial_cap_values + 128
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001200
	.dword 0x0000000000001260
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x82600f7a // ldr x26, [c27, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400f7a // str x26, [c27, #0]
	ldr x26, =0x4040c00c
	mrs x27, ELR_EL1
	sub x26, x26, x27
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b35b // cvtp c27, x26
	.inst 0xc2da437b // scvalue c27, c27, x26
	.inst 0x8260037a // ldr c26, [c27, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
