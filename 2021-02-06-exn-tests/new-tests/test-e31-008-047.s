.section text0, #alloc, #execinstr
test_start:
	.inst 0xb88584ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:7 01:01 imm9:001011000 0:0 opc:10 111000:111000 size:10
	.inst 0x5a97e061 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:3 o2:0 0:0 cond:1110 Rm:23 011010100:011010100 op:1 sf:0
	.inst 0xb35c099d // bfm:aarch64/instrs/integer/bitfield Rd:29 Rn:12 imms:000010 immr:011100 N:1 100110:100110 opc:01 sf:1
	.inst 0xc2c25183 // RETR-C-C 00011:00011 Cn:12 100:100 opc:10 11000010110000100:11000010110000100
	.zero 20464
	.inst 0x785af55e // ldrh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:10 01:01 imm9:110101111 0:0 opc:01 111000:111000 size:01
	.zero 37884
	.inst 0xc2c1c01e // CVT-R.CC-C Rd:30 Cn:0 110000:110000 Cm:1 11000010110:11000010110
	.inst 0x225f7c24 // LDXR-C.R-C Ct:4 Rn:1 (1)(1)(1)(1)(1):11111 0:0 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0xa215c3ef // STUR-C.RI-C Ct:15 Rn:31 00:00 imm9:101011100 0:0 opc:00 10100010:10100010
	.inst 0xc2f5981d // SUBS-R.CC-C Rd:29 Cn:0 100110:100110 Cm:21 11000010111:11000010111
	.inst 0xd4000001
	.zero 7148
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400723 // ldr c3, [x25, #1]
	.inst 0xc2400b27 // ldr c7, [x25, #2]
	.inst 0xc2400f2a // ldr c10, [x25, #3]
	.inst 0xc240132c // ldr c12, [x25, #4]
	.inst 0xc240172f // ldr c15, [x25, #5]
	.inst 0xc2401b35 // ldr c21, [x25, #6]
	/* Set up flags and system registers */
	ldr x25, =0x0
	msr SPSR_EL3, x25
	ldr x25, =initial_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4119 // msr CSP_EL1, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30d5d99f
	msr SCTLR_EL1, x25
	ldr x25, =0xc0000
	msr CPACR_EL1, x25
	ldr x25, =0x4
	msr S3_0_C1_C2_2, x25 // CCTLR_EL1
	ldr x25, =0x4
	msr S3_3_C1_C2_2, x25 // CCTLR_EL0
	ldr x25, =initial_DDC_EL0_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2884139 // msr DDC_EL0, c25
	ldr x25, =initial_DDC_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc28c4139 // msr DDC_EL1, c25
	ldr x25, =0x80000000
	msr HCR_EL2, x25
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601319 // ldr c25, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4039 // msr CELR_EL3, c25
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x24, #0xf
	and x25, x25, x24
	cmp x25, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400338 // ldr c24, [x25, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400738 // ldr c24, [x25, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400b38 // ldr c24, [x25, #2]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc2400f38 // ldr c24, [x25, #3]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2401338 // ldr c24, [x25, #4]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2401738 // ldr c24, [x25, #5]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc2401b38 // ldr c24, [x25, #6]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401f38 // ldr c24, [x25, #7]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2402338 // ldr c24, [x25, #8]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc2402738 // ldr c24, [x25, #9]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2402b38 // ldr c24, [x25, #10]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x25, =final_SP_EL1_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc29c4118 // mrs c24, CSP_EL1
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	ldr x25, =final_PCC_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a721 // chkeq c25, c24
	b.ne comparison_fail
	ldr x25, =esr_el1_dump_address
	ldr x25, [x25]
	mov x24, 0xc1
	orr x25, x25, x24
	ldr x24, =0x920000eb
	cmp x24, x25
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
	ldr x0, =0x00001fe0
	ldr x1, =check_data1
	ldr x2, =0x00001ff0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400010
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x40401fc4
	ldr x1, =check_data3
	ldr x2, =0x40401fc8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40405000
	ldr x1, =check_data4
	ldr x2, =0x40405004
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x4040e400
	ldr x1, =check_data5
	ldr x2, =0x4040e414
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
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
	.zero 16
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x02, 0x02, 0x04, 0x20, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data2:
	.byte 0xff, 0x84, 0x85, 0xb8, 0x61, 0xe0, 0x97, 0x5a, 0x9d, 0x09, 0x5c, 0xb3, 0x83, 0x51, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x5e, 0xf5, 0x5a, 0x78
.data
check_data5:
	.byte 0x1e, 0xc0, 0xc1, 0xc2, 0x24, 0x7c, 0x5f, 0x22, 0xef, 0xc3, 0x15, 0xa2, 0x1d, 0x98, 0xf5, 0xc2
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C3 */
	.octa 0xffc
	/* C7 */
	.octa 0x40401fc4
	/* C10 */
	.octa 0x800000000003800f0080600010000000
	/* C12 */
	.octa 0x200000008007400f0000000040405001
	/* C15 */
	.octa 0x4000002004020202020000000000
	/* C21 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffc
	/* C3 */
	.octa 0xffc
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x4040201c
	/* C10 */
	.octa 0x800000000003800f0080600010000000
	/* C12 */
	.octa 0x200000008007400f0000000040405001
	/* C15 */
	.octa 0x4000002004020202020000000000
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL1_value:
	.octa 0x2080
initial_DDC_EL0_value:
	.octa 0x80000000000300020000000000000000
initial_DDC_EL1_value:
	.octa 0xd81000004000000400ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x200080007000e01d000000004040e000
final_SP_EL1_value:
	.octa 0x2080
final_PCC_value:
	.octa 0x200080007000e01d000000004040e414
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
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001fe0
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
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
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02000339 // add c25, c25, #0
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02020339 // add c25, c25, #128
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02040339 // add c25, c25, #256
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02060339 // add c25, c25, #384
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02080339 // add c25, c25, #512
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x020a0339 // add c25, c25, #640
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x020c0339 // add c25, c25, #768
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x020e0339 // add c25, c25, #896
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02100339 // add c25, c25, #1024
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02120339 // add c25, c25, #1152
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02140339 // add c25, c25, #1280
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02160339 // add c25, c25, #1408
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x02180339 // add c25, c25, #1536
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x021a0339 // add c25, c25, #1664
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x021c0339 // add c25, c25, #1792
	.inst 0xc2c21320 // br c25
	.balign 128
	ldr x25, =esr_el1_dump_address
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600f19 // ldr x25, [c24, #0]
	cbnz x25, #28
	mrs x25, ESR_EL1
	.inst 0x82400f19 // str x25, [c24, #0]
	ldr x25, =0x4040e414
	mrs x24, ELR_EL1
	sub x25, x25, x24
	cbnz x25, #8
	smc 0
	ldr x25, =initial_VBAR_EL1_value
	.inst 0xc2c5b338 // cvtp c24, x25
	.inst 0xc2d94318 // scvalue c24, c24, x25
	.inst 0x82600319 // ldr c25, [c24, #0]
	.inst 0x021e0339 // add c25, c25, #1920
	.inst 0xc2c21320 // br c25

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
