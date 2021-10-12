.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c97bce // SCBNDS-C.CI-S Cd:14 Cn:30 1110:1110 S:1 imm6:010010 11000010110:11000010110
	.inst 0xe206dc37 // ALDURSB-R.RI-32 Rt:23 Rn:1 op2:11 imm9:001101101 V:0 op1:00 11100010:11100010
	.inst 0x2b35b3be // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:29 imm3:100 option:101 Rm:21 01011001:01011001 S:1 op:0 sf:0
	.inst 0xc2dd4520 // CSEAL-C.C-C Cd:0 Cn:9 001:001 opc:10 0:0 Cm:29 11000010110:11000010110
	.inst 0x7cc13f7f // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:31 Rn:27 11:11 imm9:000010011 0:0 opc:11 111100:111100 size:01
	.zero 40
	.inst 0x00001ffd
	.zero 5056
	.inst 0x785bf23d // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:17 00:00 imm9:110111111 0:0 opc:01 111000:111000 size:01
	.inst 0x383dd9fd // strb_reg:aarch64/instrs/memory/single/general/register Rt:29 Rn:15 10:10 S:1 option:110 Rm:29 1:1 opc:00 111000:111000 size:00
	.inst 0x8b9dbfde // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:30 Rn:30 imm6:101111 Rm:29 0:0 shift:10 01011:01011 S:0 op:0 sf:1
	.inst 0x82fd6172 // ALDR-R.RRB-32 Rt:18 Rn:11 opc:00 S:0 option:011 Rm:29 1:1 L:1 100000101:100000101
	.inst 0xd4000001
	.zero 60396
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400489 // ldr c9, [x4, #1]
	.inst 0xc240088b // ldr c11, [x4, #2]
	.inst 0xc2400c8f // ldr c15, [x4, #3]
	.inst 0xc2401091 // ldr c17, [x4, #4]
	.inst 0xc240149d // ldr c29, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	ldr x4, =0x0
	msr SPSR_EL3, x4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x82601064 // ldr c4, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x3, #0xf
	and x4, x4, x3
	cmp x4, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400083 // ldr c3, [x4, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc2400883 // ldr c3, [x4, #2]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400c83 // ldr c3, [x4, #3]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2401083 // ldr c3, [x4, #4]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2401483 // ldr c3, [x4, #5]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc2401883 // ldr c3, [x4, #6]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc2401c83 // ldr c3, [x4, #7]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc2402083 // ldr c3, [x4, #8]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2402483 // ldr c3, [x4, #9]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x4, 0x0
	orr x3, x3, x4
	ldr x4, =0x2000000
	cmp x4, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffe
	ldr x1, =check_data0
	ldr x2, =0x00001fff
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40400000
	ldr x1, =check_data1
	ldr x2, =0x40400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x4040003c
	ldr x1, =check_data2
	ldr x2, =0x4040003e
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40401400
	ldr x1, =check_data3
	ldr x2, =0x40401414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040ffc8
	ldr x1, =check_data4
	ldr x2, =0x4040ffcc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.byte 0xfd
.data
check_data1:
	.byte 0xce, 0x7b, 0xc9, 0xc2, 0x37, 0xdc, 0x06, 0xe2, 0xbe, 0xb3, 0x35, 0x2b, 0x20, 0x45, 0xdd, 0xc2
	.byte 0x7f, 0x3f, 0xc1, 0x7c
.data
check_data2:
	.byte 0xfd, 0x1f
.data
check_data3:
	.byte 0x3d, 0xf2, 0x5b, 0x78, 0xfd, 0xd9, 0x3d, 0x38, 0xde, 0xbf, 0x9d, 0x8b, 0x72, 0x61, 0xfd, 0x82
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000100050000000000001f91
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x4040dfcb
	/* C15 */
	.octa 0x40000000000100050000000000000001
	/* C17 */
	.octa 0x8000000000010005000000004040007d
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x400000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000000100050000000000001f91
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x4040dfcb
	/* C14 */
	.octa 0x412000000000000000000000
	/* C15 */
	.octa 0x40000000000100050000000000000001
	/* C17 */
	.octa 0x8000000000010005000000004040007d
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C29 */
	.octa 0x1ffd
initial_DDC_EL1_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080006800041e0000000040401001
final_PCC_value:
	.octa 0x200080006800041e0000000040401414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600c64 // ldr x4, [c3, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400c64 // str x4, [c3, #0]
	ldr x4, =0x40401414
	mrs x3, ELR_EL1
	sub x4, x4, x3
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b083 // cvtp c3, x4
	.inst 0xc2c44063 // scvalue c3, c3, x4
	.inst 0x82600064 // ldr c4, [c3, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
