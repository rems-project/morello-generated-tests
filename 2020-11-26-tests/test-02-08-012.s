.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xe0, 0xf7, 0x00, 0xff
.data
check_data1:
	.byte 0xe0, 0x53, 0xfe, 0xb8, 0x47, 0x06, 0xc0, 0xda, 0xc0, 0x0c, 0xc0, 0x9a, 0x9f, 0x32, 0x35, 0x38
	.byte 0x3f, 0xf6, 0x7e, 0xb0, 0xe1, 0xff, 0x5f, 0x08, 0xbf, 0x13, 0x30, 0xb8, 0x1c, 0x20, 0xc1, 0x1a
	.byte 0xa1, 0xc3, 0xbf, 0xb8, 0x74, 0xfd, 0x49, 0x2c, 0x60, 0x10, 0xc2, 0xc2
.data
check_data2:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C11 */
	.octa 0x800000000022000100000000003ffff8
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000000700470000000000001800
	/* C21 */
	.octa 0xe0
	/* C29 */
	.octa 0xc0000000400410040000000000001800
	/* C30 */
	.octa 0xff00f700
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xff00f7e0
	/* C11 */
	.octa 0x800000000022000100000000003ffff8
	/* C16 */
	.octa 0x0
	/* C20 */
	.octa 0xc0000000000700470000000000001800
	/* C21 */
	.octa 0xe0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0xc0000000400410040000000000001800
	/* C30 */
	.octa 0xff00f700
initial_SP_EL3_value:
	.octa 0xc0000000000500050000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800340070000000048000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb8fe53e0 // ldsmin:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:31 00:00 opc:101 0:0 Rs:30 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xdac00647 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:7 Rn:18 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0x9ac00cc0 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:0 Rn:6 o1:1 00001:00001 Rm:0 0011010110:0011010110 sf:1
	.inst 0x3835329f // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:011 o3:0 Rs:21 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xb07ef63f // ADRDP-C.ID-C Rd:31 immhi:111111011110110001 P:0 10000:10000 immlo:01 op:1
	.inst 0x085fffe1 // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:1 Rn:31 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xb83013bf // ldclr:aarch64/instrs/memory/atomicops/ld Rt:31 Rn:29 00:00 opc:001 0:0 Rs:16 1:1 R:0 A:0 111000:111000 size:10
	.inst 0x1ac1201c // lslv:aarch64/instrs/integer/shift/variable Rd:28 Rn:0 op2:00 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xb8bfc3a1 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:29 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0x2c49fd74 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:20 Rn:11 Rt2:11111 imm7:0010011 L:1 1011000:1011000 opc:00
	.inst 0xc2c21060
	.zero 1048532
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
	ldr x13, =initial_cap_values
	.inst 0xc24001ab // ldr c11, [x13, #0]
	.inst 0xc24005b0 // ldr c16, [x13, #1]
	.inst 0xc24009b4 // ldr c20, [x13, #2]
	.inst 0xc2400db5 // ldr c21, [x13, #3]
	.inst 0xc24011bd // ldr c29, [x13, #4]
	.inst 0xc24015be // ldr c30, [x13, #5]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30851037
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306d // ldr c13, [c3, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260106d // ldr c13, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc24011a3 // ldr c3, [x13, #4]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc24015a3 // ldr c3, [x13, #5]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc24019a3 // ldr c3, [x13, #6]
	.inst 0xc2c3a781 // chkeq c28, c3
	b.ne comparison_fail
	.inst 0xc2401da3 // ldr c3, [x13, #7]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24021a3 // ldr c3, [x13, #8]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x13, =0x0
	mov x3, v20.d[0]
	cmp x13, x3
	b.ne comparison_fail
	ldr x13, =0x0
	mov x3, v20.d[1]
	cmp x13, x3
	b.ne comparison_fail
	ldr x13, =0x0
	mov x3, v31.d[0]
	cmp x13, x3
	b.ne comparison_fail
	ldr x13, =0x0
	mov x3, v31.d[1]
	cmp x13, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001800
	ldr x1, =check_data0
	ldr x2, =0x00001804
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400044
	ldr x1, =check_data2
	ldr x2, =0x0040004c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
