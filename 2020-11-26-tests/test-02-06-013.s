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
	.zero 8
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0xc1, 0xc3, 0xbf, 0x38, 0xd0, 0xa3, 0x0f, 0xf8, 0xab, 0x5f, 0x26, 0x32, 0xbe, 0x7b, 0x06, 0xe2
	.byte 0x05, 0x48, 0x3e, 0x78, 0x59, 0xd8, 0x5b, 0xa2, 0x1e, 0xe3, 0xdf, 0x82, 0xff, 0x23, 0x3d, 0x38
	.byte 0xe1, 0x2f, 0x11, 0x91, 0xa1, 0x33, 0xc2, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x2000
	/* C5 */
	.octa 0xe
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x80000000500400050000000000001000
	/* C29 */
	.octa 0x8000000000074007000000000040400e
	/* C30 */
	.octa 0x1006
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x144b
	/* C2 */
	.octa 0x2000
	/* C5 */
	.octa 0xe
	/* C11 */
	.octa 0xfc43ffff
	/* C16 */
	.octa 0x0
	/* C24 */
	.octa 0x80000000500400050000000000001000
	/* C25 */
	.octa 0x0
	/* C29 */
	.octa 0x8000000000074007000000000040400e
	/* C30 */
	.octa 0xe
initial_SP_EL3_value:
	.octa 0x1000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080003007e80f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000400400140000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x38bfc3c1 // ldaprb:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:30 110000:110000 Rs:11111 111000101:111000101 size:00
	.inst 0xf80fa3d0 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:16 Rn:30 00:00 imm9:011111010 0:0 opc:00 111000:111000 size:11
	.inst 0x32265fab // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:11 Rn:29 imms:010111 immr:100110 N:0 100100:100100 opc:01 sf:0
	.inst 0xe2067bbe // ALDURSB-R.RI-64 Rt:30 Rn:29 op2:10 imm9:001100111 V:0 op1:00 11100010:11100010
	.inst 0x783e4805 // strh_reg:aarch64/instrs/memory/single/general/register Rt:5 Rn:0 10:10 S:0 option:010 Rm:30 1:1 opc:00 111000:111000 size:01
	.inst 0xa25bd859 // LDTR-C.RIB-C Ct:25 Rn:2 10:10 imm9:110111101 0:0 opc:01 10100010:10100010
	.inst 0x82dfe31e // ALDRB-R.RRB-B Rt:30 Rn:24 opc:00 S:0 option:111 Rm:31 0:0 L:1 100000101:100000101
	.inst 0x383d23ff // steorb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:010 o3:0 Rs:29 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x91112fe1 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:1 Rn:31 imm12:010001001011 sh:0 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xc2c233a1 // CHKTGD-C-C 00001:00001 Cn:29 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0xc2c21220
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
	ldr x13, =initial_cap_values
	.inst 0xc24001a0 // ldr c0, [x13, #0]
	.inst 0xc24005a2 // ldr c2, [x13, #1]
	.inst 0xc24009a5 // ldr c5, [x13, #2]
	.inst 0xc2400db0 // ldr c16, [x13, #3]
	.inst 0xc24011b8 // ldr c24, [x13, #4]
	.inst 0xc24015bd // ldr c29, [x13, #5]
	.inst 0xc24019be // ldr c30, [x13, #6]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_SP_EL3_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x3085103f
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x8260322d // ldr c13, [c17, #3]
	.inst 0xc28b412d // msr DDC_EL3, c13
	isb
	.inst 0x8260122d // ldr c13, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30851035
	msr SCTLR_EL3, x13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x17, #0xf
	and x13, x13, x17
	cmp x13, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b1 // ldr c17, [x13, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24005b1 // ldr c17, [x13, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc24009b1 // ldr c17, [x13, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400db1 // ldr c17, [x13, #3]
	.inst 0xc2d1a4a1 // chkeq c5, c17
	b.ne comparison_fail
	.inst 0xc24011b1 // ldr c17, [x13, #4]
	.inst 0xc2d1a561 // chkeq c11, c17
	b.ne comparison_fail
	.inst 0xc24015b1 // ldr c17, [x13, #5]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc24019b1 // ldr c17, [x13, #6]
	.inst 0xc2d1a701 // chkeq c24, c17
	b.ne comparison_fail
	.inst 0xc2401db1 // ldr c17, [x13, #7]
	.inst 0xc2d1a721 // chkeq c25, c17
	b.ne comparison_fail
	.inst 0xc24021b1 // ldr c17, [x13, #8]
	.inst 0xc2d1a7a1 // chkeq c29, c17
	b.ne comparison_fail
	.inst 0xc24025b1 // ldr c17, [x13, #9]
	.inst 0xc2d1a7c1 // chkeq c30, c17
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
	ldr x0, =0x00001006
	ldr x1, =check_data1
	ldr x2, =0x00001007
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
	ldr x0, =0x00001bd0
	ldr x1, =check_data3
	ldr x2, =0x00001be0
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
	ldr x0, =0x00404075
	ldr x1, =check_data5
	ldr x2, =0x00404076
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr DDC_EL3, c13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
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
