.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2b813fc // ASTUR-V.RI-S Rt:28 Rn:31 op2:00 imm9:110000001 V:1 op1:10 11100010:11100010
	.inst 0xb15377df // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:30 imm12:010011011101 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0x4b20ab9f // sub_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:28 imm3:010 option:101 Rm:0 01011001:01011001 S:0 op:1 sf:0
	.inst 0xc2c710e1 // RRLEN-R.R-C Rd:1 Rn:7 100:100 opc:00 11000010110001110:11000010110001110
	.inst 0x3881fae1 // ldtrsb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:23 10:10 imm9:000011111 0:0 opc:10 111000:111000 size:00
	.zero 1004
	.inst 0x3a5e7824 // 0x3a5e7824
	.inst 0xe21493fd // ASTURB-R.RI-32 Rt:29 Rn:31 op2:00 imm9:101001001 V:0 op1:00 11100010:11100010
	.inst 0xc2dad0e0 // BR-CI-C 0:0 0000:0000 Cn:7 100:100 imm7:1010110 110000101101:110000101101
	.zero 31732
	.inst 0xb8fd72d4 // ldumin:aarch64/instrs/memory/atomicops/ld Rt:20 Rn:22 00:00 opc:111 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xd4000001
	.zero 32760
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
	ldr x19, =initial_cap_values
	.inst 0xc2400267 // ldr c7, [x19, #0]
	.inst 0xc2400676 // ldr c22, [x19, #1]
	.inst 0xc2400a77 // ldr c23, [x19, #2]
	.inst 0xc2400e7d // ldr c29, [x19, #3]
	.inst 0xc240127e // ldr c30, [x19, #4]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q28, =0x0
	/* Set up flags and system registers */
	ldr x19, =0x4000000
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =initial_SP_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc28c4113 // msr CSP_EL1, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0x3c0000
	msr CPACR_EL1, x19
	ldr x19, =0x0
	msr S3_0_C1_C2_2, x19 // CCTLR_EL1
	ldr x19, =0x4
	msr S3_3_C1_C2_2, x19 // CCTLR_EL0
	ldr x19, =initial_DDC_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884133 // msr DDC_EL0, c19
	ldr x19, =0x80000000
	msr HCR_EL2, x19
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82601113 // ldr c19, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc28e4033 // msr CELR_EL3, c19
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30851035
	msr SCTLR_EL3, x19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x8, #0xf
	and x19, x19, x8
	cmp x19, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400268 // ldr c8, [x19, #0]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400668 // ldr c8, [x19, #1]
	.inst 0xc2c8a4e1 // chkeq c7, c8
	b.ne comparison_fail
	.inst 0xc2400a68 // ldr c8, [x19, #2]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2400e68 // ldr c8, [x19, #3]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2401268 // ldr c8, [x19, #4]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2401668 // ldr c8, [x19, #5]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2401a68 // ldr c8, [x19, #6]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x8, v28.d[0]
	cmp x19, x8
	b.ne comparison_fail
	ldr x19, =0x0
	mov x8, v28.d[1]
	cmp x19, x8
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL1_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc29c4108 // mrs c8, CSP_EL1
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984028 // mrs c8, CELR_EL1
	.inst 0xc2c8a661 // chkeq c19, c8
	b.ne comparison_fail
	ldr x8, =esr_el1_dump_address
	ldr x8, [x8]
	mov x19, 0x83
	orr x8, x8, x19
	ldr x19, =0x920000ab
	cmp x19, x8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001359
	ldr x1, =check_data0
	ldr x2, =0x0000135a
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001780
	ldr x1, =check_data1
	ldr x2, =0x00001784
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001d60
	ldr x1, =check_data2
	ldr x2, =0x00001d70
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f8c
	ldr x1, =check_data3
	ldr x2, =0x00001f90
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
	ldr x0, =0x40400400
	ldr x1, =check_data5
	ldr x2, =0x4040040c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40408000
	ldr x1, =check_data6
	ldr x2, =0x40408008
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
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
	.zero 1920
	.byte 0x00, 0x01, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1488
	.byte 0x01, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0xfb, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 656
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x04, 0x00
.data
check_data2:
	.byte 0x01, 0x80, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0xfb, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xfc, 0x13, 0xb8, 0xe2, 0xdf, 0x77, 0x53, 0xb1, 0x9f, 0xab, 0x20, 0x4b, 0xe1, 0x10, 0xc7, 0xc2
	.byte 0xe1, 0xfa, 0x81, 0x38
.data
check_data5:
	.byte 0x24, 0x78, 0x5e, 0x3a, 0xfd, 0x93, 0x14, 0xe2, 0xe0, 0xd0, 0xda, 0xc2
.data
check_data6:
	.byte 0xd4, 0x72, 0xfd, 0xb8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C7 */
	.octa 0x901000006000002a0000000000002000
	/* C22 */
	.octa 0xc000000040010b820000000000001780
	/* C23 */
	.octa 0x20000000000080000000000000
	/* C29 */
	.octa 0x40000
	/* C30 */
	.octa 0x7fffffffffc00000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C1 */
	.octa 0x2000
	/* C7 */
	.octa 0x901000006000002a0000000000002000
	/* C20 */
	.octa 0x40100
	/* C22 */
	.octa 0xc000000040010b820000000000001780
	/* C23 */
	.octa 0x20000000000080000000000000
	/* C29 */
	.octa 0x40000
	/* C30 */
	.octa 0x7fffffffffc00000
initial_SP_EL0_value:
	.octa 0x2000
initial_SP_EL1_value:
	.octa 0x40000000000700070000000000001410
initial_DDC_EL0_value:
	.octa 0x400000005fa1000b0000000000000000
initial_VBAR_EL1_value:
	.octa 0x200080005000000d0000000040400000
final_SP_EL1_value:
	.octa 0x40000000000700070000000000001410
final_PCC_value:
	.octa 0x2000800000fb00070000000040408008
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080006000e0040000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001d60
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword initial_SP_EL1_value
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_SP_EL1_value
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600d13 // ldr x19, [c8, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400d13 // str x19, [c8, #0]
	ldr x19, =0x40408008
	mrs x8, ELR_EL1
	sub x19, x19, x8
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b268 // cvtp c8, x19
	.inst 0xc2d34108 // scvalue c8, c8, x19
	.inst 0x82600113 // ldr c19, [c8, #0]
	.inst 0x021e0273 // add c19, c19, #1920
	.inst 0xc2c21260 // br c19

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
