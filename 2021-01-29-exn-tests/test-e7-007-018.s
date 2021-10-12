.section text0, #alloc, #execinstr
test_start:
	.inst 0x3831129f // stclrb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:001 o3:0 Rs:17 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xa23fc021 // LDAPR-C.R-C Ct:1 Rn:1 110000:110000 (1)(1)(1)(1)(1):11111 1:1 00:00 10100010:10100010
	.inst 0x48bd7c14 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:20 Rn:0 11111:11111 o0:0 Rs:29 1:1 L:0 0010001:0010001 size:01
	.inst 0x787802bf // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:000 o3:0 Rs:24 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c430f7 // LDPBLR-C.C-C Ct:23 Cn:7 100:100 opc:01 11000010110001000:11000010110001000
	.zero 492
	.inst 0x1b1583ff // 0x1b1583ff
	.inst 0x35f62df4 // 0x35f62df4
	.inst 0x489f7f61 // 0x489f7f61
	.inst 0x7a1b001c // 0x7a1b001c
	.inst 0xd4000001
	.zero 65004
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a47 // ldr c7, [x18, #2]
	.inst 0xc2400e51 // ldr c17, [x18, #3]
	.inst 0xc2401254 // ldr c20, [x18, #4]
	.inst 0xc2401655 // ldr c21, [x18, #5]
	.inst 0xc2401a58 // ldr c24, [x18, #6]
	.inst 0xc2401e5b // ldr c27, [x18, #7]
	.inst 0xc240225d // ldr c29, [x18, #8]
	/* Set up flags and system registers */
	ldr x18, =0x0
	msr SPSR_EL3, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30d5d99f
	msr SCTLR_EL1, x18
	ldr x18, =0xc0000
	msr CPACR_EL1, x18
	ldr x18, =0x0
	msr S3_0_C1_C2_2, x18 // CCTLR_EL1
	ldr x18, =0x4
	msr S3_3_C1_C2_2, x18 // CCTLR_EL0
	ldr x18, =initial_DDC_EL0_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2884132 // msr DDC_EL0, c18
	ldr x18, =0x80000000
	msr HCR_EL2, x18
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826012d2 // ldr c18, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc28e4032 // msr CELR_EL3, c18
	 eret
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* Check processor flags */
	mrs x18, nzcv
	ubfx x18, x18, #28, #4
	mov x22, #0x4
	and x18, x18, x22
	cmp x18, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400256 // ldr c22, [x18, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc2400656 // ldr c22, [x18, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400a56 // ldr c22, [x18, #2]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2400e56 // ldr c22, [x18, #3]
	.inst 0xc2d6a621 // chkeq c17, c22
	b.ne comparison_fail
	.inst 0xc2401256 // ldr c22, [x18, #4]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2401656 // ldr c22, [x18, #5]
	.inst 0xc2d6a6a1 // chkeq c21, c22
	b.ne comparison_fail
	.inst 0xc2401a56 // ldr c22, [x18, #6]
	.inst 0xc2d6a6e1 // chkeq c23, c22
	b.ne comparison_fail
	.inst 0xc2401e56 // ldr c22, [x18, #7]
	.inst 0xc2d6a701 // chkeq c24, c22
	b.ne comparison_fail
	.inst 0xc2402256 // ldr c22, [x18, #8]
	.inst 0xc2d6a761 // chkeq c27, c22
	b.ne comparison_fail
	.inst 0xc2402656 // ldr c22, [x18, #9]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc2402a56 // ldr c22, [x18, #10]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check system registers */
	ldr x18, =final_PCC_value
	.inst 0xc2400252 // ldr c18, [x18, #0]
	.inst 0xc2984036 // mrs c22, CELR_EL1
	.inst 0xc2d6a641 // chkeq c18, c22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x000010a0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001528
	ldr x1, =check_data2
	ldr x2, =0x0000152a
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001c00
	ldr x1, =check_data3
	ldr x2, =0x00001c10
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ec0
	ldr x1, =check_data4
	ldr x2, =0x00001ec2
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x40400000
	ldr x1, =check_data5
	ldr x2, =0x40400014
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x40400200
	ldr x1, =check_data6
	ldr x2, =0x40400214
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30850030
	msr SCTLR_EL3, x18
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
	.byte 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 112
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x10, 0x00, 0x00
	.byte 0x01, 0x02, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 3936
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x10, 0x00, 0x00
	.byte 0x01, 0x02, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x9f, 0x12, 0x31, 0x38, 0x21, 0xc0, 0x3f, 0xa2, 0x14, 0x7c, 0xbd, 0x48, 0xbf, 0x02, 0x78, 0x78
	.byte 0xf7, 0x30, 0xc4, 0xc2
.data
check_data6:
	.byte 0xff, 0x83, 0x15, 0x1b, 0xf4, 0x2d, 0xf6, 0x35, 0x61, 0x7f, 0x9f, 0x48, 0x1c, 0x00, 0x1b, 0x7a
	.byte 0x01, 0x00, 0x00, 0xd4

.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x528
	/* C1 */
	.octa 0xc00
	/* C7 */
	.octa 0x90000000000100050000000000001080
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xec0
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000200020000000000001000
	/* C29 */
	.octa 0xffff
el1_vector_jump_cap:
	.dword 0x40400300
	.dword 0xFFFFC00000010005
final_cap_values:
	/* C0 */
	.octa 0x528
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x90000000000100050000000000001080
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xec0
	/* C23 */
	.octa 0x1001000000000000000000000000
	/* C24 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000000200020000000000001000
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000400010000000040400014
initial_DDC_EL0_value:
	.octa 0xd00000005ec210000000000000000001
initial_VBAR_EL1_value:
	.octa 0x8000400000000000000000000000
final_PCC_value:
	.octa 0x20008000000200030000000040400214
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000400010000000040400000
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword 0x0000000000001090
	.dword 0x0000000000001c00
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword el1_vector_jump_cap
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_DDC_EL0_value
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
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02000252 // add c18, c18, #0
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02020252 // add c18, c18, #128
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02040252 // add c18, c18, #256
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02060252 // add c18, c18, #384
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02080252 // add c18, c18, #512
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x020a0252 // add c18, c18, #640
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x020c0252 // add c18, c18, #768
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x020e0252 // add c18, c18, #896
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02100252 // add c18, c18, #1024
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02120252 // add c18, c18, #1152
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02140252 // add c18, c18, #1280
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02160252 // add c18, c18, #1408
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x02180252 // add c18, c18, #1536
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x021a0252 // add c18, c18, #1664
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x021c0252 // add c18, c18, #1792
	.inst 0xc2c21240 // br c18
	.balign 128
	ldr x18, =esr_el1_dump_address
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x82600ed2 // ldr x18, [c22, #0]
	cbnz x18, #28
	mrs x18, ESR_EL1
	.inst 0x82400ed2 // str x18, [c22, #0]
	ldr x18, =0x40400214
	mrs x22, ELR_EL1
	sub x18, x18, x22
	cbnz x18, #8
	smc 0
	ldr x18, =initial_VBAR_EL1_value
	.inst 0xc2c5b256 // cvtp c22, x18
	.inst 0xc2d242d6 // scvalue c22, c22, x18
	.inst 0x826002d2 // ldr c18, [c22, #0]
	.inst 0x021e0252 // add c18, c18, #1920
	.inst 0xc2c21240 // br c18

	/* Translation table, two entries for the bottom GB, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000741
	.dword 0x30000000000007c1 // No write permission so that EL1 can execute
	.fill 4088, 1, 0
