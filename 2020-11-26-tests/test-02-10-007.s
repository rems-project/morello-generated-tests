.section data0, #alloc, #write
	.zero 16
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x01, 0x24, 0x00, 0x80, 0x00, 0x20
	.zero 256
	.byte 0xaa, 0x1d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3792
.data
check_data0:
	.byte 0x10, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x40, 0x01, 0x24, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 4
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x09, 0x24, 0x5f, 0xb8, 0xbe, 0x93, 0xc0, 0xc2, 0xf4, 0x53, 0x46, 0xf8, 0xc0, 0x72, 0xde, 0xc2
	.byte 0xd5, 0x07, 0xc0, 0xda, 0xc7, 0xb3, 0xc0, 0xc2, 0x5d, 0x17, 0x9f, 0xaa, 0x29, 0x20, 0xd4, 0xc2
	.byte 0xa1, 0x23, 0x20, 0x78, 0x60, 0x40, 0xd0, 0xc2, 0x80, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000080080000000000001db8
	/* C1 */
	.octa 0x100060000000000000000
	/* C3 */
	.octa 0x4001000000ffffffffffe001
	/* C16 */
	.octa 0x1
	/* C22 */
	.octa 0x901000000001000500000000000010e0
	/* C26 */
	.octa 0x1120
	/* C29 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x400100000000000000000001
	/* C1 */
	.octa 0x1daa
	/* C3 */
	.octa 0x4001000000ffffffffffe001
	/* C7 */
	.octa 0x0
	/* C9 */
	.octa 0x400000000000000000000000
	/* C16 */
	.octa 0x1
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C22 */
	.octa 0x901000000001000500000000000010e0
	/* C26 */
	.octa 0x1120
	/* C29 */
	.octa 0x1120
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x80000000000300070000000000001f8b
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000002d000e0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000000c0000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword final_cap_values + 128
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb85f2409 // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:9 Rn:0 01:01 imm9:111110010 0:0 opc:01 111000:111000 size:10
	.inst 0xc2c093be // GCTAG-R.C-C Rd:30 Cn:29 100:100 opc:100 1100001011000000:1100001011000000
	.inst 0xf84653f4 // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:20 Rn:31 00:00 imm9:001100101 0:0 opc:01 111000:111000 size:11
	.inst 0xc2de72c0 // BR-CI-C 0:0 0000:0000 Cn:22 100:100 imm7:1110011 110000101101:110000101101
	.inst 0xdac007d5 // rev16_int:aarch64/instrs/integer/arithmetic/rev Rd:21 Rn:30 opc:01 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c0b3c7 // GCSEAL-R.C-C Rd:7 Cn:30 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xaa9f175d // orr_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:29 Rn:26 imm6:000101 Rm:31 N:0 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2d42029 // SCBNDSE-C.CR-C Cd:9 Cn:1 000:000 opc:01 0:0 Rm:20 11000010110:11000010110
	.inst 0x782023a1 // ldeorh:aarch64/instrs/memory/atomicops/ld Rt:1 Rn:29 00:00 opc:010 0:0 Rs:0 1:1 R:0 A:0 111000:111000 size:01
	.inst 0xc2d04060 // SCVALUE-C.CR-C Cd:0 Cn:3 000:000 opc:10 0:0 Rm:16 11000010110:11000010110
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
	ldr x2, =initial_cap_values
	.inst 0xc2400040 // ldr c0, [x2, #0]
	.inst 0xc2400441 // ldr c1, [x2, #1]
	.inst 0xc2400843 // ldr c3, [x2, #2]
	.inst 0xc2400c50 // ldr c16, [x2, #3]
	.inst 0xc2401056 // ldr c22, [x2, #4]
	.inst 0xc240145a // ldr c26, [x2, #5]
	.inst 0xc240185d // ldr c29, [x2, #6]
	/* Set up flags and system registers */
	mov x2, #0x00000000
	msr nzcv, x2
	ldr x2, =initial_SP_EL3_value
	.inst 0xc2400042 // ldr c2, [x2, #0]
	.inst 0xc2c1d05f // cpy c31, c2
	ldr x2, =0x200
	msr CPTR_EL3, x2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	ldr x2, =0x4
	msr S3_6_C1_C2_2, x2 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603182 // ldr c2, [c12, #3]
	.inst 0xc28b4122 // msr DDC_EL3, c2
	isb
	.inst 0x82601182 // ldr c2, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21040 // br c2
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30851035
	msr SCTLR_EL3, x2
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x2, =final_cap_values
	.inst 0xc240004c // ldr c12, [x2, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240044c // ldr c12, [x2, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc240084c // ldr c12, [x2, #2]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc2400c4c // ldr c12, [x2, #3]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240104c // ldr c12, [x2, #4]
	.inst 0xc2cca521 // chkeq c9, c12
	b.ne comparison_fail
	.inst 0xc240144c // ldr c12, [x2, #5]
	.inst 0xc2cca601 // chkeq c16, c12
	b.ne comparison_fail
	.inst 0xc240184c // ldr c12, [x2, #6]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc2401c4c // ldr c12, [x2, #7]
	.inst 0xc2cca6a1 // chkeq c21, c12
	b.ne comparison_fail
	.inst 0xc240204c // ldr c12, [x2, #8]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240244c // ldr c12, [x2, #9]
	.inst 0xc2cca741 // chkeq c26, c12
	b.ne comparison_fail
	.inst 0xc240284c // ldr c12, [x2, #10]
	.inst 0xc2cca7a1 // chkeq c29, c12
	b.ne comparison_fail
	.inst 0xc2402c4c // ldr c12, [x2, #11]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001010
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001120
	ldr x1, =check_data1
	ldr x2, =0x00001122
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001db8
	ldr x1, =check_data2
	ldr x2, =0x00001dbc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff0
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b002 // cvtp c2, x0
	.inst 0xc2df4042 // scvalue c2, c2, x31
	.inst 0xc28b4122 // msr DDC_EL3, c2
	ldr x2, =0x30850030
	msr SCTLR_EL3, x2
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
