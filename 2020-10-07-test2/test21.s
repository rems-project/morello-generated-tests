.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.byte 0x0b, 0x14
.data
check_data2:
	.byte 0x5f, 0x20, 0x47, 0xb8, 0x49, 0x18, 0x91, 0xe2, 0x60, 0x1a, 0x8c, 0xeb, 0xf6, 0x03, 0x01, 0x7a
	.byte 0xdf, 0x1b, 0xda, 0xc2, 0x41, 0x68, 0xc8, 0xc2, 0xbf, 0x43, 0xf2, 0xb0, 0x42, 0x00, 0x08, 0x5a
	.byte 0x61, 0xed, 0x80, 0x82, 0x01, 0x78, 0xf9, 0x78, 0x20, 0x12, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x8000000000010005000000000000140b
	/* C11 */
	.octa 0x40000000000100050000000000000fc3
	/* C12 */
	.octa 0xfffffffffffd0fc0
	/* C19 */
	.octa 0x3c
	/* C25 */
	.octa 0x629
	/* C30 */
	.octa 0x800320070092000000000001
final_cap_values:
	/* C0 */
	.octa 0xbfd
	/* C1 */
	.octa 0x0
	/* C9 */
	.octa 0x0
	/* C11 */
	.octa 0x40000000000100050000000000000fc3
	/* C12 */
	.octa 0xfffffffffffd0fc0
	/* C19 */
	.octa 0x3c
	/* C25 */
	.octa 0x629
	/* C30 */
	.octa 0x800320070092000000000001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080004044e0f60000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000040511037000000000042e001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb847205f // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:2 00:00 imm9:001110010 0:0 opc:01 111000:111000 size:10
	.inst 0xe2911849 // ALDURSW-R.RI-64 Rt:9 Rn:2 op2:10 imm9:100010001 V:0 op1:10 11100010:11100010
	.inst 0xeb8c1a60 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:0 Rn:19 imm6:000110 Rm:12 0:0 shift:10 01011:01011 S:1 op:1 sf:1
	.inst 0x7a0103f6 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:22 Rn:31 000000:000000 Rm:1 11010000:11010000 S:1 op:1 sf:0
	.inst 0xc2da1bdf // ALIGND-C.CI-C Cd:31 Cn:30 0110:0110 U:0 imm6:110100 11000010110:11000010110
	.inst 0xc2c86841 // ORRFLGS-C.CR-C Cd:1 Cn:2 1010:1010 opc:01 Rm:8 11000010110:11000010110
	.inst 0xb0f243bf // ADRP-C.I-C Rd:31 immhi:111001001000011101 P:1 10000:10000 immlo:01 op:1
	.inst 0x5a080042 // sbc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:2 000000:000000 Rm:8 11010000:11010000 S:0 op:1 sf:0
	.inst 0x8280ed61 // ASTRH-R.RRB-32 Rt:1 Rn:11 opc:11 S:0 option:111 Rm:0 0:0 L:0 100000101:100000101
	.inst 0x78f97801 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:0 10:10 S:1 option:011 Rm:25 1:1 opc:11 111000:111000 size:01
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x7, cptr_el3
	orr x7, x7, #0x200
	msr cptr_el3, x7
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
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
	.inst 0xc24000e2 // ldr c2, [x7, #0]
	.inst 0xc24004eb // ldr c11, [x7, #1]
	.inst 0xc24008ec // ldr c12, [x7, #2]
	.inst 0xc2400cf3 // ldr c19, [x7, #3]
	.inst 0xc24010f9 // ldr c25, [x7, #4]
	.inst 0xc24014fe // ldr c30, [x7, #5]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30850032
	msr SCTLR_EL3, x7
	ldr x7, =0x4
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603227 // ldr c7, [c17, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x82601227 // ldr c7, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	/* Check processor flags */
	mrs x7, nzcv
	ubfx x7, x7, #28, #4
	mov x17, #0x3
	and x7, x7, x17
	cmp x7, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000f1 // ldr c17, [x7, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24004f1 // ldr c17, [x7, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24008f1 // ldr c17, [x7, #2]
	.inst 0xc2d1a521 // chkeq c9, c17
	b.ne comparison_fail
	.inst 0xc2400cf1 // ldr c17, [x7, #3]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc24010f1 // ldr c17, [x7, #4]
	.inst 0xc2d1a581 // chkeq c12, c17
	b.ne comparison_fail
	.inst 0xc24014f1 // ldr c17, [x7, #5]
	.inst 0xc2d1a661 // chkeq c19, c17
	b.ne comparison_fail
	.inst 0xc24018f1 // ldr c17, [x7, #6]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc2401cf1 // ldr c17, [x7, #7]
	.inst 0xc2d1a7c1 // chkeq c30, c17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000131c
	ldr x1, =check_data0
	ldr x2, =0x00001320
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001bc0
	ldr x1, =check_data1
	ldr x2, =0x00001bc2
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
	ldr x0, =0x004324b4
	ldr x1, =check_data3
	ldr x2, =0x004324b8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00432886
	ldr x1, =check_data4
	ldr x2, =0x00432888
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
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

	.balign 128
vector_table:
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
