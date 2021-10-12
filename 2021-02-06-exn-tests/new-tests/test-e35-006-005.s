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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac7 // ldr c7, [x22, #2]
	.inst 0xc2400ec8 // ldr c8, [x22, #3]
	.inst 0xc24012ce // ldr c14, [x22, #4]
	.inst 0xc24016da // ldr c26, [x22, #5]
	.inst 0xc2401add // ldr c29, [x22, #6]
	/* Set up flags and system registers */
	ldr x22, =0x4000000
	msr SPSR_EL3, x22
	ldr x22, =initial_SP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2884116 // msr CSP_EL0, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30d5d99f
	msr SCTLR_EL1, x22
	ldr x22, =0xc0000
	msr CPACR_EL1, x22
	ldr x22, =0x0
	msr S3_0_C1_C2_2, x22 // CCTLR_EL1
	ldr x22, =0x8
	msr S3_3_C1_C2_2, x22 // CCTLR_EL0
	ldr x22, =0x80000000
	msr HCR_EL2, x22
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012f6 // ldr c22, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e4036 // msr CELR_EL3, c22
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30851035
	msr SCTLR_EL3, x22
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d7 // ldr c23, [x22, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc24006d7 // ldr c23, [x22, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400ad7 // ldr c23, [x22, #2]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2400ed7 // ldr c23, [x22, #3]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc24012d7 // ldr c23, [x22, #4]
	.inst 0xc2d7a4e1 // chkeq c7, c23
	b.ne comparison_fail
	.inst 0xc24016d7 // ldr c23, [x22, #5]
	.inst 0xc2d7a501 // chkeq c8, c23
	b.ne comparison_fail
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	.inst 0xc2d7a5c1 // chkeq c14, c23
	b.ne comparison_fail
	.inst 0xc2401ed7 // ldr c23, [x22, #7]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc24022d7 // ldr c23, [x22, #8]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc24026d7 // ldr c23, [x22, #9]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2402ad7 // ldr c23, [x22, #10]
	.inst 0xc2d7a741 // chkeq c26, c23
	b.ne comparison_fail
	.inst 0xc2402ed7 // ldr c23, [x22, #11]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc24032d7 // ldr c23, [x22, #12]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check system registers */
	ldr x22, =final_SP_EL0_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	ldr x22, =final_PCC_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a6c1 // chkeq c22, c23
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x23, 0x80
	orr x22, x22, x23
	ldr x23, =0x920000eb
	cmp x23, x22
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
	ldr x0, =0x00001078
	ldr x1, =check_data1
	ldr x2, =0x0000107c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017e2
	ldr x1, =check_data2
	ldr x2, =0x000017e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c80
	ldr x1, =check_data3
	ldr x2, =0x00001c82
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001d80
	ldr x1, =check_data4
	ldr x2, =0x00001d82
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
	ldr x0, =0x40407bb0
	ldr x1, =check_data7
	ldr x2, =0x40407bb4
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
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr DDC_EL3, c22
	ldr x22, =0x30850030
	msr SCTLR_EL3, x22
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.zero 1984
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2064
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x78, 0x10
.data
check_data4:
	.zero 2
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
	.octa 0x80000000400060020000000040407bb0
	/* C1 */
	.octa 0x40000000000100050000000000001078
	/* C7 */
	.octa 0x90000000000080080000000000000fc0
	/* C8 */
	.octa 0xc0000000000100050000000000001c80
	/* C14 */
	.octa 0xc00000000001000500000000000017e2
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x8000000050040005fffff00000600006
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000400060020000000040407bcf
	/* C1 */
	.octa 0x40000000000100050000000000001078
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x90000000000080080000000000000fc0
	/* C8 */
	.octa 0xc0000000000100050000000000001c80
	/* C14 */
	.octa 0xc00000000001000500000000000017e2
	/* C15 */
	.octa 0x800000000000000000000000
	/* C16 */
	.octa 0x40
	/* C18 */
	.octa 0x200080004200021d00000000403bcf79
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0x8000000050040005fffff00000600006
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000000180060000000000001d80
initial_VBAR_EL1_value:
	.octa 0x200080004200021d0000000040400001
final_SP_EL0_value:
	.octa 0x40000000000180060000000000001d80
final_PCC_value:
	.octa 0x200080004200021d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001d3300070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword initial_SP_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword 0
final_tag_unset_locations:
	.dword 0x00000000000017e0
	.dword 0x0000000000001c80
	.dword 0x0000000000001d80
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
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020002d6 // add c22, c22, #0
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020202d6 // add c22, c22, #128
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020402d6 // add c22, c22, #256
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020602d6 // add c22, c22, #384
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020802d6 // add c22, c22, #512
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020a02d6 // add c22, c22, #640
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020c02d6 // add c22, c22, #768
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x020e02d6 // add c22, c22, #896
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021002d6 // add c22, c22, #1024
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021202d6 // add c22, c22, #1152
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021402d6 // add c22, c22, #1280
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021602d6 // add c22, c22, #1408
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021802d6 // add c22, c22, #1536
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021a02d6 // add c22, c22, #1664
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021c02d6 // add c22, c22, #1792
	.inst 0xc2c212c0 // br c22
	.balign 128
	ldr x22, =esr_el1_dump_address
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x82600ef6 // ldr x22, [c23, #0]
	cbnz x22, #28
	mrs x22, ESR_EL1
	.inst 0x82400ef6 // str x22, [c23, #0]
	ldr x22, =0x40400414
	mrs x23, ELR_EL1
	sub x22, x22, x23
	cbnz x22, #8
	smc 0
	ldr x22, =initial_VBAR_EL1_value
	.inst 0xc2c5b2d7 // cvtp c23, x22
	.inst 0xc2d642f7 // scvalue c23, c23, x22
	.inst 0x826002f6 // ldr c22, [c23, #0]
	.inst 0x021e02d6 // add c22, c22, #1920
	.inst 0xc2c212c0 // br c22

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
