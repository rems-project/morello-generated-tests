.section text0, #alloc, #execinstr
test_start:
	.inst 0x489f7fff // stllrh:aarch64/instrs/memory/ordered Rt:31 Rn:31 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x42c23cff // LDP-C.RIB-C Ct:31 Rn:7 Ct2:01111 imm7:0000100 L:1 010000101:010000101
	.inst 0xc2c5f3b0 // CVTPZ-C.R-C Cd:16 Rn:29 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x78614103 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:3 Rn:8 00:00 opc:100 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:01
	.inst 0xa2be7fba // CAS-C.R-C Ct:26 Rn:29 11111:11111 R:0 Cs:30 1:1 L:0 1:1 10100010:10100010
	.zero 17388
	.inst 0xb881f41e // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:0 01:01 imm9:000011111 0:0 opc:10 111000:111000 size:10
	.inst 0x88057c20 // stxr:aarch64/instrs/memory/exclusive/single Rt:0 Rn:1 Rt2:11111 o0:0 Rs:5 0:0 L:0 0010000:0010000 size:10
	.inst 0x787f51d0 // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:16 Rn:14 00:00 opc:101 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:01
	.inst 0x30de5b72 // ADR-C.I-C Rd:18 immhi:101111001011011011 P:1 10000:10000 immlo:01 op:0
	.inst 0xd4000001
	.zero 48108
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
	.inst 0xc2400b87 // ldr c7, [x28, #2]
	.inst 0xc2400f88 // ldr c8, [x28, #3]
	.inst 0xc240138e // ldr c14, [x28, #4]
	.inst 0xc240179a // ldr c26, [x28, #5]
	.inst 0xc2401b9d // ldr c29, [x28, #6]
	/* Set up flags and system registers */
	ldr x28, =0x4000000
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
	ldr x28, =0xc
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x8
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
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
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038a // ldr c10, [x28, #0]
	.inst 0xc2caa401 // chkeq c0, c10
	b.ne comparison_fail
	.inst 0xc240078a // ldr c10, [x28, #1]
	.inst 0xc2caa421 // chkeq c1, c10
	b.ne comparison_fail
	.inst 0xc2400b8a // ldr c10, [x28, #2]
	.inst 0xc2caa461 // chkeq c3, c10
	b.ne comparison_fail
	.inst 0xc2400f8a // ldr c10, [x28, #3]
	.inst 0xc2caa4a1 // chkeq c5, c10
	b.ne comparison_fail
	.inst 0xc240138a // ldr c10, [x28, #4]
	.inst 0xc2caa4e1 // chkeq c7, c10
	b.ne comparison_fail
	.inst 0xc240178a // ldr c10, [x28, #5]
	.inst 0xc2caa501 // chkeq c8, c10
	b.ne comparison_fail
	.inst 0xc2401b8a // ldr c10, [x28, #6]
	.inst 0xc2caa5c1 // chkeq c14, c10
	b.ne comparison_fail
	.inst 0xc2401f8a // ldr c10, [x28, #7]
	.inst 0xc2caa5e1 // chkeq c15, c10
	b.ne comparison_fail
	.inst 0xc240238a // ldr c10, [x28, #8]
	.inst 0xc2caa601 // chkeq c16, c10
	b.ne comparison_fail
	.inst 0xc240278a // ldr c10, [x28, #9]
	.inst 0xc2caa641 // chkeq c18, c10
	b.ne comparison_fail
	.inst 0xc2402b8a // ldr c10, [x28, #10]
	.inst 0xc2caa741 // chkeq c26, c10
	b.ne comparison_fail
	.inst 0xc2402f8a // ldr c10, [x28, #11]
	.inst 0xc2caa7a1 // chkeq c29, c10
	b.ne comparison_fail
	.inst 0xc240338a // ldr c10, [x28, #12]
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
	ldr x28, =esr_el1_dump_address
	ldr x28, [x28]
	mov x10, 0x80
	orr x28, x28, x10
	ldr x10, =0x920000a1
	cmp x10, x28
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
	ldr x0, =0x00001800
	ldr x1, =check_data1
	ldr x2, =0x00001802
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a5c
	ldr x1, =check_data2
	ldr x2, =0x00001a60
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
	ldr x0, =0x40404400
	ldr x1, =check_data4
	ldr x2, =0x40404414
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040fff8
	ldr x1, =check_data5
	ldr x2, =0x4040fffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00
.data
check_data1:
	.byte 0x5c, 0x1a
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0xff, 0x7f, 0x9f, 0x48, 0xff, 0x3c, 0xc2, 0x42, 0xb0, 0xf3, 0xc5, 0xc2, 0x03, 0x41, 0x61, 0x78
	.byte 0xba, 0x7f, 0xbe, 0xa2
.data
check_data4:
	.byte 0x1e, 0xf4, 0x81, 0xb8, 0x20, 0x7c, 0x05, 0x88, 0xd0, 0x51, 0x7f, 0x78, 0x72, 0x5b, 0xde, 0x30
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4040fff8
	/* C1 */
	.octa 0x1a5c
	/* C7 */
	.octa 0x90000000000100050000000000000fc0
	/* C8 */
	.octa 0xc0000000000940050000000000001800
	/* C14 */
	.octa 0x1000
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xcc00000050020004ffffe00840400007
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40410017
	/* C1 */
	.octa 0x1a5c
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x90000000000100050000000000000fc0
	/* C8 */
	.octa 0xc0000000000940050000000000001800
	/* C14 */
	.octa 0x1000
	/* C15 */
	.octa 0x100000000000000000000000000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0xfffffffffffbcf5c
	/* C26 */
	.octa 0x0
	/* C29 */
	.octa 0xcc00000050020004ffffe00840400007
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000000100050000000000001800
initial_DDC_EL1_value:
	.octa 0xc0000000000940050080000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004800401d0000000040404000
final_SP_EL0_value:
	.octa 0x40000000000100050000000000001800
final_PCC_value:
	.octa 0x200080004800401d0000000040404414
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
	.dword 0x0000000000001000
	.dword 0x0000000000001010
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
	.dword 0x0000000000001010
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001800
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
	ldr x28, =0x40404414
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
