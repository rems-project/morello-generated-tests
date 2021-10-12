.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2fe80db // SWPAL-CC.R-C Ct:27 Rn:6 100000:100000 Cs:30 1:1 R:1 A:1 10100010:10100010
	.inst 0x5a1903bf // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:29 000000:000000 Rm:25 11010000:11010000 S:0 op:1 sf:0
	.inst 0x38fd529f // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:20 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x1ac1210d // lslv:aarch64/instrs/integer/shift/variable Rd:13 Rn:8 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xb89db7ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:31 01:01 imm9:111011011 0:0 opc:10 111000:111000 size:10
	.zero 1004
	.inst 0xa2497078 // 0xa2497078
	.inst 0xc2c9abf5 // 0xc2c9abf5
	.inst 0x799b0900 // 0x799b0900
	.inst 0x3c92d5af // 0x3c92d5af
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
	ldr x26, =initial_cap_values
	.inst 0xc2400341 // ldr c1, [x26, #0]
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2400b46 // ldr c6, [x26, #2]
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc2401354 // ldr c20, [x26, #4]
	.inst 0xc240175d // ldr c29, [x26, #5]
	.inst 0xc2401b5e // ldr c30, [x26, #6]
	/* Vector registers */
	mrs x26, cptr_el3
	bfc x26, #10, #1
	msr cptr_el3, x26
	isb
	ldr q15, =0x20000208020008081010000040000000
	/* Set up flags and system registers */
	ldr x26, =0x4000000
	msr SPSR_EL3, x26
	ldr x26, =initial_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288411a // msr CSP_EL0, c26
	ldr x26, =initial_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c411a // msr CSP_EL1, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x4
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =initial_DDC_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c413a // msr DDC_EL1, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012da // ldr c26, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400356 // ldr c22, [x26, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400756 // ldr c22, [x26, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400b56 // ldr c22, [x26, #2]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400f56 // ldr c22, [x26, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401356 // ldr c22, [x26, #4]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401756 // ldr c22, [x26, #5]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401b56 // ldr c22, [x26, #6]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401f56 // ldr c22, [x26, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2402356 // ldr c22, [x26, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402756 // ldr c22, [x26, #9]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402b56 // ldr c22, [x26, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x1010000040000000
	mov x22, v15.d[0]
	cmp x26, x22
	b.ne comparison_fail
	ldr x26, =0x2000020802000808
	mov x22, v15.d[1]
	cmp x26, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	ldr x26, =final_SP_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc29c4116 // mrs c22, CSP_EL1
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x26, 0x83
	orr x22, x22, x26
	ldr x26, =0x920000ab
	cmp x26, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d94
	ldr x1, =check_data2
	ldr x2, =0x00001d96
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
	.zero 16
	.byte 0x82, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x10, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x10, 0x10, 0x08, 0x08, 0x00, 0x02, 0x08, 0x02, 0x00, 0x20
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xdb, 0x80, 0xfe, 0xa2, 0xbf, 0x03, 0x19, 0x5a, 0x9f, 0x52, 0xfd, 0x38, 0x0d, 0x21, 0xc1, 0x1a
	.byte 0xff, 0xb7, 0x9d, 0xb8
.data
check_data4:
	.byte 0x78, 0x70, 0x49, 0xa2, 0xf5, 0xab, 0xc9, 0xc2, 0x00, 0x09, 0x9b, 0x79, 0xaf, 0xd5, 0x92, 0x3c
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1021
	/* C6 */
	.octa 0xcc100000520109820000000000001000
	/* C8 */
	.octa 0x1008
	/* C20 */
	.octa 0xc00000004001011a0000000000001010
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x2000100400000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1021
	/* C6 */
	.octa 0xcc100000520109820000000000001000
	/* C8 */
	.octa 0x1008
	/* C13 */
	.octa 0xf35
	/* C20 */
	.octa 0xc00000004001011a0000000000001010
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x2000100400000000000000
initial_SP_EL0_value:
	.octa 0x80000000000020
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xd00000004004000800ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004c0002010000000040400000
final_SP_EL0_value:
	.octa 0x80000000000020
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080004c0002010000000040400414
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
	.dword 0x0000000000001000
	.dword 0x00000000000010c0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x82600eda // ldr x26, [c22, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400eda // str x26, [c22, #0]
	ldr x26, =0x40400414
	mrs x22, ELR_EL1
	sub x26, x26, x22
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b356 // cvtp c22, x26
	.inst 0xc2da42d6 // scvalue c22, c22, x26
	.inst 0x826002da // ldr c26, [c22, #0]
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
