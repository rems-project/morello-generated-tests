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
	.byte 0x82, 0x30, 0xc2, 0xc2
.data
check_data3:
	.byte 0x41, 0x30, 0xc2, 0xc2, 0xd7, 0x03, 0xc0, 0x5a, 0xaa, 0xa7, 0x22, 0xab, 0xe2, 0x13, 0xc5, 0xc2
	.byte 0xe1, 0x67, 0x22, 0x90, 0x33, 0x65, 0x11, 0x38, 0x29, 0x48, 0xc2, 0xc2, 0x3a, 0x0a, 0x03, 0xe2
	.byte 0x01, 0x52, 0xc0, 0xc2, 0xc0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x0
	/* C4 */
	.octa 0x200080004000a004000000000041a005
	/* C9 */
	.octa 0x40000000000700070000000000001ffe
	/* C17 */
	.octa 0x100e
	/* C19 */
	.octa 0x0
final_cap_values:
	/* C2 */
	.octa 0x100
	/* C4 */
	.octa 0x200080004000a004000000000041a005
	/* C9 */
	.octa 0x8000000000010005007ffffd64cfc000
	/* C17 */
	.octa 0x100e
	/* C19 */
	.octa 0x0
	/* C23 */
	.octa 0xa0000200
	/* C26 */
	.octa 0x0
	/* C30 */
	.octa 0x20008000000080080000000000400005
initial_SP_EL3_value:
	.octa 0x100
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x8000000000010005007ffffd20000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword final_cap_values + 112
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c23082 // BLRS-C-C 00010:00010 Cn:4 100:100 opc:01 11000010110000100:11000010110000100
	.zero 106496
	.inst 0xc2c23041 // CHKTGD-C-C 00001:00001 Cn:2 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x5ac003d7 // rbit_int:aarch64/instrs/integer/arithmetic/rbit Rd:23 Rn:30 101101011000000000000:101101011000000000000 sf:0
	.inst 0xab22a7aa // adds_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:10 Rn:29 imm3:001 option:101 Rm:2 01011001:01011001 S:1 op:0 sf:1
	.inst 0xc2c513e2 // CVTD-R.C-C Rd:2 Cn:31 100:100 opc:00 11000010110001010:11000010110001010
	.inst 0x902267e1 // ADRP-C.I-C Rd:1 immhi:010001001100111111 P:0 10000:10000 immlo:00 op:1
	.inst 0x38116533 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:19 Rn:9 01:01 imm9:100010110 0:0 opc:00 111000:111000 size:00
	.inst 0xc2c24829 // UNSEAL-C.CC-C Cd:9 Cn:1 0010:0010 opc:01 Cm:2 11000010110:11000010110
	.inst 0xe2030a3a // ALDURSB-R.RI-64 Rt:26 Rn:17 op2:10 imm9:000110000 V:0 op1:00 11100010:11100010
	.inst 0xc2c05201 // GCVALUE-R.C-C Rd:1 Cn:16 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0xc2c211c0
	.zero 942036
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x0, cptr_el3
	orr x0, x0, #0x200
	msr cptr_el3, x0
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
	ldr x0, =initial_cap_values
	.inst 0xc2400002 // ldr c2, [x0, #0]
	.inst 0xc2400404 // ldr c4, [x0, #1]
	.inst 0xc2400809 // ldr c9, [x0, #2]
	.inst 0xc2400c11 // ldr c17, [x0, #3]
	.inst 0xc2401013 // ldr c19, [x0, #4]
	/* Set up flags and system registers */
	mov x0, #0x00000000
	msr nzcv, x0
	ldr x0, =initial_SP_EL3_value
	.inst 0xc2400000 // ldr c0, [x0, #0]
	.inst 0xc2c1d01f // cpy c31, c0
	ldr x0, =0x200
	msr CPTR_EL3, x0
	ldr x0, =0x30850030
	msr SCTLR_EL3, x0
	ldr x0, =0x4
	msr S3_6_C1_C2_2, x0 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c0 // ldr c0, [c14, #3]
	.inst 0xc28b4120 // msr DDC_EL3, c0
	isb
	.inst 0x826011c0 // ldr c0, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c21000 // br c0
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
	isb
	/* Check processor flags */
	mrs x0, nzcv
	ubfx x0, x0, #28, #4
	mov x14, #0xf
	and x0, x0, x14
	cmp x0, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x0, =final_cap_values
	.inst 0xc240000e // ldr c14, [x0, #0]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc240040e // ldr c14, [x0, #1]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc240080e // ldr c14, [x0, #2]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc2400c0e // ldr c14, [x0, #3]
	.inst 0xc2cea621 // chkeq c17, c14
	b.ne comparison_fail
	.inst 0xc240100e // ldr c14, [x0, #4]
	.inst 0xc2cea661 // chkeq c19, c14
	b.ne comparison_fail
	.inst 0xc240140e // ldr c14, [x0, #5]
	.inst 0xc2cea6e1 // chkeq c23, c14
	b.ne comparison_fail
	.inst 0xc240180e // ldr c14, [x0, #6]
	.inst 0xc2cea741 // chkeq c26, c14
	b.ne comparison_fail
	.inst 0xc2401c0e // ldr c14, [x0, #7]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x0000103e
	ldr x1, =check_data0
	ldr x2, =0x0000103f
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ffe
	ldr x1, =check_data1
	ldr x2, =0x00001fff
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400004
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x0041a004
	ldr x1, =check_data3
	ldr x2, =0x0041a02c
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
	.inst 0xc2c5b000 // cvtp c0, x0
	.inst 0xc2df4000 // scvalue c0, c0, x31
	.inst 0xc28b4120 // msr DDC_EL3, c0
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
