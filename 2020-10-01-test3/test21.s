.section data0, #alloc, #write
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x04, 0x00, 0x00
	.zero 1856
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
	.zero 2208
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x04, 0x00, 0x00
	.zero 1
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 32
.data
check_data3:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00
.data
check_data4:
	.zero 1
.data
check_data5:
	.byte 0x54, 0xb5
.data
check_data6:
	.byte 0x43, 0x00, 0x05, 0x7a, 0xe0, 0xa0, 0xb8, 0xb9, 0xca, 0xff, 0xd2, 0x62, 0xe5, 0x07, 0x17, 0x38
	.byte 0xc0, 0x7c, 0xdf, 0x08, 0xfe, 0xdb, 0x47, 0xa2, 0x73, 0xce, 0xff, 0xc2, 0xe1, 0x65, 0xd6, 0xc2
	.byte 0x42, 0x7c, 0x82, 0x82, 0x3a, 0x02, 0x58, 0x71, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C2 */
	.octa 0x4000000000010005aaaaaaaaaaaab554
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x17f2
	/* C7 */
	.octa 0xffffffffffffd958
	/* C15 */
	.octa 0x204001e001008a00000001c001
	/* C19 */
	.octa 0x90000000000100050000000000001000
	/* C22 */
	.octa 0xc001
	/* C30 */
	.octa 0x1080
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x204001e001000000000000c001
	/* C2 */
	.octa 0x4000000000010005aaaaaaaaaaaab554
	/* C5 */
	.octa 0x0
	/* C6 */
	.octa 0x17f2
	/* C7 */
	.octa 0xffffffffffffd958
	/* C10 */
	.octa 0x0
	/* C15 */
	.octa 0x204001e001008a00000001c001
	/* C19 */
	.octa 0x401000000000000000000000000
	/* C22 */
	.octa 0xc001
	/* C30 */
	.octa 0x1800000000000000000000000
initial_csp_value:
	.octa 0x1010
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000040080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000005801001400ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x00000000000012d0
	.dword 0x00000000000012e0
	.dword 0x0000000000001750
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 32
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x7a050043 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:3 Rn:2 000000:000000 Rm:5 11010000:11010000 S:1 op:1 sf:0
	.inst 0xb9b8a0e0 // ldrsw_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:0 Rn:7 imm12:111000101000 opc:10 111001:111001 size:10
	.inst 0x62d2ffca // LDP-C.RIBW-C Ct:10 Rn:30 Ct2:11111 imm7:0100101 L:1 011000101:011000101
	.inst 0x381707e5 // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:5 Rn:31 01:01 imm9:101110000 0:0 opc:00 111000:111000 size:00
	.inst 0x08df7cc0 // ldlarb:aarch64/instrs/memory/ordered Rt:0 Rn:6 Rt2:11111 o0:0 Rs:11111 0:0 L:1 0010001:0010001 size:00
	.inst 0xa247dbfe // LDTR-C.RIB-C Ct:30 Rn:31 10:10 imm9:001111101 0:0 opc:01 10100010:10100010
	.inst 0xc2ffce73 // ALDR-C.RRB-C Ct:19 Rn:19 1:1 L:1 S:0 option:110 Rm:31 11000010111:11000010111
	.inst 0xc2d665e1 // CPYVALUE-C.C-C Cd:1 Cn:15 001:001 opc:11 0:0 Cm:22 11000010110:11000010110
	.inst 0x82827c42 // ASTRH-R.RRB-32 Rt:2 Rn:2 opc:11 S:1 option:011 Rm:2 0:0 L:0 100000101:100000101
	.inst 0x7158023a // subs_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:26 Rn:17 imm12:011000000000 sh:1 0:0 10001:10001 S:1 op:1 sf:0
	.inst 0xc2c212a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x23, cptr_el3
	orr x23, x23, #0x200
	msr cptr_el3, x23
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e2 // ldr c2, [x23, #0]
	.inst 0xc24006e5 // ldr c5, [x23, #1]
	.inst 0xc2400ae6 // ldr c6, [x23, #2]
	.inst 0xc2400ee7 // ldr c7, [x23, #3]
	.inst 0xc24012ef // ldr c15, [x23, #4]
	.inst 0xc24016f3 // ldr c19, [x23, #5]
	.inst 0xc2401af6 // ldr c22, [x23, #6]
	.inst 0xc2401efe // ldr c30, [x23, #7]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =initial_csp_value
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0xc2c1d2ff // cpy c31, c23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30850032
	msr SCTLR_EL3, x23
	ldr x23, =0x0
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032b7 // ldr c23, [c21, #3]
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	.inst 0x826012b7 // ldr c23, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f5 // ldr c21, [x23, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc24006f5 // ldr c21, [x23, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400af5 // ldr c21, [x23, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400ef5 // ldr c21, [x23, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc24012f5 // ldr c21, [x23, #4]
	.inst 0xc2d5a4c1 // chkeq c6, c21
	b.ne comparison_fail
	.inst 0xc24016f5 // ldr c21, [x23, #5]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401af5 // ldr c21, [x23, #6]
	.inst 0xc2d5a541 // chkeq c10, c21
	b.ne comparison_fail
	.inst 0xc2401ef5 // ldr c21, [x23, #7]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc24022f5 // ldr c21, [x23, #8]
	.inst 0xc2d5a661 // chkeq c19, c21
	b.ne comparison_fail
	.inst 0xc24026f5 // ldr c21, [x23, #9]
	.inst 0xc2d5a6c1 // chkeq c22, c21
	b.ne comparison_fail
	.inst 0xc2402af5 // ldr c21, [x23, #10]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001011
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000011f8
	ldr x1, =check_data1
	ldr x2, =0x000011fc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000012d0
	ldr x1, =check_data2
	ldr x2, =0x000012f0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001750
	ldr x1, =check_data3
	ldr x2, =0x00001760
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x000017f2
	ldr x1, =check_data4
	ldr x2, =0x000017f3
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00001ffc
	ldr x1, =check_data5
	ldr x2, =0x00001ffe
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400000
	ldr x1, =check_data6
	ldr x2, =0x0040002c
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	/* Done, print message */
	ldr x0, =ok_message
	b write_tube
comparison_fail:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr ddc_el3, c23
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
