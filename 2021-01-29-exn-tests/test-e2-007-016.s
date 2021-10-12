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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400845 // ldr c5, [x2, #2]
	.inst 0xc2400c4b // ldr c11, [x2, #3]
	.inst 0xc240105a // ldr c26, [x2, #4]
	.inst 0xc240145e // ldr c30, [x2, #5]
	/* Set up flags and system registers */
	ldr x2, =0x4000000
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
	ldr x2, =0x0
	msr S3_3_C1_C2_2, x2 // CCTLR_EL0
	ldr x2, =initial_DDC_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2884122 // msr DDC_EL0, c2
	ldr x2, =0x80000000
	msr HCR_EL2, x2
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82601122 // ldr c2, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
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
	/* Check processor flags */
	mrs x2, nzcv
	ubfx x2, x2, #28, #4
	mov x9, #0xf
	and x2, x2, x9
	cmp x2, #0x7
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400049 // ldr c9, [x2, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400449 // ldr c9, [x2, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400849 // ldr c9, [x2, #2]
	.inst 0xc2c9a4a1 // chkeq c5, c9
	b.ne comparison_fail
	.inst 0xc2400c49 // ldr c9, [x2, #3]
	.inst 0xc2c9a561 // chkeq c11, c9
	b.ne comparison_fail
	.inst 0xc2401049 // ldr c9, [x2, #4]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401449 // ldr c9, [x2, #5]
	.inst 0xc2c9a641 // chkeq c18, c9
	b.ne comparison_fail
	.inst 0xc2401849 // ldr c9, [x2, #6]
	.inst 0xc2c9a741 // chkeq c26, c9
	b.ne comparison_fail
	.inst 0xc2401c49 // ldr c9, [x2, #7]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2402049 // ldr c9, [x2, #8]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984109 // mrs c9, CSP_EL0
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984029 // mrs c9, CELR_EL1
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001200
	ldr x1, =check_data0
	ldr x2, =0x00001202
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001400
	ldr x1, =check_data1
	ldr x2, =0x00001404
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
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
	ldr x0, =0x40409000
	ldr x1, =check_data5
	ldr x2, =0x40409020
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	.zero 4064
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
	.zero 16
.data
check_data0:
	.byte 0x00, 0x90
.data
check_data1:
	.byte 0x00, 0x10, 0x02, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x01, 0x00, 0x00
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x1d, 0x59, 0x76, 0xb0, 0x25, 0x4c, 0x80, 0x82, 0xbb, 0x01, 0x08, 0xda, 0xfd, 0x7f, 0xbe, 0x88
	.byte 0x4e, 0xcb, 0x76, 0xc2, 0xff, 0xc3, 0x21, 0x9b, 0x27, 0xb3, 0x5f, 0xba, 0xa1, 0x48, 0xc3, 0x22
	.byte 0x7e, 0x51, 0x40, 0xb8, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 32

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000
	/* C1 */
	.octa 0xffffffff80001200
	/* C5 */
	.octa 0x90100000400480420000000040409000
	/* C11 */
	.octa 0x80000000000100050000000000001ff3
	/* C26 */
	.octa 0x9000000000010005ffffffffffff44c0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x80000000
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x90100000400480420000000040409060
	/* C11 */
	.octa 0x80000000000100050000000000001ff3
	/* C14 */
	.octa 0x101800000000000000000000000
	/* C18 */
	.octa 0x0
	/* C26 */
	.octa 0x9000000000010005ffffffffffff44c0
	/* C29 */
	.octa 0x40000000000300070100000000021000
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0xc0000000000100050000000000001400
initial_DDC_EL0_value:
	.octa 0x400000000003000700ffffff13500000
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0xc0000000000100050000000000001400
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
	.dword 0x0000000000001fe0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword el1_vector_jump_cap
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
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
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600d22 // ldr x2, [c9, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400d22 // str x2, [c9, #0]
	ldr x2, =0x40400028
	mrs x9, ELR_EL1
	sub x2, x2, x9
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b049 // cvtp c9, x2
	.inst 0xc2c24129 // scvalue c9, c9, x2
	.inst 0x82600122 // ldr c2, [c9, #0]
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
