.section text0, #alloc, #execinstr
test_start:
	.inst 0x82d5d0a1 // ALDRB-R.RRB-B Rt:1 Rn:5 opc:00 S:1 option:110 Rm:21 0:0 L:1 100000101:100000101
	.inst 0xf093e51c // ADRP-C.IP-C Rd:28 immhi:001001111100101000 P:1 10000:10000 immlo:11 op:1
	.inst 0xb80e6bfc // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:28 Rn:31 10:10 imm9:011100110 0:0 opc:00 111000:111000 size:10
	.inst 0xba1f03c1 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:30 000000:000000 Rm:31 11010000:11010000 S:1 op:0 sf:1
	.inst 0x789cace4 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:4 Rn:7 11:11 imm9:111001010 0:0 opc:10 111000:111000 size:01
	.zero 1004
	.inst 0x7880be3f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:17 11:11 imm9:000001011 0:0 opc:10 111000:111000 size:01
	.inst 0x78bfc35d // ldaprh:aarch64/instrs/memory/ordered-rcpc Rt:29 Rn:26 110000:110000 Rs:11111 111000101:111000101 size:01
	.inst 0x2db7cf4e // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/pre-idx Rt:14 Rn:26 Rt2:10011 imm7:1101111 L:0 1011011:1011011 opc:00
	.inst 0xf841b86a // ldtr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:10 Rn:3 10:10 imm9:000011011 0:0 opc:01 111000:111000 size:11
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
	ldr x19, =initial_cap_values
	.inst 0xc2400263 // ldr c3, [x19, #0]
	.inst 0xc2400665 // ldr c5, [x19, #1]
	.inst 0xc2400a67 // ldr c7, [x19, #2]
	.inst 0xc2400e71 // ldr c17, [x19, #3]
	.inst 0xc2401275 // ldr c21, [x19, #4]
	.inst 0xc240167a // ldr c26, [x19, #5]
	/* Vector registers */
	mrs x19, cptr_el3
	bfc x19, #10, #1
	msr cptr_el3, x19
	isb
	ldr q14, =0x0
	ldr q19, =0x20014000
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
	ldr x19, =0x3c0000
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
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601293 // ldr c19, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
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
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400274 // ldr c20, [x19, #0]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2400674 // ldr c20, [x19, #1]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2400a74 // ldr c20, [x19, #2]
	.inst 0xc2d4a4e1 // chkeq c7, c20
	b.ne comparison_fail
	.inst 0xc2400e74 // ldr c20, [x19, #3]
	.inst 0xc2d4a541 // chkeq c10, c20
	b.ne comparison_fail
	.inst 0xc2401274 // ldr c20, [x19, #4]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2401674 // ldr c20, [x19, #5]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2401a74 // ldr c20, [x19, #6]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2401e74 // ldr c20, [x19, #7]
	.inst 0xc2d4a781 // chkeq c28, c20
	b.ne comparison_fail
	.inst 0xc2402274 // ldr c20, [x19, #8]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	/* Check vector registers */
	ldr x19, =0x0
	mov x20, v14.d[0]
	cmp x19, x20
	b.ne comparison_fail
	ldr x19, =0x0
	mov x20, v14.d[1]
	cmp x19, x20
	b.ne comparison_fail
	ldr x19, =0x20014000
	mov x20, v19.d[0]
	cmp x19, x20
	b.ne comparison_fail
	ldr x19, =0x0
	mov x20, v19.d[1]
	cmp x19, x20
	b.ne comparison_fail
	/* Check system registers */
	ldr x19, =final_SP_EL0_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984114 // mrs c20, CSP_EL0
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	ldr x19, =final_PCC_value
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0xc2984034 // mrs c20, CELR_EL1
	.inst 0xc2d4a661 // chkeq c19, c20
	b.ne comparison_fail
	ldr x19, =esr_el1_dump_address
	ldr x19, [x19]
	mov x20, 0x80
	orr x19, x19, x20
	ldr x20, =0x920000ab
	cmp x20, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x0000100e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0000101c
	ldr x1, =check_data2
	ldr x2, =0x00001024
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001060
	ldr x1, =check_data3
	ldr x2, =0x00001062
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000010f0
	ldr x1, =check_data4
	ldr x2, =0x000010f4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001430
	ldr x1, =check_data5
	ldr x2, =0x00001438
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400014
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x40400400
	ldr x1, =check_data7
	ldr x2, =0x40400414
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =final_tag_set_locations
check_set_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_set_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cc comparison_fail
	b check_set_tags_loop
check_set_tags_end:
	ldr x0, =final_tag_unset_locations
check_unset_tags_loop:
	ldr x1, [x0], #8
	cbz x1, check_unset_tags_end
	.inst 0xc2400023 // ldr c3, [x1, #0]
	.inst 0xc2c23061 // chktgd c3
	b.cs comparison_fail
	b check_unset_tags_loop
check_unset_tags_end:
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
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 2
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x01, 0x20
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x00, 0x30, 0x0a, 0x68
.data
check_data5:
	.zero 8
.data
check_data6:
	.byte 0xa1, 0xd0, 0xd5, 0x82, 0x1c, 0xe5, 0x93, 0xf0, 0xfc, 0x6b, 0x0e, 0xb8, 0xc1, 0x03, 0x1f, 0xba
	.byte 0xe4, 0xac, 0x9c, 0x78
.data
check_data7:
	.byte 0x3f, 0xbe, 0x80, 0x78, 0x5d, 0xc3, 0xbf, 0x78, 0x4e, 0xcf, 0xb7, 0x2d, 0x6a, 0xb8, 0x41, 0xf8
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x80000000000100070000000000001415
	/* C5 */
	.octa 0x80000000508000010000000000000020
	/* C7 */
	.octa 0x8000000000002c
	/* C17 */
	.octa 0x80000000580208120000000000001001
	/* C21 */
	.octa 0xfe0
	/* C26 */
	.octa 0xc0000000000100070000000000001060
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C3 */
	.octa 0x80000000000100070000000000001415
	/* C5 */
	.octa 0x80000000508000010000000000000020
	/* C7 */
	.octa 0x8000000000002c
	/* C10 */
	.octa 0x0
	/* C17 */
	.octa 0x8000000058020812000000000000100c
	/* C21 */
	.octa 0xfe0
	/* C26 */
	.octa 0xc000000000010007000000000000101c
	/* C28 */
	.octa 0xffffffff680a3000
	/* C29 */
	.octa 0x0
initial_SP_EL0_value:
	.octa 0x1000
initial_DDC_EL0_value:
	.octa 0x400000005201000a0000000000006001
initial_VBAR_EL1_value:
	.octa 0x200080004800001d0000000040400001
final_SP_EL0_value:
	.octa 0x1000
final_PCC_value:
	.octa 0x200080004800001d0000000040400414
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040000080000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 96
	.dword initial_DDC_EL0_value
	.dword initial_VBAR_EL1_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001010
	.dword 0x0000000000001020
	.dword 0x00000000000010f0
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
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02000273 // add c19, c19, #0
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02020273 // add c19, c19, #128
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02040273 // add c19, c19, #256
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02060273 // add c19, c19, #384
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02080273 // add c19, c19, #512
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x020a0273 // add c19, c19, #640
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x020c0273 // add c19, c19, #768
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x020e0273 // add c19, c19, #896
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02100273 // add c19, c19, #1024
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02120273 // add c19, c19, #1152
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02140273 // add c19, c19, #1280
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02160273 // add c19, c19, #1408
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x02180273 // add c19, c19, #1536
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x021a0273 // add c19, c19, #1664
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
	.inst 0x021c0273 // add c19, c19, #1792
	.inst 0xc2c21260 // br c19
	.balign 128
	ldr x19, =esr_el1_dump_address
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600e93 // ldr x19, [c20, #0]
	cbnz x19, #28
	mrs x19, ESR_EL1
	.inst 0x82400e93 // str x19, [c20, #0]
	ldr x19, =0x40400414
	mrs x20, ELR_EL1
	sub x19, x19, x20
	cbnz x19, #8
	smc 0
	ldr x19, =initial_VBAR_EL1_value
	.inst 0xc2c5b274 // cvtp c20, x19
	.inst 0xc2d34294 // scvalue c20, c20, x19
	.inst 0x82600293 // ldr c19, [c20, #0]
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
