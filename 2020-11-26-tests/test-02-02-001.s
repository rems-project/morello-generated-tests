.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1b, 0x00
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x8f, 0x0a, 0xc0, 0x5a, 0xe4, 0xb0, 0xc0, 0xc2, 0xbd, 0x53, 0x3c, 0xe2, 0xbf, 0x23, 0x60, 0xf8
	.byte 0xc8, 0x10, 0xc0, 0x5a, 0xbb, 0x10, 0xc5, 0xc2, 0x13, 0xa0, 0x9f, 0x9a, 0x9e, 0xfd, 0x5f, 0x22
	.byte 0x81, 0x27, 0x7f, 0x22, 0x9f, 0xe3, 0xc0, 0xc2, 0x40, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 32
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1b000000000000
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x3fff800000000000000000000000
	/* C12 */
	.octa 0x1100
	/* C28 */
	.octa 0x401000
	/* C29 */
	.octa 0x40000000000100050000000000001040
final_cap_values:
	/* C0 */
	.octa 0x1b000000000000
	/* C1 */
	.octa 0x0
	/* C4 */
	.octa 0x1
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x3fff800000000000000000000000
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x1100
	/* C19 */
	.octa 0x1b000000000000
	/* C27 */
	.octa 0x0
	/* C28 */
	.octa 0x401000
	/* C29 */
	.octa 0x40000000000100050000000000001040
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc000000008a600000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x5ac00a8f // rev:aarch64/instrs/integer/arithmetic/rev Rd:15 Rn:20 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c0b0e4 // GCSEAL-R.C-C Rd:4 Cn:7 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xe23c53bd // ASTUR-V.RI-B Rt:29 Rn:29 op2:00 imm9:111000101 V:1 op1:00 11100010:11100010
	.inst 0xf86023bf // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:29 00:00 opc:010 o3:0 Rs:0 1:1 R:1 A:0 00:00 V:0 111:111 size:11
	.inst 0x5ac010c8 // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:8 Rn:6 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0xc2c510bb // CVTD-R.C-C Rd:27 Cn:5 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x9a9fa013 // csel:aarch64/instrs/integer/conditional/select Rd:19 Rn:0 o2:0 0:0 cond:1010 Rm:31 011010100:011010100 op:0 sf:1
	.inst 0x225ffd9e // LDAXR-C.R-C Ct:30 Rn:12 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x227f2781 // LDXP-C.R-C Ct:1 Rn:28 Ct2:01001 0:0 (1)(1)(1)(1)(1):11111 1:1 L:1 001000100:001000100
	.inst 0xc2c0e39f // SCFLGS-C.CR-C Cd:31 Cn:28 111000:111000 Rm:0 11000010110:11000010110
	.inst 0xc2c21040
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
	ldr x21, =initial_cap_values
	.inst 0xc24002a0 // ldr c0, [x21, #0]
	.inst 0xc24006a5 // ldr c5, [x21, #1]
	.inst 0xc2400aa7 // ldr c7, [x21, #2]
	.inst 0xc2400eac // ldr c12, [x21, #3]
	.inst 0xc24012bc // ldr c28, [x21, #4]
	.inst 0xc24016bd // ldr c29, [x21, #5]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q29, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	ldr x21, =0x4
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82603055 // ldr c21, [c2, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x82601055 // ldr c21, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* Check processor flags */
	mrs x21, nzcv
	ubfx x21, x21, #28, #4
	mov x2, #0xf
	and x21, x21, x2
	cmp x21, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002a2 // ldr c2, [x21, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400aa2 // ldr c2, [x21, #2]
	.inst 0xc2c2a481 // chkeq c4, c2
	b.ne comparison_fail
	.inst 0xc2400ea2 // ldr c2, [x21, #3]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc24012a2 // ldr c2, [x21, #4]
	.inst 0xc2c2a4e1 // chkeq c7, c2
	b.ne comparison_fail
	.inst 0xc24016a2 // ldr c2, [x21, #5]
	.inst 0xc2c2a521 // chkeq c9, c2
	b.ne comparison_fail
	.inst 0xc2401aa2 // ldr c2, [x21, #6]
	.inst 0xc2c2a581 // chkeq c12, c2
	b.ne comparison_fail
	.inst 0xc2401ea2 // ldr c2, [x21, #7]
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	.inst 0xc24022a2 // ldr c2, [x21, #8]
	.inst 0xc2c2a761 // chkeq c27, c2
	b.ne comparison_fail
	.inst 0xc24026a2 // ldr c2, [x21, #9]
	.inst 0xc2c2a781 // chkeq c28, c2
	b.ne comparison_fail
	.inst 0xc2402aa2 // ldr c2, [x21, #10]
	.inst 0xc2c2a7a1 // chkeq c29, c2
	b.ne comparison_fail
	.inst 0xc2402ea2 // ldr c2, [x21, #11]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x2, v29.d[0]
	cmp x21, x2
	b.ne comparison_fail
	ldr x21, =0x0
	mov x2, v29.d[1]
	cmp x21, x2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001005
	ldr x1, =check_data0
	ldr x2, =0x00001006
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001048
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001100
	ldr x1, =check_data2
	ldr x2, =0x00001110
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
	ldr x0, =0x00401000
	ldr x1, =check_data4
	ldr x2, =0x00401020
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done print message */
	/* turn off MMU */
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30850030
	msr SCTLR_EL3, x21
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
