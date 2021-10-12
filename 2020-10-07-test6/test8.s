.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 4
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0x42, 0x78, 0x08, 0x3d, 0xa4, 0x54, 0x18, 0xca, 0x54, 0xba, 0x6b, 0x10, 0x42, 0x00, 0x02, 0xba
	.byte 0x2a, 0xf1, 0xc5, 0xc2, 0xf7, 0x46, 0x82, 0x82, 0xe0, 0xe3, 0x83, 0xf8, 0x40, 0xc3, 0x37, 0xf0
	.byte 0xde, 0x23, 0x5e, 0xb8, 0x80, 0x0e, 0xc0, 0xda, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data3:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x1000
	/* C9 */
	.octa 0x200002000000
	/* C23 */
	.octa 0x8000000000070014000000000047f000
	/* C30 */
	.octa 0x101e
final_cap_values:
	/* C0 */
	.octa 0x50774d0000000000
	/* C2 */
	.octa 0x2000
	/* C9 */
	.octa 0x200002000000
	/* C10 */
	.octa 0x20008000408a00000000200002000000
	/* C20 */
	.octa 0x4d7750
	/* C23 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000408a00000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000005401000000ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x3d087842 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:2 Rn:2 imm12:001000011110 opc:00 111101:111101 size:00
	.inst 0xca1854a4 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:4 Rn:5 imm6:010101 Rm:24 N:0 shift:00 01010:01010 opc:10 sf:1
	.inst 0x106bba54 // ADR-C.I-C Rd:20 immhi:110101110111010010 P:0 10000:10000 immlo:00 op:0
	.inst 0xba020042 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:2 000000:000000 Rm:2 11010000:11010000 S:1 op:0 sf:1
	.inst 0xc2c5f12a // CVTPZ-C.R-C Cd:10 Rn:9 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x828246f7 // ALDRSB-R.RRB-64 Rt:23 Rn:23 opc:01 S:0 option:010 Rm:2 0:0 L:0 100000101:100000101
	.inst 0xf883e3e0 // prfum:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:0 Rn:31 00:00 imm9:000111110 0:0 opc:10 111000:111000 size:11
	.inst 0xf037c340 // ADRDP-C.ID-C Rd:0 immhi:011011111000011010 P:0 10000:10000 immlo:11 op:1
	.inst 0xb85e23de // ldur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:30 Rn:30 00:00 imm9:111100010 0:0 opc:01 111000:111000 size:10
	.inst 0xdac00e80 // rev:aarch64/instrs/integer/arithmetic/rev Rd:0 Rn:20 opc:11 1011010110000000000:1011010110000000000 sf:1
	.inst 0xc2c211e0
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
	.inst 0xc24001c2 // ldr c2, [x14, #0]
	.inst 0xc24005c9 // ldr c9, [x14, #1]
	.inst 0xc24009d7 // ldr c23, [x14, #2]
	.inst 0xc2400dde // ldr c30, [x14, #3]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q2, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30850032
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031ee // ldr c14, [c15, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826011ee // ldr c14, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
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
	mov x15, #0xf
	and x14, x14, x15
	cmp x14, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cf // ldr c15, [x14, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24005cf // ldr c15, [x14, #1]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc24009cf // ldr c15, [x14, #2]
	.inst 0xc2cfa521 // chkeq c9, c15
	b.ne comparison_fail
	.inst 0xc2400dcf // ldr c15, [x14, #3]
	.inst 0xc2cfa541 // chkeq c10, c15
	b.ne comparison_fail
	.inst 0xc24011cf // ldr c15, [x14, #4]
	.inst 0xc2cfa681 // chkeq c20, c15
	b.ne comparison_fail
	.inst 0xc24015cf // ldr c15, [x14, #5]
	.inst 0xc2cfa6e1 // chkeq c23, c15
	b.ne comparison_fail
	.inst 0xc24019cf // ldr c15, [x14, #6]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x15, v2.d[0]
	cmp x14, x15
	b.ne comparison_fail
	ldr x14, =0x0
	mov x15, v2.d[1]
	cmp x14, x15
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001004
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x0000121e
	ldr x1, =check_data1
	ldr x2, =0x0000121f
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
	ldr x0, =0x00481000
	ldr x1, =check_data3
	ldr x2, =0x00481001
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
