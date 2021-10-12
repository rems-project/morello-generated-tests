.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xc1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x72, 0xfa, 0xcb, 0x92, 0xa6, 0x01, 0xc1, 0xc2, 0x0c, 0x33, 0xc5, 0xc2, 0xff, 0xcf, 0x19, 0x38
	.byte 0x3f, 0x90, 0x01, 0xe2, 0x41, 0x84, 0xc2, 0xc2, 0x02, 0xa5, 0x1f, 0xe2, 0xc2, 0x1a, 0x17, 0xf8
	.byte 0xf7, 0xd0, 0xc1, 0xc2, 0x48, 0xb8, 0x54, 0xe2, 0x00, 0x10, 0xc2, 0xc2
.data
check_data5:
	.byte 0xc1
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x7e7
	/* C2 */
	.octa 0x600070000000fffe00001
	/* C8 */
	.octa 0x4df008
	/* C13 */
	.octa 0x800700060000000000000000
	/* C22 */
	.octa 0x4000000000010005000000000000108f
	/* C24 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x7e7
	/* C2 */
	.octa 0xc1
	/* C6 */
	.octa 0xc7e700000000000000000000
	/* C8 */
	.octa 0x0
	/* C12 */
	.octa 0x0
	/* C13 */
	.octa 0x800700060000000000000000
	/* C18 */
	.octa 0xffffa02cffffffff
	/* C22 */
	.octa 0x4000000000010005000000000000108f
	/* C24 */
	.octa 0x0
initial_csp_value:
	.octa 0x40000000000200000000000000002062
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000002e0600170000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword initial_csp_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x92cbfa72 // movn:aarch64/instrs/integer/ins-ext/insert/movewide Rd:18 imm16:0101111111010011 hw:10 100101:100101 opc:00 sf:1
	.inst 0xc2c101a6 // SCBNDS-C.CR-C Cd:6 Cn:13 000:000 opc:00 0:0 Rm:1 11000010110:11000010110
	.inst 0xc2c5330c // CVTP-R.C-C Rd:12 Cn:24 100:100 opc:01 11000010110001010:11000010110001010
	.inst 0x3819cfff // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:31 11:11 imm9:110011100 0:0 opc:00 111000:111000 size:00
	.inst 0xe201903f // ASTURB-R.RI-32 Rt:31 Rn:1 op2:00 imm9:000011001 V:0 op1:00 11100010:11100010
	.inst 0xc2c28441 // CHKSS-_.CC-C 00001:00001 Cn:2 001:001 opc:00 1:1 Cm:2 11000010110:11000010110
	.inst 0xe21fa502 // ALDURB-R.RI-32 Rt:2 Rn:8 op2:01 imm9:111111010 V:0 op1:00 11100010:11100010
	.inst 0xf8171ac2 // sttr:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:2 Rn:22 10:10 imm9:101110001 0:0 opc:00 111000:111000 size:11
	.inst 0xc2c1d0f7 // CPY-C.C-C Cd:23 Cn:7 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xe254b848 // ALDURSH-R.RI-64 Rt:8 Rn:2 op2:10 imm9:101001011 V:0 op1:01 11100010:11100010
	.inst 0xc2c21000
	.zero 917460
	.inst 0x00c10000
	.zero 131068
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x15, cptr_el3
	orr x15, x15, #0x200
	msr cptr_el3, x15
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
	ldr x15, =initial_cap_values
	.inst 0xc24001e1 // ldr c1, [x15, #0]
	.inst 0xc24005e2 // ldr c2, [x15, #1]
	.inst 0xc24009e8 // ldr c8, [x15, #2]
	.inst 0xc2400ded // ldr c13, [x15, #3]
	.inst 0xc24011f6 // ldr c22, [x15, #4]
	.inst 0xc24015f8 // ldr c24, [x15, #5]
	/* Set up flags and system registers */
	mov x15, #0x00000000
	msr nzcv, x15
	ldr x15, =initial_csp_value
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0xc2c1d1ff // cpy c31, c15
	ldr x15, =0x200
	msr CPTR_EL3, x15
	ldr x15, =0x30850032
	msr SCTLR_EL3, x15
	ldr x15, =0xc
	msr S3_6_C1_C2_2, x15 // CCTLR_EL3
	isb
	/* Start test */
	ldr x0, =pcc_return_ddc_capabilities
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0x8260300f // ldr c15, [c0, #3]
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	.inst 0x8260100f // ldr c15, [c0, #1]
	.inst 0x82602000 // ldr c0, [c0, #2]
	.inst 0xc2c211e0 // br c15
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
	isb
	/* Check processor flags */
	mrs x15, nzcv
	ubfx x15, x15, #28, #4
	mov x0, #0xf
	and x15, x15, x0
	cmp x15, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x15, =final_cap_values
	.inst 0xc24001e0 // ldr c0, [x15, #0]
	.inst 0xc2c0a421 // chkeq c1, c0
	b.ne comparison_fail
	.inst 0xc24005e0 // ldr c0, [x15, #1]
	.inst 0xc2c0a441 // chkeq c2, c0
	b.ne comparison_fail
	.inst 0xc24009e0 // ldr c0, [x15, #2]
	.inst 0xc2c0a4c1 // chkeq c6, c0
	b.ne comparison_fail
	.inst 0xc2400de0 // ldr c0, [x15, #3]
	.inst 0xc2c0a501 // chkeq c8, c0
	b.ne comparison_fail
	.inst 0xc24011e0 // ldr c0, [x15, #4]
	.inst 0xc2c0a581 // chkeq c12, c0
	b.ne comparison_fail
	.inst 0xc24015e0 // ldr c0, [x15, #5]
	.inst 0xc2c0a5a1 // chkeq c13, c0
	b.ne comparison_fail
	.inst 0xc24019e0 // ldr c0, [x15, #6]
	.inst 0xc2c0a641 // chkeq c18, c0
	b.ne comparison_fail
	.inst 0xc2401de0 // ldr c0, [x15, #7]
	.inst 0xc2c0a6c1 // chkeq c22, c0
	b.ne comparison_fail
	.inst 0xc24021e0 // ldr c0, [x15, #8]
	.inst 0xc2c0a701 // chkeq c24, c0
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001008
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000100c
	ldr x1, =check_data1
	ldr x2, =0x0000100e
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001800
	ldr x1, =check_data2
	ldr x2, =0x00001801
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ffe
	ldr x1, =check_data3
	ldr x2, =0x00001fff
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00400000
	ldr x1, =check_data4
	ldr x2, =0x0040002c
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x004e0002
	ldr x1, =check_data5
	ldr x2, =0x004e0003
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
	.inst 0xc2c5b00f // cvtp c15, x0
	.inst 0xc2df41ef // scvalue c15, c15, x31
	.inst 0xc28b412f // msr ddc_el3, c15
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
