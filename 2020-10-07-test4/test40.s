.section data0, #alloc, #write
	.zero 16
	.byte 0x05, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x20, 0x06, 0x80, 0x00, 0x80, 0x00, 0x20
	.zero 4064
.data
check_data0:
	.zero 16
	.byte 0x05, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x20, 0x06, 0x80, 0x00, 0x80, 0x00, 0x20
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 4
.data
check_data3:
	.byte 0x41, 0x10, 0xc4, 0xc2, 0xbe, 0xf0, 0xd1, 0x82, 0x0a, 0x90, 0xc5, 0xc2, 0xe2, 0x0f, 0xc6, 0x02
	.byte 0x42, 0x18, 0x3e, 0x71, 0xb2, 0x30, 0x44, 0x2c, 0x6d, 0xf9, 0x65, 0x82, 0x44, 0x0a, 0xc6, 0x1a
	.byte 0x0c, 0xff, 0x9f, 0x48, 0x02, 0x02, 0x71, 0x82, 0x60, 0x10, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1
	/* C2 */
	.octa 0x90000000325500070000000000001000
	/* C5 */
	.octa 0x80000000500210040000000000404004
	/* C6 */
	.octa 0x0
	/* C11 */
	.octa 0x1e00
	/* C12 */
	.octa 0x0
	/* C16 */
	.octa 0xe0
	/* C17 */
	.octa 0xffffffffffbfcffc
	/* C24 */
	.octa 0x40000000000400030000000000001000
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x0
	/* C5 */
	.octa 0x80000000500210040000000000404004
	/* C6 */
	.octa 0x0
	/* C10 */
	.octa 0x800000005f9008010000000000000001
	/* C11 */
	.octa 0x1e00
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0xe0
	/* C17 */
	.octa 0xffffffffffbfcffc
	/* C24 */
	.octa 0x40000000000400030000000000001000
	/* C30 */
	.octa 0x0
initial_SP_EL3_value:
	.octa 0x660050000800000004000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000400600000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000005f90080100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001010
	.dword 0x00000000000011e0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 128
	.dword final_cap_values + 64
	.dword final_cap_values + 192
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c41041 // LDPBR-C.C-C Ct:1 Cn:2 100:100 opc:00 11000010110001000:11000010110001000
	.inst 0x82d1f0be // ALDRB-R.RRB-B Rt:30 Rn:5 opc:00 S:1 option:111 Rm:17 0:0 L:1 100000101:100000101
	.inst 0xc2c5900a // CVTD-C.R-C Cd:10 Rn:0 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x02c60fe2 // SUB-C.CIS-C Cd:2 Cn:31 imm12:000110000011 sh:1 A:1 00000010:00000010
	.inst 0x713e1842 // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:2 Rn:2 imm12:111110000110 sh:0 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0x2c4430b2 // ldnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:18 Rn:5 Rt2:01100 imm7:0001000 L:1 1011000:1011000 opc:00
	.inst 0x8265f96d // ALDR-R.RI-32 Rt:13 Rn:11 op:10 imm9:001011111 L:1 1000001001:1000001001
	.inst 0x1ac60a44 // udiv:aarch64/instrs/integer/arithmetic/div Rd:4 Rn:18 o1:0 00001:00001 Rm:6 0011010110:0011010110 sf:0
	.inst 0x489fff0c // stlrh:aarch64/instrs/memory/ordered Rt:12 Rn:24 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:01
	.inst 0x82710202 // ALDR-C.RI-C Ct:2 Rn:16 op:00 imm9:100010000 L:1 1000001001:1000001001
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x14, cptr_el3
	orr x14, x14, #0x200
	msr cptr_el3, x14
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c2 // ldr c2, [x14, #1]
	.inst 0xc24009c5 // ldr c5, [x14, #2]
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc24011cb // ldr c11, [x14, #4]
	.inst 0xc24015cc // ldr c12, [x14, #5]
	.inst 0xc24019d0 // ldr c16, [x14, #6]
	.inst 0xc2401dd1 // ldr c17, [x14, #7]
	.inst 0xc24021d8 // ldr c24, [x14, #8]
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0x0
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
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x3, #0xf
	and x14, x14, x3
	cmp x14, #0xa
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c3 // ldr c3, [x14, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005c3 // ldr c3, [x14, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009c3 // ldr c3, [x14, #2]
	.inst 0xc2c3a441 // chkeq c2, c3
	b.ne comparison_fail
	.inst 0xc2400dc3 // ldr c3, [x14, #3]
	.inst 0xc2c3a481 // chkeq c4, c3
	b.ne comparison_fail
	.inst 0xc24011c3 // ldr c3, [x14, #4]
	.inst 0xc2c3a4a1 // chkeq c5, c3
	b.ne comparison_fail
	.inst 0xc24015c3 // ldr c3, [x14, #5]
	.inst 0xc2c3a4c1 // chkeq c6, c3
	b.ne comparison_fail
	.inst 0xc24019c3 // ldr c3, [x14, #6]
	.inst 0xc2c3a541 // chkeq c10, c3
	b.ne comparison_fail
	.inst 0xc2401dc3 // ldr c3, [x14, #7]
	.inst 0xc2c3a561 // chkeq c11, c3
	b.ne comparison_fail
	.inst 0xc24021c3 // ldr c3, [x14, #8]
	.inst 0xc2c3a581 // chkeq c12, c3
	b.ne comparison_fail
	.inst 0xc24025c3 // ldr c3, [x14, #9]
	.inst 0xc2c3a5a1 // chkeq c13, c3
	b.ne comparison_fail
	.inst 0xc24029c3 // ldr c3, [x14, #10]
	.inst 0xc2c3a601 // chkeq c16, c3
	b.ne comparison_fail
	.inst 0xc2402dc3 // ldr c3, [x14, #11]
	.inst 0xc2c3a621 // chkeq c17, c3
	b.ne comparison_fail
	.inst 0xc24031c3 // ldr c3, [x14, #12]
	.inst 0xc2c3a701 // chkeq c24, c3
	b.ne comparison_fail
	.inst 0xc24035c3 // ldr c3, [x14, #13]
	.inst 0xc2c3a7c1 // chkeq c30, c3
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x3, v12.d[0]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v12.d[1]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v18.d[0]
	cmp x14, x3
	b.ne comparison_fail
	ldr x14, =0x0
	mov x3, v18.d[1]
	cmp x14, x3
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
	ldr x0, =0x000011e0
	ldr x1, =check_data1
	ldr x2, =0x000011f0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f7c
	ldr x1, =check_data2
	ldr x2, =0x00001f80
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
	ldr x0, =0x00404024
	ldr x1, =check_data4
	ldr x2, =0x0040402c
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
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
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
