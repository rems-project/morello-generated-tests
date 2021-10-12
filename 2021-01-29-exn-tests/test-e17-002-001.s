.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c413f8 // LDPBR-C.C-C Ct:24 Cn:31 100:100 opc:00 11000010110001000:11000010110001000
	.zero 12328
	.inst 0xc2ff5b9e // CVTZ-C.CR-C Cd:30 Cn:28 0110:0110 1:1 0:0 Rm:31 11000010111:11000010111
	.inst 0x78bf10f5 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:21 Rn:7 00:00 opc:001 0:0 Rs:31 1:1 R:0 A:1 111000:111000 size:01
	.inst 0x2936781f // stp_gen:aarch64/instrs/memory/pair/general/offset Rt:31 Rn:0 Rt2:11110 imm7:1101100 L:0 1010010:1010010 opc:00
	.inst 0xf29bd209 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:9 imm16:1101111010010000 hw:00 100101:100101 opc:11 sf:1
	.inst 0x1ad20d01 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:8 o1:1 00001:00001 Rm:18 0011010110:0011010110 sf:0
	.inst 0x3809dbb1 // sttrb:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:17 Rn:29 10:10 imm9:010011101 0:0 opc:00 111000:111000 size:00
	.inst 0x8b2a63bf // add_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:29 imm3:000 option:011 Rm:10 01011001:01011001 S:0 op:0 sf:1
	.inst 0x881efd7a // stlxr:aarch64/instrs/memory/exclusive/single Rt:26 Rn:11 Rt2:11111 o0:1 Rs:30 0:0 L:0 0010000:0010000 size:10
	.inst 0xd4000001
	.zero 53168
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400447 // ldr c7, [x2, #1]
	.inst 0xc240084b // ldr c11, [x2, #2]
	.inst 0xc2400c51 // ldr c17, [x2, #3]
	.inst 0xc2401052 // ldr c18, [x2, #4]
	.inst 0xc240145c // ldr c28, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	/* Set up flags and system registers */
	ldr x2, =0x0
	msr SPSR_EL3, x2
	ldr x2, =initial_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884102 // msr CSP_EL0, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30d5d99f
	msr SCTLR_EL1, x2
	ldr x2, =0xc0000
	msr CPACR_EL1, x2
	ldr x2, =0x0
	msr S3_0_C1_C2_2, x2 // CCTLR_EL1
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x82601362 // ldr c2, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc28e4022 // msr CELR_EL3, c2
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240005b // ldr c27, [x2, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240045b // ldr c27, [x2, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc240085b // ldr c27, [x2, #2]
	.inst 0xc2dba4e1 // chkeq c7, c27
	b.ne comparison_fail
	.inst 0xc2400c5b // ldr c27, [x2, #3]
	.inst 0xc2dba561 // chkeq c11, c27
	b.ne comparison_fail
	.inst 0xc240105b // ldr c27, [x2, #4]
	.inst 0xc2dba621 // chkeq c17, c27
	b.ne comparison_fail
	.inst 0xc240145b // ldr c27, [x2, #5]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc240185b // ldr c27, [x2, #6]
	.inst 0xc2dba6a1 // chkeq c21, c27
	b.ne comparison_fail
	.inst 0xc2401c5b // ldr c27, [x2, #7]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240205b // ldr c27, [x2, #8]
	.inst 0xc2dba781 // chkeq c28, c27
	b.ne comparison_fail
	.inst 0xc240245b // ldr c27, [x2, #9]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc240285b // ldr c27, [x2, #10]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc298403b // mrs c27, CELR_EL1
	.inst 0xc2dba441 // chkeq c2, c27
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
	ldr x0, =0x00001068
	ldr x1, =check_data1
	ldr x2, =0x0000106a
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a14
	ldr x1, =check_data2
	ldr x2, =0x00001a1c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff8
	ldr x1, =check_data3
	ldr x2, =0x00001ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ffe
	ldr x1, =check_data4
	ldr x2, =0x00001fff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400004
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x4040302c
	ldr x1, =check_data6
	ldr x2, =0x40403050
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x2d, 0x30, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x40, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.byte 0x2d, 0x30, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x08, 0x40, 0x00, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0xf8, 0x13, 0xc4, 0xc2
.data
check_data6:
	.byte 0x9e, 0x5b, 0xff, 0xc2, 0xf5, 0x10, 0xbf, 0x78, 0x1f, 0x78, 0x36, 0x29, 0x09, 0xd2, 0x9b, 0xf2
	.byte 0x01, 0x0d, 0xd2, 0x1a, 0xb1, 0xdb, 0x09, 0x38, 0xbf, 0x63, 0x2a, 0x8b, 0x7a, 0xfd, 0x1e, 0x88
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001a64
	/* C7 */
	.octa 0xc0000000000100050000000000001068
	/* C11 */
	.octa 0x40000000000100050000000000001ff8
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x40000000000100050000000000001f61
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x40000000000100050000000000001a64
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0xc0000000000100050000000000001068
	/* C11 */
	.octa 0x40000000000100050000000000001ff8
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C24 */
	.octa 0x101800000000000000000000000
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x40000000000100050000000000001f61
	/* C30 */
	.octa 0x1
initial_SP_EL0_value:
	.octa 0x90000000000100050000000000001000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000040080000000040403050
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300030000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL0_value
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600f62 // ldr x2, [c27, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400f62 // str x2, [c27, #0]
	ldr x2, =0x40403050
	mrs x27, ELR_EL1
	sub x2, x2, x27
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b05b // cvtp c27, x2
	.inst 0xc2c2437b // scvalue c27, c27, x2
	.inst 0x82600362 // ldr c2, [c27, #0]
	.inst 0x021e0042 // add c2, c2, #1920
	.inst 0xc2c21040 // br c2

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
