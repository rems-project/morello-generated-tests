.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d449e0 // UNSEAL-C.CC-C Cd:0 Cn:15 0010:0010 opc:01 Cm:20 11000010110:11000010110
	.inst 0x1a9967dd // csinc:aarch64/instrs/integer/conditional/select Rd:29 Rn:30 o2:1 0:0 cond:0110 Rm:25 011010100:011010100 op:0 sf:0
	.inst 0x7821603f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x787d003f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:000 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x8265ebe6 // ALDR-R.RI-32 Rt:6 Rn:31 op:10 imm9:001011110 L:1 1000001001:1000001001
	.zero 3052
	.inst 0xc2c3539d // SEAL-C.CI-C Cd:29 Cn:28 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xb887e3dd // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:30 00:00 imm9:001111110 0:0 opc:10 111000:111000 size:10
	.inst 0xc2aaafe1 // ADD-C.CRI-C Cd:1 Cn:31 imm3:011 option:101 Rm:10 11000010101:11000010101
	.inst 0x782072ff // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:111 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xd4000001
	.zero 62444
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
	ldr x18, =initial_cap_values
	.inst 0xc2400241 // ldr c1, [x18, #0]
	.inst 0xc240064a // ldr c10, [x18, #1]
	.inst 0xc2400a4f // ldr c15, [x18, #2]
	.inst 0xc2400e54 // ldr c20, [x18, #3]
	.inst 0xc2401257 // ldr c23, [x18, #4]
	.inst 0xc2401659 // ldr c25, [x18, #5]
	.inst 0xc2401a5c // ldr c28, [x18, #6]
	.inst 0xc2401e5e // ldr c30, [x18, #7]
	/* Set up flags and system registers */
	ldr x18, =0x0
	msr SPSR_EL3, x18
	ldr x18, =initial_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884112 // msr CSP_EL0, c18
	ldr x18, =initial_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc28c4112 // msr CSP_EL1, c18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x4
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601132 // ldr c18, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x9, #0x1
	and x18, x18, x9
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400249 // ldr c9, [x18, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400649 // ldr c9, [x18, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a49 // ldr c9, [x18, #2]
	.inst 0xc2c9a541 // chkeq c10, c9
	b.ne comparison_fail
	.inst 0xc2400e49 // ldr c9, [x18, #3]
	.inst 0xc2c9a5e1 // chkeq c15, c9
	b.ne comparison_fail
	.inst 0xc2401249 // ldr c9, [x18, #4]
	.inst 0xc2c9a681 // chkeq c20, c9
	b.ne comparison_fail
	.inst 0xc2401649 // ldr c9, [x18, #5]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2401a49 // ldr c9, [x18, #6]
	.inst 0xc2c9a721 // chkeq c25, c9
	b.ne comparison_fail
	.inst 0xc2401e49 // ldr c9, [x18, #7]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402249 // ldr c9, [x18, #8]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402649 // ldr c9, [x18, #9]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_SP_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	ldr x18, =final_SP_EL1_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc29c4109 // mrs c9, CSP_EL1
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	ldr x18, =esr_el1_dump_address
	ldr x18, [x18]
	mov x9, 0x80
	orr x18, x18, x9
	ldr x9, =0x920000a8
	cmp x9, x18
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001188
	ldr x1, =check_data0
	ldr x2, =0x0000118a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a50
	ldr x1, =check_data1
	ldr x2, =0x00001a54
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
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
	ldr x0, =0x40400c00
	ldr x1, =check_data4
	ldr x2, =0x40400c14
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
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.zero 384
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3680
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0x11, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xe0, 0x49, 0xd4, 0xc2, 0xdd, 0x67, 0x99, 0x1a, 0x3f, 0x60, 0x21, 0x78, 0x3f, 0x00, 0x7d, 0x78
	.byte 0xe6, 0xeb, 0x65, 0x82
.data
check_data4:
	.byte 0x9d, 0x53, 0xc3, 0xc2, 0xdd, 0xe3, 0x87, 0xb8, 0xe1, 0xaf, 0xaa, 0xc2, 0xff, 0x72, 0x20, 0x78
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1188
	/* C10 */
	.octa 0x4000
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0xc0000000000100050000000000001ffc
	/* C25 */
	.octa 0x8000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000000019d2
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800700040080000000000000
	/* C10 */
	.octa 0x4000
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0xc0000000000100050000000000001ffc
	/* C25 */
	.octa 0x8000
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x800000000001000500000000000019d2
initial_SP_EL0_value:
	.octa 0x88000607f000000
initial_SP_EL1_value:
	.octa 0x80070004007ffffffffe0000
initial_DDC_EL0_value:
	.octa 0xc00000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000041d0000000040400801
final_SP_EL0_value:
	.octa 0x88000607f000000
final_SP_EL1_value:
	.octa 0x80070004007ffffffffe0000
final_PCC_value:
	.octa 0x200080005000041d0000000040400c14
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000028140050000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 80
	.dword final_cap_values + 144
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001180
	.dword 0x0000000000001ff0
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600d32 // ldr x18, [c9, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400d32 // str x18, [c9, #0]
	ldr x18, =0x40400c14
	mrs x9, ELR_EL1
	sub x18, x18, x9
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b249 // cvtp c9, x18
	.inst 0xc2d24129 // scvalue c9, c9, x18
	.inst 0x82600132 // ldr c18, [c9, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
