.section text0, #alloc, #execinstr
test_start:
	.inst 0xd029bfb0 // ADRP-C.I-C Rd:16 immhi:010100110111111101 P:0 10000:10000 immlo:10 op:1
	.inst 0xc2ca6ba0 // ORRFLGS-C.CR-C Cd:0 Cn:29 1010:1010 opc:01 Rm:10 11000010110:11000010110
	.inst 0xc2dfa601 // CHKEQ-_.CC-C 00001:00001 Cn:16 001:001 opc:01 1:1 Cm:31 11000010110:11000010110
	.inst 0xb84fb53e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:9 01:01 imm9:011111011 0:0 opc:01 111000:111000 size:10
	.inst 0xb8574fc1 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:30 11:11 imm9:101110100 0:0 opc:01 111000:111000 size:10
	.zero 8172
	.inst 0x40408007
	.zero 3068
	.inst 0x1a9eb7a0 // 0x1a9eb7a0
	.inst 0xc2df4c0c // CSEL-C.CI-C Cd:12 Cn:0 11:11 cond:0100 Cm:31 11000010110:11000010110
	.inst 0x38bfc31f // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:31 Rn:24 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xf9672017 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:23 Rn:0 imm12:100111001000 opc:01 111001:111001 size:11
	.inst 0xd4000001
	.zero 41524
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 432
	.inst 0x000000c2
	.zero 12284
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
	.inst 0xc2400349 // ldr c9, [x26, #0]
	.inst 0xc2400758 // ldr c24, [x26, #1]
	.inst 0xc2400b5c // ldr c28, [x26, #2]
	.inst 0xc2400f5d // ldr c29, [x26, #3]
	/* Set up flags and system registers */
	ldr x26, =0x4000000
	msr SPSR_EL3, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0xc0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x10
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL1_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc28c413a // msr DDC_EL1, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260107a // ldr c26, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
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
	mov x3, #0xf
	and x26, x26, x3
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400343 // ldr c3, [x26, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc2400743 // ldr c3, [x26, #1]
	.inst 0xc2c3a521 // chkeq c9, c3
	b.ne comparison_fail
	.inst 0xc2400b43 // ldr c3, [x26, #2]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc2400f43 // ldr c3, [x26, #3]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2401343 // ldr c3, [x26, #4]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc2401743 // ldr c3, [x26, #5]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc2401b43 // ldr c3, [x26, #6]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2401f43 // ldr c3, [x26, #7]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402343 // ldr c3, [x26, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984023 // mrs c3, CELR_EL1
	.inst 0xc2c3a741 // chkeq c26, c3
	b.ne comparison_fail
	ldr x3, =esr_el1_dump_address
	ldr x3, [x3]
	mov x26, 0x83
	orr x3, x3, x26
	ldr x26, =0x920000ab
	cmp x26, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x40400000
	ldr x1, =check_data0
	ldr x2, =0x40400014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x40402000
	ldr x1, =check_data1
	ldr x2, =0x40402004
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40402c00
	ldr x1, =check_data2
	ldr x2, =0x40402c14
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x4040ce48
	ldr x1, =check_data3
	ldr x2, =0x4040ce50
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040d000
	ldr x1, =check_data4
	ldr x2, =0x4040d001
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
	.zero 4096
.data
check_data0:
	.byte 0xb0, 0xbf, 0x29, 0xd0, 0xa0, 0x6b, 0xca, 0xc2, 0x01, 0xa6, 0xdf, 0xc2, 0x3e, 0xb5, 0x4f, 0xb8
	.byte 0xc1, 0x4f, 0x57, 0xb8
.data
check_data1:
	.byte 0x07, 0x80, 0x40, 0x40
.data
check_data2:
	.byte 0xa0, 0xb7, 0x9e, 0x1a, 0x0c, 0x4c, 0xdf, 0xc2, 0x1f, 0xc3, 0xbf, 0x38, 0x17, 0x20, 0x67, 0xf9
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2

.data
.balign 16
initial_cap_values:
	/* C9 */
	.octa 0x80000000080707870000000040402000
	/* C24 */
	.octa 0x4040d000
	/* C28 */
	.octa 0x80048003007fffffc7f04000
	/* C29 */
	.octa 0x3fff800000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40408008
	/* C9 */
	.octa 0x800000000807078700000000404020fb
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0x80048003008000001b6fa000
	/* C23 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C24 */
	.octa 0x4040d000
	/* C28 */
	.octa 0x80048003007fffffc7f04000
	/* C29 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x40408007
initial_DDC_EL1_value:
	.octa 0x800000000007c007000000004040e001
initial_VBAR_EL1_value:
	.octa 0x200080007000241d0000000040402800
final_PCC_value:
	.octa 0x200080007000241d0000000040402c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300020000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
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
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x82600c7a // ldr x26, [c3, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c7a // str x26, [c3, #0]
	ldr x26, =0x40402c14
	mrs x3, ELR_EL1
	sub x26, x26, x3
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b343 // cvtp c3, x26
	.inst 0xc2da4063 // scvalue c3, c3, x26
	.inst 0x8260007a // ldr c26, [c3, #0]
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
