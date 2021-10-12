.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7a, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 8
.data
check_data3:
	.byte 0xfe, 0x1f, 0xc4, 0x3c, 0x50, 0x50, 0x75, 0xe2, 0x22, 0x24, 0xdf, 0x9a, 0x69, 0x82, 0xe2, 0xf8
	.byte 0xc2, 0x07, 0xcf, 0xe2, 0x3a, 0x10, 0x0f, 0x12, 0x02, 0x8a, 0xa2, 0x9b, 0xe2, 0x13, 0xc0, 0xc2
	.byte 0x21, 0xda, 0x71, 0xb0, 0xc1, 0xbe, 0x54, 0x71, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x7a000000000000
	/* C2 */
	.octa 0x400000005f840004000000000000200b
	/* C19 */
	.octa 0x1001
	/* C30 */
	.octa 0x80000000000100050000000000001f00
final_cap_values:
	/* C2 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C19 */
	.octa 0x1001
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x80000000000100050000000000001f00
initial_SP_EL3_value:
	.octa 0xfb0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005400006f00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3cc41ffe // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:30 Rn:31 11:11 imm9:001000001 0:0 opc:11 111100:111100 size:00
	.inst 0xe2755050 // ASTUR-V.RI-H Rt:16 Rn:2 op2:00 imm9:101010101 V:1 op1:01 11100010:11100010
	.inst 0x9adf2422 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:1 op2:01 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0xf8e28269 // swp:aarch64/instrs/memory/atomicops/swp Rt:9 Rn:19 100000:100000 Rs:2 1:1 R:1 A:1 111000:111000 size:11
	.inst 0xe2cf07c2 // ALDUR-R.RI-64 Rt:2 Rn:30 op2:01 imm9:011110000 V:0 op1:11 11100010:11100010
	.inst 0x120f103a // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:26 Rn:1 imms:000100 immr:001111 N:0 100100:100100 opc:00 sf:0
	.inst 0x9ba28a02 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:2 Rn:16 Ra:2 o0:1 Rm:2 01:01 U:1 10011011:10011011
	.inst 0xc2c013e2 // GCBASE-R.C-C Rd:2 Cn:31 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0xb071da21 // ADRDP-C.ID-C Rd:1 immhi:111000111011010001 P:0 10000:10000 immlo:01 op:1
	.inst 0x7154bec1 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:22 imm12:010100101111 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc2c21180
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400782 // ldr c2, [x28, #1]
	.inst 0xc2400b93 // ldr c19, [x28, #2]
	.inst 0xc2400f9e // ldr c30, [x28, #3]
	/* Vector registers */
	mrs x28, cptr_el3
	bfc x28, #10, #1
	msr cptr_el3, x28
	isb
	ldr q16, =0x0
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x3085103d
	msr SCTLR_EL3, x28
	ldr x28, =0x4
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x8260319c // ldr c28, [c12, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x8260119c // ldr c28, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30851035
	msr SCTLR_EL3, x28
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc240038c // ldr c12, [x28, #0]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc240078c // ldr c12, [x28, #1]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc2400b8c // ldr c12, [x28, #2]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2400f8c // ldr c12, [x28, #3]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240138c // ldr c12, [x28, #4]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x12, v16.d[0]
	cmp x28, x12
	b.ne comparison_fail
	ldr x28, =0x0
	mov x12, v16.d[1]
	cmp x28, x12
	b.ne comparison_fail
	ldr x28, =0x0
	mov x12, v30.d[0]
	cmp x28, x12
	b.ne comparison_fail
	ldr x28, =0x0
	mov x12, v30.d[1]
	cmp x28, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001078
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f60
	ldr x1, =check_data1
	ldr x2, =0x00001f62
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ff0
	ldr x1, =check_data2
	ldr x2, =0x00001ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040002c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	ldr x28, =0x30850030
	msr SCTLR_EL3, x28
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
