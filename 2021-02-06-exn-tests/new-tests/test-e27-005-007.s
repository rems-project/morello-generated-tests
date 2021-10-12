.section text0, #alloc, #execinstr
test_start:
	.inst 0xb89bebde // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:30 Rn:30 10:10 imm9:110111110 0:0 opc:10 111000:111000 size:10
	.inst 0x7820113f // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:9 00:00 opc:001 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x38bfc09e // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:30 Rn:4 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0x78bfc3fd // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:29 Rn:31 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x88a07ccf // cas:aarch64/instrs/memory/atomicops/cas/single Rt:15 Rn:6 11111:11111 o0:0 Rs:0 1:1 L:0 0010001:0010001 size:10
	.inst 0xc2da8421 // CHKSS-_.CC-C 00001:00001 Cn:1 001:001 opc:00 1:1 Cm:26 11000010110:11000010110
	.inst 0xb87f33bf // stset:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:011 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x5ac0131e // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:24 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c5d038 // CVTDZ-C.R-C Cd:24 Rn:1 100:100 opc:10 11000010110001011:11000010110001011
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc24011c9 // ldr c9, [x14, #4]
	.inst 0xc24015cf // ldr c15, [x14, #5]
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	ldr x14, =0x0
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0xc0000
	msr CPACR_EL1, x14
	ldr x14, =0x0
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =0x4
	msr S3_3_C1_C2_2, x14 // CCTLR_EL0
	ldr x14, =initial_DDC_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288412e // msr DDC_EL0, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012ae // ldr c14, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x21, #0xf
	and x14, x14, x21
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d5 // ldr c21, [x14, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24005d5 // ldr c21, [x14, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc24009d5 // ldr c21, [x14, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400dd5 // ldr c21, [x14, #3]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24011d5 // ldr c21, [x14, #4]
	.inst 0xc2d5a521 // chkeq c9, c21
	b.ne comparison_fail
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc24019d5 // ldr c21, [x14, #6]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2401dd5 // ldr c21, [x14, #7]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc24021d5 // ldr c21, [x14, #8]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984115 // mrs c21, CSP_EL0
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001010
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010c4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001113
	ldr x1, =check_data3
	ldr x2, =0x00001114
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001800
	ldr x1, =check_data4
	ldr x2, =0x00001802
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001b40
	ldr x1, =check_data5
	ldr x2, =0x00001b42
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.byte 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
	.byte 0x2b, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 816
	.byte 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1200
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x2b, 0xc0
.data
check_data5:
	.byte 0xc0, 0x00
.data
check_data6:
	.byte 0xde, 0xeb, 0x9b, 0xb8, 0x3f, 0x11, 0x20, 0x78, 0x9e, 0xc0, 0xbf, 0x38, 0xfd, 0xc3, 0xbf, 0x78
	.byte 0xcf, 0x7c, 0xa0, 0x88, 0x21, 0x84, 0xda, 0xc2, 0xbf, 0x33, 0x7f, 0xb8, 0x1e, 0x13, 0xc0, 0x5a
	.byte 0x38, 0xd0, 0xc5, 0xc2, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400
	/* C1 */
	.octa 0x50008000000000000
	/* C4 */
	.octa 0x113
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x800
	/* C15 */
	.octa 0x0
	/* C26 */
	.octa 0x80000000000000000001
	/* C30 */
	.octa 0x52
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400
	/* C1 */
	.octa 0x50008000000000000
	/* C4 */
	.octa 0x113
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x800
	/* C15 */
	.octa 0x0
	/* C24 */
	.octa 0xc0000000088710070008000000001000
	/* C26 */
	.octa 0x80000000000000000001
	/* C29 */
	.octa 0xc0
initial_SP_EL0_value:
	.octa 0xb40
initial_DDC_EL0_value:
	.octa 0xc0000000088710070000000000002000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xb40
final_PCC_value:
	.octa 0x20008000000100070000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword el1_vector_jump_cap
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000010c0
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x82600eae // ldr x14, [c21, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400eae // str x14, [c21, #0]
	ldr x14, =0x40400028
	mrs x21, ELR_EL1
	sub x14, x14, x21
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1d5 // cvtp c21, x14
	.inst 0xc2ce42b5 // scvalue c21, c21, x14
	.inst 0x826002ae // ldr c14, [c21, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0