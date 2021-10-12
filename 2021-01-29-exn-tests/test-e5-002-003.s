.section text0, #alloc, #execinstr
test_start:
	.inst 0x78a0537b // ldsminh:aarch64/instrs/memory/atomicops/ld Rt:27 Rn:27 00:00 opc:101 0:0 Rs:0 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xf82123ff // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x22f323eb // LDP-CC.RIAW-C Ct:11 Rn:31 Ct2:01000 imm7:1100110 L:1 001000101:001000101
	.inst 0x9b3d72fd // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:23 Ra:28 o0:0 Rm:29 01:01 U:0 10011011:10011011
	.inst 0x08df7fbf // ldlarb:aarch64/instrs/memory/ordered Rt:31 Rn:29 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xc2c592d2 // 0xc2c592d2
	.inst 0xf874739f // 0xf874739f
	.inst 0x38c66c2e // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:14 Rn:1 11:11 imm9:001100110 0:0 opc:11 111000:111000 size:00
	.inst 0xeac467fe // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:31 imm6:011001 Rm:4 N:0 shift:11 01010:01010 opc:11 sf:1
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400661 // ldr c1, [x19, #1]
	.inst 0xc2400a74 // ldr c20, [x19, #2]
	.inst 0xc2400e76 // ldr c22, [x19, #3]
	.inst 0xc2401277 // ldr c23, [x19, #4]
	.inst 0xc240167b // ldr c27, [x19, #5]
	.inst 0xc2401a7c // ldr c28, [x19, #6]
	.inst 0xc2401e7d // ldr c29, [x19, #7]
	/* Set up flags and system registers */
	ldr x19, =0x0
	msr SPSR_EL3, x19
	ldr x19, =initial_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2884113 // msr CSP_EL0, c19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30d5d99f
	msr SCTLR_EL1, x19
	ldr x19, =0xc0000
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
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601053 // ldr c19, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	mov x2, #0xf
	and x19, x19, x2
	cmp x19, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400262 // ldr c2, [x19, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400a62 // ldr c2, [x19, #2]
	.inst 0xc2c2a501 // chkeq c8, c2
	b.ne comparison_fail
	.inst 0xc2400e62 // ldr c2, [x19, #3]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc2401262 // ldr c2, [x19, #4]
	.inst 0xc2c2a5c1 // chkeq c14, c2
	b.ne comparison_fail
	.inst 0xc2401662 // ldr c2, [x19, #5]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc2401a62 // ldr c2, [x19, #6]
	.inst 0xc2c2a681 // chkeq c20, c2
	b.ne comparison_fail
	.inst 0xc2401e62 // ldr c2, [x19, #7]
	.inst 0xc2c2a6c1 // chkeq c22, c2
	b.ne comparison_fail
	.inst 0xc2402262 // ldr c2, [x19, #8]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc2402662 // ldr c2, [x19, #9]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc2402a62 // ldr c2, [x19, #10]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc2402e62 // ldr c2, [x19, #11]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2403262 // ldr c2, [x19, #12]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984102 // mrs c2, CSP_EL0
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001030
	ldr x1, =check_data1
	ldr x2, =0x00001032
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001040
	ldr x1, =check_data2
	ldr x2, =0x00001041
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001067
	ldr x1, =check_data3
	ldr x2, =0x00001068
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x40400000
	ldr x1, =check_data4
	ldr x2, =0x40400028
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
	.byte 0x01, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4032
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x7b, 0x53, 0xa0, 0x78, 0xff, 0x23, 0x21, 0xf8, 0xeb, 0x23, 0xf3, 0x22, 0xfd, 0x72, 0x3d, 0x9b
	.byte 0xbf, 0x7f, 0xdf, 0x08, 0xd2, 0x92, 0xc5, 0xc2, 0x9f, 0x73, 0x74, 0xf8, 0x2e, 0x6c, 0xc6, 0x38
	.byte 0xfe, 0x67, 0xc4, 0xea, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1001
	/* C20 */
	.octa 0xc000000000000000
	/* C22 */
	.octa 0x20000000208100
	/* C23 */
	.octa 0x2
	/* C27 */
	.octa 0x1030
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x20
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x1067
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0xc0100000000300020020000000208100
	/* C20 */
	.octa 0xc000000000000000
	/* C22 */
	.octa 0x20000000208100
	/* C23 */
	.octa 0x2
	/* C27 */
	.octa 0x4
	/* C28 */
	.octa 0x1000
	/* C29 */
	.octa 0x1040
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0xc01000000003000200190000041f1c40
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xe60
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
	.dword 0x0000000000001010
	.dword el1_vector_jump_cap
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
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600c53 // ldr x19, [c2, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400c53 // str x19, [c2, #0]
	ldr x19, =0x40400028
	mrs x2, ELR_EL1
	sub x19, x19, x2
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b262 // cvtp c2, x19
	.inst 0xc2d34042 // scvalue c2, c2, x19
	.inst 0x82600053 // ldr c19, [c2, #0]
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
