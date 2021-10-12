.section text0, #alloc, #execinstr
test_start:
	.inst 0xb076591d // ADRP-C.I-C Rd:29 immhi:111011001011001000 P:0 10000:10000 immlo:01 op:1
	.inst 0x82804c25 // ASTRH-R.RRB-32 Rt:5 Rn:1 opc:11 S:0 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xda0801bb // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:27 Rn:13 000000:000000 Rm:8 11010000:11010000 S:0 op:1 sf:1
	.inst 0x88be7ffd // cas:aarch64/instrs/memory/atomicops/cas/single Rt:29 Rn:31 11111:11111 o0:0 Rs:30 1:1 L:0 0010001:0010001 size:10
	.inst 0xc276cb4e // LDR-C.RIB-C Ct:14 Rn:26 imm12:110110110010 L:1 110000100:110000100
	.zero 1004
	.inst 0x9b21c3ff // 0x9b21c3ff
	.inst 0xba5fb327 // 0xba5fb327
	.inst 0x22c348a1 // 0x22c348a1
	.inst 0xb840517e // 0xb840517e
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400781 // ldr c1, [x28, #1]
	.inst 0xc2400b85 // ldr c5, [x28, #2]
	.inst 0xc2400f8b // ldr c11, [x28, #3]
	.inst 0xc240139a // ldr c26, [x28, #4]
	.inst 0xc240179e // ldr c30, [x28, #5]
	/* Set up flags and system registers */
	ldr x28, =0x84000000
	msr SPSR_EL3, x28
	ldr x28, =initial_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288411c // msr CSP_EL0, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0xc0000
	msr CPACR_EL1, x28
	ldr x28, =0x4
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x0
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =initial_DDC_EL1_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc28c413c // msr DDC_EL1, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x10, =pcc_return_ddc_capabilities
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0x8260115c // ldr c28, [c10, #1]
	.inst 0x8260214a // ldr c10, [c10, #2]
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
	mov x10, #0x3
	and x28, x28, x10
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038a // ldr c10, [x28, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240078a // ldr c10, [x28, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc2400f8a // ldr c10, [x28, #3]
	.inst 0xc2caa561 // chkeq c11, c10
	b.ne comparison_fail
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc240178a // ldr c10, [x28, #5]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2401b8a // ldr c10, [x28, #6]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc2401f8a // ldr c10, [x28, #7]
	.inst 0xc2caa7c1 // chkeq c30, c10
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298410a // mrs c10, CSP_EL0
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc298402a // mrs c10, CELR_EL1
	.inst 0xc2caa781 // chkeq c28, c10
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x28, 0x83
	orr x10, x10, x28
	ldr x28, =0x920000ab
	cmp x28, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001082
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001200
	ldr x1, =check_data3
	ldr x2, =0x00001220
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
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x10, 0xb2, 0x38
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x00, 0x02
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0x1d, 0x59, 0x76, 0xb0, 0x25, 0x4c, 0x80, 0x82, 0xbb, 0x01, 0x08, 0xda, 0xfd, 0x7f, 0xbe, 0x88
	.byte 0x4e, 0xcb, 0x76, 0xc2
.data
check_data5:
	.byte 0xff, 0xc3, 0x21, 0x9b, 0x27, 0xb3, 0x5f, 0xba, 0xa1, 0x48, 0xc3, 0x22, 0x7e, 0x51, 0x40, 0xb8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40
	/* C1 */
	.octa 0x1040
	/* C5 */
	.octa 0x200
	/* C11 */
	.octa 0x3
	/* C26 */
	.octa 0x800000000000000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x260
	/* C11 */
	.octa 0x3
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x800000000000000000000000
	/* C29 */
	.octa 0x40000000000200000100000038b21000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000200100050000000000001000
initial_DDC_EL0_value:
	.octa 0x400000000002000000ffffff4c000400
initial_DDC_EL1_value:
	.octa 0x90000000100710070000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000500000120000000040400000
final_SP_EL0_value:
	.octa 0xc0000000200100050000000000001000
final_PCC_value:
	.octa 0x20008000500000120000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001210
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x82600d5c // ldr x28, [c10, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400d5c // str x28, [c10, #0]
	ldr x28, =0x40400414
	mrs x10, ELR_EL1
	sub x28, x28, x10
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b38a // cvtp c10, x28
	.inst 0xc2dc414a // scvalue c10, c10, x28
	.inst 0x8260015c // ldr c28, [c10, #0]
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
