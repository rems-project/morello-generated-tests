.section data0, #alloc, #write
	.zero 2048
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2032
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x03, 0x10, 0xc5, 0xc2, 0x5e, 0xf4, 0x55, 0xb8, 0xc1, 0x13, 0x8e, 0x5a, 0xa5, 0xd3, 0x22, 0x2b
	.byte 0x40, 0x00, 0x1f, 0xd6
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xd0, 0xbf, 0xa0, 0xaa, 0xc9, 0x07, 0xc0, 0xc2, 0xb2, 0x02, 0x8e, 0x78, 0x61, 0x09, 0xde, 0xc2
	.byte 0x9e, 0xa4, 0x3f, 0x92, 0xc0, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xd3140050020000028002000
	/* C2 */
	.octa 0x80000000000000000000000000001800
	/* C11 */
	.octa 0x0
	/* C21 */
	.octa 0x800000000027c03f00000000003fff50
final_cap_values:
	/* C0 */
	.octa 0xd3140050020000028002000
	/* C1 */
	.octa 0x2161000000000000000000000000
	/* C2 */
	.octa 0x8000000000000000000000000000175f
	/* C3 */
	.octa 0x0
	/* C9 */
	.octa 0xc2c2c2c2
	/* C11 */
	.octa 0x0
	/* C16 */
	.octa 0xffffffffffffffff
	/* C18 */
	.octa 0xffffffffffffc2c2
	/* C21 */
	.octa 0x800000000027c03f00000000003fff50
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080006000f8010000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400120000020000028000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c51003 // CVTD-R.C-C Rd:3 Cn:0 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0xb855f45e // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:30 Rn:2 01:01 imm9:101011111 0:0 opc:01 111000:111000 size:10
	.inst 0x5a8e13c1 // csinv:aarch64/instrs/integer/conditional/select Rd:1 Rn:30 o2:0 0:0 cond:0001 Rm:14 011010100:011010100 op:1 sf:0
	.inst 0x2b22d3a5 // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:5 Rn:29 imm3:100 option:110 Rm:2 01011001:01011001 S:1 op:0 sf:0
	.inst 0xd61f0040 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 28
	.inst 0x0000c2c2
	.zero 3884
	.inst 0xaaa0bfd0 // orn_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:16 Rn:30 imm6:101111 Rm:0 N:1 shift:10 01010:01010 opc:01 sf:1
	.inst 0xc2c007c9 // BUILD-C.C-C Cd:9 Cn:30 001:001 opc:00 0:0 Cm:0 11000010110:11000010110
	.inst 0x788e02b2 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:18 Rn:21 00:00 imm9:011100000 0:0 opc:10 111000:111000 size:01
	.inst 0xc2de0961 // SEAL-C.CC-C Cd:1 Cn:11 0010:0010 opc:00 Cm:30 11000010110:11000010110
	.inst 0x923fa49e // and_log_imm:aarch64/instrs/integer/logical/immediate Rd:30 Rn:4 imms:101001 immr:111111 N:0 100100:100100 opc:00 sf:1
	.inst 0xc2c210c0
	.zero 1044616
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x19, cptr_el3
	orr x19, x19, #0x200
	msr cptr_el3, x19
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a6b // ldr c11, [x19, #2]
	.inst 0xc2400e75 // ldr c21, [x19, #3]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850030
	msr SCTLR_EL3, x19
	ldr x19, =0xc
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d3 // ldr c19, [c6, #3]
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	.inst 0x826010d3 // ldr c19, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400266 // ldr c6, [x19, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc2c6a461 // chkeq c3, c6
	b.ne comparison_fail
	.inst 0xc2401266 // ldr c6, [x19, #4]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401666 // ldr c6, [x19, #5]
	.inst 0xc2c6a561 // chkeq c11, c6
	b.ne comparison_fail
	.inst 0xc2401a66 // ldr c6, [x19, #6]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401e66 // ldr c6, [x19, #7]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc2402266 // ldr c6, [x19, #8]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001800
	ldr x1, =check_data0
	ldr x2, =0x00001804
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400014
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400030
	ldr x1, =check_data2
	ldr x2, =0x00400032
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400f60
	ldr x1, =check_data3
	ldr x2, =0x00400f78
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr DDC_EL3, c19
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
