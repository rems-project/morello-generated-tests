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
	ldr x14, =initial_cap_values
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2400dc8 // ldr c8, [x14, #3]
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc24015dd // ldr c29, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q15, =0x80000180000000010400000000000000
	/* Set up flags and system registers */
	ldr x14, =0x4000000
	msr SPSR_EL3, x14
	ldr x14, =initial_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc288410e // msr CSP_EL0, c14
	ldr x14, =initial_SP_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c410e // msr CSP_EL1, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30d5d99f
	msr SCTLR_EL1, x14
	ldr x14, =0x3c0000
	msr CPACR_EL1, x14
	ldr x14, =0x4
	msr S3_0_C1_C2_2, x14 // CCTLR_EL1
	ldr x14, =initial_DDC_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc28c412e // msr DDC_EL1, c14
	ldr x14, =0x80000000
	msr HCR_EL2, x14
	isb
	/* Start test */
	ldr x4, =pcc_return_ddc_capabilities
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0x8260108e // ldr c14, [c4, #1]
	.inst 0x82602084 // ldr c4, [c4, #2]
	.inst 0xc28e402e // msr CELR_EL3, c14
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc2c4a401 // chkeq c0, c4
	b.ne comparison_fail
	.inst 0xc24005c4 // ldr c4, [x14, #1]
	.inst 0xc2c4a421 // chkeq c1, c4
	b.ne comparison_fail
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2c4a461 // chkeq c3, c4
	b.ne comparison_fail
	.inst 0xc2400dc4 // ldr c4, [x14, #3]
	.inst 0xc2c4a4c1 // chkeq c6, c4
	b.ne comparison_fail
	.inst 0xc24011c4 // ldr c4, [x14, #4]
	.inst 0xc2c4a501 // chkeq c8, c4
	b.ne comparison_fail
	.inst 0xc24015c4 // ldr c4, [x14, #5]
	.inst 0xc2c4a5a1 // chkeq c13, c4
	b.ne comparison_fail
	.inst 0xc24019c4 // ldr c4, [x14, #6]
	.inst 0xc2c4a681 // chkeq c20, c4
	b.ne comparison_fail
	.inst 0xc2401dc4 // ldr c4, [x14, #7]
	.inst 0xc2c4a701 // chkeq c24, c4
	b.ne comparison_fail
	.inst 0xc24021c4 // ldr c4, [x14, #8]
	.inst 0xc2c4a761 // chkeq c27, c4
	b.ne comparison_fail
	.inst 0xc24025c4 // ldr c4, [x14, #9]
	.inst 0xc2c4a7a1 // chkeq c29, c4
	b.ne comparison_fail
	.inst 0xc24029c4 // ldr c4, [x14, #10]
	.inst 0xc2c4a7c1 // chkeq c30, c4
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x400000000000000
	mov x4, v15.d[0]
	cmp x14, x4
	b.ne comparison_fail
	ldr x14, =0x8000018000000001
	mov x4, v15.d[1]
	cmp x14, x4
	b.ne comparison_fail
	/* Check system registers */
	ldr x14, =final_SP_EL0_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984104 // mrs c4, CSP_EL0
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	ldr x14, =final_SP_EL1_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc29c4104 // mrs c4, CSP_EL1
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	ldr x14, =final_PCC_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2984024 // mrs c4, CELR_EL1
	.inst 0xc2c4a5c1 // chkeq c14, c4
	b.ne comparison_fail
	ldr x4, =esr_el1_dump_address
	ldr x4, [x4]
	mov x14, 0x83
	orr x4, x4, x14
	ldr x14, =0x920000ab
	cmp x14, x4
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
	ldr x2, =0x00001041
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010d0
	ldr x1, =check_data2
	ldr x2, =0x000010e0
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
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x80
.data
check_data1:
	.zero 1
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
	.octa 0x839
	/* C6 */
	.octa 0xcc100000000064080000000000001000
	/* C8 */
	.octa 0x800
	/* C20 */
	.octa 0xc0000000400400070000000000001040
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000000000000000000000
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x839
	/* C6 */
	.octa 0xcc100000000064080000000000001000
	/* C8 */
	.octa 0x800
	/* C13 */
	.octa 0x72d
	/* C20 */
	.octa 0xc0000000400400070000000000001040
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000000000000000000000
initial_SP_EL0_value:
	.octa 0x80000000480206e650c00000c07fe3e0
initial_SP_EL1_value:
	.octa 0x0
initial_DDC_EL1_value:
	.octa 0xc00000005e04080000ffffffffffe201
initial_VBAR_EL1_value:
	.octa 0x200080005000004d0000000040400000
final_SP_EL0_value:
	.octa 0x80000000480206e650c00000c07fe3e0
final_SP_EL1_value:
	.octa 0x0
final_PCC_value:
	.octa 0x200080005000004d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000000c0000000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x00000000000010d0
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
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020001ce // add c14, c14, #0
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020201ce // add c14, c14, #128
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020401ce // add c14, c14, #256
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020601ce // add c14, c14, #384
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020801ce // add c14, c14, #512
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020a01ce // add c14, c14, #640
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020c01ce // add c14, c14, #768
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x020e01ce // add c14, c14, #896
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021001ce // add c14, c14, #1024
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021201ce // add c14, c14, #1152
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021401ce // add c14, c14, #1280
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021601ce // add c14, c14, #1408
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021801ce // add c14, c14, #1536
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021a01ce // add c14, c14, #1664
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021c01ce // add c14, c14, #1792
	.inst 0xc2c211c0 // br c14
	.balign 128
	ldr x14, =esr_el1_dump_address
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x82600c8e // ldr x14, [c4, #0]
	cbnz x14, #28
	mrs x14, ESR_EL1
	.inst 0x82400c8e // str x14, [c4, #0]
	ldr x14, =0x40400414
	mrs x4, ELR_EL1
	sub x14, x14, x4
	cbnz x14, #8
	smc 0
	ldr x14, =initial_VBAR_EL1_value
	.inst 0xc2c5b1c4 // cvtp c4, x14
	.inst 0xc2ce4084 // scvalue c4, c4, x14
	.inst 0x8260008e // ldr c14, [c4, #0]
	.inst 0x021e01ce // add c14, c14, #1920
	.inst 0xc2c211c0 // br c14

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
