.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d949f7 // UNSEAL-C.CC-C Cd:23 Cn:15 0010:0010 opc:01 Cm:25 11000010110:11000010110
	.inst 0x6d2c97fa // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:26 Rn:31 Rt2:00101 imm7:1011001 L:0 1011010:1011010 opc:01
	.inst 0xc2c533dd // CVTP-R.C-C Rd:29 Cn:30 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0xadf25ce0 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:0 Rn:7 Rt2:10111 imm7:1100100 L:1 1011011:1011011 opc:10
	.inst 0x421ffdb1 // STLR-C.R-C Ct:17 Rn:13 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.zero 1004
	.inst 0xb80518a1 // 0xb80518a1
	.inst 0xc2c733c1 // 0xc2c733c1
	.inst 0x721f6e5c // 0x721f6e5c
	.inst 0xc2c71017 // 0xc2c71017
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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a05 // ldr c5, [x16, #2]
	.inst 0xc2400e07 // ldr c7, [x16, #3]
	.inst 0xc240120d // ldr c13, [x16, #4]
	.inst 0xc240160f // ldr c15, [x16, #5]
	.inst 0xc2401a11 // ldr c17, [x16, #6]
	.inst 0xc2401e12 // ldr c18, [x16, #7]
	.inst 0xc2402219 // ldr c25, [x16, #8]
	.inst 0xc240261e // ldr c30, [x16, #9]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q5, =0x0
	ldr q26, =0x0
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x3c0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0x0
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x26, =pcc_return_ddc_capabilities
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0x82601350 // ldr c16, [c26, #1]
	.inst 0x8260235a // ldr c26, [c26, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x26, #0xf
	and x16, x16, x26
	cmp x16, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240021a // ldr c26, [x16, #0]
	.inst 0xc2daa401 // chkeq c0, c26
	b.ne comparison_fail
	.inst 0xc240061a // ldr c26, [x16, #1]
	.inst 0xc2daa421 // chkeq c1, c26
	b.ne comparison_fail
	.inst 0xc2400a1a // ldr c26, [x16, #2]
	.inst 0xc2daa4a1 // chkeq c5, c26
	b.ne comparison_fail
	.inst 0xc2400e1a // ldr c26, [x16, #3]
	.inst 0xc2daa4e1 // chkeq c7, c26
	b.ne comparison_fail
	.inst 0xc240121a // ldr c26, [x16, #4]
	.inst 0xc2daa5a1 // chkeq c13, c26
	b.ne comparison_fail
	.inst 0xc240161a // ldr c26, [x16, #5]
	.inst 0xc2daa5e1 // chkeq c15, c26
	b.ne comparison_fail
	.inst 0xc2401a1a // ldr c26, [x16, #6]
	.inst 0xc2daa621 // chkeq c17, c26
	b.ne comparison_fail
	.inst 0xc2401e1a // ldr c26, [x16, #7]
	.inst 0xc2daa641 // chkeq c18, c26
	b.ne comparison_fail
	.inst 0xc240221a // ldr c26, [x16, #8]
	.inst 0xc2daa6e1 // chkeq c23, c26
	b.ne comparison_fail
	.inst 0xc240261a // ldr c26, [x16, #9]
	.inst 0xc2daa721 // chkeq c25, c26
	b.ne comparison_fail
	.inst 0xc2402a1a // ldr c26, [x16, #10]
	.inst 0xc2daa781 // chkeq c28, c26
	b.ne comparison_fail
	.inst 0xc2402e1a // ldr c26, [x16, #11]
	.inst 0xc2daa7a1 // chkeq c29, c26
	b.ne comparison_fail
	.inst 0xc240321a // ldr c26, [x16, #12]
	.inst 0xc2daa7c1 // chkeq c30, c26
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x26, v0.d[0]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v0.d[1]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v5.d[0]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v5.d[1]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v23.d[0]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v23.d[1]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v26.d[0]
	cmp x16, x26
	b.ne comparison_fail
	ldr x16, =0x0
	mov x26, v26.d[1]
	cmp x16, x26
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298411a // mrs c26, CSP_EL0
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc298403a // mrs c26, CELR_EL1
	.inst 0xc2daa601 // chkeq c16, c26
	b.ne comparison_fail
	ldr x26, =esr_el1_dump_address
	ldr x26, [x26]
	mov x16, 0x83
	orr x26, x26, x16
	ldr x16, =0x920000e3
	cmp x16, x26
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001064
	ldr x1, =check_data0
	ldr x2, =0x00001068
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001778
	ldr x1, =check_data1
	ldr x2, =0x00001788
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400014
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400400
	ldr x1, =check_data3
	ldr x2, =0x40400414
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40403f40
	ldr x1, =check_data4
	ldr x2, =0x40403f60
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 4
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xf7, 0x49, 0xd9, 0xc2, 0xfa, 0x97, 0x2c, 0x6d, 0xdd, 0x33, 0xc5, 0xc2, 0xe0, 0x5c, 0xf2, 0xad
	.byte 0xb1, 0xfd, 0x1f, 0x42
.data
check_data3:
	.byte 0xa1, 0x18, 0x05, 0xb8, 0xc1, 0x33, 0xc7, 0xc2, 0x5c, 0x6e, 0x1f, 0x72, 0x17, 0x10, 0xc7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 32

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x400000006002002c0000000000001013
	/* C7 */
	.octa 0x800000000ea72eaf0000000040404100
	/* C13 */
	.octa 0x40000000580489f2005b16000000919f
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffffffffffffffff
	/* C5 */
	.octa 0x400000006002002c0000000000001013
	/* C7 */
	.octa 0x800000000ea72eaf0000000040403f40
	/* C13 */
	.octa 0x40000000580489f2005b16000000919f
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x400000004000000800000000000018b0
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400001
final_SP_EL0_value:
	.octa 0x400000004000000800000000000018b0
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 192
	.dword initial_SP_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600f50 // ldr x16, [c26, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400f50 // str x16, [c26, #0]
	ldr x16, =0x40400414
	mrs x26, ELR_EL1
	sub x16, x16, x26
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b21a // cvtp c26, x16
	.inst 0xc2d0435a // scvalue c26, c26, x16
	.inst 0x82600350 // ldr c16, [c26, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
