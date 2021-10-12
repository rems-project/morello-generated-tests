.section text0, #alloc, #execinstr
test_start:
	.inst 0x78c6bc3b // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:27 Rn:1 11:11 imm9:001101011 0:0 opc:11 111000:111000 size:01
	.inst 0x11451bcf // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:15 Rn:30 imm12:000101000110 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xa25e19c1 // LDTR-C.RIB-C Ct:1 Rn:14 10:10 imm9:111100001 0:0 opc:01 10100010:10100010
	.inst 0x0b2029c4 // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:4 Rn:14 imm3:010 option:001 Rm:0 01011001:01011001 S:0 op:0 sf:0
	.inst 0xc2dd067f // BUILD-C.C-C Cd:31 Cn:19 001:001 opc:00 0:0 Cm:29 11000010110:11000010110
	.inst 0xc2c19032 // 0xc2c19032
	.inst 0xc2c233c1 // 0xc2c233c1
	.inst 0x82c6cc29 // ALDRH-R.RRB-32 Rt:9 Rn:1 opc:11 S:0 option:110 Rm:6 0:0 L:1 100000101:100000101
	.inst 0xf874101d // ldclr:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:0 00:00 opc:001 0:0 Rs:20 1:1 R:1 A:0 111000:111000 size:11
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2400eee // ldr c14, [x23, #3]
	.inst 0xc24012f3 // ldr c19, [x23, #4]
	.inst 0xc24016f4 // ldr c20, [x23, #5]
	.inst 0xc2401afd // ldr c29, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	ldr x23, =0x4000000
	msr SPSR_EL3, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30d5d99f
	msr SCTLR_EL1, x23
	ldr x23, =0xc0000
	msr CPACR_EL1, x23
	ldr x23, =0x0
	msr S3_0_C1_C2_2, x23 // CCTLR_EL1
	ldr x23, =0x0
	msr S3_3_C1_C2_2, x23 // CCTLR_EL0
	ldr x23, =initial_DDC_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2884137 // msr DDC_EL0, c23
	ldr x23, =0x80000000
	msr HCR_EL2, x23
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x82601337 // ldr c23, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc28e4037 // msr CELR_EL3, c23
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x25, #0xf
	and x23, x23, x25
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f9 // ldr c25, [x23, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24006f9 // ldr c25, [x23, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc2400af9 // ldr c25, [x23, #2]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc2400ef9 // ldr c25, [x23, #3]
	.inst 0xc2d9a4c1 // chkeq c6, c25
	b.ne comparison_fail
	.inst 0xc24012f9 // ldr c25, [x23, #4]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc24016f9 // ldr c25, [x23, #5]
	.inst 0xc2d9a5c1 // chkeq c14, c25
	b.ne comparison_fail
	.inst 0xc2401af9 // ldr c25, [x23, #6]
	.inst 0xc2d9a5e1 // chkeq c15, c25
	b.ne comparison_fail
	.inst 0xc2401ef9 // ldr c25, [x23, #7]
	.inst 0xc2d9a641 // chkeq c18, c25
	b.ne comparison_fail
	.inst 0xc24022f9 // ldr c25, [x23, #8]
	.inst 0xc2d9a661 // chkeq c19, c25
	b.ne comparison_fail
	.inst 0xc24026f9 // ldr c25, [x23, #9]
	.inst 0xc2d9a681 // chkeq c20, c25
	b.ne comparison_fail
	.inst 0xc2402af9 // ldr c25, [x23, #10]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402ef9 // ldr c25, [x23, #11]
	.inst 0xc2d9a7a1 // chkeq c29, c25
	b.ne comparison_fail
	.inst 0xc24032f9 // ldr c25, [x23, #12]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check system registers */
	ldr x23, =final_SP_EL0_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984119 // mrs c25, CSP_EL0
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	ldr x23, =final_PCC_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2984039 // mrs c25, CELR_EL1
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001dc0
	ldr x1, =check_data0
	ldr x2, =0x00001dd0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001fe4
	ldr x1, =check_data1
	ldr x2, =0x00001fe6
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
	ldr x0, =0x404012fc
	ldr x1, =check_data4
	ldr x2, =0x404012fe
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
	.zero 3520
	.byte 0xe4, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 544
	.byte 0xe2, 0xae, 0xea, 0x55, 0xff, 0x98, 0x7a, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xe4, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0xe2, 0xae, 0xea, 0x55, 0xff, 0x98, 0x7a, 0x38
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
	.octa 0x800000006001e0020000000040401291
	/* C6 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000001fb0
	/* C19 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000000000000000000
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ff0
	/* C1 */
	.octa 0x1fe4
	/* C4 */
	.octa 0x9f70
	/* C6 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C14 */
	.octa 0x80000000000100050000000000001fb0
	/* C15 */
	.octa 0x146000
	/* C18 */
	.octa 0x1fe4
	/* C19 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x387a98ff55eaaee2
	/* C30 */
	.octa 0x0
initial_DDC_EL0_value:
	.octa 0x80000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x0
final_PCC_value:
	.octa 0x20008000000081000000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000081000000000040400000
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
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 192
	.dword initial_DDC_EL0_value
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
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020002f7 // add c23, c23, #0
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020202f7 // add c23, c23, #128
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020402f7 // add c23, c23, #256
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020602f7 // add c23, c23, #384
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020802f7 // add c23, c23, #512
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020a02f7 // add c23, c23, #640
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020c02f7 // add c23, c23, #768
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x020e02f7 // add c23, c23, #896
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021002f7 // add c23, c23, #1024
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021202f7 // add c23, c23, #1152
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021402f7 // add c23, c23, #1280
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021602f7 // add c23, c23, #1408
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021802f7 // add c23, c23, #1536
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021a02f7 // add c23, c23, #1664
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021c02f7 // add c23, c23, #1792
	.inst 0xc2c212e0 // br c23
	.balign 128
	ldr x23, =esr_el1_dump_address
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600f37 // ldr x23, [c25, #0]
	cbnz x23, #28
	mrs x23, ESR_EL1
	.inst 0x82400f37 // str x23, [c25, #0]
	ldr x23, =0x40400028
	mrs x25, ELR_EL1
	sub x23, x23, x25
	cbnz x23, #8
	smc 0
	ldr x23, =initial_VBAR_EL1_value
	.inst 0xc2c5b2f9 // cvtp c25, x23
	.inst 0xc2d74339 // scvalue c25, c25, x23
	.inst 0x82600337 // ldr c23, [c25, #0]
	.inst 0x021e02f7 // add c23, c23, #1920
	.inst 0xc2c212e0 // br c23

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
