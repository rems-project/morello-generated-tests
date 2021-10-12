.section data0, #alloc, #write
	.zero 32
	.byte 0x00, 0x00, 0xf9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 208
	.byte 0xe1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 224
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xf8, 0x80
	.zero 3584
.data
check_data0:
	.byte 0xf9, 0x00
.data
check_data1:
	.zero 8
.data
check_data2:
	.byte 0xe1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data3:
	.byte 0x00, 0x00, 0xf8, 0x80
.data
check_data4:
	.zero 4
.data
check_data5:
	.byte 0xdf, 0x60, 0x33, 0xf8, 0x15, 0xb0, 0xc5, 0xc2, 0xaa, 0xb8, 0xcf, 0xc2, 0xe1, 0x13, 0xc2, 0xc2
	.byte 0x70, 0x66, 0x9a, 0xb8, 0xc0, 0x43, 0xb7, 0x78, 0xff, 0x53, 0x7f, 0xb8, 0x00, 0x63, 0x21, 0x38
	.byte 0x34, 0xf4, 0x00, 0xb8, 0x41, 0xfd, 0x5f, 0xc8, 0x40, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400000400000
	/* C1 */
	.octa 0xfd8
	/* C5 */
	.octa 0x2000300070000000000000020
	/* C6 */
	.octa 0xe0
	/* C19 */
	.octa 0xe0
	/* C20 */
	.octa 0x0
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x2
	/* C30 */
	.octa 0x2
final_cap_values:
	/* C0 */
	.octa 0xf9
	/* C1 */
	.octa 0x0
	/* C5 */
	.octa 0x2000300070000000000000020
	/* C6 */
	.octa 0xe0
	/* C10 */
	.octa 0x2403f00200000000000000020
	/* C16 */
	.octa 0xe1
	/* C19 */
	.octa 0x86
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x20008000000100070000400000400000
	/* C23 */
	.octa 0x0
	/* C24 */
	.octa 0x2
	/* C30 */
	.octa 0x2
initial_SP_EL3_value:
	.octa 0x1dc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000708160000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf83360df // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:110 o3:0 Rs:19 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0xc2c5b015 // CVTP-C.R-C Cd:21 Rn:0 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0xc2cfb8aa // SCBNDS-C.CI-C Cd:10 Cn:5 1110:1110 S:0 imm6:011111 11000010110:11000010110
	.inst 0xc2c213e1 // CHKSLD-C-C 00001:00001 Cn:31 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xb89a6670 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:16 Rn:19 01:01 imm9:110100110 0:0 opc:10 111000:111000 size:10
	.inst 0x78b743c0 // ldsmaxh:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:30 00:00 opc:100 0:0 Rs:23 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xb87f53ff // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:101 o3:0 Rs:31 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x38216300 // ldumaxb:aarch64/instrs/memory/atomicops/ld Rt:0 Rn:24 00:00 opc:110 0:0 Rs:1 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xb800f434 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:20 Rn:1 01:01 imm9:000001111 0:0 opc:00 111000:111000 size:10
	.inst 0xc85ffd41 // ldaxr:aarch64/instrs/memory/exclusive/single Rt:1 Rn:10 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:11
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b25 // ldr c5, [x25, #2]
	.inst 0xc2400f26 // ldr c6, [x25, #3]
	.inst 0xc2401333 // ldr c19, [x25, #4]
	.inst 0xc2401734 // ldr c20, [x25, #5]
	.inst 0xc2401b37 // ldr c23, [x25, #6]
	.inst 0xc2401f38 // ldr c24, [x25, #7]
	.inst 0xc240233e // ldr c30, [x25, #8]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30851035
	msr SCTLR_EL3, x25
	ldr x25, =0xc
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x2, =pcc_return_ddc_capabilities
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0x82603059 // ldr c25, [c2, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601059 // ldr c25, [c2, #1]
	.inst 0x82602042 // ldr c2, [c2, #2]
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
	mov x2, #0xf
	and x25, x25, x2
	cmp x25, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400322 // ldr c2, [x25, #0]
	.inst 0xc2c2a401 // chkeq c0, c2
	b.ne comparison_fail
	.inst 0xc2400722 // ldr c2, [x25, #1]
	.inst 0xc2c2a421 // chkeq c1, c2
	b.ne comparison_fail
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2c2a4a1 // chkeq c5, c2
	b.ne comparison_fail
	.inst 0xc2400f22 // ldr c2, [x25, #3]
	.inst 0xc2c2a4c1 // chkeq c6, c2
	b.ne comparison_fail
	.inst 0xc2401322 // ldr c2, [x25, #4]
	.inst 0xc2c2a541 // chkeq c10, c2
	b.ne comparison_fail
	.inst 0xc2401722 // ldr c2, [x25, #5]
	.inst 0xc2c2a601 // chkeq c16, c2
	b.ne comparison_fail
	.inst 0xc2401b22 // ldr c2, [x25, #6]
	.inst 0xc2c2a661 // chkeq c19, c2
	b.ne comparison_fail
	.inst 0xc2401f22 // ldr c2, [x25, #7]
	.inst 0xc2c2a681 // chkeq c20, c2
	b.ne comparison_fail
	.inst 0xc2402322 // ldr c2, [x25, #8]
	.inst 0xc2c2a6a1 // chkeq c21, c2
	b.ne comparison_fail
	.inst 0xc2402722 // ldr c2, [x25, #9]
	.inst 0xc2c2a6e1 // chkeq c23, c2
	b.ne comparison_fail
	.inst 0xc2402b22 // ldr c2, [x25, #10]
	.inst 0xc2c2a701 // chkeq c24, c2
	b.ne comparison_fail
	.inst 0xc2402f22 // ldr c2, [x25, #11]
	.inst 0xc2c2a7c1 // chkeq c30, c2
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001022
	ldr x1, =check_data0
	ldr x2, =0x00001024
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
	ldr x2, =0x00001108
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x000011fc
	ldr x1, =check_data3
	ldr x2, =0x00001200
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001ff8
	ldr x1, =check_data4
	ldr x2, =0x00001ffc
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
