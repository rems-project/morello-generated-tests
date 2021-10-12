.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 4
.data
check_data2:
	.byte 0xa6, 0x40, 0x60, 0x54, 0x86, 0x1e, 0xee, 0x54, 0xc6, 0x53, 0x5e, 0xfa, 0x08, 0x90, 0xc5, 0xc2
	.byte 0xc1, 0x12, 0xc5, 0xc2, 0x5f, 0x21, 0x1e, 0x9b, 0x23, 0x6c, 0x5f, 0x91, 0xa5, 0x98, 0x2b, 0xd0
	.byte 0x52, 0x7f, 0x07, 0xf8, 0xc1, 0xaa, 0x9f, 0xb8, 0x80, 0x13, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x400006c0000ff7
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000500070000000000001c06
	/* C26 */
	.octa 0x40000000000100050000000000001501
final_cap_values:
	/* C0 */
	.octa 0x400006c0000ff7
	/* C1 */
	.octa 0x0
	/* C3 */
	.octa 0x7dcc06
	/* C5 */
	.octa 0x7001f000057316000
	/* C8 */
	.octa 0x700400006c0000ff7
	/* C18 */
	.octa 0x0
	/* C22 */
	.octa 0x80000000000500070000000000001c06
	/* C26 */
	.octa 0x40000000000100050000000000001578
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000006000f0000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x7001f000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 96
	.dword final_cap_values + 112
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x546040a6 // b_cond:aarch64/instrs/branch/conditional/cond cond:0110 0:0 imm19:0110000001000000101 01010100:01010100
	.inst 0x54ee1e86 // b_cond:aarch64/instrs/branch/conditional/cond cond:0110 0:0 imm19:1110111000011110100 01010100:01010100
	.inst 0xfa5e53c6 // ccmp_reg:aarch64/instrs/integer/conditional/compare/register nzcv:0110 0:0 Rn:30 00:00 cond:0101 Rm:30 111010010:111010010 op:1 sf:1
	.inst 0xc2c59008 // CVTD-C.R-C Cd:8 Rn:0 100:100 opc:00 11000010110001011:11000010110001011
	.inst 0xc2c512c1 // CVTD-R.C-C Rd:1 Cn:22 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x9b1e215f // madd:aarch64/instrs/integer/arithmetic/mul/uniform/add-sub Rd:31 Rn:10 Ra:8 o0:0 Rm:30 0011011000:0011011000 sf:1
	.inst 0x915f6c23 // add_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:3 Rn:1 imm12:011111011011 sh:1 0:0 10001:10001 S:0 op:0 sf:1
	.inst 0xd02b98a5 // ADRP-C.I-C Rd:5 immhi:010101110011000101 P:0 10000:10000 immlo:10 op:1
	.inst 0xf8077f52 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:18 Rn:26 11:11 imm9:001110111 0:0 opc:00 111000:111000 size:11
	.inst 0xb89faac1 // ldtrsw:aarch64/instrs/memory/single/general/immediate/signed/offset/unpriv Rt:1 Rn:22 10:10 imm9:111111010 0:0 opc:10 111000:111000 size:10
	.inst 0xc2c21380
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x11, cptr_el3
	orr x11, x11, #0x200
	msr cptr_el3, x11
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
	ldr x11, =initial_cap_values
	.inst 0xc2400160 // ldr c0, [x11, #0]
	.inst 0xc2400572 // ldr c18, [x11, #1]
	.inst 0xc2400976 // ldr c22, [x11, #2]
	.inst 0xc2400d7a // ldr c26, [x11, #3]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x4
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x28, =pcc_return_ddc_capabilities
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0x8260338b // ldr c11, [c28, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x8260138b // ldr c11, [c28, #1]
	.inst 0x8260239c // ldr c28, [c28, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* Check processor flags */
	mrs x11, nzcv
	ubfx x11, x11, #28, #4
	mov x28, #0xf
	and x11, x11, x28
	cmp x11, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc240017c // ldr c28, [x11, #0]
	.inst 0xc2dca401 // chkeq c0, c28
	b.ne comparison_fail
	.inst 0xc240057c // ldr c28, [x11, #1]
	.inst 0xc2dca421 // chkeq c1, c28
	b.ne comparison_fail
	.inst 0xc240097c // ldr c28, [x11, #2]
	.inst 0xc2dca461 // chkeq c3, c28
	b.ne comparison_fail
	.inst 0xc2400d7c // ldr c28, [x11, #3]
	.inst 0xc2dca4a1 // chkeq c5, c28
	b.ne comparison_fail
	.inst 0xc240117c // ldr c28, [x11, #4]
	.inst 0xc2dca501 // chkeq c8, c28
	b.ne comparison_fail
	.inst 0xc240157c // ldr c28, [x11, #5]
	.inst 0xc2dca641 // chkeq c18, c28
	b.ne comparison_fail
	.inst 0xc240197c // ldr c28, [x11, #6]
	.inst 0xc2dca6c1 // chkeq c22, c28
	b.ne comparison_fail
	.inst 0xc2401d7c // ldr c28, [x11, #7]
	.inst 0xc2dca741 // chkeq c26, c28
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001578
	ldr x1, =check_data0
	ldr x2, =0x00001580
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001c00
	ldr x1, =check_data1
	ldr x2, =0x00001c04
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x0040002c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
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
