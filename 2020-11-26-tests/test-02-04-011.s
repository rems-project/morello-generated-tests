.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0xf6, 0x83, 0x50, 0xa9, 0x3d, 0x4d, 0x26, 0x90, 0xbf, 0x72, 0x3f, 0xb8, 0x5d, 0x26, 0xc1, 0x78
	.byte 0x14, 0x44, 0x9f, 0x82, 0x66, 0xfe, 0xdb, 0x6c, 0x9e, 0xc8, 0x37, 0xa2, 0xc0, 0x9f, 0x7f, 0xb1
	.byte 0x3d, 0x16, 0xf6, 0xe2, 0xad, 0x03, 0x17, 0x3a, 0x60, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x85, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data6:
	.zero 16
.data
check_data7:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x48000000000100050000000000800988
	/* C17 */
	.octa 0x201f
	/* C18 */
	.octa 0x80000000400251060000000000408000
	/* C19 */
	.octa 0x800000000003000700000000004004e0
	/* C21 */
	.octa 0xc0000000400000310000000000001028
	/* C23 */
	.octa 0xff8007f8
	/* C30 */
	.octa 0x4000000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0xfe7000
	/* C4 */
	.octa 0x48000000000100050000000000800988
	/* C13 */
	.octa 0xff8007f8
	/* C17 */
	.octa 0x201f
	/* C18 */
	.octa 0x80000000400251060000000000408012
	/* C19 */
	.octa 0x80000000000300070000000000400698
	/* C20 */
	.octa 0x0
	/* C21 */
	.octa 0xc0000000400000310000000000001028
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xff8007f8
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x4000000000000000000000000000
initial_SP_EL3_value:
	.octa 0x800000000807c05700000000003fff40
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200620070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000003e03000700ffffffc0000010
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 176
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa95083f6 // ldp_gen:aarch64/instrs/memory/pair/general/offset Rt:22 Rn:31 Rt2:00000 imm7:0100001 L:1 1010010:1010010 opc:10
	.inst 0x90264d3d // ADRDP-C.ID-C Rd:29 immhi:010011001001101001 P:0 10000:10000 immlo:00 op:1
	.inst 0xb83f72bf // stumin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:21 00:00 opc:111 o3:0 Rs:31 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0x78c1265d // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:29 Rn:18 01:01 imm9:000010010 0:0 opc:11 111000:111000 size:01
	.inst 0x829f4414 // ALDRSB-R.RRB-64 Rt:20 Rn:0 opc:01 S:0 option:010 Rm:31 0:0 L:0 100000101:100000101
	.inst 0x6cdbfe66 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:6 Rn:19 Rt2:11111 imm7:0110111 L:1 1011001:1011001 opc:01
	.inst 0xa237c89e // STR-C.RRB-C Ct:30 Rn:4 10:10 S:0 option:110 Rm:23 1:1 opc:00 10100010:10100010
	.inst 0xb17f9fc0 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:30 imm12:111111100111 sh:1 0:0 10001:10001 S:1 op:0 sf:1
	.inst 0xe2f6163d // ALDUR-V.RI-D Rt:29 Rn:17 op2:01 imm9:101100001 V:1 op1:11 11100010:11100010
	.inst 0x3a1703ad // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:13 Rn:29 000000:000000 Rm:23 11010000:11010000 S:1 op:0 sf:0
	.inst 0xc2c21060
	.zero 36
	.inst 0x00001085
	.zero 1048492
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
	.inst 0xc24001c4 // ldr c4, [x14, #0]
	.inst 0xc24005d1 // ldr c17, [x14, #1]
	.inst 0xc24009d2 // ldr c18, [x14, #2]
	.inst 0xc2400dd3 // ldr c19, [x14, #3]
	.inst 0xc24011d5 // ldr c21, [x14, #4]
	.inst 0xc24015d7 // ldr c23, [x14, #5]
	.inst 0xc24019de // ldr c30, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306e // ldr c14, [c3, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260106e // ldr c14, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x3, #0xf
	and x14, x14, x3
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c3 // ldr c3, [x14, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc2400dc3 // ldr c3, [x14, #3]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc24011c3 // ldr c3, [x14, #4]
	.inst 0xc2c3a641 // chkeq c18, c3
	b.ne comparison_fail
	.inst 0xc24015c3 // ldr c3, [x14, #5]
	.inst 0xc2c3a661 // chkeq c19, c3
	b.ne comparison_fail
	.inst 0xc24019c3 // ldr c3, [x14, #6]
	.inst 0xc2c3a681 // chkeq c20, c3
	b.ne comparison_fail
	.inst 0xc2401dc3 // ldr c3, [x14, #7]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc24021c3 // ldr c3, [x14, #8]
	.inst 0xc2c3a6c1 // chkeq c22, c3
	b.ne comparison_fail
	.inst 0xc24025c3 // ldr c3, [x14, #9]
	.inst 0xc2c3a6e1 // chkeq c23, c3
	b.ne comparison_fail
	.inst 0xc24029c3 // ldr c3, [x14, #10]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc2402dc3 // ldr c3, [x14, #11]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x3, v6.d[0]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v6.d[1]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v29.d[0]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v29.d[1]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v31.d[0]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v31.d[1]
	cmp x14, x3
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001028
	ldr x1, =check_data0
	ldr x2, =0x0000102c
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001085
	ldr x1, =check_data1
	ldr x2, =0x00001086
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001180
	ldr x1, =check_data2
	ldr x2, =0x00001190
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001f80
	ldr x1, =check_data3
	ldr x2, =0x00001f88
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
	ldr x0, =0x00400048
	ldr x1, =check_data5
	ldr x2, =0x00400058
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004004e0
	ldr x1, =check_data6
	ldr x2, =0x004004f0
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00408000
	ldr x1, =check_data7
	ldr x2, =0x00408002
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
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
