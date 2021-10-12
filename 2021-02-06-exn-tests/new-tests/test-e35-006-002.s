.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7fff // stllrh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x42c23cff // LDP-C.RIB-C Ct:31 Rn:7 Ct2:01111 imm7:0000100 L:1 010000101:010000101
	.inst 0xc2c5f3b0 // CVTPZ-C.R-C Cd:16 Rn:29 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x78614103 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:8 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xa2be7fba // CAS-C.R-C Ct:26 Rn:29 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.zero 1004
	.inst 0xb881f41e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:0 01:01 imm9:000011111 0:0 opc:10 111000:111000 size:10
	.inst 0x88057c20 // stxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:1 Rt2:11111 o0:0 Rs:5 0:0 L:0 0010000:0010000 size:10
	.inst 0x787f51d0 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:14 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x30de5b72 // ADR-C.I-C Rd:18 immhi:101111001011011011 P:1 10000:10000 immlo:01 op:0
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc2400987 // ldr c7, [x12, #2]
	.inst 0xc2400d88 // ldr c8, [x12, #3]
	.inst 0xc240118e // ldr c14, [x12, #4]
	.inst 0xc240159d // ldr c29, [x12, #5]
	/* Set up flags and system registers */
	ldr x12, =0x4000000
	msr SPSR_EL3, x12
	ldr x12, =initial_SP_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc288410c // msr CSP_EL0, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30d5d99f
	msr SCTLR_EL1, x12
	ldr x12, =0xc0000
	msr CPACR_EL1, x12
	ldr x12, =0x0
	msr S3_0_C1_C2_2, x12 // CCTLR_EL1
	ldr x12, =0x8
	msr S3_3_C1_C2_2, x12 // CCTLR_EL0
	ldr x12, =0x80000000
	msr HCR_EL2, x12
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012cc // ldr c12, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e402c // msr CELR_EL3, c12
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400196 // ldr c22, [x12, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400596 // ldr c22, [x12, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400996 // ldr c22, [x12, #2]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400d96 // ldr c22, [x12, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2401196 // ldr c22, [x12, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401596 // ldr c22, [x12, #5]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401996 // ldr c22, [x12, #6]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2401d96 // ldr c22, [x12, #7]
	.inst 0xc2d6a5e1 // chkeq c15, c22
	b.ne comparison_fail
	.inst 0xc2402196 // ldr c22, [x12, #8]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc2402596 // ldr c22, [x12, #9]
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	.inst 0xc2402996 // ldr c22, [x12, #10]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402d96 // ldr c22, [x12, #11]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x12, =final_SP_EL0_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	ldr x12, =final_PCC_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a581 // chkeq c12, c22
	b.ne comparison_fail
	ldr x12, =esr_el1_dump_address
	ldr x12, [x12]
	mov x22, 0x80
	orr x12, x12, x22
	ldr x22, =0x920000a9
	cmp x22, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001060
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
	ldr x0, =0x00001820
	ldr x1, =check_data2
	ldr x2, =0x00001822
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001832
	ldr x1, =check_data3
	ldr x2, =0x00001834
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ef8
	ldr x1, =check_data4
	ldr x2, =0x00001efc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400400
	ldr x1, =check_data6
	ldr x2, =0x40400414
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x4040fff8
	ldr x1, =check_data7
	ldr x2, =0x4040fffc
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
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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
	.zero 80
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
	.zero 32
	.byte 0xf9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1952
	.byte 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1984
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x01, 0x00, 0x00
.data
check_data1:
	.byte 0xf8, 0x1e
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xff, 0x7f, 0x9f, 0x48, 0xff, 0x3c, 0xc2, 0x42, 0xb0, 0xf3, 0xc5, 0xc2, 0x03, 0x41, 0x61, 0x78
	.byte 0xba, 0x7f, 0xbe, 0xa2
.data
check_data6:
	.byte 0x1e, 0xf4, 0x81, 0xb8, 0x20, 0x7c, 0x05, 0x88, 0xd0, 0x51, 0x7f, 0x78, 0x72, 0x5b, 0xde, 0x30
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8000000000010005000000004040fff8
	/* C1 */
	.octa 0x40000000000100050000000000001ef8
	/* C7 */
	.octa 0x90000000400000040000000000001000
	/* C8 */
	.octa 0xc0000000000100050000000000001080
	/* C14 */
	.octa 0xc0000000000100050000000000001832
	/* C29 */
	.octa 0x8000000000ffe40040400000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000040410017
	/* C1 */
	.octa 0x40000000000100050000000000001ef8
	/* C3 */
	.octa 0xf9
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x90000000400000040000000000001000
	/* C8 */
	.octa 0xc0000000000100050000000000001080
	/* C14 */
	.octa 0xc0000000000100050000000000001832
	/* C15 */
	.octa 0x100800000000000000000000000
	/* C16 */
	.octa 0x8
	/* C18 */
	.octa 0x200080004414d01d00000000403bcf79
	/* C29 */
	.octa 0x8000000000ffe40040400000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x400000000006000f0000000000001820
initial_VBAR_EL1_value:
	.octa 0x200080004414d01d0000000040400001
final_SP_EL0_value:
	.octa 0x400000000006000f0000000000001820
final_PCC_value:
	.octa 0x200080004414d01d0000000040400414
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
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword initial_SP_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001080
	.dword 0x0000000000001820
	.dword 0x0000000000001830
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
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0200018c // add c12, c12, #0
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0202018c // add c12, c12, #128
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0204018c // add c12, c12, #256
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0206018c // add c12, c12, #384
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0208018c // add c12, c12, #512
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020a018c // add c12, c12, #640
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020c018c // add c12, c12, #768
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x020e018c // add c12, c12, #896
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0210018c // add c12, c12, #1024
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0212018c // add c12, c12, #1152
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0214018c // add c12, c12, #1280
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0216018c // add c12, c12, #1408
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x0218018c // add c12, c12, #1536
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021a018c // add c12, c12, #1664
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021c018c // add c12, c12, #1792
	.inst 0xc2c21180 // br c12
	.balign 128
	ldr x12, =esr_el1_dump_address
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x82600ecc // ldr x12, [c22, #0]
	cbnz x12, #28
	mrs x12, ESR_EL1
	.inst 0x82400ecc // str x12, [c22, #0]
	ldr x12, =0x40400414
	mrs x22, ELR_EL1
	sub x12, x12, x22
	cbnz x12, #8
	smc 0
	ldr x12, =initial_VBAR_EL1_value
	.inst 0xc2c5b196 // cvtp c22, x12
	.inst 0xc2cc42d6 // scvalue c22, c22, x12
	.inst 0x826002cc // ldr c12, [c22, #0]
	.inst 0x021e018c // add c12, c12, #1920
	.inst 0xc2c21180 // br c12

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
