.section data0, #alloc, #write
	.zero 4048
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xdd, 0x0f, 0x00, 0x00
	.zero 32
.data
check_data0:
	.byte 0x1c, 0x20
.data
check_data1:
	.zero 16
.data
check_data2:
	.byte 0xdd, 0x0f, 0x00, 0x00
.data
check_data3:
	.byte 0x3e, 0x20, 0x3e, 0x2b, 0xbb, 0x13, 0xc0, 0x5a, 0xff, 0x02, 0x7e, 0x78, 0x91, 0x19, 0xd3, 0xc2
	.byte 0x3f, 0x70, 0x21, 0xb8, 0x9d, 0x73, 0x04, 0x30, 0x56, 0x46, 0xd3, 0x78, 0x21, 0x20, 0xdd, 0x1a
	.byte 0x2a, 0xfc, 0x7f, 0x42, 0x0c, 0x50, 0x51, 0xa9, 0x00, 0x11, 0xc2, 0xc2
.data
check_data4:
	.zero 2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001e08
	/* C1 */
	.octa 0xc0000000000100050000000000001fdc
	/* C12 */
	.octa 0xa101e1070082000000000001
	/* C18 */
	.octa 0x800000007001600200000000004b692e
	/* C23 */
	.octa 0xc0000000000500070000000000001000
	/* C30 */
	.octa 0x40
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000001e08
	/* C1 */
	.octa 0x3fb80
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C17 */
	.octa 0xa101e1070082000000000000
	/* C18 */
	.octa 0x800000007001600200000000004b6862
	/* C20 */
	.octa 0x0
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xc0000000000500070000000000001000
	/* C29 */
	.octa 0x20008000004100070000000000408e85
	/* C30 */
	.octa 0x201c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000004100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000004d004f0000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 0
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x2b3e203e // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:30 Rn:1 imm3:000 option:001 Rm:30 01011001:01011001 S:1 op:0 sf:0
	.inst 0x5ac013bb // clz_int:aarch64/instrs/integer/arithmetic/cnt Rd:27 Rn:29 op:0 10110101100000000010:10110101100000000010 sf:0
	.inst 0x787e02ff // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:23 00:00 opc:000 o3:0 Rs:30 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2d31991 // ALIGND-C.CI-C Cd:17 Cn:12 0110:0110 U:0 imm6:100110 11000010110:11000010110
	.inst 0xb821703f // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:111 o3:0 Rs:1 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x3004739d // ADR-C.I-C Rd:29 immhi:000010001110011100 P:0 10000:10000 immlo:01 op:0
	.inst 0x78d34656 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:22 Rn:18 01:01 imm9:100110100 0:0 opc:11 111000:111000 size:01
	.inst 0x1add2021 // lslv:aarch64/instrs/integer/shift/variable Rd:1 Rn:1 op2:00 0010:0010 Rm:29 0011010110:0011010110 sf:0
	.inst 0x427ffc2a // ALDAR-R.R-32 Rt:10 Rn:1 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 1:1 L:1 010000100:010000100
	.inst 0xa951500c // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:12 Rn:0 Rt2:10100 imm7:0100010 L:1 1010010:1010010 opc:10
	.inst 0xc2c21100
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
	ldr x24, =initial_cap_values
	.inst 0xc2400300 // ldr c0, [x24, #0]
	.inst 0xc2400701 // ldr c1, [x24, #1]
	.inst 0xc2400b0c // ldr c12, [x24, #2]
	.inst 0xc2400f12 // ldr c18, [x24, #3]
	.inst 0xc2401317 // ldr c23, [x24, #4]
	.inst 0xc240171e // ldr c30, [x24, #5]
	/* Set up flags and system registers */
	mov x24, #0x00000000
	msr nzcv, x24
	ldr x24, =0x200
	msr CPTR_EL3, x24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	ldr x24, =0x4
	msr S3_6_C1_C2_2, x24 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603118 // ldr c24, [c8, #3]
	.inst 0xc28b4138 // msr DDC_EL3, c24
	isb
	.inst 0x82601118 // ldr c24, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c21300 // br c24
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30851035
	msr SCTLR_EL3, x24
	isb
	/* Check processor flags */
	mrs x24, nzcv
	ubfx x24, x24, #28, #4
	mov x8, #0xf
	and x24, x24, x8
	cmp x24, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x24, =final_cap_values
	.inst 0xc2400308 // ldr c8, [x24, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc2400708 // ldr c8, [x24, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400b08 // ldr c8, [x24, #2]
	.inst 0xc2c8a541 // chkeq c10, c8
	b.ne comparison_fail
	.inst 0xc2400f08 // ldr c8, [x24, #3]
	.inst 0xc2c8a581 // chkeq c12, c8
	b.ne comparison_fail
	.inst 0xc2401308 // ldr c8, [x24, #4]
	.inst 0xc2c8a621 // chkeq c17, c8
	b.ne comparison_fail
	.inst 0xc2401708 // ldr c8, [x24, #5]
	.inst 0xc2c8a641 // chkeq c18, c8
	b.ne comparison_fail
	.inst 0xc2401b08 // ldr c8, [x24, #6]
	.inst 0xc2c8a681 // chkeq c20, c8
	b.ne comparison_fail
	.inst 0xc2401f08 // ldr c8, [x24, #7]
	.inst 0xc2c8a6c1 // chkeq c22, c8
	b.ne comparison_fail
	.inst 0xc2402308 // ldr c8, [x24, #8]
	.inst 0xc2c8a6e1 // chkeq c23, c8
	b.ne comparison_fail
	.inst 0xc2402708 // ldr c8, [x24, #9]
	.inst 0xc2c8a7a1 // chkeq c29, c8
	b.ne comparison_fail
	.inst 0xc2402b08 // ldr c8, [x24, #10]
	.inst 0xc2c8a7c1 // chkeq c30, c8
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
	ldr x0, =0x00001f18
	ldr x1, =check_data1
	ldr x2, =0x00001f28
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fdc
	ldr x1, =check_data2
	ldr x2, =0x00001fe0
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
	ldr x0, =0x004b692e
	ldr x1, =check_data4
	ldr x2, =0x004b6930
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004bfb80
	ldr x1, =check_data5
	ldr x2, =0x004bfb84
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b018 // cvtp c24, x0
	.inst 0xc2df4318 // scvalue c24, c24, x31
	.inst 0xc28b4138 // msr DDC_EL3, c24
	ldr x24, =0x30850030
	msr SCTLR_EL3, x24
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
