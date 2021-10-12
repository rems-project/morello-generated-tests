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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400746 // ldr c6, [x26, #1]
	.inst 0xc2400b4f // ldr c15, [x26, #2]
	.inst 0xc2400f5d // ldr c29, [x26, #3]
	/* Set up flags and system registers */
	ldr x26, =0x4000000
	msr SPSR_EL3, x26
	ldr x26, =initial_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288411a // msr CSP_EL0, c26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30d5d99f
	msr SCTLR_EL1, x26
	ldr x26, =0x3c0000
	msr CPACR_EL1, x26
	ldr x26, =0x0
	msr S3_0_C1_C2_2, x26 // CCTLR_EL1
	ldr x26, =0x0
	msr S3_3_C1_C2_2, x26 // CCTLR_EL0
	ldr x26, =initial_DDC_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc288413a // msr DDC_EL0, c26
	ldr x26, =0x80000000
	msr HCR_EL2, x26
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x8260105a // ldr c26, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc28e403a // msr CELR_EL3, c26
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30851035
	msr SCTLR_EL3, x26
	isb
	/* Check processor flags */
	mrs x26, nzcv
	ubfx x26, x26, #28, #4
	mov x2, #0xf
	and x26, x26, x2
	cmp x26, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc2400342 // ldr c2, [x26, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400742 // ldr c2, [x26, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400b42 // ldr c2, [x26, #2]
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	.inst 0xc2400f42 // ldr c2, [x26, #3]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc2401342 // ldr c2, [x26, #4]
	.inst 0xc2c2a5e1 // chkeq c15, c2
	b.ne comparison_fail
	.inst 0xc2401742 // ldr c2, [x26, #5]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x26, =0x0
	mov x2, v16.d[0]
	cmp x26, x2
	b.ne comparison_fail
	ldr x26, =0x0
	mov x2, v16.d[1]
	cmp x26, x2
	b.ne comparison_fail
	/* Check system registers */
	ldr x26, =final_SP_EL0_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984102 // mrs c2, CSP_EL0
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	ldr x26, =final_PCC_value
	.inst 0xc240035a // ldr c26, [x26, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001034
	ldr x1, =check_data0
	ldr x2, =0x00001036
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000010f8
	ldr x1, =check_data1
	ldr x2, =0x00001100
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e0
	ldr x1, =check_data2
	ldr x2, =0x000011e4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001944
	ldr x1, =check_data3
	ldr x2, =0x00001948
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
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr DDC_EL3, c26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
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
	.zero 48
	.byte 0x00, 0x00, 0x00, 0x00, 0x77, 0xfd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 416
	.byte 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3600
.data
check_data0:
	.byte 0x77, 0xfd
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0x34, 0x10, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0xe1, 0x13, 0xc2, 0xc2, 0xbf, 0x13, 0x6f, 0x78, 0xb0, 0x43, 0x4c, 0xfc, 0xfe, 0x4f, 0x66, 0x11
	.byte 0xbf, 0x93, 0xc5, 0xc2, 0xc1, 0x9c, 0xa4, 0xb9, 0x09, 0x04, 0xc1, 0xc2, 0xff, 0x73, 0x7d, 0xb8
	.byte 0x3d, 0x7e, 0x1e, 0x9b, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C6 */
	.octa 0x8000000000070027fffffffffffff4a8
	/* C15 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000401401e50000000000001034
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C6 */
	.octa 0x8000000000070027fffffffffffff4a8
	/* C9 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C30 */
	.octa 0x9941e0
initial_SP_EL0_value:
	.octa 0xc00000000001000500000000000011e0
initial_DDC_EL0_value:
	.octa 0x701120220000000000000000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc00000000001000500000000000011e0
final_PCC_value:
	.octa 0x20008000000000000000000040400028
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
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0200035a // add c26, c26, #0
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0202035a // add c26, c26, #128
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0204035a // add c26, c26, #256
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0206035a // add c26, c26, #384
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0208035a // add c26, c26, #512
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x020a035a // add c26, c26, #640
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x020c035a // add c26, c26, #768
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x020e035a // add c26, c26, #896
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0210035a // add c26, c26, #1024
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0212035a // add c26, c26, #1152
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0214035a // add c26, c26, #1280
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0216035a // add c26, c26, #1408
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x0218035a // add c26, c26, #1536
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x021a035a // add c26, c26, #1664
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x021c035a // add c26, c26, #1792
	.inst 0xc2c21340 // br c26
	.balign 128
	ldr x26, =esr_el1_dump_address
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x82600c5a // ldr x26, [c2, #0]
	cbnz x26, #28
	mrs x26, ESR_EL1
	.inst 0x82400c5a // str x26, [c2, #0]
	ldr x26, =0x40400028
	mrs x2, ELR_EL1
	sub x26, x26, x2
	cbnz x26, #8
	smc 0
	ldr x26, =initial_VBAR_EL1_value
	.inst 0xc2c5b342 // cvtp c2, x26
	.inst 0xc2da4042 // scvalue c2, c2, x26
	.inst 0x8260005a // ldr c26, [c2, #0]
	.inst 0x021e035a // add c26, c26, #1920
	.inst 0xc2c21340 // br c26

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
