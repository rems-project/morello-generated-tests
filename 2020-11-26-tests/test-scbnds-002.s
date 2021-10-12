.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0x00, 0x10
.data
check_data3:
	.zero 32
.data
check_data4:
	.byte 0xbe, 0x7e, 0x5f, 0x88, 0x20, 0x81, 0x3e, 0x78, 0xcd, 0x7f, 0xbd, 0xa2, 0xdf, 0x24, 0xe3, 0x02
	.byte 0x2b, 0x77, 0x36, 0x6d, 0x20, 0x00, 0xc2, 0xc2, 0xef, 0x43, 0xc0, 0xc2, 0x01, 0x48, 0x3a, 0x36
	.byte 0x5f, 0x52, 0x7d, 0xf8, 0x1d, 0xa4, 0x6f, 0x62, 0x00, 0x11, 0xc2, 0xc2
.data
check_data5:
	.byte 0x00, 0x10, 0x00, 0x00
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x400000000000000000001f80
	/* C6 */
	.octa 0x404001a9c40080000000000100
	/* C9 */
	.octa 0x1580
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0x401008
	/* C25 */
	.octa 0x1468
	/* C29 */
	.octa 0x200000
final_cap_values:
	/* C1 */
	.octa 0x400000000000000000001f80
	/* C6 */
	.octa 0x404001a9c40080000000000100
	/* C9 */
	.octa 0x0
	/* C13 */
	.octa 0x4000000000000000000000000000
	/* C15 */
	.octa 0x404001a9c40000000000001f80
	/* C18 */
	.octa 0x1000
	/* C21 */
	.octa 0x401008
	/* C25 */
	.octa 0x1468
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc81000000003000700ffe0000002e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001d70
	.dword 0x0000000000001d80
	.dword initial_cap_values + 48
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x885f7ebe // ldxr:aarch64/instrs/memory/exclusive/single Rt:30 Rn:21 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:10
	.inst 0x783e8120 // swph:aarch64/instrs/memory/atomicops/swp Rt:0 Rn:9 100000:100000 Rs:30 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xa2bd7fcd // CAS-C.R-C Ct:13 Rn:30 11111:11111 R:0 Cs:29 1:1 L:0 1:1 10100010:10100010
	.inst 0x02e324df // SUB-C.CIS-C Cd:31 Cn:6 imm12:100011001001 sh:1 A:1 00000010:00000010
	.inst 0x6d36772b // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:11 Rn:25 Rt2:11101 imm7:1101100 L:0 1011010:1011010 opc:01
	.inst 0xc2c20020 // 0xc2c20020
	.inst 0xc2c043ef // SCVALUE-C.CR-C Cd:15 Cn:31 000:000 opc:10 0:0 Rm:0 11000010110:11000010110
	.inst 0x363a4801 // tbz:aarch64/instrs/branch/conditional/test Rt:1 imm14:01001001000000 b40:00111 op:0 011011:011011 b5:0
	.inst 0xf87d525f // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:18 00:00 opc:101 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x626fa41d // LDNP-C.RIB-C Ct:29 Rn:0 Ct2:01001 imm7:1011111 L:1 011000100:011000100
	.inst 0xc2c21100
	.zero 4060
	.inst 0x00001000
	.zero 1044468
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
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
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
	ldr x12, =initial_cap_values
	.inst 0xc2400181 // ldr c1, [x12, #0]
	.inst 0xc2400586 // ldr c6, [x12, #1]
	.inst 0xc2400989 // ldr c9, [x12, #2]
	.inst 0xc2400d8d // ldr c13, [x12, #3]
	.inst 0xc2401192 // ldr c18, [x12, #4]
	.inst 0xc2401595 // ldr c21, [x12, #5]
	.inst 0xc2401999 // ldr c25, [x12, #6]
	.inst 0xc2401d9d // ldr c29, [x12, #7]
	/* Vector registers */
	mrs x12, cptr_el3
	bfc x12, #10, #1
	msr cptr_el3, x12
	isb
	ldr q11, =0x0
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x8260310c // ldr c12, [c8, #3]
	.inst 0xc28b412c // msr DDC_EL3, c12
	isb
	.inst 0x8260110c // ldr c12, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30851035
	msr SCTLR_EL3, x12
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400188 // ldr c8, [x12, #0]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400588 // ldr c8, [x12, #1]
	.inst 0xc2c8a4c1 // chkeq c6, c8
	b.ne comparison_fail
	.inst 0xc2400988 // ldr c8, [x12, #2]
	.inst 0xc2c8a521 // chkeq c9, c8
	b.ne comparison_fail
	.inst 0xc2400d88 // ldr c8, [x12, #3]
	.inst 0xc2c8a5a1 // chkeq c13, c8
	b.ne comparison_fail
	.inst 0xc2401188 // ldr c8, [x12, #4]
	.inst 0xc2c8a5e1 // chkeq c15, c8
	b.ne comparison_fail
	.inst 0xc2401588 // ldr c8, [x12, #5]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2401988 // ldr c8, [x12, #6]
	.inst 0xc2c8a6a1 // chkeq c21, c8
	b.ne comparison_fail
	.inst 0xc2401d88 // ldr c8, [x12, #7]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2402188 // ldr c8, [x12, #8]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402588 // ldr c8, [x12, #9]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0x0
	mov x8, v11.d[0]
	cmp x12, x8
	b.ne comparison_fail
	ldr x12, =0x0
	mov x8, v11.d[1]
	cmp x12, x8
	b.ne comparison_fail
	ldr x12, =0x0
	mov x8, v29.d[0]
	cmp x12, x8
	b.ne comparison_fail
	ldr x12, =0x0
	mov x8, v29.d[1]
	cmp x12, x8
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
	ldr x0, =0x000013c8
	ldr x1, =check_data1
	ldr x2, =0x000013d8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001580
	ldr x1, =check_data2
	ldr x2, =0x00001582
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001d70
	ldr x1, =check_data3
	ldr x2, =0x00001d90
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00401008
	ldr x1, =check_data5
	ldr x2, =0x0040100c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr DDC_EL3, c12
	ldr x12, =0x30850030
	msr SCTLR_EL3, x12
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
