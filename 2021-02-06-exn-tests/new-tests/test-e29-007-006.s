.section text0, #alloc, #execinstr
test_start:
	.inst 0x08dffda1 // ldarb:aarch64/instrs/memory/ordered Rt:1 Rn:13 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0x382b62df // stumaxb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:110 o3:0 Rs:11 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa20f941e // STR-C.RIAW-C Ct:30 Rn:0 01:01 imm9:011111001 0:0 opc:00 10100010:10100010
	.inst 0x387d33bf // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:00
	.inst 0xc87f8bea // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:10 Rn:31 Rt2:00010 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.zero 1004
	.inst 0x382172c9 // lduminb:aarch64/instrs/memory/atomicops/ld Rt:9 Rn:22 00:00 opc:111 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x3a1e0341 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:26 000000:000000 Rm:30 11010000:11010000 S:1 op:0 sf:0
	.inst 0x629d6be2 // STP-C.RIBW-C Ct:2 Rn:31 Ct2:11010 imm7:0111010 L:0 011000101:011000101
	.inst 0xb811ad5c // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:28 Rn:10 11:11 imm9:100011010 0:0 opc:00 111000:111000 size:10
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009ea // ldr c10, [x15, #2]
	.inst 0xc2400deb // ldr c11, [x15, #3]
	.inst 0xc24011ed // ldr c13, [x15, #4]
	.inst 0xc24015f6 // ldr c22, [x15, #5]
	.inst 0xc24019fa // ldr c26, [x15, #6]
	.inst 0xc2401dfc // ldr c28, [x15, #7]
	.inst 0xc24021fd // ldr c29, [x15, #8]
	.inst 0xc24025fe // ldr c30, [x15, #9]
	/* Set up flags and system registers */
	ldr x15, =0x4000000
	msr SPSR_EL3, x15
	ldr x15, =initial_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc288410f // msr CSP_EL0, c15
	ldr x15, =initial_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c410f // msr CSP_EL1, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30d5d99f
	msr SCTLR_EL1, x15
	ldr x15, =0xc0000
	msr CPACR_EL1, x15
	ldr x15, =0x0
	msr S3_0_C1_C2_2, x15 // CCTLR_EL1
	ldr x15, =initial_DDC_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc28c412f // msr DDC_EL1, c15
	ldr x15, =0x80000000
	msr HCR_EL2, x15
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826011cf // ldr c15, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
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
	mov x14, #0xb
	and x15, x15, x14
	cmp x15, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001ee // ldr c14, [x15, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24005ee // ldr c14, [x15, #1]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc24009ee // ldr c14, [x15, #2]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc2400dee // ldr c14, [x15, #3]
	.inst 0xc2cea541 // chkeq c10, c14
	b.ne comparison_fail
	.inst 0xc24011ee // ldr c14, [x15, #4]
	.inst 0xc2cea561 // chkeq c11, c14
	b.ne comparison_fail
	.inst 0xc24015ee // ldr c14, [x15, #5]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc24019ee // ldr c14, [x15, #6]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2401dee // ldr c14, [x15, #7]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc24021ee // ldr c14, [x15, #8]
	.inst 0xc2cea781 // chkeq c28, c14
	b.ne comparison_fail
	.inst 0xc24025ee // ldr c14, [x15, #9]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc24029ee // ldr c14, [x15, #10]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check system registers */
	ldr x15, =final_SP_EL0_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298410e // mrs c14, CSP_EL0
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	ldr x15, =final_SP_EL1_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc29c410e // mrs c14, CSP_EL1
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	ldr x15, =final_PCC_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc298402e // mrs c14, CELR_EL1
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	ldr x15, =esr_el1_dump_address
	ldr x15, [x15]
	mov x14, 0x80
	orr x15, x15, x14
	ldr x14, =0x920000a8
	cmp x14, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000015c0
	ldr x1, =check_data1
	ldr x2, =0x000015e0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f1c
	ldr x1, =check_data2
	ldr x2, =0x00001f20
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
	ldr x0, =0x40400400
	ldr x1, =check_data4
	ldr x2, =0x40400414
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
	.byte 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x0a, 0x04, 0x00, 0x00, 0x0a, 0x40, 0x10, 0x00
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x02, 0x00
.data
check_data3:
	.byte 0xa1, 0xfd, 0xdf, 0x08, 0xdf, 0x62, 0x2b, 0x38, 0x1e, 0x94, 0x0f, 0xa2, 0xbf, 0x33, 0x7d, 0x38
	.byte 0xea, 0x8b, 0x7f, 0xc8
.data
check_data4:
	.byte 0xc9, 0x72, 0x21, 0x38, 0x41, 0x03, 0x1e, 0x3a, 0xe2, 0x6b, 0x9d, 0x62, 0x5c, 0xad, 0x11, 0xb8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x48000000000d00070000000000001000
	/* C2 */
	.octa 0x4000000000000000000000000000
	/* C10 */
	.octa 0x2002
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000d00070000000000001000
	/* C22 */
	.octa 0xc0000000400200030000000000001000
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x20000
	/* C29 */
	.octa 0xc0000000000700070000000000001000
	/* C30 */
	.octa 0x10400a0000040a0000100000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x48000000000d00070000000000001f90
	/* C2 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x0
	/* C10 */
	.octa 0x1f1c
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000d00070000000000001000
	/* C22 */
	.octa 0xc0000000400200030000000000001000
	/* C26 */
	.octa 0x4000000000000000000000000000
	/* C28 */
	.octa 0x20000
	/* C29 */
	.octa 0xc0000000000700070000000000001000
	/* C30 */
	.octa 0x10400a0000040a0000100000000000
initial_SP_EL0_value:
	.octa 0x2000000000010
initial_SP_EL1_value:
	.octa 0x1220
initial_DDC_EL1_value:
	.octa 0xc8000000000180060080000000000000
initial_VBAR_EL1_value:
	.octa 0x200080004000001d0000000040400000
final_SP_EL0_value:
	.octa 0x2000000000010
final_SP_EL1_value:
	.octa 0x15c0
final_PCC_value:
	.octa 0x200080004000001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword initial_cap_values + 128
	.dword initial_cap_values + 144
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x00000000000015c0
	.dword 0x00000000000015d0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x0000000000001f10
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
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020001ef // add c15, c15, #0
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020201ef // add c15, c15, #128
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020401ef // add c15, c15, #256
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020601ef // add c15, c15, #384
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020801ef // add c15, c15, #512
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020a01ef // add c15, c15, #640
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020c01ef // add c15, c15, #768
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x020e01ef // add c15, c15, #896
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021001ef // add c15, c15, #1024
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021201ef // add c15, c15, #1152
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021401ef // add c15, c15, #1280
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021601ef // add c15, c15, #1408
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021801ef // add c15, c15, #1536
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021a01ef // add c15, c15, #1664
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
	.inst 0x021c01ef // add c15, c15, #1792
	.inst 0xc2c211e0 // br c15
	.balign 128
	ldr x15, =esr_el1_dump_address
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x82600dcf // ldr x15, [c14, #0]
	cbnz x15, #28
	mrs x15, ESR_EL1
	.inst 0x82400dcf // str x15, [c14, #0]
	ldr x15, =0x40400414
	mrs x14, ELR_EL1
	sub x15, x15, x14
	cbnz x15, #8
	smc 0
	ldr x15, =initial_VBAR_EL1_value
	.inst 0xc2c5b1ee // cvtp c14, x15
	.inst 0xc2cf41ce // scvalue c14, c14, x15
	.inst 0x826001cf // ldr c15, [c14, #0]
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
