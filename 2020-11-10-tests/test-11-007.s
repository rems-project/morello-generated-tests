.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 64
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x60, 0x02, 0x1f, 0xd6, 0x4e, 0x14, 0xc0, 0xda, 0xf1, 0xa6, 0x0c, 0x39, 0x80, 0xa7, 0xc0, 0xc2
	.byte 0x0c, 0xbc, 0x67, 0x82, 0xc2, 0xfe, 0x1e, 0x22, 0x3f, 0xfc, 0x5f, 0x08, 0x00, 0x68, 0xd3, 0xc2
	.byte 0x96, 0xb0, 0xc4, 0xc2, 0x42, 0x0c, 0x41, 0x31, 0x20, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 8
.data
check_data4:
	.zero 16
.data
check_data5:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400040000000000000000000404000
	/* C1 */
	.octa 0x800000000001000500000000004ffffe
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x80000000000100050000000000001c80
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x4
	/* C22 */
	.octa 0x400000004010401100000000004f8000
	/* C23 */
	.octa 0x40000000000100050000000000001cd5
	/* C28 */
	.octa 0x20408040000100070000000000400011
final_cap_values:
	/* C0 */
	.octa 0x400040000000000000000000404000
	/* C1 */
	.octa 0x800000000001000500000000004ffffe
	/* C2 */
	.octa 0x43000
	/* C4 */
	.octa 0x80000000000100050000000000001c80
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x3f
	/* C17 */
	.octa 0x0
	/* C19 */
	.octa 0x4
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0x40000000000100050000000000001cd5
	/* C28 */
	.octa 0x20408040000100070000000000400011
	/* C29 */
	.octa 0x400000000000000000000000404000
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600100000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000500030010000000000400001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword initial_cap_values + 128
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword final_cap_values + 144
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xd61f0260 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:19 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.inst 0xdac0144e // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:14 Rn:2 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0x390ca6f1 // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:17 Rn:23 imm12:001100101001 opc:00 111001:111001 size:00
	.inst 0xc2c0a780 // BLRS-C.C-C 00000:00000 Cn:28 001:001 opc:01 1:1 Cm:0 11000010110:11000010110
	.inst 0x8267bc0c // ALDR-R.RI-64 Rt:12 Rn:0 op:11 imm9:001111011 L:1 1000001001:1000001001
	.inst 0x221efec2 // STLXR-R.CR-C Ct:2 Rn:22 (1)(1)(1)(1)(1):11111 1:1 Rs:30 0:0 L:0 001000100:001000100
	.inst 0x085ffc3f // ldaxrb:aarch64/instrs/memory/exclusive/single Rt:31 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:1 0010000:0010000 size:00
	.inst 0xc2d36800 // ORRFLGS-C.CR-C Cd:0 Cn:0 1010:1010 opc:01 Rm:19 11000010110:11000010110
	.inst 0xc2c4b096 // LDCT-R.R-_ Rt:22 Rn:4 100:100 opc:01 11000010110001001:11000010110001001
	.inst 0x31410c42 // adds_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:2 imm12:000001000011 sh:1 0:0 10001:10001 S:1 op:0 sf:0
	.inst 0xc2c21120
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
	ldr x20, =initial_cap_values
	.inst 0xc2400280 // ldr c0, [x20, #0]
	.inst 0xc2400681 // ldr c1, [x20, #1]
	.inst 0xc2400a82 // ldr c2, [x20, #2]
	.inst 0xc2400e84 // ldr c4, [x20, #3]
	.inst 0xc2401291 // ldr c17, [x20, #4]
	.inst 0xc2401693 // ldr c19, [x20, #5]
	.inst 0xc2401a96 // ldr c22, [x20, #6]
	.inst 0xc2401e97 // ldr c23, [x20, #7]
	.inst 0xc240229c // ldr c28, [x20, #8]
	/* Set up flags and system registers */
	mov x20, #0x00000000
	msr nzcv, x20
	ldr x20, =0x200
	msr CPTR_EL3, x20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	ldr x20, =0x88
	msr S3_6_C1_C2_2, x20 // CCTLR_EL3
	isb
	/* Start test */
	ldr x9, =pcc_return_ddc_capabilities
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0x82603134 // ldr c20, [c9, #3]
	.inst 0xc28b4134 // msr DDC_EL3, c20
	isb
	.inst 0x82601134 // ldr c20, [c9, #1]
	.inst 0x82602129 // ldr c9, [c9, #2]
	.inst 0xc2c21280 // br c20
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30851035
	msr SCTLR_EL3, x20
	isb
	/* Check processor flags */
	mrs x20, nzcv
	ubfx x20, x20, #28, #4
	mov x9, #0xf
	and x20, x20, x9
	cmp x20, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x20, =final_cap_values
	.inst 0xc2400289 // ldr c9, [x20, #0]
	.inst 0xc2c9a401 // chkeq c0, c9
	b.ne comparison_fail
	.inst 0xc2400689 // ldr c9, [x20, #1]
	.inst 0xc2c9a421 // chkeq c1, c9
	b.ne comparison_fail
	.inst 0xc2400a89 // ldr c9, [x20, #2]
	.inst 0xc2c9a441 // chkeq c2, c9
	b.ne comparison_fail
	.inst 0xc2400e89 // ldr c9, [x20, #3]
	.inst 0xc2c9a481 // chkeq c4, c9
	b.ne comparison_fail
	.inst 0xc2401289 // ldr c9, [x20, #4]
	.inst 0xc2c9a581 // chkeq c12, c9
	b.ne comparison_fail
	.inst 0xc2401689 // ldr c9, [x20, #5]
	.inst 0xc2c9a5c1 // chkeq c14, c9
	b.ne comparison_fail
	.inst 0xc2401a89 // ldr c9, [x20, #6]
	.inst 0xc2c9a621 // chkeq c17, c9
	b.ne comparison_fail
	.inst 0xc2401e89 // ldr c9, [x20, #7]
	.inst 0xc2c9a661 // chkeq c19, c9
	b.ne comparison_fail
	.inst 0xc2402289 // ldr c9, [x20, #8]
	.inst 0xc2c9a6c1 // chkeq c22, c9
	b.ne comparison_fail
	.inst 0xc2402689 // ldr c9, [x20, #9]
	.inst 0xc2c9a6e1 // chkeq c23, c9
	b.ne comparison_fail
	.inst 0xc2402a89 // ldr c9, [x20, #10]
	.inst 0xc2c9a781 // chkeq c28, c9
	b.ne comparison_fail
	.inst 0xc2402e89 // ldr c9, [x20, #11]
	.inst 0xc2c9a7a1 // chkeq c29, c9
	b.ne comparison_fail
	.inst 0xc2403289 // ldr c9, [x20, #12]
	.inst 0xc2c9a7c1 // chkeq c30, c9
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001c80
	ldr x1, =check_data0
	ldr x2, =0x00001cc0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
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
	ldr x0, =0x004043d8
	ldr x1, =check_data3
	ldr x2, =0x004043e0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004f8000
	ldr x1, =check_data4
	ldr x2, =0x004f8010
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffffe
	ldr x1, =check_data5
	ldr x2, =0x004fffff
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	/* Done print message */
	/* turn off MMU */
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b014 // cvtp c20, x0
	.inst 0xc2df4294 // scvalue c20, c20, x31
	.inst 0xc28b4134 // msr DDC_EL3, c20
	ldr x20, =0x30850030
	msr SCTLR_EL3, x20
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
