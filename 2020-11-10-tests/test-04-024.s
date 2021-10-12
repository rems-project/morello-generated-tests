.section data0, #alloc, #write
	.zero 2048
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0x18, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xc8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data4:
	.byte 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.zero 32
.data
check_data6:
	.byte 0x74, 0xfd, 0x1f, 0x42, 0x48, 0x7e, 0x46, 0x62, 0x0d, 0x68, 0x54, 0x6c, 0x0c, 0xd8, 0x60, 0xb8
	.byte 0xd3, 0xfe, 0x5f, 0x22, 0x02, 0xc4, 0x06, 0x38, 0x5e, 0x31, 0xc7, 0xc2, 0x22, 0xb0, 0xc5, 0xc2
	.byte 0xa2, 0x33, 0x22, 0x38, 0x4d, 0xa4, 0x0b, 0xb8, 0x00, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xffc000000000c0
	/* C2 */
	.octa 0x18
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x480
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x400
	/* C20 */
	.octa 0x8
	/* C22 */
	.octa 0x400
	/* C29 */
	.octa 0x400
final_cap_values:
	/* C0 */
	.octa 0x6c
	/* C1 */
	.octa 0xffc000000000c0
	/* C2 */
	.octa 0xc2
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C11 */
	.octa 0x480
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C18 */
	.octa 0x400
	/* C19 */
	.octa 0x8
	/* C20 */
	.octa 0x8
	/* C22 */
	.octa 0x400
	/* C29 */
	.octa 0x400
	/* C30 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000300060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000005c0c140000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x00000000000018d0
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x421ffd74 // STLR-C.R-C Ct:20 Rn:11 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:0 010000100:010000100
	.inst 0x62467e48 // LDNP-C.RIB-C Ct:8 Rn:18 Ct2:11111 imm7:0001100 L:1 011000100:011000100
	.inst 0x6c54680d // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:13 Rn:0 Rt2:11010 imm7:0101000 L:1 1011000:1011000 opc:01
	.inst 0xb860d80c // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:12 Rn:0 10:10 S:1 option:110 Rm:0 1:1 opc:01 111000:111000 size:10
	.inst 0x225ffed3 // LDAXR-C.R-C Ct:19 Rn:22 (1)(1)(1)(1)(1):11111 1:1 (1)(1)(1)(1)(1):11111 0:0 L:1 001000100:001000100
	.inst 0x3806c402 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:2 Rn:0 01:01 imm9:001101100 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c7315e // RRMASK-R.R-C Rd:30 Rn:10 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c5b022 // CVTP-C.R-C Cd:2 Rn:1 100:100 opc:01 11000010110001011:11000010110001011
	.inst 0x382233a2 // ldsetb:aarch64/instrs/memory/atomicops/ld Rt:2 Rn:29 00:00 opc:011 0:0 Rs:2 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xb80ba44d // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:13 Rn:2 01:01 imm9:010111010 0:0 opc:00 111000:111000 size:10
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e1 // ldr c1, [x7, #1]
	.inst 0xc24008e2 // ldr c2, [x7, #2]
	.inst 0xc2400cea // ldr c10, [x7, #3]
	.inst 0xc24010eb // ldr c11, [x7, #4]
	.inst 0xc24014ed // ldr c13, [x7, #5]
	.inst 0xc24018f2 // ldr c18, [x7, #6]
	.inst 0xc2401cf4 // ldr c20, [x7, #7]
	.inst 0xc24020f6 // ldr c22, [x7, #8]
	.inst 0xc24024fd // ldr c29, [x7, #9]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851037
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603307 // ldr c7, [c24, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601307 // ldr c7, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f8 // ldr c24, [x7, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc24004f8 // ldr c24, [x7, #1]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24008f8 // ldr c24, [x7, #2]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400cf8 // ldr c24, [x7, #3]
	.inst 0xc2d8a501 // chkeq c8, c24
	b.ne comparison_fail
	.inst 0xc24010f8 // ldr c24, [x7, #4]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc24014f8 // ldr c24, [x7, #5]
	.inst 0xc2d8a561 // chkeq c11, c24
	b.ne comparison_fail
	.inst 0xc24018f8 // ldr c24, [x7, #6]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2401cf8 // ldr c24, [x7, #7]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc24020f8 // ldr c24, [x7, #8]
	.inst 0xc2d8a641 // chkeq c18, c24
	b.ne comparison_fail
	.inst 0xc24024f8 // ldr c24, [x7, #9]
	.inst 0xc2d8a661 // chkeq c19, c24
	b.ne comparison_fail
	.inst 0xc24028f8 // ldr c24, [x7, #10]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2402cf8 // ldr c24, [x7, #11]
	.inst 0xc2d8a6c1 // chkeq c22, c24
	b.ne comparison_fail
	.inst 0xc24030f8 // ldr c24, [x7, #12]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc24034f8 // ldr c24, [x7, #13]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x24, v13.d[0]
	cmp x7, x24
	b.ne comparison_fail
	ldr x7, =0x0
	mov x24, v13.d[1]
	cmp x7, x24
	b.ne comparison_fail
	ldr x7, =0x0
	mov x24, v26.d[0]
	cmp x7, x24
	b.ne comparison_fail
	ldr x7, =0x0
	mov x24, v26.d[1]
	cmp x7, x24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001400
	ldr x1, =check_data0
	ldr x2, =0x00001404
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001408
	ldr x1, =check_data1
	ldr x2, =0x0000140c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001540
	ldr x1, =check_data2
	ldr x2, =0x00001550
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001800
	ldr x1, =check_data3
	ldr x2, =0x00001810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001880
	ldr x1, =check_data4
	ldr x2, =0x00001890
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x000018c0
	ldr x1, =check_data5
	ldr x2, =0x000018e0
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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
