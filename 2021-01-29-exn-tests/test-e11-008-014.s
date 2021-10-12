.section text0, #alloc, #execinstr
test_start:
	.inst 0x78c6bc3b // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:27 Rn:1 11:11 imm9:001101011 0:0 opc:11 111000:111000 size:01
	.inst 0x11451bcf // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:30 imm12:000101000110 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xa25e19c1 // LDTR-C.RIB-C Ct:1 Rn:14 10:10 imm9:111100001 0:0 opc:01 10100010:10100010
	.inst 0x0b2029c4 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:4 Rn:14 imm3:010 option:001 Rm:0 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2dd067f // BUILD-C.C-C Cd:31 Cn:19 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0xc2c19032 // 0xc2c19032
	.inst 0xc2c233c1 // 0xc2c233c1
	.inst 0x82c6cc29 // 0x82c6cc29
	.inst 0xf874101d // 0xf874101d
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
	ldr x8, =initial_cap_values
	.inst 0xc2400100 // ldr c0, [x8, #0]
	.inst 0xc2400501 // ldr c1, [x8, #1]
	.inst 0xc2400906 // ldr c6, [x8, #2]
	.inst 0xc2400d0e // ldr c14, [x8, #3]
	.inst 0xc2401113 // ldr c19, [x8, #4]
	.inst 0xc2401514 // ldr c20, [x8, #5]
	.inst 0xc240191d // ldr c29, [x8, #6]
	.inst 0xc2401d1e // ldr c30, [x8, #7]
	/* Set up flags and system registers */
	ldr x8, =0x4000000
	msr SPSR_EL3, x8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x30d5d99f
	msr SCTLR_EL1, x8
	ldr x8, =0xc0000
	msr CPACR_EL1, x8
	ldr x8, =0x0
	msr S3_0_C1_C2_2, x8 // CCTLR_EL1
	ldr x8, =0x0
	msr S3_3_C1_C2_2, x8 // CCTLR_EL0
	ldr x8, =initial_DDC_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2884128 // msr DDC_EL0, c8
	ldr x8, =0x80000000
	msr HCR_EL2, x8
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82601308 // ldr c8, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc28e4028 // msr CELR_EL3, c8
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x24, #0xf
	and x8, x8, x24
	cmp x8, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400118 // ldr c24, [x8, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400518 // ldr c24, [x8, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc2400918 // ldr c24, [x8, #2]
	.inst 0xc2d8a481 // chkeq c4, c24
	b.ne comparison_fail
	.inst 0xc2400d18 // ldr c24, [x8, #3]
	.inst 0xc2d8a4c1 // chkeq c6, c24
	b.ne comparison_fail
	.inst 0xc2401118 // ldr c24, [x8, #4]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc2401518 // ldr c24, [x8, #5]
	.inst 0xc2d8a5c1 // chkeq c14, c24
	b.ne comparison_fail
	.inst 0xc2401918 // ldr c24, [x8, #6]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401d18 // ldr c24, [x8, #7]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc2402118 // ldr c24, [x8, #8]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc2402518 // ldr c24, [x8, #9]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2402918 // ldr c24, [x8, #10]
	.inst 0xc2d8a761 // chkeq c27, c24
	b.ne comparison_fail
	.inst 0xc2402d18 // ldr c24, [x8, #11]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2403118 // ldr c24, [x8, #12]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check system registers */
	ldr x8, =final_SP_EL0_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984118 // mrs c24, CSP_EL0
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	ldr x8, =final_PCC_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2984038 // mrs c24, CELR_EL1
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001144
	ldr x1, =check_data0
	ldr x2, =0x00001146
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001e30
	ldr x1, =check_data1
	ldr x2, =0x00001e40
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
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
	ldr x0, =0x4040ffe4
	ldr x1, =check_data4
	ldr x2, =0x4040ffe6
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
	.zero 3632
	.byte 0xe4, 0xff, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 432
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xe4, 0xff, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
.data
check_data3:
	.byte 0x3b, 0xbc, 0xc6, 0x78, 0xcf, 0x1b, 0x45, 0x11, 0xc1, 0x19, 0x5e, 0xa2, 0xc4, 0x29, 0x20, 0x0b
	.byte 0x7f, 0x06, 0xdd, 0xc2, 0x32, 0x90, 0xc1, 0xc2, 0xc1, 0x33, 0xc2, 0xc2, 0x29, 0xcc, 0xc6, 0x82
	.byte 0x1d, 0x10, 0x74, 0xf8, 0x01, 0x00, 0x00, 0xd4
.data
check_data4:
	.zero 2

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x800000005149014a00000000000010d9
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000002020
	/* C19 */
	.octa 0x3c0070021a00000000001
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x30c02001c000000140000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x4040ffe4
	/* C4 */
	.octa 0x9fe0
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000002020
	/* C15 */
	.octa 0x146000
	/* C18 */
	.octa 0x4040ffe4
	/* C19 */
	.octa 0x3c0070021a00000000001
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x3c0070021a00000000001
final_PCC_value:
	.octa 0x20008000000080080000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword initial_DDC_EL0_value
	.dword final_SP_EL0_value
	.dword final_PCC_value
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
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02000108 // add c8, c8, #0
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02020108 // add c8, c8, #128
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02040108 // add c8, c8, #256
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02060108 // add c8, c8, #384
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02080108 // add c8, c8, #512
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020a0108 // add c8, c8, #640
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020c0108 // add c8, c8, #768
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x020e0108 // add c8, c8, #896
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02100108 // add c8, c8, #1024
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02120108 // add c8, c8, #1152
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02140108 // add c8, c8, #1280
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02160108 // add c8, c8, #1408
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x02180108 // add c8, c8, #1536
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021a0108 // add c8, c8, #1664
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021c0108 // add c8, c8, #1792
	.inst 0xc2c21100 // br c8
	.balign 128
	ldr x8, =esr_el1_dump_address
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600f08 // ldr x8, [c24, #0]
	cbnz x8, #28
	mrs x8, ESR_EL1
	.inst 0x82400f08 // str x8, [c24, #0]
	ldr x8, =0x40400028
	mrs x24, ELR_EL1
	sub x8, x8, x24
	cbnz x8, #8
	smc 0
	ldr x8, =initial_VBAR_EL1_value
	.inst 0xc2c5b118 // cvtp c24, x8
	.inst 0xc2c84318 // scvalue c24, c24, x8
	.inst 0x82600308 // ldr c8, [c24, #0]
	.inst 0x021e0108 // add c8, c8, #1920
	.inst 0xc2c21100 // br c8

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
