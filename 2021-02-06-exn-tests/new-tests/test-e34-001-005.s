.section text0, #alloc, #execinstr
test_start:
	.inst 0xfc54dcfd // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:29 Rn:7 11:11 imm9:101001101 0:0 opc:01 111100:111100 size:11
	.inst 0xd65f03a0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 56
	.inst 0x79a060bd // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:29 Rn:5 imm12:100000011000 opc:10 111001:111001 size:01
	.inst 0xc2c1a5a1 // CHKEQ-_.CC-C 00001:00001 Cn:13 001:001 opc:01 1:1 Cm:1 11000010110:11000010110
	.inst 0xe28a93c4 // ASTUR-R.RI-32 Rt:4 Rn:30 op2:00 imm9:010101001 V:0 op1:10 11100010:11100010
	.zero 948
	.inst 0xf8a013e2 // ldclr:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:31 00:00 opc:001 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:11
	.inst 0xa2e07fbb // CASA-C.R-C Ct:27 Rn:29 11111:11111 R:0 Cs:0 1:1 L:1 1:1 10100010:10100010
	.inst 0x82678821 // ALDR-R.RI-32 Rt:1 Rn:1 op:10 imm9:001111000 L:1 1000001001:1000001001
	.inst 0xc87f5461 // ldxp:aarch64/instrs/memory/exclusive/pair Rt:1 Rn:3 Rt2:10101 o0:0 Rs:11111 1:1 L:1 0010000:0010000 sz:1 1:1
	.inst 0xd4000001
	.zero 3100
	.inst 0x00001480
	.zero 61388
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400963 // ldr c3, [x11, #2]
	.inst 0xc2400d65 // ldr c5, [x11, #3]
	.inst 0xc2401167 // ldr c7, [x11, #4]
	.inst 0xc240156d // ldr c13, [x11, #5]
	.inst 0xc240197b // ldr c27, [x11, #6]
	.inst 0xc2401d7d // ldr c29, [x11, #7]
	.inst 0xc240217e // ldr c30, [x11, #8]
	/* Set up flags and system registers */
	ldr x11, =0x4000000
	msr SPSR_EL3, x11
	ldr x11, =initial_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c410b // msr CSP_EL1, c11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30d5d99f
	msr SCTLR_EL1, x11
	ldr x11, =0x3c0000
	msr CPACR_EL1, x11
	ldr x11, =0x4
	msr S3_0_C1_C2_2, x11 // CCTLR_EL1
	ldr x11, =0x4
	msr S3_3_C1_C2_2, x11 // CCTLR_EL0
	ldr x11, =initial_DDC_EL0_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc288412b // msr DDC_EL0, c11
	ldr x11, =initial_DDC_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc28c412b // msr DDC_EL1, c11
	ldr x11, =0x80000000
	msr HCR_EL2, x11
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260110b // ldr c11, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e402b // msr CELR_EL3, c11
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x8, #0xf
	and x11, x11, x8
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400168 // ldr c8, [x11, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400568 // ldr c8, [x11, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400968 // ldr c8, [x11, #2]
	.inst 0xc2c8a441 // chkeq c2, c8
	b.ne comparison_fail
	.inst 0xc2400d68 // ldr c8, [x11, #3]
	.inst 0xc2c8a461 // chkeq c3, c8
	b.ne comparison_fail
	.inst 0xc2401168 // ldr c8, [x11, #4]
	.inst 0xc2c8a4a1 // chkeq c5, c8
	b.ne comparison_fail
	.inst 0xc2401568 // ldr c8, [x11, #5]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2401968 // ldr c8, [x11, #6]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401d68 // ldr c8, [x11, #7]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2402168 // ldr c8, [x11, #8]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc2402568 // ldr c8, [x11, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402968 // ldr c8, [x11, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x11, =0x0
	mov x8, v29.d[0]
	cmp x11, x8
	b.ne comparison_fail
	ldr x11, =0x0
	mov x8, v29.d[1]
	cmp x11, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x11, =final_SP_EL1_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc29c4108 // mrs c8, CSP_EL1
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	ldr x11, =final_PCC_value
	.inst 0xc240016b // ldr c11, [x11, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a561 // chkeq c11, c8
	b.ne comparison_fail
	ldr x11, =esr_el1_dump_address
	ldr x11, [x11]
	mov x8, 0x80
	orr x11, x11, x8
	ldr x8, =0x920000e1
	cmp x8, x11
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001030
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001104
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001480
	ldr x1, =check_data3
	ldr x2, =0x00001490
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400008
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400040
	ldr x1, =check_data5
	ldr x2, =0x4040004c
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
	ldr x0, =0x40400f50
	ldr x1, =check_data7
	ldr x2, =0x40400f58
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x40401030
	ldr x1, =check_data8
	ldr x2, =0x40401032
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
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
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
	.byte 0xff, 0xff, 0xbf, 0xdf, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1136
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11
	.zero 2928
.data
check_data0:
	.byte 0xff, 0xff, 0xbf, 0xdf, 0x00, 0xff, 0xff, 0xff
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11
.data
check_data4:
	.byte 0xfd, 0xdc, 0x54, 0xfc, 0xa0, 0x03, 0x5f, 0xd6
.data
check_data5:
	.byte 0xbd, 0x60, 0xa0, 0x79, 0xa1, 0xa5, 0xc1, 0xc2, 0xc4, 0x93, 0x8a, 0xe2
.data
check_data6:
	.byte 0xe2, 0x13, 0xa0, 0xf8, 0xbb, 0x7f, 0xe0, 0xa2, 0x21, 0x88, 0x67, 0x82, 0x61, 0x54, 0x7f, 0xc8
	.byte 0x01, 0x00, 0x00, 0xd4
.data
check_data7:
	.zero 8
.data
check_data8:
	.byte 0x80, 0x14

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x80000000682008420000000000000f20
	/* C3 */
	.octa 0x1020
	/* C5 */
	.octa 0x800000000005400f0000000040400000
	/* C7 */
	.octa 0x80000000000080080000000040401003
	/* C13 */
	.octa 0x7fffffff97dff7bdfffffffffffff0df
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x40400040
	/* C30 */
	.octa 0xffffffffffffff59
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x11000000000000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0xffffff00dfbfffff
	/* C3 */
	.octa 0x1020
	/* C5 */
	.octa 0x800000000005400f0000000040400000
	/* C7 */
	.octa 0x80000000000080080000000040400f50
	/* C13 */
	.octa 0x7fffffff97dff7bdfffffffffffff0df
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x4000000000000000000000000000
	/* C29 */
	.octa 0x1480
	/* C30 */
	.octa 0xffffffffffffff59
initial_SP_EL1_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x4000000000070007007fffffffffe001
initial_DDC_EL1_value:
	.octa 0xd8100000010700070000000000000003
initial_VBAR_EL1_value:
	.octa 0x200080005000001d0000000040400000
final_SP_EL1_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080005000001d0000000040400414
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
	.dword 0x0000000000001480
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0x0000000000001480
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
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0200016b // add c11, c11, #0
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0202016b // add c11, c11, #128
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0204016b // add c11, c11, #256
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0206016b // add c11, c11, #384
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0208016b // add c11, c11, #512
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x020a016b // add c11, c11, #640
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x020c016b // add c11, c11, #768
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x020e016b // add c11, c11, #896
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0210016b // add c11, c11, #1024
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0212016b // add c11, c11, #1152
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0214016b // add c11, c11, #1280
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0216016b // add c11, c11, #1408
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x0218016b // add c11, c11, #1536
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x021a016b // add c11, c11, #1664
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x021c016b // add c11, c11, #1792
	.inst 0xc2c21160 // br c11
	.balign 128
	ldr x11, =esr_el1_dump_address
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x82600d0b // ldr x11, [c8, #0]
	cbnz x11, #28
	mrs x11, ESR_EL1
	.inst 0x82400d0b // str x11, [c8, #0]
	ldr x11, =0x40400414
	mrs x8, ELR_EL1
	sub x11, x11, x8
	cbnz x11, #8
	smc 0
	ldr x11, =initial_VBAR_EL1_value
	.inst 0xc2c5b168 // cvtp c8, x11
	.inst 0xc2cb4108 // scvalue c8, c8, x11
	.inst 0x8260010b // ldr c11, [c8, #0]
	.inst 0x021e016b // add c11, c11, #1920
	.inst 0xc2c21160 // br c11

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
