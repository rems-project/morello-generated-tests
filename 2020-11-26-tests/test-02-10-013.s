.section data0, #alloc, #write
	.byte 0xfb, 0x37, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0xfb, 0x37
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data5:
	.byte 0x01
.data
check_data6:
	.zero 2
.data
check_data7:
	.byte 0x3e, 0x51, 0x4c, 0x78, 0x01, 0x11, 0xc1, 0xc2, 0xbe, 0xff, 0x5f, 0x48, 0xe5, 0x10, 0xeb, 0x78
	.byte 0xdf, 0x20, 0x2b, 0xf8, 0x94, 0x27, 0x01, 0x79, 0xa6, 0x93, 0x7c, 0x82, 0xe0, 0x77, 0x04, 0x38
	.byte 0x5c, 0x00, 0x2e, 0x38, 0x00, 0xf0, 0x1c, 0x7c, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data8:
	.zero 2
.data
check_data9:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2001
	/* C2 */
	.octa 0x1030
	/* C6 */
	.octa 0x1200
	/* C7 */
	.octa 0x1000
	/* C8 */
	.octa 0x400000000000000000002001
	/* C9 */
	.octa 0xf4d
	/* C11 */
	.octa 0x4
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C28 */
	.octa 0xfae
	/* C29 */
	.octa 0x9010000000070007000000000043e410
final_cap_values:
	/* C0 */
	.octa 0x2001
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x1030
	/* C5 */
	.octa 0x37fb
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1000
	/* C8 */
	.octa 0x400000000000000000002001
	/* C9 */
	.octa 0xf4d
	/* C11 */
	.octa 0x4
	/* C14 */
	.octa 0x0
	/* C20 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C29 */
	.octa 0x9010000000070007000000000043e410
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x1800
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000011600970000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000180060000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 160
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x784c513e // ldurh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:9 00:00 imm9:011000101 0:0 opc:01 111000:111000 size:01
	.inst 0xc2c11101 // GCLIM-R.C-C Rd:1 Cn:8 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0x485fffbe // ldaxrh:aarch64/instrs/memory/exclusive/single Rt:30 Rn:29 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:01
	.inst 0x78eb10e5 // ldclrh:aarch64/instrs/memory/atomicops/ld Rt:5 Rn:7 00:00 opc:001 0:0 Rs:11 1:1 R:1 A:1 111000:111000 size:01
	.inst 0xf82b20df // steor:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:010 o3:0 Rs:11 1:1 R:0 A:0 00:00 V:0 111:111 size:11
	.inst 0x79012794 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:20 Rn:28 imm12:000001001001 opc:00 111001:111001 size:01
	.inst 0x827c93a6 // ALDR-C.RI-C Ct:6 Rn:29 op:00 imm9:111001001 L:1 1000001001:1000001001
	.inst 0x380477e0 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:0 Rn:31 01:01 imm9:001000111 0:0 opc:00 111000:111000 size:00
	.inst 0x382e005c // ldaddb:aarch64/instrs/memory/atomicops/ld Rt:28 Rn:2 00:00 opc:000 0:0 Rs:14 1:1 R:0 A:0 111000:111000 size:00
	.inst 0x7c1cf000 // stur_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/offset/normal Rt:0 Rn:0 00:00 imm9:111001111 0:0 opc:00 111100:111100 size:01
	.inst 0xc2c212c0
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
	.inst 0xc24006a2 // ldr c2, [x21, #1]
	.inst 0xc2400aa6 // ldr c6, [x21, #2]
	.inst 0xc2400ea7 // ldr c7, [x21, #3]
	.inst 0xc24012a8 // ldr c8, [x21, #4]
	.inst 0xc24016a9 // ldr c9, [x21, #5]
	.inst 0xc2401aab // ldr c11, [x21, #6]
	.inst 0xc2401eae // ldr c14, [x21, #7]
	.inst 0xc24022b4 // ldr c20, [x21, #8]
	.inst 0xc24026bc // ldr c28, [x21, #9]
	.inst 0xc2402abd // ldr c29, [x21, #10]
	/* Vector registers */
	mrs x21, cptr_el3
	bfc x21, #10, #1
	msr cptr_el3, x21
	isb
	ldr q0, =0x0
	/* Set up flags and system registers */
	mov x21, #0x00000000
	msr nzcv, x21
	ldr x21, =initial_SP_EL3_value
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0xc2c1d2bf // cpy c31, c21
	ldr x21, =0x200
	msr CPTR_EL3, x21
	ldr x21, =0x3085103d
	msr SCTLR_EL3, x21
	ldr x21, =0x0
	msr S3_6_C1_C2_2, x21 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032d5 // ldr c21, [c22, #3]
	.inst 0xc28b4135 // msr DDC_EL3, c21
	isb
	.inst 0x826012d5 // ldr c21, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
	.inst 0xc2c212a0 // br c21
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b015 // cvtp c21, x0
	.inst 0xc2df42b5 // scvalue c21, c21, x31
	.inst 0xc28b4135 // msr DDC_EL3, c21
	ldr x21, =0x30851035
	msr SCTLR_EL3, x21
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x21, =final_cap_values
	.inst 0xc24002b6 // ldr c22, [x21, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24006b6 // ldr c22, [x21, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc2400ab6 // ldr c22, [x21, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400eb6 // ldr c22, [x21, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc24012b6 // ldr c22, [x21, #4]
	.inst 0xc2d6a4c1 // chkeq c6, c22
	b.ne comparison_fail
	.inst 0xc24016b6 // ldr c22, [x21, #5]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc2401ab6 // ldr c22, [x21, #6]
	.inst 0xc2d6a501 // chkeq c8, c22
	b.ne comparison_fail
	.inst 0xc2401eb6 // ldr c22, [x21, #7]
	.inst 0xc2d6a521 // chkeq c9, c22
	b.ne comparison_fail
	.inst 0xc24022b6 // ldr c22, [x21, #8]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc24026b6 // ldr c22, [x21, #9]
	.inst 0xc2d6a5c1 // chkeq c14, c22
	b.ne comparison_fail
	.inst 0xc2402ab6 // ldr c22, [x21, #10]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc2402eb6 // ldr c22, [x21, #11]
	.inst 0xc2d6a781 // chkeq c28, c22
	b.ne comparison_fail
	.inst 0xc24032b6 // ldr c22, [x21, #12]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc24036b6 // ldr c22, [x21, #13]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x21, =0x0
	mov x22, v0.d[0]
	cmp x21, x22
	b.ne comparison_fail
	ldr x21, =0x0
	mov x22, v0.d[1]
	cmp x21, x22
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
	ldr x0, =0x00001012
	ldr x1, =check_data1
	ldr x2, =0x00001014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001030
	ldr x1, =check_data2
	ldr x2, =0x00001031
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001040
	ldr x1, =check_data3
	ldr x2, =0x00001042
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001200
	ldr x1, =check_data4
	ldr x2, =0x00001208
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001800
	ldr x1, =check_data5
	ldr x2, =0x00001801
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00001fd0
	ldr x1, =check_data6
	ldr x2, =0x00001fd2
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00400000
	ldr x1, =check_data7
	ldr x2, =0x0040002c
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x0043e410
	ldr x1, =check_data8
	ldr x2, =0x0043e412
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	ldr x0, =0x004400a0
	ldr x1, =check_data9
	ldr x2, =0x004400b0
check_data_loop9:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop9
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
