.section data0, #alloc, #write
	.zero 2592
	.byte 0x00, 0x8d, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1488
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x10, 0x00
.data
check_data1:
	.byte 0x00, 0x08
.data
check_data2:
	.byte 0x00, 0x08
.data
check_data3:
	.zero 16
.data
check_data4:
	.byte 0x3e, 0xa0, 0xbb, 0xf9, 0x6f, 0x17, 0x1e, 0x78, 0x3f, 0x40, 0x3e, 0x78, 0x20, 0x51, 0xc2, 0xc2
.data
check_data5:
	.byte 0xe0, 0x65, 0xbe, 0x82, 0xbf, 0x30, 0x22, 0x38, 0x3a, 0x70, 0x44, 0x82, 0xde, 0xe3, 0xd0, 0xc2
	.byte 0xde, 0xc3, 0x2b, 0x31, 0x53, 0x76, 0xd2, 0xb7
.data
check_data6:
	.byte 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x10800000000000
	/* C1 */
	.octa 0xc0000000200600040000000000001a20
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000000100050000000000001000
	/* C9 */
	.octa 0x20008000900795230000000000400805
	/* C15 */
	.octa 0x800
	/* C19 */
	.octa 0x400000000000000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000200700bf0000000000001080
	/* C30 */
	.octa 0x800
final_cap_values:
	/* C0 */
	.octa 0x10800000000000
	/* C1 */
	.octa 0xc0000000200600040000000000001a20
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0xc0000000000100050000000000001000
	/* C9 */
	.octa 0x20008000900795230000000000400805
	/* C15 */
	.octa 0x800
	/* C19 */
	.octa 0x400000000000000
	/* C26 */
	.octa 0x0
	/* C27 */
	.octa 0x40000000200700bf0000000000001061
	/* C30 */
	.octa 0x12f0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000000100050000000000382000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 64
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf9bba03e // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:1 imm12:111011101000 opc:10 111001:111001 size:11
	.inst 0x781e176f // strh_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:15 Rn:27 01:01 imm9:111100001 0:0 opc:00 111000:111000 size:01
	.inst 0x783e403f // stsmaxh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:1 00:00 opc:100 o3:0 Rs:30 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c25120 // RET-C-C 00000:00000 Cn:9 100:100 opc:10 11000010110000100:11000010110000100
	.zero 2036
	.inst 0x82be65e0 // ASTR-R.RRB-64 Rt:0 Rn:15 opc:01 S:0 option:011 Rm:30 1:1 L:0 100000101:100000101
	.inst 0x382230bf // stsetb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:5 00:00 opc:011 o3:0 Rs:2 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0x8244703a // ASTR-C.RI-C Ct:26 Rn:1 op:00 imm9:001000111 L:0 1000001001:1000001001
	.inst 0xc2d0e3de // SCFLGS-C.CR-C Cd:30 Cn:30 111000:111000 Rm:16 11000010110:11000010110
	.inst 0x312bc3de // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:30 imm12:101011110000 sh:0 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xb7d27653 // tbnz:aarch64/instrs/branch/conditional/test Rt:19 imm14:01001110110010 b40:11010 op:1 011011:011011 b5:1
	.zero 20164
	.inst 0xc2c211a0
	.zero 1026332
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d65 // ldr c5, [x11, #3]
	.inst 0xc2401169 // ldr c9, [x11, #4]
	.inst 0xc240156f // ldr c15, [x11, #5]
	.inst 0xc2401973 // ldr c19, [x11, #6]
	.inst 0xc2401d7a // ldr c26, [x11, #7]
	.inst 0xc240217b // ldr c27, [x11, #8]
	.inst 0xc240257e // ldr c30, [x11, #9]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30851037
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ab // ldr c11, [c13, #3]
	.inst 0xc28b412b // msr DDC_EL3, c11
	isb
	.inst 0x826011ab // ldr c11, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30851035
	msr SCTLR_EL3, x11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x13, #0xf
	and x11, x11, x13
	cmp x11, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240016d // ldr c13, [x11, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc240056d // ldr c13, [x11, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240096d // ldr c13, [x11, #2]
	.inst 0xc2cda441 // chkeq c2, c13
	b.ne comparison_fail
	.inst 0xc2400d6d // ldr c13, [x11, #3]
	.inst 0xc2cda4a1 // chkeq c5, c13
	b.ne comparison_fail
	.inst 0xc240116d // ldr c13, [x11, #4]
	.inst 0xc2cda521 // chkeq c9, c13
	b.ne comparison_fail
	.inst 0xc240156d // ldr c13, [x11, #5]
	.inst 0xc2cda5e1 // chkeq c15, c13
	b.ne comparison_fail
	.inst 0xc240196d // ldr c13, [x11, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401d6d // ldr c13, [x11, #7]
	.inst 0xc2cda741 // chkeq c26, c13
	b.ne comparison_fail
	.inst 0xc240216d // ldr c13, [x11, #8]
	.inst 0xc2cda761 // chkeq c27, c13
	b.ne comparison_fail
	.inst 0xc240256d // ldr c13, [x11, #9]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001082
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a20
	ldr x1, =check_data2
	ldr x2, =0x00001a22
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e90
	ldr x1, =check_data3
	ldr x2, =0x00001ea0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x00400010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400804
	ldr x1, =check_data5
	ldr x2, =0x0040081c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004056e0
	ldr x1, =check_data6
	ldr x2, =0x004056e4
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done print message */
	/* turn off MMU */
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr DDC_EL3, c11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
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
