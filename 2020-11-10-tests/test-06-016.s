.section data0, #alloc, #write
	.zero 224
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x08, 0x00
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0xfe, 0xcc, 0x29, 0xb0, 0x71, 0xfc, 0x5f, 0x42, 0xb1, 0x63, 0x50, 0x91, 0x53, 0x54, 0x8f, 0x2c
	.byte 0x60, 0x63, 0x5d, 0x82, 0x99, 0xfe, 0xe0, 0x48, 0xa2, 0x7c, 0x5f, 0x48, 0x31, 0xf0, 0xc5, 0xc2
	.byte 0x81, 0x16, 0xc0, 0x5a, 0x00, 0x58, 0x82, 0xaa, 0xe0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4000000000000000004000000000
	/* C1 */
	.octa 0x80008ec001
	/* C2 */
	.octa 0x1004
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x1000
	/* C20 */
	.octa 0x10e0
	/* C27 */
	.octa 0x48000000000100050000000000000180
final_cap_values:
	/* C0 */
	.octa 0x8
	/* C1 */
	.octa 0x12
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x1000
	/* C5 */
	.octa 0x1000
	/* C17 */
	.octa 0x200080000606400700000080008ec001
	/* C20 */
	.octa 0x10e0
	/* C27 */
	.octa 0x48000000000100050000000000000180
	/* C30 */
	.octa 0x53d9d000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000060640070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000600000000000000000000800
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword initial_cap_values + 0
	.dword initial_cap_values + 96
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb029ccfe // ADRDP-C.ID-C Rd:30 immhi:010100111001100111 P:0 10000:10000 immlo:01 op:1
	.inst 0x425ffc71 // LDAR-C.R-C Ct:17 Rn:3 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 010000100:010000100
	.inst 0x915063b1 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:17 Rn:29 imm12:010000011000 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0x2c8f5453 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:19 Rn:2 Rt2:10101 imm7:0011110 L:0 1011001:1011001 opc:00
	.inst 0x825d6360 // ASTR-C.RI-C Ct:0 Rn:27 op:00 imm9:111010110 L:0 1000001001:1000001001
	.inst 0x48e0fe99 // cash:aarch64/instrs/memory/atomicops/cas/single Rt:25 Rn:20 11111:11111 o0:1 Rs:0 1:1 L:1 0010001:0010001 size:01
	.inst 0x485f7ca2 // ldxrh:aarch64/instrs/memory/exclusive/single Rt:2 Rn:5 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0xc2c5f031 // CVTPZ-C.R-C Cd:17 Rn:1 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x5ac01681 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:1 Rn:20 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xaa825800 // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:0 Rn:0 imm6:010110 Rm:2 N:0 shift:10 01010:01010 opc:01 sf:1
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
	ldr x18, =initial_cap_values
	.inst 0xc2400240 // ldr c0, [x18, #0]
	.inst 0xc2400641 // ldr c1, [x18, #1]
	.inst 0xc2400a42 // ldr c2, [x18, #2]
	.inst 0xc2400e43 // ldr c3, [x18, #3]
	.inst 0xc2401245 // ldr c5, [x18, #4]
	.inst 0xc2401654 // ldr c20, [x18, #5]
	.inst 0xc2401a5b // ldr c27, [x18, #6]
	/* Vector registers */
	mrs x18, cptr_el3
	bfc x18, #10, #1
	msr cptr_el3, x18
	isb
	ldr q19, =0x0
	ldr q21, =0x0
	/* Set up flags and system registers */
	mov x18, #0x00000000
	msr nzcv, x18
	ldr x18, =0x200
	msr CPTR_EL3, x18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	ldr x18, =0x4
	msr S3_6_C1_C2_2, x18 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032f2 // ldr c18, [c23, #3]
	.inst 0xc28b4132 // msr DDC_EL3, c18
	isb
	.inst 0x826012f2 // ldr c18, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21240 // br c18
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b012 // cvtp c18, x0
	.inst 0xc2df4252 // scvalue c18, c18, x31
	.inst 0xc28b4132 // msr DDC_EL3, c18
	ldr x18, =0x30851035
	msr SCTLR_EL3, x18
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x18, =final_cap_values
	.inst 0xc2400257 // ldr c23, [x18, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400657 // ldr c23, [x18, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400a57 // ldr c23, [x18, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400e57 // ldr c23, [x18, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2401257 // ldr c23, [x18, #4]
	.inst 0xc2d7a4a1 // chkeq c5, c23
	b.ne comparison_fail
	.inst 0xc2401657 // ldr c23, [x18, #5]
	.inst 0xc2d7a621 // chkeq c17, c23
	b.ne comparison_fail
	.inst 0xc2401a57 // ldr c23, [x18, #6]
	.inst 0xc2d7a681 // chkeq c20, c23
	b.ne comparison_fail
	.inst 0xc2401e57 // ldr c23, [x18, #7]
	.inst 0xc2d7a761 // chkeq c27, c23
	b.ne comparison_fail
	.inst 0xc2402257 // ldr c23, [x18, #8]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check vector registers */
	ldr x18, =0x0
	mov x23, v19.d[0]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v19.d[1]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v21.d[0]
	cmp x18, x23
	b.ne comparison_fail
	ldr x18, =0x0
	mov x23, v21.d[1]
	cmp x18, x23
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
	ldr x0, =0x000010e0
	ldr x1, =check_data1
	ldr x2, =0x000010e2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ee0
	ldr x1, =check_data2
	ldr x2, =0x00001ef0
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
