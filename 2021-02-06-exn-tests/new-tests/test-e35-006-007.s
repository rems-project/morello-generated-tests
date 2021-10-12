.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7fff // stllrh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x42c23cff // LDP-C.RIB-C Ct:31 Rn:7 Ct2:01111 imm7:0000100 L:1 010000101:010000101
	.inst 0xc2c5f3b0 // CVTPZ-C.R-C Cd:16 Rn:29 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x78614103 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:8 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xa2be7fba // CAS-C.R-C Ct:26 Rn:29 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.zero 37868
	.inst 0xb881f41e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:0 01:01 imm9:000011111 0:0 opc:10 111000:111000 size:10
	.inst 0x88057c20 // stxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:1 Rt2:11111 o0:0 Rs:5 0:0 L:0 0010000:0010000 size:10
	.inst 0x787f51d0 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:14 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x30de5b72 // ADR-C.I-C Rd:18 immhi:101111001011011011 P:1 10000:10000 immlo:01 op:0
	.inst 0xd4000001
	.zero 27628
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
	.inst 0xc2400080 // ldr c0, [x4, #0]
	.inst 0xc2400481 // ldr c1, [x4, #1]
	.inst 0xc2400887 // ldr c7, [x4, #2]
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc240108e // ldr c14, [x4, #4]
	.inst 0xc240149a // ldr c26, [x4, #5]
	.inst 0xc240189d // ldr c29, [x4, #6]
	/* Set up flags and system registers */
	ldr x4, =0x4000000
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884104 // msr CSP_EL0, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0xc0000
	msr CPACR_EL1, x4
	ldr x4, =0x0
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =0x8
	msr S3_3_C1_C2_2, x4 // CCTLR_EL0
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82601184 // ldr c4, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008c // ldr c12, [x4, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240048c // ldr c12, [x4, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240088c // ldr c12, [x4, #2]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc2400c8c // ldr c12, [x4, #3]
	.inst 0xc2cca4a1 // chkeq c5, c12
	b.ne comparison_fail
	.inst 0xc240108c // ldr c12, [x4, #4]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240148c // ldr c12, [x4, #5]
	.inst 0xc2cca501 // chkeq c8, c12
	b.ne comparison_fail
	.inst 0xc240188c // ldr c12, [x4, #6]
	.inst 0xc2cca5c1 // chkeq c14, c12
	b.ne comparison_fail
	.inst 0xc2401c8c // ldr c12, [x4, #7]
	.inst 0xc2cca5e1 // chkeq c15, c12
	b.ne comparison_fail
	.inst 0xc240208c // ldr c12, [x4, #8]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240248c // ldr c12, [x4, #9]
	.inst 0xc2cca641 // chkeq c18, c12
	b.ne comparison_fail
	.inst 0xc240288c // ldr c12, [x4, #10]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc2402c8c // ldr c12, [x4, #11]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc240308c // ldr c12, [x4, #12]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc298410c // mrs c12, CSP_EL0
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc298402c // mrs c12, CELR_EL1
	.inst 0xc2cca481 // chkeq c4, c12
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x12, 0x80
	orr x4, x4, x12
	ldr x12, =0x920000a1
	cmp x12, x4
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001004
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010e0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001880
	ldr x1, =check_data3
	ldr x2, =0x00001882
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000019f8
	ldr x1, =check_data4
	ldr x2, =0x000019fc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ff8
	ldr x1, =check_data5
	ldr x2, =0x00001ffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40409400
	ldr x1, =check_data7
	ldr x2, =0x40409414
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
	.byte 0xfa, 0xa9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 192
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
	.zero 3872
.data
check_data0:
	.byte 0xf8, 0x19
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x20, 0x00, 0x00
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 4
.data
check_data6:
	.byte 0xff, 0x7f, 0x9f, 0x48, 0xff, 0x3c, 0xc2, 0x42, 0xb0, 0xf3, 0xc5, 0xc2, 0x03, 0x41, 0x61, 0x78
	.byte 0xba, 0x7f, 0xbe, 0xa2
.data
check_data7:
	.byte 0x1e, 0xf4, 0x81, 0xb8, 0x20, 0x7c, 0x05, 0x88, 0xd0, 0x51, 0x7f, 0x78, 0x72, 0x5b, 0xde, 0x30
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1ff8
	/* C1 */
	.octa 0x19f8
	/* C7 */
	.octa 0x90000000000180050000000000001080
	/* C8 */
	.octa 0xc00000000007000f0000000000001000
	/* C14 */
	.octa 0x1004
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xcc0000000000800800fff00040400002
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x2017
	/* C1 */
	.octa 0x19f8
	/* C3 */
	.octa 0xa9fa
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x90000000000180050000000000001080
	/* C8 */
	.octa 0xc00000000007000f0000000000001000
	/* C14 */
	.octa 0x1004
	/* C15 */
	.octa 0x2001800000000000000000000000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0x403c5f79
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xcc0000000000800800fff00040400002
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x400000004e010e090000000000001880
initial_DDC_EL1_value:
	.octa 0xc00000004004000a00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080004000841d0000000040409000
final_SP_EL0_value:
	.octa 0x400000004e010e090000000000001880
final_PCC_value:
	.octa 0x200080004000841d0000000040409414
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
	.dword 0x00000000000010c0
	.dword 0x00000000000010d0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000010c0
	.dword 0x00000000000010d0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001880
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
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600d84 // ldr x4, [c12, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400d84 // str x4, [c12, #0]
	ldr x4, =0x40409414
	mrs x12, ELR_EL1
	sub x4, x4, x12
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b08c // cvtp c12, x4
	.inst 0xc2c4418c // scvalue c12, c12, x4
	.inst 0x82600184 // ldr c4, [c12, #0]
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
