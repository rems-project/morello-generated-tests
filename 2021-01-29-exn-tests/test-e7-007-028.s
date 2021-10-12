.section text0, #alloc, #execinstr
test_start:
	.inst 0x3831129f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc021 // LDAPR-C.R-C Ct:1 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x48bd7c14 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:20 Rn:0 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x787802bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c430f7 // LDPBLR-C.C-C Ct:23 Cn:7 100:100 opc:01 11000010110001000:11000010110001000
	.zero 44
	.inst 0x1b1583ff // 0x1b1583ff
	.inst 0x35f62df4 // 0x35f62df4
	.inst 0x489f7f61 // 0x489f7f61
	.inst 0x7a1b001c // 0x7a1b001c
	.inst 0xd4000001
	.zero 65452
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e1 // ldr c1, [x15, #1]
	.inst 0xc24009e7 // ldr c7, [x15, #2]
	.inst 0xc2400df1 // ldr c17, [x15, #3]
	.inst 0xc24011f4 // ldr c20, [x15, #4]
	.inst 0xc24015f5 // ldr c21, [x15, #5]
	.inst 0xc24019f8 // ldr c24, [x15, #6]
	.inst 0xc2401dfb // ldr c27, [x15, #7]
	.inst 0xc24021fd // ldr c29, [x15, #8]
	/* Set up flags and system registers */
	ldr x15, =0x0
	msr SPSR_EL3, x15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =0x4
	msr S3_3_C1_C2_2, x15 // CCTLR_EL0
	ldr x15, =initial_DDC_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288412f // msr DDC_EL0, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260118f // ldr c15, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc28e402f // msr CELR_EL3, c15
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30851035
	msr SCTLR_EL3, x15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x12, #0x4
	and x15, x15, x12
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ec // ldr c12, [x15, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc24005ec // ldr c12, [x15, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc24009ec // ldr c12, [x15, #2]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc2400dec // ldr c12, [x15, #3]
	.inst 0xc2cca621 // chkeq c17, c12
	b.ne comparison_fail
	.inst 0xc24011ec // ldr c12, [x15, #4]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc24015ec // ldr c12, [x15, #5]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc24019ec // ldr c12, [x15, #6]
	.inst 0xc2cca6e1 // chkeq c23, c12
	b.ne comparison_fail
	.inst 0xc2401dec // ldr c12, [x15, #7]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc24021ec // ldr c12, [x15, #8]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc24025ec // ldr c12, [x15, #9]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc24029ec // ldr c12, [x15, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca5e1 // chkeq c15, c12
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
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001410
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x40400040
	ldr x1, =check_data4
	ldr x2, =0x40400054
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr DDC_EL3, c15
	ldr x15, =0x30850030
	msr SCTLR_EL3, x15
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
	.byte 0x41, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x41, 0x00, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x9f, 0x12, 0x31, 0x38, 0x21, 0xc0, 0x3f, 0xa2, 0x14, 0x7c, 0xbd, 0x48, 0xbf, 0x02, 0x78, 0x78
	.byte 0xf7, 0x30, 0xc4, 0xc2
.data
check_data4:
	.byte 0xff, 0x83, 0x15, 0x1b, 0xf4, 0x2d, 0xf6, 0x35, 0x61, 0x7f, 0x9f, 0x48, 0x1c, 0x00, 0x1b, 0x7a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400
	/* C7 */
	.octa 0x90100000000500070000000000001000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000100050000000000001ffc
	/* C29 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x90100000000500070000000000001000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000100050000000000001ffc
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000200010000000040400014
initial_DDC_EL0_value:
	.octa 0xd0000000100710070000000000006000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000200030000000040400054
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001400
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
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
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x82600d8f // ldr x15, [c12, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400d8f // str x15, [c12, #0]
	ldr x15, =0x40400054
	mrs x12, ELR_EL1
	sub x15, x15, x12
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ec // cvtp c12, x15
	.inst 0xc2cf418c // scvalue c12, c12, x15
	.inst 0x8260018f // ldr c15, [c12, #0]
	.inst 0x021e01ef // add c15, c15, #1920
	.inst 0xc2c211e0 // br c15

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
