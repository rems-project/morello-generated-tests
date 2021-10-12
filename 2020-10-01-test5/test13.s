.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 1
.data
check_data1:
	.zero 1
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x5f, 0x52, 0xc1, 0xc2, 0xc1, 0x2b, 0xd7, 0xc2, 0xff, 0x43, 0x08, 0xa2, 0xc0, 0xc5, 0x0f, 0xe2
	.byte 0x21, 0xf0, 0xc0, 0xc2, 0xdd, 0x7f, 0xbe, 0x9b, 0xdf, 0x03, 0x1f, 0x9b, 0xe1, 0x79, 0x20, 0x38
	.byte 0x82, 0x51, 0x11, 0x32, 0x35, 0x48, 0xc2, 0xc2, 0x60, 0x10, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C14 */
	.octa 0x80000000400400140000000000001000
	/* C15 */
	.octa 0x1000
	/* C30 */
	.octa 0x200000000000000000000000000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x400
	/* C14 */
	.octa 0x80000000400400140000000000001000
	/* C15 */
	.octa 0x1000
	/* C21 */
	.octa 0x400
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x200000000000000000000000000
initial_csp_value:
	.octa 0x179c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000010100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x400000004002001300ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword final_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c1525f // CFHI-R.C-C Rd:31 Cn:18 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2d72bc1 // BICFLGS-C.CR-C Cd:1 Cn:30 1010:1010 opc:00 Rm:23 11000010110:11000010110
	.inst 0xa20843ff // STUR-C.RI-C Ct:31 Rn:31 00:00 imm9:010000100 0:0 opc:00 10100010:10100010
	.inst 0xe20fc5c0 // ALDURB-R.RI-32 Rt:0 Rn:14 op2:01 imm9:011111100 V:0 op1:00 11100010:11100010
	.inst 0xc2c0f021 // GCTYPE-R.C-C Rd:1 Cn:1 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0x9bbe7fdd // umaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:29 Rn:30 Ra:31 o0:0 Rm:30 01:01 U:1 10011011:10011011
	.inst 0x9b1f03df // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:30 Ra:0 o0:0 Rm:31 0011011000:0011011000 sf:1
	.inst 0x382079e1 // strb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:15 10:10 S:1 option:011 Rm:0 1:1 opc:00 111000:111000 size:00
	.inst 0x32115182 // orr_log_imm:aarch64/instrs/integer/logical/immediate Rd:2 Rn:12 imms:010100 immr:010001 N:0 100100:100100 opc:01 sf:0
	.inst 0xc2c24835 // UNSEAL-C.CC-C Cd:21 Cn:1 0010:0010 opc:01 Cm:2 11000010110:11000010110
	.inst 0xc2c21060
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x13, cptr_el3
	orr x13, x13, #0x200
	msr cptr_el3, x13
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
	ldr x13, =initial_cap_values
	.inst 0xc24001ae // ldr c14, [x13, #0]
	.inst 0xc24005af // ldr c15, [x13, #1]
	.inst 0xc24009be // ldr c30, [x13, #2]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =initial_csp_value
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0xc2c1d1bf // cpy c31, c13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850032
	msr SCTLR_EL3, x13
	ldr x13, =0x0
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x3, =pcc_return_ddc_capabilities
	.inst 0xc2400063 // ldr c3, [x3, #0]
	.inst 0x8260306d // ldr c13, [c3, #3]
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	.inst 0x8260106d // ldr c13, [c3, #1]
	.inst 0x82602063 // ldr c3, [c3, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001a3 // ldr c3, [x13, #0]
	.inst 0xc2c3a401 // chkeq c0, c3
	b.ne comparison_fail
	.inst 0xc24005a3 // ldr c3, [x13, #1]
	.inst 0xc2c3a421 // chkeq c1, c3
	b.ne comparison_fail
	.inst 0xc24009a3 // ldr c3, [x13, #2]
	.inst 0xc2c3a5c1 // chkeq c14, c3
	b.ne comparison_fail
	.inst 0xc2400da3 // ldr c3, [x13, #3]
	.inst 0xc2c3a5e1 // chkeq c15, c3
	b.ne comparison_fail
	.inst 0xc24011a3 // ldr c3, [x13, #4]
	.inst 0xc2c3a6a1 // chkeq c21, c3
	b.ne comparison_fail
	.inst 0xc24015a3 // ldr c3, [x13, #5]
	.inst 0xc2c3a7a1 // chkeq c29, c3
	b.ne comparison_fail
	.inst 0xc24019a3 // ldr c3, [x13, #6]
	.inst 0xc2c3a7c1 // chkeq c30, c3
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
	ldr x0, =0x000010fc
	ldr x1, =check_data1
	ldr x2, =0x000010fd
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001820
	ldr x1, =check_data2
	ldr x2, =0x00001830
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
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
