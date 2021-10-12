.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xa0, 0x17
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xde, 0x63, 0x86, 0xf8, 0x00, 0x7c, 0x9f, 0x48, 0x20, 0x00, 0x5f, 0xd6
.data
check_data3:
	.byte 0x80, 0x73, 0xed, 0xc2, 0xbf, 0x13, 0xc0, 0xc2, 0xfd, 0x2b, 0xda, 0x9a, 0x5f, 0x02, 0x00, 0x9a
	.byte 0x3e, 0xd7, 0x69, 0x82, 0xdf, 0x1b, 0xfd, 0xc2, 0x7f, 0xdf, 0x3f, 0x39, 0x00, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x17a0
	/* C1 */
	.octa 0x400800
	/* C25 */
	.octa 0x80000000000100060000000000001f61
	/* C27 */
	.octa 0x1007
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C29 */
	.octa 0x400000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x3fff800000006b00000000000000
	/* C1 */
	.octa 0x400800
	/* C25 */
	.octa 0x80000000000100060000000000001f61
	/* C27 */
	.octa 0x1007
	/* C28 */
	.octa 0x3fff800000000000000000000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000110000000000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf88663de // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:001100110 0:0 opc:10 111000:111000 size:11
	.inst 0x489f7c00 // stllrh:aarch64/instrs/memory/ordered Rt:0 Rn:0 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0xd65f0020 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:1 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 2036
	.inst 0xc2ed7380 // EORFLGS-C.CI-C Cd:0 Cn:28 0:0 10:10 imm8:01101011 11000010111:11000010111
	.inst 0xc2c013bf // GCBASE-R.C-C Rd:31 Cn:29 100:100 opc:000 1100001011000000:1100001011000000
	.inst 0x9ada2bfd // asrv:aarch64/instrs/integer/shift/variable Rd:29 Rn:31 op2:10 0010:0010 Rm:26 0011010110:0011010110 sf:1
	.inst 0x9a00025f // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:18 000000:000000 Rm:0 11010000:11010000 S:0 op:0 sf:1
	.inst 0x8269d73e // ALDRB-R.RI-B Rt:30 Rn:25 op:01 imm9:010011101 L:1 1000001001:1000001001
	.inst 0xc2fd1bdf // CVT-C.CR-C Cd:31 Cn:30 0110:0110 0:0 0:0 Rm:29 11000010111:11000010111
	.inst 0x393fdf7f // strb_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:27 imm12:111111110111 opc:00 111001:111001 size:00
	.inst 0xc2c21100
	.zero 1046496
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e0 // ldr c0, [x23, #0]
	.inst 0xc24006e1 // ldr c1, [x23, #1]
	.inst 0xc2400af9 // ldr c25, [x23, #2]
	.inst 0xc2400efb // ldr c27, [x23, #3]
	.inst 0xc24012fc // ldr c28, [x23, #4]
	.inst 0xc24016fd // ldr c29, [x23, #5]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851037
	msr SCTLR_EL3, x23
	ldr x23, =0xc
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x8, =pcc_return_ddc_capabilities
	.inst 0xc2400108 // ldr c8, [x8, #0]
	.inst 0x82603117 // ldr c23, [c8, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601117 // ldr c23, [c8, #1]
	.inst 0x82602108 // ldr c8, [c8, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002e8 // ldr c8, [x23, #0]
	.inst 0xc2c8a401 // chkeq c0, c8
	b.ne comparison_fail
	.inst 0xc24006e8 // ldr c8, [x23, #1]
	.inst 0xc2c8a421 // chkeq c1, c8
	b.ne comparison_fail
	.inst 0xc2400ae8 // ldr c8, [x23, #2]
	.inst 0xc2c8a721 // chkeq c25, c8
	b.ne comparison_fail
	.inst 0xc2400ee8 // ldr c8, [x23, #3]
	.inst 0xc2c8a761 // chkeq c27, c8
	b.ne comparison_fail
	.inst 0xc24012e8 // ldr c8, [x23, #4]
	.inst 0xc2c8a781 // chkeq c28, c8
	b.ne comparison_fail
	.inst 0xc24016e8 // ldr c8, [x23, #5]
	.inst 0xc2c8a7c1 // chkeq c30, c8
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000017a0
	ldr x1, =check_data0
	ldr x2, =0x000017a2
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
	ldr x2, =0x0040000c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400800
	ldr x1, =check_data3
	ldr x2, =0x00400820
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
