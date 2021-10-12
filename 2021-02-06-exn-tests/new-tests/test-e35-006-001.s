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
	ldr x9, =initial_cap_values
	.inst 0xc2400120 // ldr c0, [x9, #0]
	.inst 0xc2400521 // ldr c1, [x9, #1]
	.inst 0xc2400927 // ldr c7, [x9, #2]
	.inst 0xc2400d28 // ldr c8, [x9, #3]
	.inst 0xc240112e // ldr c14, [x9, #4]
	.inst 0xc240153d // ldr c29, [x9, #5]
	/* Set up flags and system registers */
	ldr x9, =0x4000000
	msr SPSR_EL3, x9
	ldr x9, =initial_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2884109 // msr CSP_EL0, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x30d5d99f
	msr SCTLR_EL1, x9
	ldr x9, =0xc0000
	msr CPACR_EL1, x9
	ldr x9, =0x8
	msr S3_0_C1_C2_2, x9 // CCTLR_EL1
	ldr x9, =0x8
	msr S3_3_C1_C2_2, x9 // CCTLR_EL0
	ldr x9, =initial_DDC_EL1_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc28c4129 // msr DDC_EL1, c9
	ldr x9, =0x80000000
	msr HCR_EL2, x9
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601309 // ldr c9, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4029 // msr CELR_EL3, c9
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30851035
	msr SCTLR_EL3, x9
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400138 // ldr c24, [x9, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400538 // ldr c24, [x9, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400938 // ldr c24, [x9, #2]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400d38 // ldr c24, [x9, #3]
	.inst 0xc2d8a4a1 // chkeq c5, c24
	b.ne comparison_fail
	.inst 0xc2401138 // ldr c24, [x9, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401538 // ldr c24, [x9, #5]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc2401938 // ldr c24, [x9, #6]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc2401d38 // ldr c24, [x9, #7]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2402138 // ldr c24, [x9, #8]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc2402538 // ldr c24, [x9, #9]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2402938 // ldr c24, [x9, #10]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402d38 // ldr c24, [x9, #11]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x9, =final_SP_EL0_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	ldr x9, =final_PCC_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	ldr x9, =esr_el1_dump_address
	ldr x9, [x9]
	mov x24, 0x80
	orr x9, x9, x24
	ldr x24, =0x920000a8
	cmp x24, x9
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
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001060
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001202
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000017e8
	ldr x1, =check_data3
	ldr x2, =0x000017ea
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff8
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
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
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	ldr x9, =0x30850030
	msr SCTLR_EL3, x9
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
	.zero 416
	.byte 0xfa, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3568
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xf8, 0x1f
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
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1ff8
	/* C1 */
	.octa 0x1ff8
	/* C7 */
	.octa 0x90000000400400140000000000001000
	/* C8 */
	.octa 0xc0000000400100020000000000001200
	/* C14 */
	.octa 0x17e8
	/* C29 */
	.octa 0x80000040400000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x2017
	/* C1 */
	.octa 0x1ff8
	/* C3 */
	.octa 0xfa
	/* C5 */
	.octa 0x1
	/* C7 */
	.octa 0x90000000400400140000000000001000
	/* C8 */
	.octa 0xc0000000400100020000000000001200
	/* C14 */
	.octa 0x17e8
	/* C15 */
	.octa 0x1800000000000000000000000
	/* C16 */
	.octa 0x0
	/* C18 */
	.octa 0xfffffffffffbcedc
	/* C29 */
	.octa 0x80000040400000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x40000000040100050000000000001000
initial_DDC_EL1_value:
	.octa 0xc00000004004008a0000000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004480009d0000000040400000
final_SP_EL0_value:
	.octa 0x40000000040100050000000000001000
final_PCC_value:
	.octa 0x200080004480009d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000200070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001040
	.dword 0x0000000000001050
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001200
	.dword 0x00000000000017e0
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
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02000129 // add c9, c9, #0
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02020129 // add c9, c9, #128
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02040129 // add c9, c9, #256
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02060129 // add c9, c9, #384
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02080129 // add c9, c9, #512
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x020a0129 // add c9, c9, #640
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x020c0129 // add c9, c9, #768
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x020e0129 // add c9, c9, #896
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02100129 // add c9, c9, #1024
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02120129 // add c9, c9, #1152
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02140129 // add c9, c9, #1280
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02160129 // add c9, c9, #1408
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x02180129 // add c9, c9, #1536
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x021a0129 // add c9, c9, #1664
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x021c0129 // add c9, c9, #1792
	.inst 0xc2c21120 // br c9
	.balign 128
	ldr x9, =esr_el1_dump_address
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600f09 // ldr x9, [c24, #0]
	cbnz x9, #28
	mrs x9, ESR_EL1
	.inst 0x82400f09 // str x9, [c24, #0]
	ldr x9, =0x40400414
	mrs x24, ELR_EL1
	sub x9, x9, x24
	cbnz x9, #8
	smc 0
	ldr x9, =initial_VBAR_EL1_value
	.inst 0xc2c5b138 // cvtp c24, x9
	.inst 0xc2c94318 // scvalue c24, c24, x9
	.inst 0x82600309 // ldr c9, [c24, #0]
	.inst 0x021e0129 // add c9, c9, #1920
	.inst 0xc2c21120 // br c9

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
