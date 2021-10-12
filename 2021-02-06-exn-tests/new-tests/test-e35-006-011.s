.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7fff // stllrh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x42c23cff // LDP-C.RIB-C Ct:31 Rn:7 Ct2:01111 imm7:0000100 L:1 010000101:010000101
	.inst 0xc2c5f3b0 // CVTPZ-C.R-C Cd:16 Rn:29 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x78614103 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:8 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xa2be7fba // CAS-C.R-C Ct:26 Rn:29 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.zero 33772
	.inst 0xb881f41e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:0 01:01 imm9:000011111 0:0 opc:10 111000:111000 size:10
	.inst 0x88057c20 // stxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:1 Rt2:11111 o0:0 Rs:5 0:0 L:0 0010000:0010000 size:10
	.inst 0x787f51d0 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:14 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x30de5b72 // ADR-C.I-C Rd:18 immhi:101111001011011011 P:1 10000:10000 immlo:01 op:0
	.inst 0xd4000001
	.zero 31724
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
	ldr x10, =initial_cap_values
	.inst 0xc2400140 // ldr c0, [x10, #0]
	.inst 0xc2400541 // ldr c1, [x10, #1]
	.inst 0xc2400947 // ldr c7, [x10, #2]
	.inst 0xc2400d48 // ldr c8, [x10, #3]
	.inst 0xc240114e // ldr c14, [x10, #4]
	.inst 0xc240155a // ldr c26, [x10, #5]
	.inst 0xc240195d // ldr c29, [x10, #6]
	/* Set up flags and system registers */
	ldr x10, =0x4000000
	msr SPSR_EL3, x10
	ldr x10, =initial_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288410a // msr CSP_EL0, c10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x8
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x8
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL1_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc28c412a // msr DDC_EL1, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260126a // ldr c10, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
	.inst 0xc28e402a // msr CELR_EL3, c10
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30851035
	msr SCTLR_EL3, x10
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x10, =final_cap_values
	.inst 0xc2400153 // ldr c19, [x10, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc2400553 // ldr c19, [x10, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc2400953 // ldr c19, [x10, #2]
	.inst 0xc2d3a461 // chkeq c3, c19
	b.ne comparison_fail
	.inst 0xc2400d53 // ldr c19, [x10, #3]
	.inst 0xc2d3a4a1 // chkeq c5, c19
	b.ne comparison_fail
	.inst 0xc2401153 // ldr c19, [x10, #4]
	.inst 0xc2d3a4e1 // chkeq c7, c19
	b.ne comparison_fail
	.inst 0xc2401553 // ldr c19, [x10, #5]
	.inst 0xc2d3a501 // chkeq c8, c19
	b.ne comparison_fail
	.inst 0xc2401953 // ldr c19, [x10, #6]
	.inst 0xc2d3a5c1 // chkeq c14, c19
	b.ne comparison_fail
	.inst 0xc2401d53 // ldr c19, [x10, #7]
	.inst 0xc2d3a5e1 // chkeq c15, c19
	b.ne comparison_fail
	.inst 0xc2402153 // ldr c19, [x10, #8]
	.inst 0xc2d3a601 // chkeq c16, c19
	b.ne comparison_fail
	.inst 0xc2402553 // ldr c19, [x10, #9]
	.inst 0xc2d3a641 // chkeq c18, c19
	b.ne comparison_fail
	.inst 0xc2402953 // ldr c19, [x10, #10]
	.inst 0xc2d3a741 // chkeq c26, c19
	b.ne comparison_fail
	.inst 0xc2402d53 // ldr c19, [x10, #11]
	.inst 0xc2d3a7a1 // chkeq c29, c19
	b.ne comparison_fail
	.inst 0xc2403153 // ldr c19, [x10, #12]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984113 // mrs c19, CSP_EL0
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984033 // mrs c19, CELR_EL1
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x19, 0x80
	orr x10, x10, x19
	ldr x19, =0x920000eb
	cmp x19, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001050
	ldr x1, =check_data0
	ldr x2, =0x00001070
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001802
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x40408400
	ldr x1, =check_data5
	ldr x2, =0x40408414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040fff8
	ldr x1, =check_data6
	ldr x2, =0x4040fffc
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00a // cvtp c10, x0
	.inst 0xc2df414a // scvalue c10, c10, x31
	.inst 0xc28b412a // msr DDC_EL3, c10
	ldr x10, =0x30850030
	msr SCTLR_EL3, x10
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
	.zero 96
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 16
	.byte 0xf9, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3936
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data1:
	.byte 0xf8, 0x1f
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 6
.data
check_data4:
	.byte 0xff, 0x7f, 0x9f, 0x48, 0xff, 0x3c, 0xc2, 0x42, 0xb0, 0xf3, 0xc5, 0xc2, 0x03, 0x41, 0x61, 0x78
	.byte 0xba, 0x7f, 0xbe, 0xa2
.data
check_data5:
	.byte 0x1e, 0xf4, 0x81, 0xb8, 0x20, 0x7c, 0x05, 0x88, 0xd0, 0x51, 0x7f, 0x78, 0x72, 0x5b, 0xde, 0x30
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data6:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4040fff8
	/* C1 */
	.octa 0x1ff8
	/* C7 */
	.octa 0x90000000004081000000000000001010
	/* C8 */
	.octa 0xc0000000400100040000000000001080
	/* C14 */
	.octa 0x1ffc
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000807980fffffe80040400000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40410017
	/* C1 */
	.octa 0x1ff8
	/* C3 */
	.octa 0x9ff9
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x90000000004081000000000000001010
	/* C8 */
	.octa 0xc0000000400100040000000000001080
	/* C14 */
	.octa 0x1ffc
	/* C15 */
	.octa 0x101800000000000000000000000
	/* C16 */
	.octa 0x100
	/* C18 */
	.octa 0xfffffffffffbcf78
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000807980fffffe80040400000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000400000040000000000001800
initial_DDC_EL1_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x20008000400080010000000040408000
final_SP_EL0_value:
	.octa 0x40000000400000040000000000001800
final_PCC_value:
	.octa 0x20008000400080010000000040408414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000012b00070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001050
	.dword 0x0000000000001060
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001050
	.dword 0x0000000000001060
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001080
	.dword 0x0000000000001800
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
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x82600e6a // ldr x10, [c19, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400e6a // str x10, [c19, #0]
	ldr x10, =0x40408414
	mrs x19, ELR_EL1
	sub x10, x10, x19
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b153 // cvtp c19, x10
	.inst 0xc2ca4273 // scvalue c19, c19, x10
	.inst 0x8260026a // ldr c10, [c19, #0]
	.inst 0x021e014a // add c10, c10, #1920
	.inst 0xc2c21140 // br c10

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
