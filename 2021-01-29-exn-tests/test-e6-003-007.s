.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2fe80db // SWPAL-CC.R-C Ct:27 Rn:6 100000:100000 Cs:30 1:1 R:1 A:1 10100010:10100010
	.inst 0x5a1903bf // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:29 000000:000000 Rm:25 11010000:11010000 S:0 op:1 sf:0
	.inst 0x38fd529f // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:20 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x1ac1210d // lslv:aarch64/instrs/integer/shift/variable Rd:13 Rn:8 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xb89db7ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:31 01:01 imm9:111011011 0:0 opc:10 111000:111000 size:10
	.zero 1004
	.inst 0xa2497078 // 0xa2497078
	.inst 0xc2c9abf5 // 0xc2c9abf5
	.inst 0x799b0900 // 0x799b0900
	.inst 0x3c92d5af // 0x3c92d5af
	.inst 0xd4000001
	.zero 64492
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400603 // ldr c3, [x16, #1]
	.inst 0xc2400a06 // ldr c6, [x16, #2]
	.inst 0xc2400e08 // ldr c8, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc240161d // ldr c29, [x16, #5]
	.inst 0xc2401a1e // ldr c30, [x16, #6]
	/* Vector registers */
	mrs x16, cptr_el3
	bfc x16, #10, #1
	msr cptr_el3, x16
	isb
	ldr q15, =0x4020000000000000000000020200000
	/* Set up flags and system registers */
	ldr x16, =0x4000000
	msr SPSR_EL3, x16
	ldr x16, =initial_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2884110 // msr CSP_EL0, c16
	ldr x16, =initial_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4110 // msr CSP_EL1, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30d5d99f
	msr SCTLR_EL1, x16
	ldr x16, =0x1c0000
	msr CPACR_EL1, x16
	ldr x16, =0x4
	msr S3_0_C1_C2_2, x16 // CCTLR_EL1
	ldr x16, =initial_DDC_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc28c4130 // msr DDC_EL1, c16
	ldr x16, =0x80000000
	msr HCR_EL2, x16
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010f0 // ldr c16, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
	.inst 0xc28e4030 // msr CELR_EL3, c16
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30851035
	msr SCTLR_EL3, x16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400207 // ldr c7, [x16, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400607 // ldr c7, [x16, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400e07 // ldr c7, [x16, #3]
	.inst 0xc2c7a4c1 // chkeq c6, c7
	b.ne comparison_fail
	.inst 0xc2401207 // ldr c7, [x16, #4]
	.inst 0xc2c7a501 // chkeq c8, c7
	b.ne comparison_fail
	.inst 0xc2401607 // ldr c7, [x16, #5]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401a07 // ldr c7, [x16, #6]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401e07 // ldr c7, [x16, #7]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc2402207 // ldr c7, [x16, #8]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402607 // ldr c7, [x16, #9]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402a07 // ldr c7, [x16, #10]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x20200000
	mov x7, v15.d[0]
	cmp x16, x7
	b.ne comparison_fail
	ldr x16, =0x402000000000000
	mov x7, v15.d[1]
	cmp x16, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x16, =final_SP_EL0_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	ldr x16, =final_SP_EL1_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc29c4107 // mrs c7, CSP_EL1
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	ldr x16, =final_PCC_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	ldr x7, =esr_el1_dump_address
	ldr x7, [x7]
	mov x16, 0x83
	orr x7, x7, x16
	ldr x16, =0x920000ab
	cmp x16, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001050
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001200
	ldr x1, =check_data2
	ldr x2, =0x00001210
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d84
	ldr x1, =check_data3
	ldr x2, =0x00001d86
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
	ldr x2, =0x40400414
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
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
	.byte 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x20, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x04
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xdb, 0x80, 0xfe, 0xa2, 0xbf, 0x03, 0x19, 0x5a, 0x9f, 0x52, 0xfd, 0x38, 0x0d, 0x21, 0xc1, 0x1a
	.byte 0xff, 0xb7, 0x9d, 0xb8
.data
check_data5:
	.byte 0x78, 0x70, 0x49, 0xa2, 0xf5, 0xab, 0xc9, 0xc2, 0x00, 0x09, 0x9b, 0x79, 0xaf, 0xd5, 0x92, 0x3c
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0xfa9
	/* C6 */
	.octa 0xcc10000058040c6c0000000000001200
	/* C8 */
	.octa 0x1000
	/* C20 */
	.octa 0xc00000005004001a0000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0xfa9
	/* C6 */
	.octa 0xcc10000058040c6c0000000000001200
	/* C8 */
	.octa 0x1000
	/* C13 */
	.octa 0xf2d
	/* C20 */
	.octa 0xc00000005004001a0000000000001000
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x8000000000560010300401a0
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc01000003ff900070080000000000001
initial_VBAR_EL1_value:
	.octa 0x200080004000004d0000000040400000
final_SP_EL0_value:
	.octa 0x8000000000560010300401a0
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080004000004d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001040
	.dword 0x0000000000001200
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword initial_SP_EL0_value
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02000210 // add c16, c16, #0
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02020210 // add c16, c16, #128
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02040210 // add c16, c16, #256
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02060210 // add c16, c16, #384
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02080210 // add c16, c16, #512
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x020a0210 // add c16, c16, #640
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x020c0210 // add c16, c16, #768
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x020e0210 // add c16, c16, #896
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02100210 // add c16, c16, #1024
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02120210 // add c16, c16, #1152
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02140210 // add c16, c16, #1280
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02160210 // add c16, c16, #1408
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x02180210 // add c16, c16, #1536
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x021a0210 // add c16, c16, #1664
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x021c0210 // add c16, c16, #1792
	.inst 0xc2c21200 // br c16
	.balign 128
	ldr x16, =esr_el1_dump_address
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x82600cf0 // ldr x16, [c7, #0]
	cbnz x16, #28
	mrs x16, ESR_EL1
	.inst 0x82400cf0 // str x16, [c7, #0]
	ldr x16, =0x40400414
	mrs x7, ELR_EL1
	sub x16, x16, x7
	cbnz x16, #8
	smc 0
	ldr x16, =initial_VBAR_EL1_value
	.inst 0xc2c5b207 // cvtp c7, x16
	.inst 0xc2d040e7 // scvalue c7, c7, x16
	.inst 0x826000f0 // ldr c16, [c7, #0]
	.inst 0x021e0210 // add c16, c16, #1920
	.inst 0xc2c21200 // br c16

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
