.section data0, #alloc, #write
	.zero 144
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2
	.zero 3936
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0x62, 0xc5, 0xe7, 0xf0, 0x3d, 0x84, 0x58, 0xbc, 0x15, 0xf4, 0xc0, 0xe2, 0x3e, 0x90, 0xc5, 0xc2
	.byte 0xde, 0x7f, 0x5e, 0x9b, 0x3e, 0x70, 0x94, 0x1a, 0xf5, 0xc5, 0xbd, 0xe2, 0x0e, 0x60, 0xd6, 0x38
	.byte 0xe0, 0x73, 0xc2, 0xc2, 0xff, 0xb3, 0xc0, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000408451
	/* C1 */
	.octa 0x405008
	/* C15 */
	.octa 0x800000000001000500000000000010c0
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000408451
	/* C1 */
	.octa 0x404f90
	/* C2 */
	.octa 0xffffffffcfcaf000
	/* C14 */
	.octa 0xffffffc2
	/* C15 */
	.octa 0x800000000001000500000000000010c0
	/* C21 */
	.octa 0xc2c2c2c2c2c2c2c2
	/* C30 */
	.octa 0x404f90
initial_csp_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000500050020000000000410001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 64
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf0e7c562 // ADRP-C.IP-C Rd:2 immhi:110011111000101011 P:1 10000:10000 immlo:11 op:1
	.inst 0xbc58843d // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:29 Rn:1 01:01 imm9:110001000 0:0 opc:01 111100:111100 size:10
	.inst 0xe2c0f415 // ALDUR-R.RI-64 Rt:21 Rn:0 op2:01 imm9:000001111 V:0 op1:11 11100010:11100010
	.inst 0xc2c5903e // CVTD-C.R-C Cd:30 Rn:1 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0x9b5e7fde // smulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:30 Rn:30 Ra:11111 0:0 Rm:30 10:10 U:0 10011011:10011011
	.inst 0x1a94703e // csel:aarch64/instrs/integer/conditional/select Rd:30 Rn:1 o2:0 0:0 cond:0111 Rm:20 011010100:011010100 op:0 sf:0
	.inst 0xe2bdc5f5 // ALDUR-V.RI-S Rt:21 Rn:15 op2:01 imm9:111011100 V:1 op1:10 11100010:11100010
	.inst 0x38d6600e // ldursb:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:14 Rn:0 00:00 imm9:101100110 0:0 opc:11 111000:111000 size:00
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c0b3ff // GCSEAL-R.C-C Rd:31 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c210c0
	.zero 20444
	.inst 0xc2c2c2c2
	.zero 13224
	.inst 0xc2000000
	.zero 168
	.inst 0xc2c2c2c2
	.inst 0xc2c2c2c2
	.zero 1014680
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x12, cptr_el3
	orr x12, x12, #0x200
	msr cptr_el3, x12
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
	ldr x12, =initial_cap_values
	.inst 0xc2400180 // ldr c0, [x12, #0]
	.inst 0xc2400581 // ldr c1, [x12, #1]
	.inst 0xc240098f // ldr c15, [x12, #2]
	/* Set up flags and system registers */
	mov x12, #0x00000000
	msr nzcv, x12
	ldr x12, =initial_csp_value
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0xc2c1d19f // cpy c31, c12
	ldr x12, =0x200
	msr CPTR_EL3, x12
	ldr x12, =0x30850032
	msr SCTLR_EL3, x12
	ldr x12, =0x0
	msr S3_6_C1_C2_2, x12 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030cc // ldr c12, [c6, #3]
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	.inst 0x826010cc // ldr c12, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21180 // br c12
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
	isb
	/* Check processor flags */
	mrs x12, nzcv
	ubfx x12, x12, #28, #4
	mov x6, #0x1
	and x12, x12, x6
	cmp x12, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x12, =final_cap_values
	.inst 0xc2400186 // ldr c6, [x12, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400586 // ldr c6, [x12, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc2400986 // ldr c6, [x12, #2]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400d86 // ldr c6, [x12, #3]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401186 // ldr c6, [x12, #4]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401586 // ldr c6, [x12, #5]
	.inst 0xc2c6a6a1 // chkeq c21, c6
	b.ne comparison_fail
	.inst 0xc2401986 // ldr c6, [x12, #6]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x12, =0xc2c2c2c2
	mov x6, v21.d[0]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v21.d[1]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0xc2c2c2c2
	mov x6, v29.d[0]
	cmp x12, x6
	b.ne comparison_fail
	ldr x12, =0x0
	mov x6, v29.d[1]
	cmp x12, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000109c
	ldr x1, =check_data0
	ldr x2, =0x000010a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040002c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00405008
	ldr x1, =check_data2
	ldr x2, =0x0040500c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004083b7
	ldr x1, =check_data3
	ldr x2, =0x004083b8
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00408460
	ldr x1, =check_data4
	ldr x2, =0x00408468
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
	.inst 0xc2c5b00c // cvtp c12, x0
	.inst 0xc2df418c // scvalue c12, c12, x31
	.inst 0xc28b412c // msr ddc_el3, c12
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
