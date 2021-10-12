.section text0, #alloc, #execinstr
test_start:
	.inst 0xb076591d // ADRP-C.I-C Rd:29 immhi:111011001011001000 P:0 10000:10000 immlo:01 op:1
	.inst 0x82804c25 // ASTRH-R.RRB-32 Rt:5 Rn:1 opc:11 S:0 option:010 Rm:0 0:0 L:0 100000101:100000101
	.inst 0xda0801bb // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:27 Rn:13 000000:000000 Rm:8 11010000:11010000 S:0 op:1 sf:1
	.inst 0x88be7ffd // cas:aarch64/instrs/memory/atomicops/cas/single Rt:29 Rn:31 11111:11111 o0:0 Rs:30 1:1 L:0 0010001:0010001 size:10
	.inst 0xc276cb4e // LDR-C.RIB-C Ct:14 Rn:26 imm12:110110110010 L:1 110000100:110000100
	.inst 0x9b21c3ff // 0x9b21c3ff
	.inst 0xba5fb327 // 0xba5fb327
	.inst 0x22c348a1 // 0x22c348a1
	.inst 0xb840517e // 0xb840517e
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a25 // ldr c5, [x17, #2]
	.inst 0xc2400e2b // ldr c11, [x17, #3]
	.inst 0xc240123a // ldr c26, [x17, #4]
	.inst 0xc240163e // ldr c30, [x17, #5]
	/* Set up flags and system registers */
	ldr x17, =0x4000000
	msr SPSR_EL3, x17
	ldr x17, =initial_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884111 // msr CSP_EL0, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30d5d99f
	msr SCTLR_EL1, x17
	ldr x17, =0xc0000
	msr CPACR_EL1, x17
	ldr x17, =0x0
	msr S3_0_C1_C2_2, x17 // CCTLR_EL1
	ldr x17, =0x0
	msr S3_3_C1_C2_2, x17 // CCTLR_EL0
	ldr x17, =initial_DDC_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2884131 // msr DDC_EL0, c17
	ldr x17, =0x80000000
	msr HCR_EL2, x17
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82601051 // ldr c17, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc28e4031 // msr CELR_EL3, c17
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30851035
	msr SCTLR_EL3, x17
	isb
	/* Check processor flags */
	mrs x17, nzcv
	ubfx x17, x17, #28, #4
	mov x2, #0xf
	and x17, x17, x2
	cmp x17, #0x7
	b.ne comparison_fail
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400222 // ldr c2, [x17, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400622 // ldr c2, [x17, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2400e22 // ldr c2, [x17, #3]
	.inst 0xc2c2a561 // chkeq c11, c2
	b.ne comparison_fail
	.inst 0xc2401222 // ldr c2, [x17, #4]
	.inst 0xc2c2a5c1 // chkeq c14, c2
	b.ne comparison_fail
	.inst 0xc2401622 // ldr c2, [x17, #5]
	.inst 0xc2c2a641 // chkeq c18, c2
	b.ne comparison_fail
	.inst 0xc2401a22 // ldr c2, [x17, #6]
	.inst 0xc2c2a741 // chkeq c26, c2
	b.ne comparison_fail
	.inst 0xc2401e22 // ldr c2, [x17, #7]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2402222 // ldr c2, [x17, #8]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check system registers */
	ldr x17, =final_SP_EL0_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984102 // mrs c2, CSP_EL0
	.inst 0xc2c2a621 // chkeq c17, c2
	b.ne comparison_fail
	ldr x17, =final_PCC_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2984022 // mrs c2, CELR_EL1
	.inst 0xc2c2a621 // chkeq c17, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001020
	ldr x1, =check_data0
	ldr x2, =0x00001022
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f70
	ldr x1, =check_data1
	ldr x2, =0x00001f74
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fd0
	ldr x1, =check_data2
	ldr x2, =0x00001ff0
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
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	ldr x17, =0x30850030
	msr SCTLR_EL3, x17
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
	.zero 4096
.data
check_data0:
	.byte 0xd0, 0x1f
.data
check_data1:
	.byte 0x00, 0x10, 0xb1, 0x6e
.data
check_data2:
	.zero 32
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x1d, 0x59, 0x76, 0xb0, 0x25, 0x4c, 0x80, 0x82, 0xbb, 0x01, 0x08, 0xda, 0xfd, 0x7f, 0xbe, 0x88
	.byte 0x4e, 0xcb, 0x76, 0xc2, 0xff, 0xc3, 0x21, 0x9b, 0x27, 0xb3, 0x5f, 0xba, 0xa1, 0x48, 0xc3, 0x22
	.byte 0x7e, 0x51, 0x40, 0xb8, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x8
	/* C1 */
	.octa 0x1018
	/* C5 */
	.octa 0x80100000000100050000000000001fd0
	/* C11 */
	.octa 0x80000000000100050000000000001ff3
	/* C26 */
	.octa 0x8000000000010005ffffffffffff44c0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x8
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x80100000000100050000000000002030
	/* C11 */
	.octa 0x80000000000100050000000000001ff3
	/* C14 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x8000000000010005ffffffffffff44c0
	/* C29 */
	.octa 0x4000000000020007008000006eb11000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001f70
initial_DDC_EL0_value:
	.octa 0x4000000000020007007fffff81ff0000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001f70
final_PCC_value:
	.octa 0x200080001abd402f0000000040400028
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080001abd402f0000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL0_value
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
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02000231 // add c17, c17, #0
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02020231 // add c17, c17, #128
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02040231 // add c17, c17, #256
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02060231 // add c17, c17, #384
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02080231 // add c17, c17, #512
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x020a0231 // add c17, c17, #640
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x020c0231 // add c17, c17, #768
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x020e0231 // add c17, c17, #896
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02100231 // add c17, c17, #1024
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02120231 // add c17, c17, #1152
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02140231 // add c17, c17, #1280
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02160231 // add c17, c17, #1408
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x02180231 // add c17, c17, #1536
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x021a0231 // add c17, c17, #1664
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x021c0231 // add c17, c17, #1792
	.inst 0xc2c21220 // br c17
	.balign 128
	ldr x17, =esr_el1_dump_address
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600c51 // ldr x17, [c2, #0]
	cbnz x17, #28
	mrs x17, ESR_EL1
	.inst 0x82400c51 // str x17, [c2, #0]
	ldr x17, =0x40400028
	mrs x2, ELR_EL1
	sub x17, x17, x2
	cbnz x17, #8
	smc 0
	ldr x17, =initial_VBAR_EL1_value
	.inst 0xc2c5b222 // cvtp c2, x17
	.inst 0xc2d14042 // scvalue c2, c2, x17
	.inst 0x82600051 // ldr c17, [c2, #0]
	.inst 0x021e0231 // add c17, c17, #1920
	.inst 0xc2c21220 // br c17

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
