.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2d7d55f // ALDUR-R.RI-64 Rt:31 Rn:10 op2:01 imm9:101111101 V:0 op1:11 11100010:11100010
	.inst 0x82a153c0 // ASTR-R.RRB-32 Rt:0 Rn:30 opc:00 S:1 option:010 Rm:1 1:1 L:0 100000101:100000101
	.inst 0x782a701f // stuminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:111 o3:0 Rs:10 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0x93cdc538 // extr:aarch64/instrs/integer/ins-ext/extract/immediate Rd:24 Rn:9 imms:110001 Rm:13 0:0 N:1 00100111:00100111 sf:1
	.inst 0xc2c8617f // SCOFF-C.CR-C Cd:31 Cn:11 000:000 opc:11 0:0 Rm:8 11000010110:11000010110
	.inst 0x9b3f2f7d // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:27 Ra:11 o0:0 Rm:31 01:01 U:0 10011011:10011011
	.inst 0x786703df // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:000 o3:0 Rs:7 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0x9b587cdc // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:28 Rn:6 Ra:11111 0:0 Rm:24 10:10 U:0 10011011:10011011
	.inst 0xbd3005bf // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:31 Rn:13 imm12:110000000001 opc:00 111101:111101 size:10
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a87 // ldr c7, [x20, #2]
	.inst 0xc2400e88 // ldr c8, [x20, #3]
	.inst 0xc240128a // ldr c10, [x20, #4]
	.inst 0xc240168b // ldr c11, [x20, #5]
	.inst 0xc2401a8d // ldr c13, [x20, #6]
	.inst 0xc2401e9e // ldr c30, [x20, #7]
	/* Vector registers */
	mrs x20, cptr_el3
	bfc x20, #10, #1
	msr cptr_el3, x20
	isb
	ldr q31, =0x1020000
	/* Set up flags and system registers */
	ldr x20, =0x4000000
	msr SPSR_EL3, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30d5d99f
	msr SCTLR_EL1, x20
	ldr x20, =0x3c0000
	msr CPACR_EL1, x20
	ldr x20, =0x0
	msr S3_0_C1_C2_2, x20 // CCTLR_EL1
	ldr x20, =0x0
	msr S3_3_C1_C2_2, x20 // CCTLR_EL0
	ldr x20, =initial_DDC_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2884134 // msr DDC_EL0, c20
	ldr x20, =0x80000000
	msr HCR_EL2, x20
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826012b4 // ldr c20, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc28e4034 // msr CELR_EL3, c20
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400295 // ldr c21, [x20, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400695 // ldr c21, [x20, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a95 // ldr c21, [x20, #2]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2400e95 // ldr c21, [x20, #3]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2401295 // ldr c21, [x20, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401695 // ldr c21, [x20, #5]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401a95 // ldr c21, [x20, #6]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401e95 // ldr c21, [x20, #7]
	.inst 0xc2d5a7a1 // chkeq c29, c21
	b.ne comparison_fail
	.inst 0xc2402295 // ldr c21, [x20, #8]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x20, =0x1020000
	mov x21, v31.d[0]
	cmp x20, x21
	b.ne comparison_fail
	ldr x20, =0x0
	mov x21, v31.d[1]
	cmp x20, x21
	b.ne comparison_fail
	/* Check system registers */
	ldr x20, =final_SP_EL0_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984115 // mrs c21, CSP_EL0
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	ldr x20, =final_PCC_value
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0xc2984035 // mrs c21, CELR_EL1
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001794
	ldr x1, =check_data0
	ldr x2, =0x00001796
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bc4
	ldr x1, =check_data1
	ldr x2, =0x00001bc8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fe0
	ldr x1, =check_data2
	ldr x2, =0x00001fe4
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
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
	ldr x0, =0x404003a0
	ldr x1, =check_data5
	ldr x2, =0x404003a8
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x26, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0xfc, 0x1f, 0x00, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x02, 0x01
.data
check_data3:
	.byte 0x26, 0x00
.data
check_data4:
	.byte 0x5f, 0xd5, 0xd7, 0xe2, 0xc0, 0x53, 0xa1, 0x82, 0x1f, 0x70, 0x2a, 0x78, 0x38, 0xc5, 0xcd, 0x93
	.byte 0x7f, 0x61, 0xc8, 0xc2, 0x7d, 0x2f, 0x3f, 0x9b, 0xdf, 0x03, 0x67, 0x78, 0xdc, 0x7c, 0x58, 0x9b
	.byte 0xbf, 0x05, 0x30, 0xbd, 0x01, 0x00, 0x00, 0xd4
.data
check_data5:
	.zero 8

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffc
	/* C1 */
	.octa 0x10c
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x40400423
	/* C11 */
	.octa 0x800020030000000000000000
	/* C13 */
	.octa 0x4000000000010005ffffffffffffefdc
	/* C30 */
	.octa 0xc0000000000100050000000000001794
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0xc0000000000100050000000000001ffc
	/* C1 */
	.octa 0x10c
	/* C7 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x40400423
	/* C11 */
	.octa 0x800020030000000000000000
	/* C13 */
	.octa 0x4000000000010005ffffffffffffefdc
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0xc0000000000100050000000000001794
initial_DDC_EL0_value:
	.octa 0xc0000000000080080000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x800020030000000000000000
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 0
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword initial_DDC_EL0_value
	.dword final_PCC_value
	.dword 0
final_tag_set_locations:
	.dword 0
final_tag_unset_locations:
	.dword 0x0000000000001790
	.dword 0x0000000000001bc0
	.dword 0x0000000000001fe0
	.dword 0x0000000000001ff0
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
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02000294 // add c20, c20, #0
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02020294 // add c20, c20, #128
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02040294 // add c20, c20, #256
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02060294 // add c20, c20, #384
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02080294 // add c20, c20, #512
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x020a0294 // add c20, c20, #640
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x020c0294 // add c20, c20, #768
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x020e0294 // add c20, c20, #896
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02100294 // add c20, c20, #1024
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02120294 // add c20, c20, #1152
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02140294 // add c20, c20, #1280
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02160294 // add c20, c20, #1408
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x02180294 // add c20, c20, #1536
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x021a0294 // add c20, c20, #1664
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x021c0294 // add c20, c20, #1792
	.inst 0xc2c21280 // br c20
	.balign 128
	ldr x20, =esr_el1_dump_address
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x82600eb4 // ldr x20, [c21, #0]
	cbnz x20, #28
	mrs x20, ESR_EL1
	.inst 0x82400eb4 // str x20, [c21, #0]
	ldr x20, =0x40400028
	mrs x21, ELR_EL1
	sub x20, x20, x21
	cbnz x20, #8
	smc 0
	ldr x20, =initial_VBAR_EL1_value
	.inst 0xc2c5b295 // cvtp c21, x20
	.inst 0xc2d442b5 // scvalue c21, c21, x20
	.inst 0x826002b4 // ldr c20, [c21, #0]
	.inst 0x021e0294 // add c20, c20, #1920
	.inst 0xc2c21280 // br c20

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
