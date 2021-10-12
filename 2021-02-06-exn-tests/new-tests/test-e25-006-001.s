.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c08bbf // CHKSSU-C.CC-C Cd:31 Cn:29 0010:0010 opc:10 Cm:0 11000010110:11000010110
	.inst 0x78df0ecc // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:12 Rn:22 11:11 imm9:111110000 0:0 opc:11 111000:111000 size:01
	.inst 0xf86163cf // ldumax:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:30 00:00 opc:110 0:0 Rs:1 1:1 R:1 A:0 111000:111000 size:11
	.inst 0xc2c153b0 // CFHI-R.C-C Rd:16 Cn:29 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2f09ac1 // SUBS-R.CC-C Rd:1 Cn:22 100110:100110 Cm:16 11000010111:11000010111
	.inst 0x489f7e61 // stllrh:aarch64/instrs/memory/ordered Rt:1 Rn:19 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xc2c1d05e // CPY-C.C-C Cd:30 Cn:2 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xa2479021 // LDUR-C.RI-C Ct:1 Rn:1 00:00 imm9:001111001 0:0 opc:01 10100010:10100010
	.inst 0xf83542ff // stsmax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:100 o3:0 Rs:21 1:1 R:0 A:0 00:00 V:0 111:111 size:11
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400761 // ldr c1, [x27, #1]
	.inst 0xc2400b73 // ldr c19, [x27, #2]
	.inst 0xc2400f75 // ldr c21, [x27, #3]
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc2401777 // ldr c23, [x27, #5]
	.inst 0xc2401b7d // ldr c29, [x27, #6]
	.inst 0xc2401f7e // ldr c30, [x27, #7]
	/* Set up flags and system registers */
	ldr x27, =0x0
	msr SPSR_EL3, x27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30d5d99f
	msr SCTLR_EL1, x27
	ldr x27, =0xc0000
	msr CPACR_EL1, x27
	ldr x27, =0x0
	msr S3_0_C1_C2_2, x27 // CCTLR_EL1
	ldr x27, =0x4
	msr S3_3_C1_C2_2, x27 // CCTLR_EL0
	ldr x27, =initial_DDC_EL0_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc288413b // msr DDC_EL0, c27
	ldr x27, =0x80000000
	msr HCR_EL2, x27
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x8260113b // ldr c27, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e403b // msr CELR_EL3, c27
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30851035
	msr SCTLR_EL3, x27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x9, #0xf
	and x27, x27, x9
	cmp x27, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc2400369 // ldr c9, [x27, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400769 // ldr c9, [x27, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400b69 // ldr c9, [x27, #2]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2400f69 // ldr c9, [x27, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401369 // ldr c9, [x27, #4]
	.inst 0xc2c9a601 // chkeq c16, c9
	b.ne comparison_fail
	.inst 0xc2401769 // ldr c9, [x27, #5]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2401b69 // ldr c9, [x27, #6]
	.inst 0xc2c9a6a1 // chkeq c21, c9
	b.ne comparison_fail
	.inst 0xc2401f69 // ldr c9, [x27, #7]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402369 // ldr c9, [x27, #8]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402769 // ldr c9, [x27, #9]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x27, =final_PCC_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a761 // chkeq c27, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x0000101a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001070
	ldr x1, =check_data1
	ldr x2, =0x00001072
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x40400000
	ldr x1, =check_data2
	ldr x2, =0x40400028
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	ldr x27, =0x30850030
	msr SCTLR_EL3, x27
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x04, 0x04, 0x02, 0x02, 0x81
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x04, 0x02, 0x02, 0x01
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x0f
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xbf, 0x8b, 0xc0, 0xc2, 0xcc, 0x0e, 0xdf, 0x78, 0xcf, 0x63, 0x61, 0xf8, 0xb0, 0x53, 0xc1, 0xc2
	.byte 0xc1, 0x9a, 0xf0, 0xc2, 0x61, 0x7e, 0x9f, 0x48, 0x5e, 0xd0, 0xc1, 0xc2, 0x21, 0x90, 0x47, 0xa2
	.byte 0xff, 0x42, 0x35, 0xf8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400185ba0000000000018000
	/* C1 */
	.octa 0x0
	/* C19 */
	.octa 0x1012
	/* C21 */
	.octa 0x102020402000000
	/* C22 */
	.octa 0x107a
	/* C23 */
	.octa 0x1002
	/* C29 */
	.octa 0xe90000000000000001
	/* C30 */
	.octa 0x100a
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x400185ba0000000000018000
	/* C1 */
	.octa 0x81020204040000020000000000000000
	/* C12 */
	.octa 0x0
	/* C15 */
	.octa 0x1
	/* C16 */
	.octa 0xe9
	/* C19 */
	.octa 0x1012
	/* C21 */
	.octa 0x102020402000000
	/* C22 */
	.octa 0x106a
	/* C23 */
	.octa 0x1002
	/* C29 */
	.octa 0xe90000000000000001
initial_DDC_EL0_value:
	.octa 0xc00000005102000600ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x200080000005004f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000005004f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword el1_vector_jump_cap
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
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0200037b // add c27, c27, #0
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0202037b // add c27, c27, #128
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0204037b // add c27, c27, #256
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0206037b // add c27, c27, #384
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0208037b // add c27, c27, #512
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x020a037b // add c27, c27, #640
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x020c037b // add c27, c27, #768
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x020e037b // add c27, c27, #896
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0210037b // add c27, c27, #1024
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0212037b // add c27, c27, #1152
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0214037b // add c27, c27, #1280
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0216037b // add c27, c27, #1408
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x0218037b // add c27, c27, #1536
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x021a037b // add c27, c27, #1664
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x021c037b // add c27, c27, #1792
	.inst 0xc2c21360 // br c27
	.balign 128
	ldr x27, =esr_el1_dump_address
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x82600d3b // ldr x27, [c9, #0]
	cbnz x27, #28
	mrs x27, ESR_EL1
	.inst 0x82400d3b // str x27, [c9, #0]
	ldr x27, =0x40400028
	mrs x9, ELR_EL1
	sub x27, x27, x9
	cbnz x27, #8
	smc 0
	ldr x27, =initial_VBAR_EL1_value
	.inst 0xc2c5b369 // cvtp c9, x27
	.inst 0xc2db4129 // scvalue c9, c9, x27
	.inst 0x8260013b // ldr c27, [c9, #0]
	.inst 0x021e037b // add c27, c27, #1920
	.inst 0xc2c21360 // br c27

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
