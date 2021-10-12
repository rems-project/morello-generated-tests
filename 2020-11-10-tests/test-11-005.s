.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data3:
	.byte 0xf2, 0xb3, 0x87, 0x38, 0x5b, 0x88, 0xcb, 0xc2, 0x3f, 0xd4, 0xd2, 0x78, 0x3e, 0x54, 0xfd, 0x02
	.byte 0x1f, 0xbc, 0x28, 0x51, 0x61, 0x12, 0xc2, 0xc2, 0x03, 0x57, 0x25, 0xe2, 0xb6, 0x6d, 0x05, 0xa2
	.byte 0xc1, 0x6b, 0xde, 0xc2, 0xfe, 0xfc, 0xdf, 0x48, 0x80, 0x13, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x80000000000300070000000000001000
	/* C2 */
	.octa 0x204800800c0000007fffff8000
	/* C7 */
	.octa 0x800000000009800600000000004ffffc
	/* C11 */
	.octa 0x5004800c0000008000000000
	/* C13 */
	.octa 0x48000000000300070000000000001010
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x4000000000000000000000000000
	/* C24 */
	.octa 0x40200c
final_cap_values:
	/* C1 */
	.octa 0x8000000000030007ffffffffff0abf2d
	/* C2 */
	.octa 0x204800800c0000007fffff8000
	/* C7 */
	.octa 0x800000000009800600000000004ffffc
	/* C11 */
	.octa 0x5004800c0000008000000000
	/* C13 */
	.octa 0x48000000000300070000000000001570
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x0
	/* C22 */
	.octa 0x4000000000000000000000000000
	/* C24 */
	.octa 0x40200c
	/* C27 */
	.octa 0x4800800c0000007fffff8000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x800000005e040a010000000000000f8a
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000618020110000000000400001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 16
	.dword final_cap_values + 32
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 144
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3887b3f2 // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:31 00:00 imm9:001111011 0:0 opc:10 111000:111000 size:00
	.inst 0xc2cb885b // CHKSSU-C.CC-C Cd:27 Cn:2 0010:0010 opc:10 Cm:11 11000010110:11000010110
	.inst 0x78d2d43f // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:1 01:01 imm9:100101101 0:0 opc:11 111000:111000 size:01
	.inst 0x02fd543e // SUB-C.CIS-C Cd:30 Cn:1 imm12:111101010101 sh:1 A:1 00000010:00000010
	.inst 0x5128bc1f // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:31 Rn:0 imm12:101000101111 sh:0 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2c21261 // CHKSLD-C-C 00001:00001 Cn:19 100:100 opc:00 11000010110000100:11000010110000100
	.inst 0xe2255703 // ALDUR-V.RI-B Rt:3 Rn:24 op2:01 imm9:001010101 V:1 op1:00 11100010:11100010
	.inst 0xa2056db6 // STR-C.RIBW-C Ct:22 Rn:13 11:11 imm9:001010110 0:0 opc:00 10100010:10100010
	.inst 0xc2de6bc1 // ORRFLGS-C.CR-C Cd:1 Cn:30 1010:1010 opc:01 Rm:30 11000010110:11000010110
	.inst 0x48dffcfe // ldarh:aarch64/instrs/memory/ordered Rt:30 Rn:7 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010001:0010001 size:01
	.inst 0xc2c21380
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
	.inst 0xc24001c1 // ldr c1, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dcb // ldr c11, [x14, #3]
	.inst 0xc24011cd // ldr c13, [x14, #4]
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	.inst 0xc2401dd8 // ldr c24, [x14, #7]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851037
	msr SCTLR_EL3, x14
	ldr x14, =0x0
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338e // ldr c14, [c28, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260138e // ldr c14, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
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
	mov x28, #0xf
	and x14, x14, x28
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001dc // ldr c28, [x14, #0]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc24005dc // ldr c28, [x14, #1]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc24009dc // ldr c28, [x14, #2]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc2400ddc // ldr c28, [x14, #3]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc24011dc // ldr c28, [x14, #4]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc24015dc // ldr c28, [x14, #5]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc24019dc // ldr c28, [x14, #6]
	.inst 0xc2dca661 // chkeq c19, c28
	b.ne comparison_fail
	.inst 0xc2401ddc // ldr c28, [x14, #7]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc24021dc // ldr c28, [x14, #8]
	.inst 0xc2dca701 // chkeq c24, c28
	b.ne comparison_fail
	.inst 0xc24025dc // ldr c28, [x14, #9]
	.inst 0xc2dca761 // chkeq c27, c28
	b.ne comparison_fail
	.inst 0xc24029dc // ldr c28, [x14, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x28, v3.d[0]
	cmp x14, x28
	b.ne comparison_fail
	ldr x14, =0x0
	mov x28, v3.d[1]
	cmp x14, x28
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
	ldr x0, =0x00001005
	ldr x1, =check_data1
	ldr x2, =0x00001006
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001570
	ldr x1, =check_data2
	ldr x2, =0x00001580
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
	ldr x0, =0x00402061
	ldr x1, =check_data4
	ldr x2, =0x00402062
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffc
	ldr x1, =check_data5
	ldr x2, =0x004ffffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
