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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a65 // ldr c5, [x19, #2]
	.inst 0xc2400e67 // ldr c7, [x19, #3]
	.inst 0xc240126d // ldr c13, [x19, #4]
	.inst 0xc240166f // ldr c15, [x19, #5]
	.inst 0xc2401a71 // ldr c17, [x19, #6]
	.inst 0xc2401e72 // ldr c18, [x19, #7]
	.inst 0xc2402279 // ldr c25, [x19, #8]
	.inst 0xc240267e // ldr c30, [x19, #9]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q5, =0x0
	ldr q26, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x0
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4133 // msr DDC_EL1, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601373 // ldr c19, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x27, #0xf
	and x19, x19, x27
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc240027b // ldr c27, [x19, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240067b // ldr c27, [x19, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400a7b // ldr c27, [x19, #2]
	.inst 0xc2dba4a1 // chkeq c5, c27
	b.ne comparison_fail
	.inst 0xc2400e7b // ldr c27, [x19, #3]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc240127b // ldr c27, [x19, #4]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc240167b // ldr c27, [x19, #5]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc2401a7b // ldr c27, [x19, #6]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc2401e7b // ldr c27, [x19, #7]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240227b // ldr c27, [x19, #8]
	.inst 0xc2dba6e1 // chkeq c23, c27
	b.ne comparison_fail
	.inst 0xc240267b // ldr c27, [x19, #9]
	.inst 0xc2dba721 // chkeq c25, c27
	b.ne comparison_fail
	.inst 0xc2402a7b // ldr c27, [x19, #10]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc2402e7b // ldr c27, [x19, #11]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240327b // ldr c27, [x19, #12]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x27, v0.d[0]
	cmp x19, x27
	b.ne comparison_fail
	ldr x19, =0x0
	mov x27, v0.d[1]
	cmp x19, x27
	b.ne comparison_fail
	ldr x19, =0x0
	mov x27, v5.d[0]
	cmp x19, x27
	b.ne comparison_fail
	ldr x19, =0x0
	mov x27, v5.d[1]
	cmp x19, x27
	b.ne comparison_fail
	ldr x19, =0x0
	mov x27, v23.d[0]
	cmp x19, x27
	b.ne comparison_fail
	ldr x19, =0x0
	mov x27, v23.d[1]
	cmp x19, x27
	b.ne comparison_fail
	ldr x19, =0x0
	mov x27, v26.d[0]
	cmp x19, x27
	b.ne comparison_fail
	ldr x19, =0x0
	mov x27, v26.d[1]
	cmp x19, x27
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298411b // mrs c27, CSP_EL0
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba661 // chkeq c19, c27
	b.ne comparison_fail
	ldr x27, =esr_el1_dump_address
	ldr x27, [x27]
	mov x19, 0x83
	orr x27, x27, x19
	ldr x19, =0x920000eb
	cmp x19, x27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001004
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001640
	ldr x1, =check_data1
	ldr x2, =0x00001660
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ec8
	ldr x1, =check_data2
	ldr x2, =0x00001ed8
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
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 32
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xf7, 0x49, 0xd9, 0xc2, 0xfa, 0x97, 0x2c, 0x6d, 0xdd, 0x33, 0xc5, 0xc2, 0xe0, 0x5c, 0xf2, 0xad
	.byte 0xb1, 0xfd, 0x1f, 0x42
.data
check_data4:
	.byte 0xa1, 0x18, 0x05, 0xb8, 0xc1, 0x33, 0xc7, 0xc2, 0x5c, 0x6e, 0x1f, 0x72, 0x17, 0x10, 0xc7, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x300000000000000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0xfb3
	/* C7 */
	.octa 0x800000005e0400020000000000001800
	/* C13 */
	.octa 0x800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x1ffffffe
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x300000000000000
	/* C1 */
	.octa 0xffffffffffffffff
	/* C5 */
	.octa 0xfb3
	/* C7 */
	.octa 0x800000005e0400020000000000001640
	/* C13 */
	.octa 0x800000000000000000000000
	/* C15 */
	.octa 0x0
	/* C17 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x1ffffffe
	/* C23 */
	.octa 0x300000000000000
	/* C25 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x1ffffffe
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000000000080000000000002000
initial_DDC_EL1_value:
	.octa 0x40000000000300070000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800001d0000000040400000
final_SP_EL0_value:
	.octa 0x40000000000000080000000000002000
final_PCC_value:
	.octa 0x200080004800001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000100700070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 192
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600f73 // ldr x19, [c27, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400f73 // str x19, [c27, #0]
	ldr x19, =0x40400414
	mrs x27, ELR_EL1
	sub x19, x19, x27
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b27b // cvtp c27, x19
	.inst 0xc2d3437b // scvalue c27, c27, x19
	.inst 0x82600373 // ldr c19, [c27, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
