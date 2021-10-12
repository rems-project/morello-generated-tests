.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.zero 8
.data
check_data2:
	.zero 1
.data
check_data3:
	.zero 2
.data
check_data4:
	.byte 0x5e, 0x78, 0xd0, 0xc2, 0x20, 0xdc, 0x8a, 0xe2, 0xe0, 0x4f, 0x4b, 0x93, 0x7e, 0x9d, 0x4d, 0x82
	.byte 0x82, 0x79, 0xd4, 0xc2, 0x86, 0x7e, 0x1b, 0x3c, 0x6d, 0xc3, 0x1e, 0x78, 0x05, 0x2d, 0x02, 0x6b
	.byte 0x5a, 0xd0, 0xc5, 0xc2, 0x5f, 0x00, 0x1d, 0x1a, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000000200070000000000001103
	/* C2 */
	.octa 0x300010000000000000000
	/* C11 */
	.octa 0x40000000570000010000000000001018
	/* C12 */
	.octa 0x60002000000000fff7800
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x1aa7
	/* C27 */
	.octa 0x1fe8
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000000200070000000000001103
	/* C2 */
	.octa 0x7a807800000000000fff7800
	/* C11 */
	.octa 0x40000000570000010000000000001018
	/* C12 */
	.octa 0x60002000000000fff7800
	/* C13 */
	.octa 0x0
	/* C20 */
	.octa 0x1a5e
	/* C26 */
	.octa 0x4000000040000022000000000fff7822
	/* C27 */
	.octa 0x1fe8
	/* C30 */
	.octa 0x420000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000200100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x40000000400000220000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword final_cap_values + 16
	.dword final_cap_values + 48
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2d0785e // SCBNDS-C.CI-S Cd:30 Cn:2 1110:1110 S:1 imm6:100000 11000010110:11000010110
	.inst 0xe28adc20 // ASTUR-C.RI-C Ct:0 Rn:1 op2:11 imm9:010101101 V:0 op1:10 11100010:11100010
	.inst 0x934b4fe0 // sbfm:aarch64/instrs/integer/bitfield Rd:0 Rn:31 imms:010011 immr:001011 N:1 100110:100110 opc:00 sf:1
	.inst 0x824d9d7e // ASTR-R.RI-64 Rt:30 Rn:11 op:11 imm9:011011001 L:0 1000001001:1000001001
	.inst 0xc2d47982 // SCBNDS-C.CI-S Cd:2 Cn:12 1110:1110 S:1 imm6:101000 11000010110:11000010110
	.inst 0x3c1b7e86 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/pre-idx Rt:6 Rn:20 11:11 imm9:110110111 0:0 opc:00 111100:111100 size:00
	.inst 0x781ec36d // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:13 Rn:27 00:00 imm9:111101100 0:0 opc:00 111000:111000 size:01
	.inst 0x6b022d05 // subs_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:5 Rn:8 imm6:001011 Rm:2 0:0 shift:00 01011:01011 S:1 op:1 sf:0
	.inst 0xc2c5d05a // CVTDZ-C.R-C Cd:26 Rn:2 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0x1a1d005f // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:31 Rn:2 000000:000000 Rm:29 11010000:11010000 S:0 op:0 sf:0
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x17, cptr_el3
	orr x17, x17, #0x200
	msr cptr_el3, x17
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
	ldr x17, =initial_cap_values
	.inst 0xc2400220 // ldr c0, [x17, #0]
	.inst 0xc2400621 // ldr c1, [x17, #1]
	.inst 0xc2400a22 // ldr c2, [x17, #2]
	.inst 0xc2400e2b // ldr c11, [x17, #3]
	.inst 0xc240122c // ldr c12, [x17, #4]
	.inst 0xc240162d // ldr c13, [x17, #5]
	.inst 0xc2401a34 // ldr c20, [x17, #6]
	.inst 0xc2401e3b // ldr c27, [x17, #7]
	/* Vector registers */
	mrs x17, cptr_el3
	bfc x17, #10, #1
	msr cptr_el3, x17
	isb
	ldr q6, =0x0
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b1 // ldr c17, [c21, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x826012b1 // ldr c17, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21220 // br c17
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x17, =final_cap_values
	.inst 0xc2400235 // ldr c21, [x17, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400635 // ldr c21, [x17, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400a35 // ldr c21, [x17, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400e35 // ldr c21, [x17, #3]
	.inst 0xc2d5a561 // chkeq c11, c21
	b.ne comparison_fail
	.inst 0xc2401235 // ldr c21, [x17, #4]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401635 // ldr c21, [x17, #5]
	.inst 0xc2d5a5a1 // chkeq c13, c21
	b.ne comparison_fail
	.inst 0xc2401a35 // ldr c21, [x17, #6]
	.inst 0xc2d5a681 // chkeq c20, c21
	b.ne comparison_fail
	.inst 0xc2401e35 // ldr c21, [x17, #7]
	.inst 0xc2d5a741 // chkeq c26, c21
	b.ne comparison_fail
	.inst 0xc2402235 // ldr c21, [x17, #8]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402635 // ldr c21, [x17, #9]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x17, =0x0
	mov x21, v6.d[0]
	cmp x17, x21
	b.ne comparison_fail
	ldr x17, =0x0
	mov x21, v6.d[1]
	cmp x17, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000011b0
	ldr x1, =check_data0
	ldr x2, =0x000011c0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000016e0
	ldr x1, =check_data1
	ldr x2, =0x000016e8
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a80
	ldr x1, =check_data2
	ldr x2, =0x00001a81
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff6
	ldr x1, =check_data3
	ldr x2, =0x00001ff8
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
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b011 // cvtp c17, x0
	.inst 0xc2df4231 // scvalue c17, c17, x31
	.inst 0xc28b4131 // msr DDC_EL3, c17
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
