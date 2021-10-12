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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400483 // ldr c3, [x4, #1]
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2400c88 // ldr c8, [x4, #3]
	.inst 0xc2401094 // ldr c20, [x4, #4]
	.inst 0xc240149d // ldr c29, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Vector registers */
	mrs x4, cptr_el3
	bfc x4, #10, #1
	msr cptr_el3, x4
	isb
	ldr q15, =0x2404040080010801040000200020000
	/* Set up flags and system registers */
	ldr x4, =0x4000000
	msr SPSR_EL3, x4
	ldr x4, =initial_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2884104 // msr CSP_EL0, c4
	ldr x4, =initial_SP_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4104 // msr CSP_EL1, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30d5d99f
	msr SCTLR_EL1, x4
	ldr x4, =0x3c0000
	msr CPACR_EL1, x4
	ldr x4, =0x4
	msr S3_0_C1_C2_2, x4 // CCTLR_EL1
	ldr x4, =initial_DDC_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc28c4124 // msr DDC_EL1, c4
	ldr x4, =0x80000000
	msr HCR_EL2, x4
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82601224 // ldr c4, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc28e4024 // msr CELR_EL3, c4
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30851035
	msr SCTLR_EL3, x4
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc2400091 // ldr c17, [x4, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc2400491 // ldr c17, [x4, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400891 // ldr c17, [x4, #2]
	.inst 0xc2d1a461 // chkeq c3, c17
	b.ne comparison_fail
	.inst 0xc2400c91 // ldr c17, [x4, #3]
	.inst 0xc2d1a4c1 // chkeq c6, c17
	b.ne comparison_fail
	.inst 0xc2401091 // ldr c17, [x4, #4]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc2401491 // ldr c17, [x4, #5]
	.inst 0xc2d1a5a1 // chkeq c13, c17
	b.ne comparison_fail
	.inst 0xc2401891 // ldr c17, [x4, #6]
	.inst 0xc2d1a681 // chkeq c20, c17
	b.ne comparison_fail
	.inst 0xc2401c91 // ldr c17, [x4, #7]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2402091 // ldr c17, [x4, #8]
	.inst 0xc2d1a761 // chkeq c27, c17
	b.ne comparison_fail
	.inst 0xc2402491 // ldr c17, [x4, #9]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc2402891 // ldr c17, [x4, #10]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x1040000200020000
	mov x17, v15.d[0]
	cmp x4, x17
	b.ne comparison_fail
	ldr x4, =0x240404008001080
	mov x17, v15.d[1]
	cmp x4, x17
	b.ne comparison_fail
	/* Check system registers */
	ldr x4, =final_SP_EL0_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984111 // mrs c17, CSP_EL0
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	ldr x4, =final_SP_EL1_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc29c4111 // mrs c17, CSP_EL1
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	ldr x4, =final_PCC_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2984031 // mrs c17, CELR_EL1
	.inst 0xc2d1a481 // chkeq c4, c17
	b.ne comparison_fail
	ldr x17, =esr_el1_dump_address
	ldr x17, [x17]
	mov x4, 0x83
	orr x17, x17, x4
	ldr x4, =0x920000ab
	cmp x4, x17
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
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001081
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010a0
	ldr x1, =check_data2
	ldr x2, =0x000010b0
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
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr DDC_EL3, c4
	ldr x4, =0x30850030
	msr SCTLR_EL3, x4
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
	.zero 128
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0x00, 0x00, 0x02, 0x00, 0x02, 0x00, 0x40, 0x10, 0x80, 0x10, 0x00, 0x08, 0x40, 0x40, 0x40, 0x02
.data
check_data1:
	.byte 0x08
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
	.octa 0x1009
	/* C6 */
	.octa 0xcc100000600400060000000000001000
	/* C8 */
	.octa 0x1000
	/* C20 */
	.octa 0xc0000000000500040000000000001080
	/* C29 */
	.octa 0x40
	/* C30 */
	.octa 0x40102000010000008000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x1009
	/* C6 */
	.octa 0xcc100000600400060000000000001000
	/* C8 */
	.octa 0x1000
	/* C13 */
	.octa 0xf2d
	/* C20 */
	.octa 0xc0000000000500040000000000001080
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x40
	/* C30 */
	.octa 0x40102000010000008000000000000
initial_SP_EL0_value:
	.octa 0x3119400200008000
initial_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL1_value:
	.octa 0xd00000000003000700ffe00000000001
initial_VBAR_EL1_value:
	.octa 0x200080005000020e0000000040400000
final_SP_EL0_value:
	.octa 0x3119400200008000
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080005000020e0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000020100060000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x00000000000010a0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
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
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02000084 // add c4, c4, #0
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02020084 // add c4, c4, #128
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02040084 // add c4, c4, #256
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02060084 // add c4, c4, #384
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02080084 // add c4, c4, #512
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x020a0084 // add c4, c4, #640
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x020c0084 // add c4, c4, #768
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x020e0084 // add c4, c4, #896
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02100084 // add c4, c4, #1024
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02120084 // add c4, c4, #1152
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02140084 // add c4, c4, #1280
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02160084 // add c4, c4, #1408
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x02180084 // add c4, c4, #1536
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x021a0084 // add c4, c4, #1664
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x021c0084 // add c4, c4, #1792
	.inst 0xc2c21080 // br c4
	.balign 128
	ldr x4, =esr_el1_dump_address
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600e24 // ldr x4, [c17, #0]
	cbnz x4, #28
	mrs x4, ESR_EL1
	.inst 0x82400e24 // str x4, [c17, #0]
	ldr x4, =0x40400414
	mrs x17, ELR_EL1
	sub x4, x4, x17
	cbnz x4, #8
	smc 0
	ldr x4, =initial_VBAR_EL1_value
	.inst 0xc2c5b091 // cvtp c17, x4
	.inst 0xc2c44231 // scvalue c17, c17, x4
	.inst 0x82600224 // ldr c4, [c17, #0]
	.inst 0x021e0084 // add c4, c4, #1920
	.inst 0xc2c21080 // br c4

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
