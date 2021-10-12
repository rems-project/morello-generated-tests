.section text0, #alloc, #execinstr
test_start:
	.inst 0x220d7ffb // STXR-R.CR-C Ct:27 Rn:31 (1)(1)(1)(1)(1):11111 0:0 Rs:13 0:0 L:0 001000100:001000100
	.inst 0xe22b7d7f // ALDUR-V.RI-Q Rt:31 Rn:11 op2:11 imm9:010110111 V:1 op1:00 11100010:11100010
	.inst 0x887fc3df // ldaxp:aarch64/instrs/memory/exclusive/pair Rt:31 Rn:30 Rt2:10000 o0:1 Rs:11111 1:1 L:1 0010000:0010000 sz:0 1:1
	.inst 0x7823403f // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:3 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c613e1 // CLRPERM-C.CI-C Cd:1 Cn:31 100:100 perm:000 1100001011000110:1100001011000110
	.inst 0x71756fa0 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:29 imm12:110101011011 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xe23c0c17 // ALDUR-V.RI-Q Rt:23 Rn:0 op2:11 imm9:111000000 V:1 op1:00 11100010:11100010
	.inst 0xc2df63dd // SCOFF-C.CR-C Cd:29 Cn:30 000:000 opc:11 0:0 Rm:31 11000010110:11000010110
	.inst 0x8280efbf // ASTRH-R.RRB-32 Rt:31 Rn:29 opc:11 S:0 option:111 Rm:0 0:0 L:0 100000101:100000101
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
	.inst 0xc2400041 // ldr c1, [x2, #0]
	.inst 0xc2400443 // ldr c3, [x2, #1]
	.inst 0xc240084b // ldr c11, [x2, #2]
	.inst 0xc2400c5b // ldr c27, [x2, #3]
	.inst 0xc240105d // ldr c29, [x2, #4]
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
	ldr x2, =0x3c0000
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
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826010e2 // ldr c2, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	mov x7, #0xf
	and x2, x2, x7
	cmp x2, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc2400047 // ldr c7, [x2, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc2400447 // ldr c7, [x2, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc2400847 // ldr c7, [x2, #2]
	.inst 0xc2c7a461 // chkeq c3, c7
	b.ne comparison_fail
	.inst 0xc2400c47 // ldr c7, [x2, #3]
	.inst 0xc2c7a561 // chkeq c11, c7
	b.ne comparison_fail
	.inst 0xc2401047 // ldr c7, [x2, #4]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc2401447 // ldr c7, [x2, #5]
	.inst 0xc2c7a601 // chkeq c16, c7
	b.ne comparison_fail
	.inst 0xc2401847 // ldr c7, [x2, #6]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2401c47 // ldr c7, [x2, #7]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc2402047 // ldr c7, [x2, #8]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x2, =0x0
	mov x7, v23.d[0]
	cmp x2, x7
	b.ne comparison_fail
	ldr x2, =0x0
	mov x7, v23.d[1]
	cmp x2, x7
	b.ne comparison_fail
	ldr x2, =0x0
	mov x7, v31.d[0]
	cmp x2, x7
	b.ne comparison_fail
	ldr x2, =0x0
	mov x7, v31.d[1]
	cmp x2, x7
	b.ne comparison_fail
	/* Check system registers */
	ldr x2, =final_SP_EL0_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984107 // mrs c7, CSP_EL0
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	ldr x2, =final_PCC_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2984027 // mrs c7, CELR_EL1
	.inst 0xc2c7a441 // chkeq c2, c7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001050
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
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001102
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001410
	ldr x1, =check_data3
	ldr x2, =0x00001418
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe0
	ldr x1, =check_data4
	ldr x2, =0x00001ff0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400000
	ldr x1, =check_data6
	ldr x2, =0x40400028
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
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
	.zero 4080
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 2
.data
check_data6:
	.byte 0xfb, 0x7f, 0x0d, 0x22, 0x7f, 0x7d, 0x2b, 0xe2, 0xdf, 0xc3, 0x7f, 0x88, 0x3f, 0x40, 0x23, 0x78
	.byte 0xe1, 0x13, 0xc6, 0xc2, 0xa0, 0x6f, 0x75, 0x71, 0x17, 0x0c, 0x3c, 0xe2, 0xdd, 0x63, 0xdf, 0xc2
	.byte 0xbf, 0xef, 0x80, 0x82, 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0xc0000000000100050000000000001ffc
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0x1f29
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0xd5c100
	/* C30 */
	.octa 0x800000000000a0080000000000001410
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x1100
	/* C1 */
	.octa 0x4c000000000100050000000000001040
	/* C3 */
	.octa 0x0
	/* C11 */
	.octa 0x1f29
	/* C13 */
	.octa 0x1
	/* C16 */
	.octa 0x0
	/* C27 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000000a0080000000000000000
	/* C30 */
	.octa 0x800000000000a0080000000000001410
initial_SP_EL0_value:
	.octa 0x4c000000000100050000000000001040
initial_DDC_EL0_value:
	.octa 0xc0000000000100050000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_SP_EL0_value:
	.octa 0x4c000000000100050000000000001040
final_PCC_value:
	.octa 0x20008000000100070000000040400028
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
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword final_cap_values + 128
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
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02000042 // add c2, c2, #0
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02020042 // add c2, c2, #128
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02040042 // add c2, c2, #256
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02060042 // add c2, c2, #384
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02080042 // add c2, c2, #512
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x020a0042 // add c2, c2, #640
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x020c0042 // add c2, c2, #768
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x020e0042 // add c2, c2, #896
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02100042 // add c2, c2, #1024
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02120042 // add c2, c2, #1152
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02140042 // add c2, c2, #1280
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02160042 // add c2, c2, #1408
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x02180042 // add c2, c2, #1536
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x021a0042 // add c2, c2, #1664
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
	.inst 0x021c0042 // add c2, c2, #1792
	.inst 0xc2c21040 // br c2
	.balign 128
	ldr x2, =esr_el1_dump_address
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x82600ce2 // ldr x2, [c7, #0]
	cbnz x2, #28
	mrs x2, ESR_EL1
	.inst 0x82400ce2 // str x2, [c7, #0]
	ldr x2, =0x40400028
	mrs x7, ELR_EL1
	sub x2, x2, x7
	cbnz x2, #8
	smc 0
	ldr x2, =initial_VBAR_EL1_value
	.inst 0xc2c5b047 // cvtp c7, x2
	.inst 0xc2c240e7 // scvalue c7, c7, x2
	.inst 0x826000e2 // ldr c2, [c7, #0]
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
