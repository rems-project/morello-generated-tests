.section data0, #alloc, #write
	.zero 240
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc2, 0xc2, 0xc2, 0xc2, 0x00, 0x00, 0x00, 0x00
	.zero 3840
.data
check_data0:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data1:
	.byte 0xc2, 0x10, 0xce, 0x37, 0x07, 0xd8, 0x7f, 0xb8, 0xc0, 0x2f, 0xdf, 0x9a, 0xd4, 0x7f, 0xa3, 0x02
	.byte 0x49, 0x50, 0xd6, 0x78, 0x0e, 0xc0, 0xde, 0xc2, 0x5f, 0x00, 0xf0, 0xc2, 0xdb, 0xde, 0xd4, 0xf0
	.byte 0xfa, 0xe5, 0x8f, 0xe2, 0x00, 0xa2, 0xa5, 0xb9, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.byte 0xc2, 0xc2
.data
check_data3:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
check_data4:
	.byte 0xc2, 0xc2, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000400080020000000000448478
	/* C2 */
	.octa 0x800000000001000500000000004200fb
	/* C15 */
	.octa 0xffa
	/* C16 */
	.octa 0x800000000001000500000000004fda58
	/* C30 */
	.octa 0x740070000000200002000
final_cap_values:
	/* C0 */
	.octa 0xffffffffc2c2c2c2
	/* C2 */
	.octa 0x800000000001000500000000004200fb
	/* C7 */
	.octa 0xc2c2c2c2
	/* C9 */
	.octa 0xffffc2c2
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0xffa
	/* C16 */
	.octa 0x800000000001000500000000004fda58
	/* C20 */
	.octa 0x740070000000200001721
	/* C26 */
	.octa 0xc2c2c2c2
	/* C27 */
	.octa 0x2000800000064007ffffffffa9fdb000
	/* C30 */
	.octa 0x740070000000200002000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000640070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000004001100100ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x37ce10c2 // tbnz:aarch64/instrs/branch/conditional/test Rt:2 imm14:11000010000110 b40:11001 op:1 011011:011011 b5:0
	.inst 0xb87fd807 // ldr_reg_gen:aarch64/instrs/memory/single/general/register Rt:7 Rn:0 10:10 S:1 option:110 Rm:31 1:1 opc:01 111000:111000 size:10
	.inst 0x9adf2fc0 // rorv:aarch64/instrs/integer/shift/variable Rd:0 Rn:30 op2:11 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x02a37fd4 // SUB-C.CIS-C Cd:20 Cn:30 imm12:100011011111 sh:0 A:1 00000010:00000010
	.inst 0x78d65049 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:9 Rn:2 00:00 imm9:101100101 0:0 opc:11 111000:111000 size:01
	.inst 0xc2dec00e // CVT-R.CC-C Rd:14 Cn:0 110000:110000 Cm:30 11000010110:11000010110
	.inst 0xc2f0005f // BICFLGS-C.CI-C Cd:31 Cn:2 0:0 00:00 imm8:10000000 11000010111:11000010111
	.inst 0xf0d4dedb // ADRP-C.IP-C Rd:27 immhi:101010011011110110 P:1 10000:10000 immlo:11 op:1
	.inst 0xe28fe5fa // ALDUR-R.RI-32 Rt:26 Rn:15 op2:01 imm9:011111110 V:0 op1:10 11100010:11100010
	.inst 0xb9a5a200 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:16 imm12:100101101000 opc:10 111001:111001 size:10
	.inst 0xc2c210c0
	.zero 131124
	.inst 0x0000c2c2
	.zero 164884
	.inst 0xc2c2c2c2
	.zero 752508
	.inst 0xc2c2c2c2
	.zero 4
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
	ldr x19, =initial_cap_values
	.inst 0xc2400260 // ldr c0, [x19, #0]
	.inst 0xc2400662 // ldr c2, [x19, #1]
	.inst 0xc2400a6f // ldr c15, [x19, #2]
	.inst 0xc2400e70 // ldr c16, [x19, #3]
	.inst 0xc240127e // ldr c30, [x19, #4]
	/* Set up flags and system registers */
	mov x19, #0x00000000
	msr nzcv, x19
	ldr x19, =0x200
	msr CPTR_EL3, x19
	ldr x19, =0x30850032
	msr SCTLR_EL3, x19
	ldr x19, =0x0
	msr S3_6_C1_C2_2, x19 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030d3 // ldr c19, [c6, #3]
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	.inst 0x826010d3 // ldr c19, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
	.inst 0xc2c21260 // br c19
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
	isb
	/* Check processor flags */
	mrs x19, nzcv
	ubfx x19, x19, #28, #4
	mov x6, #0xf
	and x19, x19, x6
	cmp x19, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x19, =final_cap_values
	.inst 0xc2400266 // ldr c6, [x19, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc2400666 // ldr c6, [x19, #1]
	.inst 0xc2c6a441 // chkeq c2, c6
	b.ne comparison_fail
	.inst 0xc2400a66 // ldr c6, [x19, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400e66 // ldr c6, [x19, #3]
	.inst 0xc2c6a521 // chkeq c9, c6
	b.ne comparison_fail
	.inst 0xc2401266 // ldr c6, [x19, #4]
	.inst 0xc2c6a5c1 // chkeq c14, c6
	b.ne comparison_fail
	.inst 0xc2401666 // ldr c6, [x19, #5]
	.inst 0xc2c6a5e1 // chkeq c15, c6
	b.ne comparison_fail
	.inst 0xc2401a66 // ldr c6, [x19, #6]
	.inst 0xc2c6a601 // chkeq c16, c6
	b.ne comparison_fail
	.inst 0xc2401e66 // ldr c6, [x19, #7]
	.inst 0xc2c6a681 // chkeq c20, c6
	b.ne comparison_fail
	.inst 0xc2402266 // ldr c6, [x19, #8]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc2402666 // ldr c6, [x19, #9]
	.inst 0xc2c6a761 // chkeq c27, c6
	b.ne comparison_fail
	.inst 0xc2402a66 // ldr c6, [x19, #10]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010f8
	ldr x1, =check_data0
	ldr x2, =0x000010fc
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
	ldr x0, =0x00420060
	ldr x1, =check_data2
	ldr x2, =0x00420062
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00448478
	ldr x1, =check_data3
	ldr x2, =0x0044847c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004ffff8
	ldr x1, =check_data4
	ldr x2, =0x004ffffc
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
	.inst 0xc2c5b013 // cvtp c19, x0
	.inst 0xc2df4273 // scvalue c19, c19, x31
	.inst 0xc28b4133 // msr ddc_el3, c19
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
