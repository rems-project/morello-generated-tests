.section data0, #alloc, #write
	.zero 128
	.byte 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3952
.data
check_data0:
	.byte 0xff, 0x00, 0x00, 0xfe, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 16
.data
check_data4:
	.zero 16
.data
check_data5:
	.byte 0xd7, 0xdb, 0xbf, 0x82, 0x44, 0x58, 0x87, 0x79, 0x1e, 0x00, 0xc0, 0x5a, 0x4f, 0x10, 0xf3, 0xb8
	.byte 0xdf, 0x72, 0x3f, 0xf8, 0x5e, 0x4d, 0x21, 0xe2, 0xe8, 0x27, 0x88, 0x6a, 0x02, 0x52, 0x43, 0x38
	.byte 0xce, 0x3b, 0x32, 0xe2, 0x5e, 0x90, 0xc5, 0xc2, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xb4040000
	/* C2 */
	.octa 0xc0000000000400070000000000001000
	/* C10 */
	.octa 0x1fcc
	/* C16 */
	.octa 0x8000000000010005000000000000104e
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0xc0000000000700060000000000001080
	/* C30 */
	.octa 0x1000
final_cap_values:
	/* C0 */
	.octa 0xb4040000
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x1fcc
	/* C15 */
	.octa 0xfe0000ff
	/* C16 */
	.octa 0x8000000000010005000000000000104e
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0xc0000000000700060000000000001080
	/* C30 */
	.octa 0xc000000040010f9f0000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000404400000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000040010f9f00ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x82bfdbd7 // ASTR-V.RRB-D Rt:23 Rn:30 opc:10 S:1 option:110 Rm:31 1:1 L:0 100000101:100000101
	.inst 0x79875844 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:4 Rn:2 imm12:000111010110 opc:10 111001:111001 size:01
	.inst 0x5ac0001e // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:30 Rn:0 101101011000000000000:101101011000000000000 sf:0
	.inst 0xb8f3104f // ldclr:aarch64/instrs/memory/atomicops/ld Rt:15 Rn:2 00:00 opc:001 0:0 Rs:19 1:1 R:1 A:1 111000:111000 size:10
	.inst 0xf83f72df // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:22 00:00 opc:111 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xe2214d5e // ALDUR-V.RI-Q Rt:30 Rn:10 op2:11 imm9:000010100 V:1 op1:00 11100010:11100010
	.inst 0x6a8827e8 // ands_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:8 Rn:31 imm6:001001 Rm:8 N:0 shift:10 01010:01010 opc:11 sf:0
	.inst 0x38435202 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:2 Rn:16 00:00 imm9:000110101 0:0 opc:01 111000:111000 size:00
	.inst 0xe2323bce // ASTUR-V.RI-Q Rt:14 Rn:30 op2:10 imm9:100100011 V:1 op1:00 11100010:11100010
	.inst 0xc2c5905e // CVTD-C.R-C Cd:30 Rn:2 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c212a0
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2400b2a // ldr c10, [x25, #2]
	.inst 0xc2400f30 // ldr c16, [x25, #3]
	.inst 0xc2401333 // ldr c19, [x25, #4]
	.inst 0xc2401736 // ldr c22, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Vector registers */
	mrs x25, cptr_el3
	bfc x25, #10, #1
	msr cptr_el3, x25
	isb
	ldr q14, =0x0
	ldr q23, =0xfe0000ff
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851037
	msr SCTLR_EL3, x25
	ldr x25, =0x0
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b9 // ldr c25, [c21, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x826012b9 // ldr c25, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	isb
	/* Check processor flags */
	mrs x25, nzcv
	ubfx x25, x25, #28, #4
	mov x21, #0xf
	and x25, x25, x21
	cmp x25, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400335 // ldr c21, [x25, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400735 // ldr c21, [x25, #1]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400b35 // ldr c21, [x25, #2]
	.inst 0xc2d5a481 // chkeq c4, c21
	b.ne comparison_fail
	.inst 0xc2400f35 // ldr c21, [x25, #3]
	.inst 0xc2d5a501 // chkeq c8, c21
	b.ne comparison_fail
	.inst 0xc2401335 // ldr c21, [x25, #4]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401735 // ldr c21, [x25, #5]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2401b35 // ldr c21, [x25, #6]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2401f35 // ldr c21, [x25, #7]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc2402335 // ldr c21, [x25, #8]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402735 // ldr c21, [x25, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x25, =0x0
	mov x21, v14.d[0]
	cmp x25, x21
	b.ne comparison_fail
	ldr x25, =0x0
	mov x21, v14.d[1]
	cmp x25, x21
	b.ne comparison_fail
	ldr x25, =0xfe0000ff
	mov x21, v23.d[0]
	cmp x25, x21
	b.ne comparison_fail
	ldr x25, =0x0
	mov x21, v23.d[1]
	cmp x25, x21
	b.ne comparison_fail
	ldr x25, =0x0
	mov x21, v30.d[0]
	cmp x25, x21
	b.ne comparison_fail
	ldr x25, =0x0
	mov x21, v30.d[1]
	cmp x25, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001088
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000013ac
	ldr x1, =check_data2
	ldr x2, =0x000013ae
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f50
	ldr x1, =check_data3
	ldr x2, =0x00001f60
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
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x0040002c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
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
