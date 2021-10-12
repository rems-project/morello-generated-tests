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
	ldr x16, =initial_cap_values
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2400e07 // ldr c7, [x16, #3]
	.inst 0xc240120b // ldr c11, [x16, #4]
	.inst 0xc2401619 // ldr c25, [x16, #5]
	.inst 0xc2401a1c // ldr c28, [x16, #6]
	/* Set up flags and system registers */
	ldr x16, =0x0
	msr SPSR_EL3, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0xc0000
	msr CPACR_EL1, x16
	ldr x16, =0x0
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =0xc
	msr S3_3_C1_C2_2, x16 // CCTLR_EL0
	ldr x16, =initial_DDC_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884130 // msr DDC_EL0, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601110 // ldr c16, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400208 // ldr c8, [x16, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400608 // ldr c8, [x16, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400a08 // ldr c8, [x16, #2]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2401208 // ldr c8, [x16, #4]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401608 // ldr c8, [x16, #5]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc2401a08 // ldr c8, [x16, #6]
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	.inst 0xc2401e08 // ldr c8, [x16, #7]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2402208 // ldr c8, [x16, #8]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2402608 // ldr c8, [x16, #9]
	.inst 0xc2c8a741 // chkeq c26, c8
	b.ne comparison_fail
	.inst 0xc2402a08 // ldr c8, [x16, #10]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc2402e08 // ldr c8, [x16, #11]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a601 // chkeq c16, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001024
	ldr x1, =check_data0
	ldr x2, =0x00001026
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000103e
	ldr x1, =check_data1
	ldr x2, =0x0000103f
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ffc
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
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.zero 1
.data
check_data2:
	.zero 12
.data
check_data3:
	.byte 0x25, 0xf4, 0xc7, 0x78, 0x09, 0x50, 0xc0, 0xc2, 0xfd, 0x00, 0x3c, 0x78, 0x3a, 0xff, 0x7f, 0x42
	.byte 0x31, 0xb1, 0xc5, 0xc2, 0xdd, 0xe8, 0x7f, 0x88, 0x01, 0x08, 0xc0, 0xda, 0x2b, 0xf8, 0x02, 0x38
	.byte 0x21, 0x53, 0x78, 0xd2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xf100000
	/* C1 */
	.octa 0x1ff4
	/* C6 */
	.octa 0x1ff0
	/* C7 */
	.octa 0x1024
	/* C11 */
	.octa 0x0
	/* C25 */
	.octa 0x80000000000300070000000000001ff8
	/* C28 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xf100000
	/* C1 */
	.octa 0x1fffe0f8
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x1ff0
	/* C7 */
	.octa 0x1024
	/* C9 */
	.octa 0xf100000
	/* C11 */
	.octa 0x0
	/* C17 */
	.octa 0x2000800000004008000000000f100000
	/* C25 */
	.octa 0x80000000000300070000000000001ff8
	/* C26 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0xc00000000006000600ffffffffc00001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000040080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000040400000
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
	.dword 0x0000000000001020
	.dword 0x0000000000001030
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600d10 // ldr x16, [c8, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400d10 // str x16, [c8, #0]
	ldr x16, =0x40400028
	mrs x8, ELR_EL1
	sub x16, x16, x8
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b208 // cvtp c8, x16
	.inst 0xc2d04108 // scvalue c8, c8, x16
	.inst 0x82600110 // ldr c16, [c8, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
