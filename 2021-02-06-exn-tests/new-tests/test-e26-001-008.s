.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d449e0 // UNSEAL-C.CC-C Cd:0 Cn:15 0010:0010 opc:01 Cm:20 11000010110:11000010110
	.inst 0x1a9967dd // csinc:aarch64/instrs/integer/conditional/select Rd:29 Rn:30 o2:1 0:0 cond:0110 Rm:25 011010100:011010100 op:0 sf:0
	.inst 0x7821603f // stumaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:110 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x787d003f // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:000 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x8265ebe6 // ALDR-R.RI-32 Rt:6 Rn:31 op:10 imm9:001011110 L:1 1000001001:1000001001
	.zero 37868
	.inst 0xc2c3539d // SEAL-C.CI-C Cd:29 Cn:28 100:100 form:10 11000010110000110:11000010110000110
	.inst 0xb887e3dd // ldursw:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:29 Rn:30 00:00 imm9:001111110 0:0 opc:10 111000:111000 size:10
	.inst 0xc2aaafe1 // ADD-C.CRI-C Cd:1 Cn:31 imm3:011 option:101 Rm:10 11000010101:11000010101
	.inst 0x782072ff // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:111 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xd4000001
	.zero 27628
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
	ldr x24, =initial_cap_values
	.inst 0xc2400301 // ldr c1, [x24, #0]
	.inst 0xc240070a // ldr c10, [x24, #1]
	.inst 0xc2400b0f // ldr c15, [x24, #2]
	.inst 0xc2400f14 // ldr c20, [x24, #3]
	.inst 0xc2401317 // ldr c23, [x24, #4]
	.inst 0xc2401719 // ldr c25, [x24, #5]
	.inst 0xc2401b1c // ldr c28, [x24, #6]
	.inst 0xc2401f1e // ldr c30, [x24, #7]
	/* Set up flags and system registers */
	ldr x24, =0x0
	msr SPSR_EL3, x24
	ldr x24, =initial_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884118 // msr CSP_EL0, c24
	ldr x24, =initial_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4118 // msr CSP_EL1, c24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30d5d99f
	msr SCTLR_EL1, x24
	ldr x24, =0xc0000
	msr CPACR_EL1, x24
	ldr x24, =0x0
	msr S3_0_C1_C2_2, x24 // CCTLR_EL1
	ldr x24, =0x4
	msr S3_3_C1_C2_2, x24 // CCTLR_EL0
	ldr x24, =initial_DDC_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2884138 // msr DDC_EL0, c24
	ldr x24, =initial_DDC_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc28c4138 // msr DDC_EL1, c24
	ldr x24, =0x80000000
	msr HCR_EL2, x24
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82601218 // ldr c24, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
	.inst 0xc28e4038 // msr CELR_EL3, c24
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x16, #0x1
	and x24, x24, x16
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400310 // ldr c16, [x24, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400710 // ldr c16, [x24, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400b10 // ldr c16, [x24, #2]
	.inst 0xc2d0a541 // chkeq c10, c16
	b.ne comparison_fail
	.inst 0xc2400f10 // ldr c16, [x24, #3]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401310 // ldr c16, [x24, #4]
	.inst 0xc2d0a681 // chkeq c20, c16
	b.ne comparison_fail
	.inst 0xc2401710 // ldr c16, [x24, #5]
	.inst 0xc2d0a6e1 // chkeq c23, c16
	b.ne comparison_fail
	.inst 0xc2401b10 // ldr c16, [x24, #6]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401f10 // ldr c16, [x24, #7]
	.inst 0xc2d0a781 // chkeq c28, c16
	b.ne comparison_fail
	.inst 0xc2402310 // ldr c16, [x24, #8]
	.inst 0xc2d0a7a1 // chkeq c29, c16
	b.ne comparison_fail
	.inst 0xc2402710 // ldr c16, [x24, #9]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check system registers */
	ldr x24, =final_SP_EL0_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984110 // mrs c16, CSP_EL0
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	ldr x24, =final_SP_EL1_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc29c4110 // mrs c16, CSP_EL1
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	ldr x24, =final_PCC_value
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0xc2984030 // mrs c16, CELR_EL1
	.inst 0xc2d0a701 // chkeq c24, c16
	b.ne comparison_fail
	ldr x24, =esr_el1_dump_address
	ldr x24, [x24]
	mov x16, 0x80
	orr x24, x24, x16
	ldr x16, =0x920000ab
	cmp x16, x24
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
	ldr x0, =0x00001088
	ldr x1, =check_data1
	ldr x2, =0x0000108c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000017fe
	ldr x1, =check_data2
	ldr x2, =0x00001800
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
	ldr x0, =0x40409400
	ldr x1, =check_data4
	ldr x2, =0x40409414
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
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
	.zero 2016
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xdb, 0xd7
	.zero 2048
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0x21, 0x60
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
	.octa 0x17da
	/* C10 */
	.octa 0x1040
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0x1000
	/* C25 */
	.octa 0x8845
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x100a
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x800700070080000000001400
	/* C10 */
	.octa 0x1040
	/* C15 */
	.octa 0x0
	/* C20 */
	.octa 0x4000000000000000000000000000
	/* C23 */
	.octa 0x1000
	/* C25 */
	.octa 0x8845
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x100a
initial_SP_EL0_value:
	.octa 0x1849040
initial_SP_EL1_value:
	.octa 0x80070007007fffffffff9200
initial_DDC_EL0_value:
	.octa 0xc0000000400000240000000000000003
initial_DDC_EL1_value:
	.octa 0xc00000000007000f00ffffffffffe001
initial_VBAR_EL1_value:
	.octa 0x2000800058008c1d0000000040409000
final_SP_EL0_value:
	.octa 0x1849040
final_SP_EL1_value:
	.octa 0x80070007007fffffffff9200
final_PCC_value:
	.octa 0x2000800058008c1d0000000040409414
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
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 112
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001000
	.dword 0x00000000000017f0
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
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02000318 // add c24, c24, #0
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02020318 // add c24, c24, #128
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02040318 // add c24, c24, #256
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02060318 // add c24, c24, #384
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02080318 // add c24, c24, #512
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x020a0318 // add c24, c24, #640
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x020c0318 // add c24, c24, #768
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x020e0318 // add c24, c24, #896
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02100318 // add c24, c24, #1024
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02120318 // add c24, c24, #1152
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02140318 // add c24, c24, #1280
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02160318 // add c24, c24, #1408
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x02180318 // add c24, c24, #1536
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x021a0318 // add c24, c24, #1664
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x021c0318 // add c24, c24, #1792
	.inst 0xc2c21300 // br c24
	.balign 128
	ldr x24, =esr_el1_dump_address
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600e18 // ldr x24, [c16, #0]
	cbnz x24, #28
	mrs x24, ESR_EL1
	.inst 0x82400e18 // str x24, [c16, #0]
	ldr x24, =0x40409414
	mrs x16, ELR_EL1
	sub x24, x24, x16
	cbnz x24, #8
	smc 0
	ldr x24, =initial_VBAR_EL1_value
	.inst 0xc2c5b310 // cvtp c16, x24
	.inst 0xc2d84210 // scvalue c16, c16, x24
	.inst 0x82600218 // ldr c24, [c16, #0]
	.inst 0x021e0318 // add c24, c24, #1920
	.inst 0xc2c21300 // br c24

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
