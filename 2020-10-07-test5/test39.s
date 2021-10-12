.section data0, #alloc, #write
	.zero 16
	.byte 0x81, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x87, 0x80, 0x8f, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 96
	.byte 0x30, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0xc0, 0x00, 0x80, 0x00, 0x20
	.zero 3952
.data
check_data0:
	.zero 16
	.byte 0x81, 0x80, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x87, 0x80, 0x8f, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.byte 0x30, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x01, 0xc0, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.byte 0xc1, 0x13, 0xc4, 0xc2
.data
check_data3:
	.byte 0xc0, 0x11, 0xc2, 0xc2
.data
check_data4:
	.byte 0x08, 0x00, 0x1f, 0x9a, 0x5f, 0x70, 0xc0, 0xc2, 0x05, 0xf8, 0xa2, 0x9b, 0xff, 0x53, 0xf2, 0x82
	.byte 0xac, 0x0f, 0xc1, 0xc2, 0xde, 0x67, 0xc8, 0x82, 0x3e, 0x30, 0xc3, 0xc2, 0xc0, 0x26, 0xb1, 0x02
	.byte 0xc0, 0x10, 0xd3, 0xc2
.data
check_data5:
	.zero 4
.data
check_data6:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x4feffe
	/* C2 */
	.octa 0x100060000000000000000
	/* C6 */
	.octa 0x90100000000500070000000000000f00
	/* C18 */
	.octa 0x8004b672
	/* C22 */
	.octa 0x800720048000000000000000
	/* C30 */
	.octa 0x90000000000100050000000000001000
final_cap_values:
	/* C0 */
	.octa 0x800720047ffffffffffff3b7
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x100060000000000000000
	/* C5 */
	.octa 0x1000
	/* C6 */
	.octa 0x90100000000500070000000000000f00
	/* C8 */
	.octa 0x4feffe
	/* C18 */
	.octa 0x8004b672
	/* C22 */
	.octa 0x800720048000000000000000
	/* C30 */
	.octa 0x800000000000000000000000
initial_SP_EL3_value:
	.octa 0xfffffffe003d2630
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700060000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x0000000000001080
	.dword initial_cap_values + 32
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c413c1 // LDPBR-C.C-C Ct:1 Cn:30 100:100 opc:00 11000010110001000:11000010110001000
	.zero 44
	.inst 0xc2c211c0
	.zero 32844
	.inst 0x9a1f0008 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:8 Rn:0 000000:000000 Rm:31 11010000:11010000 S:0 op:0 sf:1
	.inst 0xc2c0705f // GCOFF-R.C-C Rd:31 Cn:2 100:100 opc:011 1100001011000000:1100001011000000
	.inst 0x9ba2f805 // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:5 Rn:0 Ra:30 o0:1 Rm:2 01:01 U:1 10011011:10011011
	.inst 0x82f253ff // ALDR-R.RRB-32 Rt:31 Rn:31 opc:00 S:1 option:010 Rm:18 1:1 L:1 100000101:100000101
	.inst 0xc2c10fac // CSEL-C.CI-C Cd:12 Cn:29 11:11 cond:0000 Cm:1 11000010110:11000010110
	.inst 0x82c867de // ALDRSB-R.RRB-32 Rt:30 Rn:30 opc:01 S:0 option:011 Rm:8 0:0 L:1 100000101:100000101
	.inst 0xc2c3303e // SEAL-C.CI-C Cd:30 Cn:1 100:100 form:01 11000010110000110:11000010110000110
	.inst 0x02b126c0 // SUB-C.CIS-C Cd:0 Cn:22 imm12:110001001001 sh:0 A:1 00000010:00000010
	.inst 0xc2d310c0 // BR-CI-C 0:0 0000:0000 Cn:6 100:100 imm7:0011000 110000101101:110000101101
	.zero 1015644
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x27, cptr_el3
	orr x27, x27, #0x200
	msr cptr_el3, x27
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
	ldr x27, =initial_cap_values
	.inst 0xc2400360 // ldr c0, [x27, #0]
	.inst 0xc2400762 // ldr c2, [x27, #1]
	.inst 0xc2400b66 // ldr c6, [x27, #2]
	.inst 0xc2400f72 // ldr c18, [x27, #3]
	.inst 0xc2401376 // ldr c22, [x27, #4]
	.inst 0xc240177e // ldr c30, [x27, #5]
	/* Set up flags and system registers */
	mov x27, #0x40000000
	msr nzcv, x27
	ldr x27, =initial_SP_EL3_value
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0xc2c1d37f // cpy c31, c27
	ldr x27, =0x200
	msr CPTR_EL3, x27
	ldr x27, =0x30850038
	msr SCTLR_EL3, x27
	ldr x27, =0x0
	msr S3_6_C1_C2_2, x27 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031db // ldr c27, [c14, #3]
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	.inst 0x826011db // ldr c27, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21360 // br c27
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
	isb
	/* Check processor flags */
	mrs x27, nzcv
	ubfx x27, x27, #28, #4
	mov x14, #0x6
	and x27, x27, x14
	cmp x27, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x27, =final_cap_values
	.inst 0xc240036e // ldr c14, [x27, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc240076e // ldr c14, [x27, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc2400b6e // ldr c14, [x27, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400f6e // ldr c14, [x27, #3]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc240136e // ldr c14, [x27, #4]
	.inst 0xc2cea4c1 // chkeq c6, c14
	b.ne comparison_fail
	.inst 0xc240176e // ldr c14, [x27, #5]
	.inst 0xc2cea501 // chkeq c8, c14
	b.ne comparison_fail
	.inst 0xc2401b6e // ldr c14, [x27, #6]
	.inst 0xc2cea641 // chkeq c18, c14
	b.ne comparison_fail
	.inst 0xc2401f6e // ldr c14, [x27, #7]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc240236e // ldr c14, [x27, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001080
	ldr x1, =check_data1
	ldr x2, =0x00001090
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400030
	ldr x1, =check_data3
	ldr x2, =0x00400034
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00408080
	ldr x1, =check_data4
	ldr x2, =0x004080a4
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004ffff8
	ldr x1, =check_data5
	ldr x2, =0x004ffffc
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x004ffffe
	ldr x1, =check_data6
	ldr x2, =0x004fffff
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01b // cvtp c27, x0
	.inst 0xc2df437b // scvalue c27, c27, x31
	.inst 0xc28b413b // msr DDC_EL3, c27
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
