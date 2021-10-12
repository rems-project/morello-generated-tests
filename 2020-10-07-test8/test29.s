.section data0, #alloc, #write
	.zero 256
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x06, 0x00, 0x00, 0x80, 0x00, 0x20
	.zero 3808
.data
check_data0:
	.zero 1
.data
check_data1:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x10, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x00, 0x06, 0x00, 0x00, 0x80, 0x00, 0x20
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0xdf, 0x43, 0x56, 0xe2, 0xff, 0xf7, 0x74, 0xb9, 0x40, 0x00, 0x3f, 0xd6
.data
check_data5:
	.byte 0x31, 0x30, 0xc1, 0xc2, 0x01, 0x48, 0x2f, 0x38, 0x82, 0x4e, 0xcd, 0x78, 0x9c, 0xd1, 0xc1, 0xc2
	.byte 0x5f, 0x39, 0x55, 0xe2, 0x2f, 0x30, 0xc4, 0xc2
.data
check_data6:
	.byte 0x01, 0x51, 0xc1, 0xc2, 0x00, 0x13, 0xc2, 0xc2
.data
check_data7:
	.zero 4
.data
check_data8:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40000000000100070000000000000080
	/* C1 */
	.octa 0x90000000000100050000000000001100
	/* C2 */
	.octa 0x400040
	/* C10 */
	.octa 0x4840ad
	/* C15 */
	.octa 0xf80
	/* C20 */
	.octa 0x80000000000100050000000000001f28
	/* C30 */
	.octa 0x205c
final_cap_values:
	/* C0 */
	.octa 0x40000000000100070000000000000080
	/* C2 */
	.octa 0x0
	/* C10 */
	.octa 0x4840ad
	/* C15 */
	.octa 0x800000000000000000000000
	/* C17 */
	.octa 0x0
	/* C20 */
	.octa 0x80000000000100050000000000001ffc
	/* C30 */
	.octa 0x20008000000100070000000000400059
initial_SP_EL3_value:
	.octa 0x800000007c012cfe0000000000400000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000000a000000001fdefc00001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001100
	.dword 0x0000000000001110
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 48
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe25643df // ASTURH-R.RI-32 Rt:31 Rn:30 op2:00 imm9:101100100 V:0 op1:01 11100010:11100010
	.inst 0xb974f7ff // ldr_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:31 Rn:31 imm12:110100111101 opc:01 111001:111001 size:10
	.inst 0xd63f0040 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:2 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.zero 52
	.inst 0xc2c13031 // GCFLGS-R.C-C Rd:17 Cn:1 100:100 opc:01 11000010110000010:11000010110000010
	.inst 0x382f4801 // strb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:0 10:10 S:0 option:010 Rm:15 1:1 opc:00 111000:111000 size:00
	.inst 0x78cd4e82 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:2 Rn:20 11:11 imm9:011010100 0:0 opc:11 111000:111000 size:01
	.inst 0xc2c1d19c // CPY-C.C-C Cd:28 Cn:12 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xe255395f // ALDURSH-R.RI-64 Rt:31 Rn:10 op2:10 imm9:101010011 V:0 op1:01 11100010:11100010
	.inst 0xc2c4302f // LDPBLR-C.C-C Ct:15 Cn:1 100:100 opc:01 11000010110001000:11000010110001000
	.zero 4008
	.inst 0xc2c15101 // CFHI-R.C-C Rd:1 Cn:8 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c21300
	.zero 1044472
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x25, cptr_el3
	orr x25, x25, #0x200
	msr cptr_el3, x25
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
	ldr x25, =initial_cap_values
	.inst 0xc2400320 // ldr c0, [x25, #0]
	.inst 0xc2400721 // ldr c1, [x25, #1]
	.inst 0xc2400b22 // ldr c2, [x25, #2]
	.inst 0xc2400f2a // ldr c10, [x25, #3]
	.inst 0xc240132f // ldr c15, [x25, #4]
	.inst 0xc2401734 // ldr c20, [x25, #5]
	.inst 0xc2401b3e // ldr c30, [x25, #6]
	/* Set up flags and system registers */
	mov x25, #0x00000000
	msr nzcv, x25
	ldr x25, =initial_SP_EL3_value
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0xc2c1d33f // cpy c31, c25
	ldr x25, =0x200
	msr CPTR_EL3, x25
	ldr x25, =0x30850030
	msr SCTLR_EL3, x25
	ldr x25, =0x4
	msr S3_6_C1_C2_2, x25 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603319 // ldr c25, [c24, #3]
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	.inst 0x82601319 // ldr c25, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c21320 // br c25
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x25, =final_cap_values
	.inst 0xc2400338 // ldr c24, [x25, #0]
	.inst 0xc2d8a401 // chkeq c0, c24
	b.ne comparison_fail
	.inst 0xc2400738 // ldr c24, [x25, #1]
	.inst 0xc2d8a441 // chkeq c2, c24
	b.ne comparison_fail
	.inst 0xc2400b38 // ldr c24, [x25, #2]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc2400f38 // ldr c24, [x25, #3]
	.inst 0xc2d8a5e1 // chkeq c15, c24
	b.ne comparison_fail
	.inst 0xc2401338 // ldr c24, [x25, #4]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401738 // ldr c24, [x25, #5]
	.inst 0xc2d8a681 // chkeq c20, c24
	b.ne comparison_fail
	.inst 0xc2401b38 // ldr c24, [x25, #6]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001001
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001100
	ldr x1, =check_data1
	ldr x2, =0x00001120
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fc0
	ldr x1, =check_data2
	ldr x2, =0x00001fc2
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffc
	ldr x1, =check_data3
	ldr x2, =0x00001ffe
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040000c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400040
	ldr x1, =check_data5
	ldr x2, =0x00400058
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00401000
	ldr x1, =check_data6
	ldr x2, =0x00401008
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004034f4
	ldr x1, =check_data7
	ldr x2, =0x004034f8
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00484000
	ldr x1, =check_data8
	ldr x2, =0x00484002
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b019 // cvtp c25, x0
	.inst 0xc2df4339 // scvalue c25, c25, x31
	.inst 0xc28b4139 // msr DDC_EL3, c25
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
