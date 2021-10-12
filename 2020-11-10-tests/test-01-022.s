.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x80, 0x00, 0x00
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xdc, 0x82, 0x11, 0xb9, 0x75, 0xb8, 0x5e, 0x82, 0xdf, 0xa7, 0x96, 0xca, 0xe2, 0x40, 0x68, 0x3d
	.byte 0x1f, 0x50, 0x33, 0x78, 0x09, 0x99, 0x6e, 0xb0, 0x1e, 0xb0, 0xc5, 0xc2, 0xfe, 0x67, 0x53, 0x82
	.byte 0xa1, 0x91, 0x23, 0xb7, 0x81, 0xdb, 0x46, 0xca, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xc0000000562100800000000000001000
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0xffffffffffffffd0
	/* C7 */
	.octa 0x8000000060020a120000000000001000
	/* C19 */
	.octa 0x8000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x400000005884008c0000000000000000
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0xc0000000562100800000000000001000
	/* C3 */
	.octa 0xffffffffffffffd0
	/* C7 */
	.octa 0x8000000060020a120000000000001000
	/* C9 */
	.octa 0x400000005d46088400000000dd321000
	/* C19 */
	.octa 0x8000
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x400000005884008c0000000000000000
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000200140050000000000001000
initial_SP_EL3_value:
	.octa 0x660
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200140050000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000005d4608840000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb91182dc // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:22 imm12:010001100000 opc:00 111001:111001 size:10
	.inst 0x825eb875 // ASTR-R.RI-32 Rt:21 Rn:3 op:10 imm9:111101011 L:0 1000001001:1000001001
	.inst 0xca96a7df // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:31 Rn:30 imm6:101001 Rm:22 N:0 shift:10 01010:01010 opc:10 sf:1
	.inst 0x3d6840e2 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:2 Rn:7 imm12:101000010000 opc:01 111101:111101 size:00
	.inst 0x7833501f // stsminh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:0 00:00 opc:101 o3:0 Rs:19 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xb06e9909 // ADRP-C.I-C Rd:9 immhi:110111010011001000 P:0 10000:10000 immlo:01 op:1
	.inst 0xc2c5b01e // CVTP-C.R-C Cd:30 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x825367fe // ASTRB-R.RI-B Rt:30 Rn:31 op:01 imm9:100110110 L:0 1000001001:1000001001
	.inst 0xb72391a1 // tbnz:aarch64/instrs/branch/conditional/test Rt:1 imm14:01110010001101 b40:00100 op:1 011011:011011 b5:1
	.inst 0xca46db81 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:28 imm6:110110 Rm:6 N:0 shift:01 01010:01010 opc:10 sf:1
	.inst 0xc2c21300
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2400dc7 // ldr c7, [x14, #3]
	.inst 0xc24011d3 // ldr c19, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	.inst 0xc2401ddc // ldr c28, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085103d
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x8260330e // ldr c14, [c24, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260130e // ldr c14, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d8 // ldr c24, [x14, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24005d8 // ldr c24, [x14, #1]
	.inst 0xc2d8a461 // chkeq c3, c24
	b.ne comparison_fail
	.inst 0xc24009d8 // ldr c24, [x14, #2]
	.inst 0xc2d8a4e1 // chkeq c7, c24
	b.ne comparison_fail
	.inst 0xc2400dd8 // ldr c24, [x14, #3]
	.inst 0xc2d8a521 // chkeq c9, c24
	b.ne comparison_fail
	.inst 0xc24011d8 // ldr c24, [x14, #4]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc24015d8 // ldr c24, [x14, #5]
	.inst 0xc2d8a6a1 // chkeq c21, c24
	b.ne comparison_fail
	.inst 0xc24019d8 // ldr c24, [x14, #6]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc2401dd8 // ldr c24, [x14, #7]
	.inst 0xc2d8a781 // chkeq c28, c24
	b.ne comparison_fail
	.inst 0xc24021d8 // ldr c24, [x14, #8]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x24, v2.d[0]
	cmp x14, x24
	b.ne comparison_fail
	ldr x14, =0x0
	mov x24, v2.d[1]
	cmp x14, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000101a
	ldr x1, =check_data1
	ldr x2, =0x0000101b
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001180
	ldr x1, =check_data2
	ldr x2, =0x00001184
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001a10
	ldr x1, =check_data3
	ldr x2, =0x00001a11
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
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
