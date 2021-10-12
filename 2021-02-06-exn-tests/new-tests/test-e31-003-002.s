.section text0, #alloc, #execinstr
test_start:
	.inst 0x78c7f425 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:1 01:01 imm9:001111111 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c05009 // GCVALUE-R.C-C Rd:9 Cn:0 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x783c00fd // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:7 00:00 opc:000 0:0 Rs:28 1:1 R:0 A:0 111000:111000 size:01
	.inst 0x427fff3a // ALDAR-R.R-32 Rt:26 Rn:25 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xc2c5b131 // CVTP-C.R-C Cd:17 Rn:9 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x887fe8dd // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:29 Rn:6 Rt2:11010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0xdac00801 // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:1 Rn:0 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x3802f82b // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:11 Rn:1 10:10 imm9:000101111 0:0 opc:00 111000:111000 size:00
	.inst 0xd2785321 // eor_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:25 imms:010100 immr:111000 N:1 100100:100100 opc:10 sf:1
	.inst 0xd4000001
	.zero 65496
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
	.inst 0xc2400946 // ldr c6, [x10, #2]
	.inst 0xc2400d47 // ldr c7, [x10, #3]
	.inst 0xc240114b // ldr c11, [x10, #4]
	.inst 0xc2401559 // ldr c25, [x10, #5]
	.inst 0xc240195c // ldr c28, [x10, #6]
	/* Set up flags and system registers */
	ldr x10, =0x0
	msr SPSR_EL3, x10
	ldr x10, =0x200
	msr CPTR_EL3, x10
	ldr x10, =0x30d5d99f
	msr SCTLR_EL1, x10
	ldr x10, =0xc0000
	msr CPACR_EL1, x10
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x4
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012ca // ldr c10, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	.inst 0xc2400156 // ldr c22, [x10, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400556 // ldr c22, [x10, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400956 // ldr c22, [x10, #2]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc2400d56 // ldr c22, [x10, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc2401156 // ldr c22, [x10, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401556 // ldr c22, [x10, #5]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc2401956 // ldr c22, [x10, #6]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc2401d56 // ldr c22, [x10, #7]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2402156 // ldr c22, [x10, #8]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc2402556 // ldr c22, [x10, #9]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402956 // ldr c22, [x10, #10]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc2402d56 // ldr c22, [x10, #11]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a541 // chkeq c10, c22
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
	ldr x0, =0x0000100f
	ldr x1, =check_data1
	ldr x2, =0x00001012
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010d8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40400000
	ldr x1, =check_data3
	ldr x2, =0x40400028
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x4040fff8
	ldr x1, =check_data4
	ldr x2, =0x4040fffc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 3
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x25, 0xf4, 0xc7, 0x78, 0x09, 0x50, 0xc0, 0xc2, 0xfd, 0x00, 0x3c, 0x78, 0x3a, 0xff, 0x7f, 0x42
	.byte 0x31, 0xb1, 0xc5, 0xc2, 0xdd, 0xe8, 0x7f, 0x88, 0x01, 0x08, 0xc0, 0xda, 0x2b, 0xf8, 0x02, 0x38
	.byte 0x21, 0x53, 0x78, 0xd2, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffe0ffffff
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0xd0
	/* C7 */
	.octa 0x10
	/* C11 */
	.octa 0x0
	/* C25 */
	.octa 0x8000000000010005000000004040fff8
	/* C28 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xffffffffe0ffffff
	/* C1 */
	.octa 0x5fbf00f8
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0xd0
	/* C7 */
	.octa 0x10
	/* C9 */
	.octa 0xffffffffe0ffffff
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x2000800000000000ffffffffe0ffffff
	/* C25 */
	.octa 0x8000000000010005000000004040fff8
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc00000000407040500ffffffffff8001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000000000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001010
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
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x82600eca // ldr x10, [c22, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eca // str x10, [c22, #0]
	ldr x10, =0x40400028
	mrs x22, ELR_EL1
	sub x10, x10, x22
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b156 // cvtp c22, x10
	.inst 0xc2ca42d6 // scvalue c22, c22, x10
	.inst 0x826002ca // ldr c10, [c22, #0]
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
