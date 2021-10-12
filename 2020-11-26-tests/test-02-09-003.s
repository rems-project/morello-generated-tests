.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0xa0, 0x17, 0x16, 0xfc, 0xbd, 0x22, 0xc6, 0x9a, 0x01, 0x76, 0x1f, 0x72, 0xe0, 0x7f, 0x05, 0x48
	.byte 0xdb, 0xbf, 0x76, 0x91, 0xc1, 0xb7, 0x52, 0x02, 0xfd, 0x03, 0xbd, 0x78, 0xfd, 0x1b, 0xfe, 0xc2
	.byte 0x46, 0xcd, 0x1b, 0xe2, 0x1e, 0x14, 0xc0, 0x5a, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000000700830000000000001100
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C29 */
	.octa 0x1000
	/* C30 */
	.octa 0x7a007017fffffffc06000
final_cap_values:
	/* C1 */
	.octa 0x7a00701800000000b3000
	/* C5 */
	.octa 0x1
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x80000000000700830000000000001100
	/* C16 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C27 */
	.octa 0x1800000009b5000
	/* C29 */
	.octa 0x800420070180001fffc06000
initial_SP_EL3_value:
	.octa 0x800420070000000000001800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000060000000080000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xfc1617a0 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:0 Rn:29 01:01 imm9:101100001 0:0 opc:00 111100:111100 size:11
	.inst 0x9ac622bd // lslv:aarch64/instrs/integer/shift/variable Rd:29 Rn:21 op2:00 0010:0010 Rm:6 0011010110:0011010110 sf:1
	.inst 0x721f7601 // ands_log_imm:aarch64/instrs/integer/logical/immediate Rd:1 Rn:16 imms:011101 immr:011111 N:0 100100:100100 opc:11 sf:0
	.inst 0x48057fe0 // stxrh:aarch64/instrs/memory/exclusive/single Rt:0 Rn:31 Rt2:11111 o0:0 Rs:5 0:0 L:0 0010000:0010000 size:01
	.inst 0x9176bfdb // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:27 Rn:30 imm12:110110101111 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x0252b7c1 // ADD-C.CIS-C Cd:1 Cn:30 imm12:010010101101 sh:1 A:0 00000010:00000010
	.inst 0x78bd03fd // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:31 00:00 opc:000 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xc2fe1bfd // CVT-C.CR-C Cd:29 Cn:31 0110:0110 0:0 0:0 Rm:30 11000010111:11000010111
	.inst 0xe21bcd46 // ALDURSB-R.RI-32 Rt:6 Rn:10 op2:11 imm9:110111100 V:0 op1:00 11100010:11100010
	.inst 0x5ac0141e // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:30 Rn:0 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c212e0
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
	ldr x8, =initial_cap_values
	.inst 0xc2400106 // ldr c6, [x8, #0]
	.inst 0xc240050a // ldr c10, [x8, #1]
	.inst 0xc2400910 // ldr c16, [x8, #2]
	.inst 0xc2400d15 // ldr c21, [x8, #3]
	.inst 0xc240111d // ldr c29, [x8, #4]
	.inst 0xc240151e // ldr c30, [x8, #5]
	/* Vector registers */
	mrs x8, cptr_el3
	bfc x8, #10, #1
	msr cptr_el3, x8
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x8, #0x00000000
	msr nzcv, x8
	ldr x8, =initial_SP_EL3_value
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0xc2c1d11f // cpy c31, c8
	ldr x8, =0x200
	msr CPTR_EL3, x8
	ldr x8, =0x3085103d
	msr SCTLR_EL3, x8
	ldr x8, =0x4
	msr S3_6_C1_C2_2, x8 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032e8 // ldr c8, [c23, #3]
	.inst 0xc28b4128 // msr DDC_EL3, c8
	isb
	.inst 0x826012e8 // ldr c8, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21100 // br c8
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30851035
	msr SCTLR_EL3, x8
	isb
	/* Check processor flags */
	mrs x8, nzcv
	ubfx x8, x8, #28, #4
	mov x23, #0xf
	and x8, x8, x23
	cmp x8, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x8, =final_cap_values
	.inst 0xc2400117 // ldr c23, [x8, #0]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400517 // ldr c23, [x8, #1]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2400917 // ldr c23, [x8, #2]
	.inst 0xc2d7a4c1 // chkeq c6, c23
	b.ne comparison_fail
	.inst 0xc2400d17 // ldr c23, [x8, #3]
	.inst 0xc2d7a541 // chkeq c10, c23
	b.ne comparison_fail
	.inst 0xc2401117 // ldr c23, [x8, #4]
	.inst 0xc2d7a601 // chkeq c16, c23
	b.ne comparison_fail
	.inst 0xc2401517 // ldr c23, [x8, #5]
	.inst 0xc2d7a6a1 // chkeq c21, c23
	b.ne comparison_fail
	.inst 0xc2401917 // ldr c23, [x8, #6]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2401d17 // ldr c23, [x8, #7]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x8, =0x0
	mov x23, v0.d[0]
	cmp x8, x23
	b.ne comparison_fail
	ldr x8, =0x0
	mov x23, v0.d[1]
	cmp x8, x23
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
	ldr x0, =0x000010bc
	ldr x1, =check_data1
	ldr x2, =0x000010bd
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001802
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
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b008 // cvtp c8, x0
	.inst 0xc2df4108 // scvalue c8, c8, x31
	.inst 0xc28b4128 // msr DDC_EL3, c8
	ldr x8, =0x30850030
	msr SCTLR_EL3, x8
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
