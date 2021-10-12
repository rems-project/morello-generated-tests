.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0x786f13bf // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:001 o3:0 Rs:15 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xfc4c43b0 // ldur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:16 Rn:29 00:00 imm9:011000100 0:0 opc:01 111100:111100 size:11
	.inst 0x11664ffe // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:31 imm12:100110010011 sh:1 0:0 10001:10001 S:0 op:0 sf:0
	.inst 0xc2c593bf // CVTD-C.R-C Cd:31 Rn:29 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xb9a49cc1 // 0xb9a49cc1
	.inst 0xc2c10409 // 0xc2c10409
	.inst 0xb87d73ff // 0xb87d73ff
	.inst 0x9b1e7e3d // 0x9b1e7e3d
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
	ldr x28, =initial_cap_values
	.inst 0xc2400380 // ldr c0, [x28, #0]
	.inst 0xc2400786 // ldr c6, [x28, #1]
	.inst 0xc2400b8f // ldr c15, [x28, #2]
	.inst 0xc2400f9d // ldr c29, [x28, #3]
	/* Set up flags and system registers */
	ldr x28, =0x4000000
	msr SPSR_EL3, x28
	ldr x28, =initial_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288411c // msr CSP_EL0, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30d5d99f
	msr SCTLR_EL1, x28
	ldr x28, =0x3c0000
	msr CPACR_EL1, x28
	ldr x28, =0x0
	msr S3_0_C1_C2_2, x28 // CCTLR_EL1
	ldr x28, =0x0
	msr S3_3_C1_C2_2, x28 // CCTLR_EL0
	ldr x28, =initial_DDC_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc288413c // msr DDC_EL0, c28
	ldr x28, =0x80000000
	msr HCR_EL2, x28
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826012fc // ldr c28, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc28e403c // msr CELR_EL3, c28
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x23, #0xf
	and x28, x28, x23
	cmp x28, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400397 // ldr c23, [x28, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400797 // ldr c23, [x28, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400b97 // ldr c23, [x28, #2]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2400f97 // ldr c23, [x28, #3]
	.inst 0xc2d7a521 // chkeq c9, c23
	b.ne comparison_fail
	.inst 0xc2401397 // ldr c23, [x28, #4]
	.inst 0xc2d7a5e1 // chkeq c15, c23
	b.ne comparison_fail
	.inst 0xc2401797 // ldr c23, [x28, #5]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x23, v16.d[0]
	cmp x28, x23
	b.ne comparison_fail
	ldr x28, =0x0
	mov x23, v16.d[1]
	cmp x28, x23
	b.ne comparison_fail
	/* Check system registers */
	ldr x28, =final_SP_EL0_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984117 // mrs c23, CSP_EL0
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	ldr x28, =final_PCC_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2984037 // mrs c23, CELR_EL1
	.inst 0xc2d7a781 // chkeq c28, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010c8
	ldr x1, =check_data1
	ldr x2, =0x000010d0
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
	ldr x0, =0x40403ff8
	ldr x1, =check_data3
	ldr x2, =0x40403ffc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
	.byte 0x05, 0x00, 0x00, 0x00, 0xeb, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x05, 0x00, 0x00, 0x00, 0xeb, 0xff
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xe1, 0x13, 0xc2, 0xc2, 0xbf, 0x13, 0x6f, 0x78, 0xb0, 0x43, 0x4c, 0xfc, 0xfe, 0x4f, 0x66, 0x11
	.byte 0xbf, 0x93, 0xc5, 0xc2, 0xc1, 0x9c, 0xa4, 0xb9, 0x09, 0x04, 0xc1, 0xc2, 0xff, 0x73, 0x7d, 0xb8
	.byte 0x3d, 0x7e, 0x1e, 0x9b, 0x01, 0x00, 0x00, 0xd4
.data
check_data3:
	.zero 4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x80000000000100050000000040401b5c
	/* C15 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000000300070000000000001004
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x3fff800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x80000000000100050000000040401b5c
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C30 */
	.octa 0x994000
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001000
initial_DDC_EL0_value:
	.octa 0x800300070080e00000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001000
final_PCC_value:
	.octa 0x20008000000080100000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080100000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword initial_SP_EL0_value
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
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0200039c // add c28, c28, #0
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0202039c // add c28, c28, #128
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0204039c // add c28, c28, #256
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0206039c // add c28, c28, #384
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0208039c // add c28, c28, #512
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x020a039c // add c28, c28, #640
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x020c039c // add c28, c28, #768
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x020e039c // add c28, c28, #896
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0210039c // add c28, c28, #1024
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0212039c // add c28, c28, #1152
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0214039c // add c28, c28, #1280
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0216039c // add c28, c28, #1408
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x0218039c // add c28, c28, #1536
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x021a039c // add c28, c28, #1664
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x021c039c // add c28, c28, #1792
	.inst 0xc2c21380 // br c28
	.balign 128
	ldr x28, =esr_el1_dump_address
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x82600efc // ldr x28, [c23, #0]
	cbnz x28, #28
	mrs x28, ESR_EL1
	.inst 0x82400efc // str x28, [c23, #0]
	ldr x28, =0x40400028
	mrs x23, ELR_EL1
	sub x28, x28, x23
	cbnz x28, #8
	smc 0
	ldr x28, =initial_VBAR_EL1_value
	.inst 0xc2c5b397 // cvtp c23, x28
	.inst 0xc2dc42f7 // scvalue c23, c23, x28
	.inst 0x826002fc // ldr c28, [c23, #0]
	.inst 0x021e039c // add c28, c28, #1920
	.inst 0xc2c21380 // br c28

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
