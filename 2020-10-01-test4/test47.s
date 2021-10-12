.section data0, #alloc, #write
	.zero 96
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3984
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0xc5, 0xd5, 0x3c, 0xf0, 0x63, 0xdf, 0xc2, 0x07, 0xa0, 0x45, 0x38, 0x20, 0x24, 0xcd, 0xc2
	.byte 0x1f, 0x90, 0xc5, 0xc2, 0x01, 0x84, 0xc8, 0xc2, 0x60, 0x01, 0x3f, 0xd6
.data
check_data2:
	.byte 0xc2
.data
check_data3:
	.byte 0xe7, 0x93, 0x13, 0x32, 0x22, 0x90, 0xc5, 0xc2, 0x72, 0xd0, 0x80, 0x5a, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400024
	/* C1 */
	.octa 0x40020001000000007fffe000
	/* C8 */
	.octa 0x100050000000000000001
	/* C11 */
	.octa 0x404000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0x1060
final_cap_values:
	/* C0 */
	.octa 0x40020001ffffffffffffffff
	/* C1 */
	.octa 0x40020001000000007fffe000
	/* C2 */
	.octa 0x8000000020010005000000007fffe000
	/* C7 */
	.octa 0xe003e003
	/* C8 */
	.octa 0x100050000000000000001
	/* C11 */
	.octa 0x404000
	/* C13 */
	.octa 0x0
	/* C14 */
	.octa 0xfbc
	/* C16 */
	.octa 0xc007c005ffffffffffffc005
	/* C18 */
	.octa 0x0
	/* C30 */
	.octa 0x40001c
initial_csp_value:
	.octa 0xc007c0050000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002001c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000200100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3cd5c5c2 // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:2 Rn:14 01:01 imm9:101011100 0:0 opc:11 111100:111100 size:00
	.inst 0xc2df63f0 // SCOFF-C.CR-C Cd:16 Cn:31 000:000 opc:11 0:0 Rm:31 11000010110:11000010110
	.inst 0x3845a007 // ldurb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:0 00:00 imm9:001011010 0:0 opc:01 111000:111000 size:00
	.inst 0xc2cd2420 // CPYTYPE-C.C-C Cd:0 Cn:1 001:001 opc:01 0:0 Cm:13 11000010110:11000010110
	.inst 0xc2c5901f // CVTD-C.R-C Cd:31 Rn:0 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c88401 // CHKSS-_.CC-C 00001:00001 Cn:0 001:001 opc:00 1:1 Cm:8 11000010110:11000010110
	.inst 0xd63f0160 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:11 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 96
	.inst 0x00c20000
	.zero 16256
	.inst 0x321393e7 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:7 Rn:31 imms:100100 immr:010011 N:0 100100:100100 opc:01 sf:0
	.inst 0xc2c59022 // CVTD-C.R-C Cd:2 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x5a80d072 // csinv:aarch64/instrs/integer/conditional/select Rd:18 Rn:3 o2:0 0:0 cond:1101 Rm:0 011010100:011010100 op:1 sf:0
	.inst 0xc2c21380
	.zero 1032176
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x29, cptr_el3
	orr x29, x29, #0x200
	msr cptr_el3, x29
	isb
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr cvbar_el3, c1
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
	ldr x29, =initial_cap_values
	.inst 0xc24003a0 // ldr c0, [x29, #0]
	.inst 0xc24007a1 // ldr c1, [x29, #1]
	.inst 0xc2400ba8 // ldr c8, [x29, #2]
	.inst 0xc2400fab // ldr c11, [x29, #3]
	.inst 0xc24013ad // ldr c13, [x29, #4]
	.inst 0xc24017ae // ldr c14, [x29, #5]
	/* Set up flags and system registers */
	mov x29, #0x00000000
	msr nzcv, x29
	ldr x29, =initial_csp_value
	.inst 0xc24003bd // ldr c29, [x29, #0]
	.inst 0xc2c1d3bf // cpy c31, c29
	ldr x29, =0x200
	msr CPTR_EL3, x29
	ldr x29, =0x30850030
	msr SCTLR_EL3, x29
	ldr x29, =0xc
	msr S3_6_C1_C2_2, x29 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260339d // ldr c29, [c28, #3]
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	.inst 0x8260139d // ldr c29, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c213a0 // br c29
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
	isb
	/* Check processor flags */
	mrs x29, nzcv
	ubfx x29, x29, #28, #4
	mov x28, #0xf
	and x29, x29, x28
	cmp x29, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x29, =final_cap_values
	.inst 0xc24003bc // ldr c28, [x29, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc24007bc // ldr c28, [x29, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc2400bbc // ldr c28, [x29, #2]
	.inst 0xc2dca441 // chkeq c2, c28
	b.ne comparison_fail
	.inst 0xc2400fbc // ldr c28, [x29, #3]
	.inst 0xc2dca4e1 // chkeq c7, c28
	b.ne comparison_fail
	.inst 0xc24013bc // ldr c28, [x29, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc24017bc // ldr c28, [x29, #5]
	.inst 0xc2dca561 // chkeq c11, c28
	b.ne comparison_fail
	.inst 0xc2401bbc // ldr c28, [x29, #6]
	.inst 0xc2dca5a1 // chkeq c13, c28
	b.ne comparison_fail
	.inst 0xc2401fbc // ldr c28, [x29, #7]
	.inst 0xc2dca5c1 // chkeq c14, c28
	b.ne comparison_fail
	.inst 0xc24023bc // ldr c28, [x29, #8]
	.inst 0xc2dca601 // chkeq c16, c28
	b.ne comparison_fail
	.inst 0xc24027bc // ldr c28, [x29, #9]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc2402bbc // ldr c28, [x29, #10]
	.inst 0xc2dca7c1 // chkeq c30, c28
	b.ne comparison_fail
	/* Check vector registers */
	ldr x29, =0xc2c2c2c2c2c2c2c2
	mov x28, v2.d[0]
	cmp x29, x28
	b.ne comparison_fail
	ldr x29, =0xc2c2c2c2c2c2c2c2
	mov x28, v2.d[1]
	cmp x29, x28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001060
	ldr x1, =check_data0
	ldr x2, =0x00001070
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040001c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x0040007e
	ldr x1, =check_data2
	ldr x2, =0x0040007f
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00404000
	ldr x1, =check_data3
	ldr x2, =0x00404010
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
	.inst 0xc2c5b01d // cvtp c29, x0
	.inst 0xc2df43bd // scvalue c29, c29, x31
	.inst 0xc28b413d // msr ddc_el3, c29
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
