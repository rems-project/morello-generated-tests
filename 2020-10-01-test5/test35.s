.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0xd2, 0x00, 0x00, 0x00, 0x00, 0xc2, 0x01, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x2e, 0xe4, 0x09, 0xa2, 0x82, 0x82, 0xfd, 0xc2, 0x00, 0xa4, 0xcc, 0xc2
.data
check_data5:
	.byte 0x00, 0x71, 0xff, 0x82, 0xbf, 0x21, 0x60, 0x58, 0x00, 0x0f, 0xc1, 0xe2, 0xc0, 0x34, 0x06, 0xe2
	.byte 0x56, 0x82, 0xcd, 0x78, 0xf2, 0xe1, 0xd2, 0xc2, 0x4d, 0x40, 0xeb, 0xc2, 0x60, 0x13, 0xc2, 0xc2
.data
check_data6:
	.zero 2
.data
check_data7:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xa0408008000180060000000000403ff1
	/* C1 */
	.octa 0x1000
	/* C6 */
	.octa 0x1a41
	/* C8 */
	.octa 0x1024
	/* C12 */
	.octa 0x400008000000000000000000000000
	/* C14 */
	.octa 0x4001c200000000d2008000000000
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C18 */
	.octa 0x800000005184d001000000000040d020
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C24 */
	.octa 0x10b0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x19e0
	/* C2 */
	.octa 0x3fff800000000000000000000000
	/* C6 */
	.octa 0x1a41
	/* C8 */
	.octa 0x1024
	/* C12 */
	.octa 0x400008000000000000000000000000
	/* C13 */
	.octa 0x3fff800000000000000000000000
	/* C14 */
	.octa 0x4001c200000000d2008000000000
	/* C15 */
	.octa 0x3fff800000000000000000000000
	/* C18 */
	.octa 0x3fff800000000000000000000000
	/* C20 */
	.octa 0x3fff800000000000000000000000
	/* C22 */
	.octa 0x0
	/* C24 */
	.octa 0x10b0
	/* C29 */
	.octa 0x400000000000000000000000000000
	/* C30 */
	.octa 0x2000800080008008000000000040000c
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc8000000283b00070000150013c00000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword initial_cap_values + 112
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword final_cap_values + 208
	.dword final_cap_values + 224
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa209e42e // STR-C.RIAW-C Ct:14 Rn:1 01:01 imm9:010011110 0:0 opc:00 10100010:10100010
	.inst 0xc2fd8282 // BICFLGS-C.CI-C Cd:2 Cn:20 0:0 00:00 imm8:11101100 11000010111:11000010111
	.inst 0xc2cca400 // BLRS-C.C-C 00000:00000 Cn:0 001:001 opc:01 1:1 Cm:12 11000010110:11000010110
	.zero 16356
	.inst 0x82ff7100 // ALDR-R.RRB-32 Rt:0 Rn:8 opc:00 S:1 option:011 Rm:31 1:1 L:1 100000101:100000101
	.inst 0x586021bf // ldr_lit_gen:aarch64/instrs/memory/literal/general Rt:31 imm19:0110000000100001101 011000:011000 opc:01
	.inst 0xe2c10f00 // ALDUR-C.RI-C Ct:0 Rn:24 op2:11 imm9:000010000 V:0 op1:11 11100010:11100010
	.inst 0xe20634c0 // ALDURB-R.RI-32 Rt:0 Rn:6 op2:01 imm9:001100011 V:0 op1:00 11100010:11100010
	.inst 0x78cd8256 // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:22 Rn:18 00:00 imm9:011011000 0:0 opc:11 111000:111000 size:01
	.inst 0xc2d2e1f2 // SCFLGS-C.CR-C Cd:18 Cn:15 111000:111000 Rm:18 11000010110:11000010110
	.inst 0xc2eb404d // BICFLGS-C.CI-C Cd:13 Cn:2 0:0 00:00 imm8:01011010 11000010111:11000010111
	.inst 0xc2c21360
	.zero 1032176
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x26, cptr_el3
	orr x26, x26, #0x200
	msr cptr_el3, x26
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
	ldr x26, =initial_cap_values
	.inst 0xc2400340 // ldr c0, [x26, #0]
	.inst 0xc2400741 // ldr c1, [x26, #1]
	.inst 0xc2400b46 // ldr c6, [x26, #2]
	.inst 0xc2400f48 // ldr c8, [x26, #3]
	.inst 0xc240134c // ldr c12, [x26, #4]
	.inst 0xc240174e // ldr c14, [x26, #5]
	.inst 0xc2401b4f // ldr c15, [x26, #6]
	.inst 0xc2401f52 // ldr c18, [x26, #7]
	.inst 0xc2402354 // ldr c20, [x26, #8]
	.inst 0xc2402758 // ldr c24, [x26, #9]
	/* Set up flags and system registers */
	mov x26, #0x00000000
	msr nzcv, x26
	ldr x26, =0x200
	msr CPTR_EL3, x26
	ldr x26, =0x30850030
	msr SCTLR_EL3, x26
	ldr x26, =0x84
	msr S3_6_C1_C2_2, x26 // CCTLR_EL3
	isb
	/* Start test */
	ldr x27, =pcc_return_ddc_capabilities
	.inst 0xc240037b // ldr c27, [x27, #0]
	.inst 0x8260337a // ldr c26, [c27, #3]
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	.inst 0x8260137a // ldr c26, [c27, #1]
	.inst 0x8260237b // ldr c27, [c27, #2]
	.inst 0xc2c21340 // br c26
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x26, =final_cap_values
	.inst 0xc240035b // ldr c27, [x26, #0]
	.inst 0xc2dba401 // chkeq c0, c27
	b.ne comparison_fail
	.inst 0xc240075b // ldr c27, [x26, #1]
	.inst 0xc2dba421 // chkeq c1, c27
	b.ne comparison_fail
	.inst 0xc2400b5b // ldr c27, [x26, #2]
	.inst 0xc2dba441 // chkeq c2, c27
	b.ne comparison_fail
	.inst 0xc2400f5b // ldr c27, [x26, #3]
	.inst 0xc2dba4c1 // chkeq c6, c27
	b.ne comparison_fail
	.inst 0xc240135b // ldr c27, [x26, #4]
	.inst 0xc2dba501 // chkeq c8, c27
	b.ne comparison_fail
	.inst 0xc240175b // ldr c27, [x26, #5]
	.inst 0xc2dba581 // chkeq c12, c27
	b.ne comparison_fail
	.inst 0xc2401b5b // ldr c27, [x26, #6]
	.inst 0xc2dba5a1 // chkeq c13, c27
	b.ne comparison_fail
	.inst 0xc2401f5b // ldr c27, [x26, #7]
	.inst 0xc2dba5c1 // chkeq c14, c27
	b.ne comparison_fail
	.inst 0xc240235b // ldr c27, [x26, #8]
	.inst 0xc2dba5e1 // chkeq c15, c27
	b.ne comparison_fail
	.inst 0xc240275b // ldr c27, [x26, #9]
	.inst 0xc2dba641 // chkeq c18, c27
	b.ne comparison_fail
	.inst 0xc2402b5b // ldr c27, [x26, #10]
	.inst 0xc2dba681 // chkeq c20, c27
	b.ne comparison_fail
	.inst 0xc2402f5b // ldr c27, [x26, #11]
	.inst 0xc2dba6c1 // chkeq c22, c27
	b.ne comparison_fail
	.inst 0xc240335b // ldr c27, [x26, #12]
	.inst 0xc2dba701 // chkeq c24, c27
	b.ne comparison_fail
	.inst 0xc240375b // ldr c27, [x26, #13]
	.inst 0xc2dba7a1 // chkeq c29, c27
	b.ne comparison_fail
	.inst 0xc2403b5b // ldr c27, [x26, #14]
	.inst 0xc2dba7c1 // chkeq c30, c27
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001010
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001024
	ldr x1, =check_data1
	ldr x2, =0x00001028
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000010c0
	ldr x1, =check_data2
	ldr x2, =0x000010d0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001aa4
	ldr x1, =check_data3
	ldr x2, =0x00001aa5
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
	ldr x0, =0x00403ff0
	ldr x1, =check_data5
	ldr x2, =0x00404010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x0040d0f8
	ldr x1, =check_data6
	ldr x2, =0x0040d0fa
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x004c4428
	ldr x1, =check_data7
	ldr x2, =0x004c4430
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01a // cvtp c26, x0
	.inst 0xc2df435a // scvalue c26, c26, x31
	.inst 0xc28b413a // msr ddc_el3, c26
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
