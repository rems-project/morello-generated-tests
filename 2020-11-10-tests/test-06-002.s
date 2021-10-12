.section data0, #alloc, #write
	.zero 4080
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.zero 32
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80
.data
check_data2:
	.byte 0x4d, 0x31, 0xe2, 0xc2, 0x20, 0x84, 0xc0, 0xc2, 0xd8, 0x3b, 0xcc, 0xc2, 0xc2, 0xdf, 0xcd, 0xac
	.byte 0xb6, 0x18, 0xb3, 0x34, 0x80, 0xd1, 0xc5, 0xc2, 0xdb, 0x4b, 0xd6, 0xc2, 0xf4, 0x5e, 0xeb, 0x30
	.byte 0x51, 0x00, 0x02, 0x1a, 0x9f, 0x60, 0x39, 0xf8, 0xe0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400002000000000000000000000000
	/* C1 */
	.octa 0x20408002600100000000000000400009
	/* C4 */
	.octa 0xc0000000000100050000000000001ff0
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0xffffffffffffffff
	/* C22 */
	.octa 0x4000000000000000000000000001
	/* C25 */
	.octa 0x8000000000000000
	/* C30 */
	.octa 0x80000000000100070000000000001000
final_cap_values:
	/* C0 */
	.octa 0x10004ffffffffffffffff
	/* C1 */
	.octa 0x20408002600100000000000000400009
	/* C4 */
	.octa 0xc0000000000100050000000000001ff0
	/* C10 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0xffffffffffffffff
	/* C13 */
	.octa 0x3fff800000001100000000000000
	/* C20 */
	.octa 0x204080006001000000000000003d6bf9
	/* C22 */
	.octa 0x4000000000000000000000000001
	/* C24 */
	.octa 0x80000000501810000000000000001000
	/* C25 */
	.octa 0x8000000000000000
	/* C27 */
	.octa 0x800000000001000700000000000011b0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x800000000001000700000000000011b0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x100040000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2e2314d // EORFLGS-C.CI-C Cd:13 Cn:10 0:0 10:10 imm8:00010001 11000010111:11000010111
	.inst 0xc2c08420 // BRS-C.C-C 00000:00000 Cn:1 001:001 opc:00 1:1 Cm:0 11000010110:11000010110
	.inst 0xc2cc3bd8 // SCBNDS-C.CI-C Cd:24 Cn:30 1110:1110 S:0 imm6:011000 11000010110:11000010110
	.inst 0xaccddfc2 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:2 Rn:30 Rt2:10111 imm7:0011011 L:1 1011001:1011001 opc:10
	.inst 0x34b318b6 // cbz:aarch64/instrs/branch/conditional/compare Rt:22 imm19:1011001100011000101 op:0 011010:011010 sf:0
	.inst 0xc2c5d180 // CVTDZ-C.R-C Cd:0 Rn:12 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2d64bdb // UNSEAL-C.CC-C Cd:27 Cn:30 0010:0010 opc:01 Cm:22 11000010110:11000010110
	.inst 0x30eb5ef4 // ADR-C.I-C Rd:20 immhi:110101101011110111 P:1 10000:10000 immlo:01 op:0
	.inst 0x1a020051 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:17 Rn:2 000000:000000 Rm:2 11010000:11010000 S:0 op:0 sf:0
	.inst 0xf839609f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:4 00:00 opc:110 o3:0 Rs:25 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c210e0
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
	.inst 0xc24009c4 // ldr c4, [x14, #2]
	.inst 0xc2400dca // ldr c10, [x14, #3]
	.inst 0xc24011cc // ldr c12, [x14, #4]
	.inst 0xc24015d6 // ldr c22, [x14, #5]
	.inst 0xc24019d9 // ldr c25, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x7, =pcc_return_ddc_capabilities
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0x826030ee // ldr c14, [c7, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826010ee // ldr c14, [c7, #1]
	.inst 0x826020e7 // ldr c7, [c7, #2]
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
	.inst 0xc24001c7 // ldr c7, [x14, #0]
	.inst 0xc2c7a401 // chkeq c0, c7
	b.ne comparison_fail
	.inst 0xc24005c7 // ldr c7, [x14, #1]
	.inst 0xc2c7a421 // chkeq c1, c7
	b.ne comparison_fail
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2c7a481 // chkeq c4, c7
	b.ne comparison_fail
	.inst 0xc2400dc7 // ldr c7, [x14, #3]
	.inst 0xc2c7a541 // chkeq c10, c7
	b.ne comparison_fail
	.inst 0xc24011c7 // ldr c7, [x14, #4]
	.inst 0xc2c7a581 // chkeq c12, c7
	b.ne comparison_fail
	.inst 0xc24015c7 // ldr c7, [x14, #5]
	.inst 0xc2c7a5a1 // chkeq c13, c7
	b.ne comparison_fail
	.inst 0xc24019c7 // ldr c7, [x14, #6]
	.inst 0xc2c7a681 // chkeq c20, c7
	b.ne comparison_fail
	.inst 0xc2401dc7 // ldr c7, [x14, #7]
	.inst 0xc2c7a6c1 // chkeq c22, c7
	b.ne comparison_fail
	.inst 0xc24021c7 // ldr c7, [x14, #8]
	.inst 0xc2c7a701 // chkeq c24, c7
	b.ne comparison_fail
	.inst 0xc24025c7 // ldr c7, [x14, #9]
	.inst 0xc2c7a721 // chkeq c25, c7
	b.ne comparison_fail
	.inst 0xc24029c7 // ldr c7, [x14, #10]
	.inst 0xc2c7a761 // chkeq c27, c7
	b.ne comparison_fail
	.inst 0xc2402dc7 // ldr c7, [x14, #11]
	.inst 0xc2c7a7a1 // chkeq c29, c7
	b.ne comparison_fail
	.inst 0xc24031c7 // ldr c7, [x14, #12]
	.inst 0xc2c7a7c1 // chkeq c30, c7
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x7, v2.d[0]
	cmp x14, x7
	b.ne comparison_fail
	ldr x14, =0x0
	mov x7, v2.d[1]
	cmp x14, x7
	b.ne comparison_fail
	ldr x14, =0x0
	mov x7, v23.d[0]
	cmp x14, x7
	b.ne comparison_fail
	ldr x14, =0x0
	mov x7, v23.d[1]
	cmp x14, x7
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff0
	ldr x1, =check_data1
	ldr x2, =0x00001ff8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
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
