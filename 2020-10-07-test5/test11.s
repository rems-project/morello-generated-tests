.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x5e, 0x23, 0xdf, 0x1a, 0xe7, 0x03, 0x13, 0x78, 0x19, 0x08, 0x76, 0x82, 0x3f, 0xd0, 0xc1, 0xc2
	.byte 0xe4, 0x3b, 0x4f, 0xba, 0x71, 0xca, 0xfe, 0x78, 0xb8, 0x4d, 0x47, 0x2d, 0x54, 0x3e, 0x9e, 0x72
	.byte 0x02, 0x6c, 0xe1, 0x82, 0x5a, 0xf2, 0xc5, 0xc2, 0xc0, 0x10, 0xc2, 0xc2
.data
check_data2:
	.zero 8
.data
check_data3:
	.zero 4
.data
check_data4:
	.zero 4
.data
check_data5:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x40a0b8
	/* C1 */
	.octa 0xf1e10
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000100050000000000407fb8
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000000100050000000000000000
	/* C26 */
	.octa 0x4fffe4
final_cap_values:
	/* C0 */
	.octa 0x40a0b8
	/* C1 */
	.octa 0xf1e10
	/* C7 */
	.octa 0x0
	/* C13 */
	.octa 0x80000000000100050000000000407fb8
	/* C17 */
	.octa 0x0
	/* C18 */
	.octa 0x0
	/* C19 */
	.octa 0x80000000000100050000000000000000
	/* C25 */
	.octa 0x0
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x4fffe4
initial_SP_EL3_value:
	.octa 0x400000000007000500000000000010ec
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x1adf235e // lslv:aarch64/instrs/integer/shift/variable Rd:30 Rn:26 op2:00 0010:0010 Rm:31 0011010110:0011010110 sf:0
	.inst 0x781303e7 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:7 Rn:31 00:00 imm9:100110000 0:0 opc:00 111000:111000 size:01
	.inst 0x82760819 // ALDR-R.RI-32 Rt:25 Rn:0 op:10 imm9:101100000 L:1 1000001001:1000001001
	.inst 0xc2c1d03f // CPY-C.C-C Cd:31 Cn:1 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xba4f3be4 // ccmn_imm:aarch64/instrs/integer/conditional/compare/immediate nzcv:0100 0:0 Rn:31 10:10 cond:0011 imm5:01111 111010010:111010010 op:0 sf:1
	.inst 0x78feca71 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:17 Rn:19 10:10 S:0 option:110 Rm:30 1:1 opc:11 111000:111000 size:01
	.inst 0x2d474db8 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:24 Rn:13 Rt2:10011 imm7:0001110 L:1 1011010:1011010 opc:00
	.inst 0x729e3e54 // movk:aarch64/instrs/integer/ins-ext/insert/movewide Rd:20 imm16:1111000111110010 hw:00 100101:100101 opc:11 sf:0
	.inst 0x82e16c02 // ALDR-V.RRB-S Rt:2 Rn:0 opc:11 S:0 option:011 Rm:1 1:1 L:1 100000101:100000101
	.inst 0xc2c5f25a // CVTPZ-C.R-C Cd:26 Rn:18 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c210c0
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
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc24011d2 // ldr c18, [x14, #4]
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc24019da // ldr c26, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x20000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x6, =pcc_return_ddc_capabilities
	.inst 0xc24000c6 // ldr c6, [x6, #0]
	.inst 0x826030ce // ldr c14, [c6, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826010ce // ldr c14, [c6, #1]
	.inst 0x826020c6 // ldr c6, [c6, #2]
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
	mov x6, #0xf
	and x14, x14, x6
	cmp x14, #0x4
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001c6 // ldr c6, [x14, #0]
	.inst 0xc2c6a401 // chkeq c0, c6
	b.ne comparison_fail
	.inst 0xc24005c6 // ldr c6, [x14, #1]
	.inst 0xc2c6a421 // chkeq c1, c6
	b.ne comparison_fail
	.inst 0xc24009c6 // ldr c6, [x14, #2]
	.inst 0xc2c6a4e1 // chkeq c7, c6
	b.ne comparison_fail
	.inst 0xc2400dc6 // ldr c6, [x14, #3]
	.inst 0xc2c6a5a1 // chkeq c13, c6
	b.ne comparison_fail
	.inst 0xc24011c6 // ldr c6, [x14, #4]
	.inst 0xc2c6a621 // chkeq c17, c6
	b.ne comparison_fail
	.inst 0xc24015c6 // ldr c6, [x14, #5]
	.inst 0xc2c6a641 // chkeq c18, c6
	b.ne comparison_fail
	.inst 0xc24019c6 // ldr c6, [x14, #6]
	.inst 0xc2c6a661 // chkeq c19, c6
	b.ne comparison_fail
	.inst 0xc2401dc6 // ldr c6, [x14, #7]
	.inst 0xc2c6a721 // chkeq c25, c6
	b.ne comparison_fail
	.inst 0xc24021c6 // ldr c6, [x14, #8]
	.inst 0xc2c6a741 // chkeq c26, c6
	b.ne comparison_fail
	.inst 0xc24025c6 // ldr c6, [x14, #9]
	.inst 0xc2c6a7c1 // chkeq c30, c6
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x6, v2.d[0]
	cmp x14, x6
	b.ne comparison_fail
	ldr x14, =0x0
	mov x6, v2.d[1]
	cmp x14, x6
	b.ne comparison_fail
	ldr x14, =0x0
	mov x6, v19.d[0]
	cmp x14, x6
	b.ne comparison_fail
	ldr x14, =0x0
	mov x6, v19.d[1]
	cmp x14, x6
	b.ne comparison_fail
	ldr x14, =0x0
	mov x6, v24.d[0]
	cmp x14, x6
	b.ne comparison_fail
	ldr x14, =0x0
	mov x6, v24.d[1]
	cmp x14, x6
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000101c
	ldr x1, =check_data0
	ldr x2, =0x0000101e
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
	ldr x0, =0x00407ff0
	ldr x1, =check_data2
	ldr x2, =0x00407ff8
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0040a638
	ldr x1, =check_data3
	ldr x2, =0x0040a63c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004fbec8
	ldr x1, =check_data4
	ldr x2, =0x004fbecc
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004fffe4
	ldr x1, =check_data5
	ldr x2, =0x004fffe6
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
