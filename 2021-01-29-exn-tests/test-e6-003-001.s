.section text0, #alloc, #execinstr
test_start:
	.inst 0xa2fe80db // SWPAL-CC.R-C Ct:27 Rn:6 100000:100000 Cs:30 1:1 R:1 A:1 10100010:10100010
	.inst 0x5a1903bf // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:29 000000:000000 Rm:25 11010000:11010000 S:0 op:1 sf:0
	.inst 0x38fd529f // ldsminb:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:20 00:00 opc:101 0:0 Rs:29 1:1 R:1 A:1 111000:111000 size:00
	.inst 0x1ac1210d // lslv:aarch64/instrs/integer/shift/variable Rd:13 Rn:8 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xb89db7ff // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:31 01:01 imm9:111011011 0:0 opc:10 111000:111000 size:10
	.zero 1004
	.inst 0xa2497078 // LDUR-C.RI-C Ct:24 Rn:3 00:00 imm9:010010111 0:0 opc:01 10100010:10100010
	.inst 0xc2c9abf5 // EORFLGS-C.CR-C Cd:21 Cn:31 1010:1010 opc:10 Rm:9 11000010110:11000010110
	.inst 0x799b0900 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:8 imm12:011011000010 opc:10 111001:111001 size:01
	.inst 0x3c92d5af // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:15 Rn:13 01:01 imm9:100101101 0:0 opc:10 111100:111100 size:00
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e1 // ldr c1, [x7, #0]
	.inst 0xc24004e3 // ldr c3, [x7, #1]
	.inst 0xc24008e6 // ldr c6, [x7, #2]
	.inst 0xc2400ce8 // ldr c8, [x7, #3]
	.inst 0xc24010f4 // ldr c20, [x7, #4]
	.inst 0xc24014fd // ldr c29, [x7, #5]
	.inst 0xc24018fe // ldr c30, [x7, #6]
	/* Vector registers */
	mrs x7, cptr_el3
	bfc x7, #10, #1
	msr cptr_el3, x7
	isb
	ldr q15, =0x2004000000000008000000000000000
	/* Set up flags and system registers */
	ldr x7, =0x4000000
	msr SPSR_EL3, x7
	ldr x7, =initial_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2884107 // msr CSP_EL0, c7
	ldr x7, =initial_SP_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4107 // msr CSP_EL1, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30d5d99f
	msr SCTLR_EL1, x7
	ldr x7, =0x1c0000
	msr CPACR_EL1, x7
	ldr x7, =0x4
	msr S3_0_C1_C2_2, x7 // CCTLR_EL1
	ldr x7, =initial_DDC_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc28c4127 // msr DDC_EL1, c7
	ldr x7, =0x80000000
	msr HCR_EL2, x7
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012c7 // ldr c7, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4027 // msr CELR_EL3, c7
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f6 // ldr c22, [x7, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24004f6 // ldr c22, [x7, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24008f6 // ldr c22, [x7, #2]
	.inst 0xc2d6a461 // chkeq c3, c22
	b.ne comparison_fail
	.inst 0xc2400cf6 // ldr c22, [x7, #3]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24010f6 // ldr c22, [x7, #4]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc24014f6 // ldr c22, [x7, #5]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc24018f6 // ldr c22, [x7, #6]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401cf6 // ldr c22, [x7, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc24020f6 // ldr c22, [x7, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc24024f6 // ldr c22, [x7, #9]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc24028f6 // ldr c22, [x7, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x8000000000000000
	mov x22, v15.d[0]
	cmp x7, x22
	b.ne comparison_fail
	ldr x7, =0x200400000000000
	mov x22, v15.d[1]
	cmp x7, x22
	b.ne comparison_fail
	/* Check system registers */
	ldr x7, =final_SP_EL0_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984116 // mrs c22, CSP_EL0
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	ldr x7, =final_SP_EL1_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc29c4116 // mrs c22, CSP_EL1
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	ldr x7, =final_PCC_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	ldr x22, =esr_el1_dump_address
	ldr x22, [x22]
	mov x7, 0x0
	orr x22, x22, x7
	ldr x7, =0x9a000000
	cmp x7, x22
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
	ldr x0, =0x000010c0
	ldr x1, =check_data1
	ldr x2, =0x000010d0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000180c
	ldr x1, =check_data2
	ldr x2, =0x0000180d
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
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x02
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 1
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
	.octa 0x29
	/* C6 */
	.octa 0xcc100000000300070000000000001000
	/* C8 */
	.octa 0x0
	/* C20 */
	.octa 0xc000000040010006000000000000180c
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
	.octa 0x29
	/* C6 */
	.octa 0xcc100000000300070000000000001000
	/* C8 */
	.octa 0x0
	/* C13 */
	.octa 0xffffffffffffff2d
	/* C20 */
	.octa 0xc000000040010006000000000000180c
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x234
initial_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
initial_DDC_EL1_value:
	.octa 0xd00000001e87100700ffffffffffe000
initial_VBAR_EL1_value:
	.octa 0x200080007000001d0000000040400000
final_SP_EL0_value:
	.octa 0x234
final_SP_EL1_value:
	.octa 0x3fff800000000000000000000000
final_PCC_value:
	.octa 0x200080007000001d0000000040400414
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
	.dword 0x0000000000001000
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword el1_vector_jump_cap
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 160
	.dword initial_DDC_EL1_value
	.dword initial_VBAR_EL1_value
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
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020000e7 // add c7, c7, #0
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020200e7 // add c7, c7, #128
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020400e7 // add c7, c7, #256
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020600e7 // add c7, c7, #384
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020800e7 // add c7, c7, #512
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020a00e7 // add c7, c7, #640
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020c00e7 // add c7, c7, #768
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x020e00e7 // add c7, c7, #896
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021000e7 // add c7, c7, #1024
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021200e7 // add c7, c7, #1152
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021400e7 // add c7, c7, #1280
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021600e7 // add c7, c7, #1408
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021800e7 // add c7, c7, #1536
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021a00e7 // add c7, c7, #1664
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021c00e7 // add c7, c7, #1792
	.inst 0xc2c210e0 // br c7
	.balign 128
	ldr x7, =esr_el1_dump_address
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x82600ec7 // ldr x7, [c22, #0]
	cbnz x7, #28
	mrs x7, ESR_EL1
	.inst 0x82400ec7 // str x7, [c22, #0]
	ldr x7, =0x40400414
	mrs x22, ELR_EL1
	sub x7, x7, x22
	cbnz x7, #8
	smc 0
	ldr x7, =initial_VBAR_EL1_value
	.inst 0xc2c5b0f6 // cvtp c22, x7
	.inst 0xc2c742d6 // scvalue c22, c22, x7
	.inst 0x826002c7 // ldr c7, [c22, #0]
	.inst 0x021e00e7 // add c7, c7, #1920
	.inst 0xc2c210e0 // br c7

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
