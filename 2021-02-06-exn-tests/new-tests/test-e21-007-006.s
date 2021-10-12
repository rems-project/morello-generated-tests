.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc1c0 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:0 Rn:14 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x5ac00bfb // rev:aarch64/instrs/integer/arithmetic/rev Rd:27 Rn:31 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2cdf820 // SCBNDS-C.CI-S Cd:0 Cn:1 1110:1110 S:1 imm6:011011 11000010110:11000010110
	.inst 0x387763ff // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:110 o3:0 Rs:23 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xb805791f // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:31 Rn:8 10:10 imm9:001010111 0:0 opc:00 111000:111000 size:10
	.zero 21484
	.inst 0xc2d7a97d // EORFLGS-C.CR-C Cd:29 Cn:11 1010:1010 opc:10 Rm:23 11000010110:11000010110
	.inst 0x7847843e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:1 01:01 imm9:001111000 0:0 opc:01 111000:111000 size:01
	.inst 0xf83e503f // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:1 00:00 opc:101 0:0 Rs:30 1:1 R:0 A:0 111000:111000 size:11
	.inst 0xa20b4bbd // STTR-C.RIB-C Ct:29 Rn:29 10:10 imm9:010110100 0:0 opc:00 10100010:10100010
	.inst 0xd4000001
	.zero 44012
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
	.inst 0xc2400141 // ldr c1, [x10, #0]
	.inst 0xc2400548 // ldr c8, [x10, #1]
	.inst 0xc240094b // ldr c11, [x10, #2]
	.inst 0xc2400d4e // ldr c14, [x10, #3]
	.inst 0xc2401157 // ldr c23, [x10, #4]
	/* Set up flags and system registers */
	ldr x10, =0x0
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
	ldr x10, =0x0
	msr S3_0_C1_C2_2, x10 // CCTLR_EL1
	ldr x10, =0x0
	msr S3_3_C1_C2_2, x10 // CCTLR_EL0
	ldr x10, =initial_DDC_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc288412a // msr DDC_EL0, c10
	ldr x10, =0x80000000
	msr HCR_EL2, x10
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012aa // ldr c10, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
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
	.inst 0xc2400155 // ldr c21, [x10, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400555 // ldr c21, [x10, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400955 // ldr c21, [x10, #2]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2400d55 // ldr c21, [x10, #3]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401155 // ldr c21, [x10, #4]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401555 // ldr c21, [x10, #5]
	.inst 0xc2d5a6e1 // chkeq c23, c21
	b.ne comparison_fail
	.inst 0xc2401955 // ldr c21, [x10, #6]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2401d55 // ldr c21, [x10, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402155 // ldr c21, [x10, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x10, =final_SP_EL0_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984115 // mrs c21, CSP_EL0
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	ldr x10, =final_PCC_value
	.inst 0xc240014a // ldr c10, [x10, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	ldr x10, =esr_el1_dump_address
	ldr x10, [x10]
	mov x21, 0x80
	orr x10, x10, x21
	ldr x21, =0x920000e1
	cmp x21, x10
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001008
	ldr x1, =check_data1
	ldr x2, =0x0000100a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001080
	ldr x1, =check_data2
	ldr x2, =0x00001088
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001b40
	ldr x1, =check_data3
	ldr x2, =0x00001b50
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
	ldr x0, =0x40405400
	ldr x1, =check_data5
	ldr x2, =0x40405414
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
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0x01
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x05, 0x00, 0x00, 0x40, 0x00, 0x48
.data
check_data4:
	.byte 0xc0, 0xc1, 0xbf, 0x38, 0xfb, 0x0b, 0xc0, 0x5a, 0x20, 0xf8, 0xcd, 0xc2, 0xff, 0x63, 0x77, 0x38
	.byte 0x1f, 0x79, 0x05, 0xb8
.data
check_data5:
	.byte 0x7d, 0xa9, 0xd7, 0xc2, 0x3e, 0x84, 0x47, 0x78, 0x3f, 0x50, 0x3e, 0xf8, 0xbd, 0x4b, 0x0b, 0xa2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001008
	/* C8 */
	.octa 0x3ffffffffffaa
	/* C11 */
	.octa 0x48004000000500070000000000001000
	/* C14 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc000000051b810080000000000001008
	/* C1 */
	.octa 0xc0000000000100050000000000001080
	/* C8 */
	.octa 0x3ffffffffffaa
	/* C11 */
	.octa 0x48004000000500070000000000001000
	/* C14 */
	.octa 0x1000
	/* C23 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x48004000000500070000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc0000000000080080000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000441e0000000040405001
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004000441e0000000040405414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001b40
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001080
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
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0200014a // add c10, c10, #0
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0202014a // add c10, c10, #128
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0204014a // add c10, c10, #256
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0206014a // add c10, c10, #384
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0208014a // add c10, c10, #512
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x020a014a // add c10, c10, #640
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x020c014a // add c10, c10, #768
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x020e014a // add c10, c10, #896
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0210014a // add c10, c10, #1024
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0212014a // add c10, c10, #1152
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0214014a // add c10, c10, #1280
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0216014a // add c10, c10, #1408
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x0218014a // add c10, c10, #1536
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x021a014a // add c10, c10, #1664
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
	.inst 0x021c014a // add c10, c10, #1792
	.inst 0xc2c21140 // br c10
	.balign 128
	ldr x10, =esr_el1_dump_address
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x82600eaa // ldr x10, [c21, #0]
	cbnz x10, #28
	mrs x10, ESR_EL1
	.inst 0x82400eaa // str x10, [c21, #0]
	ldr x10, =0x40405414
	mrs x21, ELR_EL1
	sub x10, x10, x21
	cbnz x10, #8
	smc 0
	ldr x10, =initial_VBAR_EL1_value
	.inst 0xc2c5b155 // cvtp c21, x10
	.inst 0xc2ca42b5 // scvalue c21, c21, x10
	.inst 0x826002aa // ldr c10, [c21, #0]
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
