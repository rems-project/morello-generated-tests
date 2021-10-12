.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0xfe
.data
check_data1:
	.byte 0x84, 0x4e, 0x72, 0xb5, 0x21, 0x01, 0xd0, 0x69, 0x37, 0x48, 0x31, 0xeb, 0xc0, 0xef, 0xcb, 0x38
	.byte 0x62, 0x1b, 0xe7, 0xc2, 0x4c, 0xf0, 0xc5, 0xc2, 0x36, 0xd0, 0xc0, 0xc2, 0x3e, 0x7e, 0x9f, 0x08
	.byte 0x7e, 0xf6, 0xe9, 0x8a, 0x3e, 0x2c, 0xc2, 0x9a, 0x20, 0x13, 0xc2, 0xc2
.data
check_data2:
	.zero 8
.data
.balign 16
initial_cap_values:
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000324002
	/* C9 */
	.octa 0x800000000001000700000000003fffe0
	/* C17 */
	.octa 0x40000000000100050000000000001ffe
	/* C27 */
	.octa 0x72007006833c081000000
	/* C30 */
	.octa 0x80000000000100070000000000001f40
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x7200700a833c081326002
	/* C4 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000324002
	/* C9 */
	.octa 0x80000000000100070000000000400060
	/* C12 */
	.octa 0x200080006000000000a833c081726002
	/* C17 */
	.octa 0x40000000000100050000000000001ffe
	/* C22 */
	.octa 0x0
	/* C23 */
	.octa 0xffffffffffff8008
	/* C27 */
	.octa 0x72007006833c081000000
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000600000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 80
	.dword final_cap_values + 80
	.dword final_cap_values + 112
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xb5724e84 // cbnz:aarch64/instrs/branch/conditional/compare Rt:4 imm19:0111001001001110100 op:1 011010:011010 sf:1
	.inst 0x69d00121 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:1 Rn:9 Rt2:00000 imm7:0100000 L:1 1010011:1010011 opc:01
	.inst 0xeb314837 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:23 Rn:1 imm3:010 option:010 Rm:17 01011001:01011001 S:1 op:1 sf:1
	.inst 0x38cbefc0 // ldrsb_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:0 Rn:30 11:11 imm9:010111110 0:0 opc:11 111000:111000 size:00
	.inst 0xc2e71b62 // CVT-C.CR-C Cd:2 Cn:27 0110:0110 0:0 0:0 Rm:7 11000010111:11000010111
	.inst 0xc2c5f04c // CVTPZ-C.R-C Cd:12 Rn:2 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0xc2c0d036 // GCPERM-R.C-C Rd:22 Cn:1 100:100 opc:110 1100001011000000:1100001011000000
	.inst 0x089f7e3e // stllrb:aarch64/instrs/memory/ordered Rt:30 Rn:17 Rt2:11111 o0:0 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0x8ae9f67e // bic_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:30 Rn:19 imm6:111101 Rm:9 N:1 shift:11 01010:01010 opc:00 sf:1
	.inst 0x9ac22c3e // rorv:aarch64/instrs/integer/shift/variable Rd:30 Rn:1 op2:11 0010:0010 Rm:2 0011010110:0011010110 sf:1
	.inst 0xc2c21320
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
	.inst 0xc24001a4 // ldr c4, [x13, #0]
	.inst 0xc24005a7 // ldr c7, [x13, #1]
	.inst 0xc24009a9 // ldr c9, [x13, #2]
	.inst 0xc2400db1 // ldr c17, [x13, #3]
	.inst 0xc24011bb // ldr c27, [x13, #4]
	.inst 0xc24015be // ldr c30, [x13, #5]
	/* Set up flags and system registers */
	mov x13, #0x00000000
	msr nzcv, x13
	ldr x13, =0x200
	msr CPTR_EL3, x13
	ldr x13, =0x30850030
	msr SCTLR_EL3, x13
	ldr x13, =0xc
	msr S3_6_C1_C2_2, x13 // CCTLR_EL3
	isb
	/* Start test */
	ldr x25, =pcc_return_ddc_capabilities
	.inst 0xc2400339 // ldr c25, [x25, #0]
	.inst 0x8260132d // ldr c13, [c25, #1]
	.inst 0x82602339 // ldr c25, [c25, #2]
	.inst 0xc2c211a0 // br c13
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00d // cvtp c13, x0
	.inst 0xc2df41ad // scvalue c13, c13, x31
	.inst 0xc28b412d // msr ddc_el3, c13
	isb
	/* Check processor flags */
	mrs x13, nzcv
	ubfx x13, x13, #28, #4
	mov x25, #0xf
	and x13, x13, x25
	cmp x13, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x13, =final_cap_values
	.inst 0xc24001b9 // ldr c25, [x13, #0]
	.inst 0xc2d9a401 // chkeq c0, c25
	b.ne comparison_fail
	.inst 0xc24005b9 // ldr c25, [x13, #1]
	.inst 0xc2d9a421 // chkeq c1, c25
	b.ne comparison_fail
	.inst 0xc24009b9 // ldr c25, [x13, #2]
	.inst 0xc2d9a441 // chkeq c2, c25
	b.ne comparison_fail
	.inst 0xc2400db9 // ldr c25, [x13, #3]
	.inst 0xc2d9a481 // chkeq c4, c25
	b.ne comparison_fail
	.inst 0xc24011b9 // ldr c25, [x13, #4]
	.inst 0xc2d9a4e1 // chkeq c7, c25
	b.ne comparison_fail
	.inst 0xc24015b9 // ldr c25, [x13, #5]
	.inst 0xc2d9a521 // chkeq c9, c25
	b.ne comparison_fail
	.inst 0xc24019b9 // ldr c25, [x13, #6]
	.inst 0xc2d9a581 // chkeq c12, c25
	b.ne comparison_fail
	.inst 0xc2401db9 // ldr c25, [x13, #7]
	.inst 0xc2d9a621 // chkeq c17, c25
	b.ne comparison_fail
	.inst 0xc24021b9 // ldr c25, [x13, #8]
	.inst 0xc2d9a6c1 // chkeq c22, c25
	b.ne comparison_fail
	.inst 0xc24025b9 // ldr c25, [x13, #9]
	.inst 0xc2d9a6e1 // chkeq c23, c25
	b.ne comparison_fail
	.inst 0xc24029b9 // ldr c25, [x13, #10]
	.inst 0xc2d9a761 // chkeq c27, c25
	b.ne comparison_fail
	.inst 0xc2402db9 // ldr c25, [x13, #11]
	.inst 0xc2d9a7c1 // chkeq c30, c25
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001ffe
	ldr x1, =check_data0
	ldr x2, =0x00001fff
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
	ldr x0, =0x00400060
	ldr x1, =check_data2
	ldr x2, =0x00400068
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
