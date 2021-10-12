.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 32
.data
check_data2:
	.byte 0xb3, 0x20
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0x3f, 0x54, 0x0b, 0x38, 0xe1, 0xa3, 0x17, 0x78, 0xff, 0xe5, 0xec, 0x62, 0xc0, 0x03, 0x5f, 0xd6
	.byte 0x20, 0x88, 0x50, 0x93, 0x03, 0xb0, 0xc0, 0xc2, 0x0f, 0xd0, 0xc5, 0xc2, 0x83, 0x84, 0x22, 0xeb
	.byte 0x7e, 0x04, 0x2f, 0x9b, 0xeb, 0x34, 0xfc, 0x42, 0x00, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x1ffe
	/* C7 */
	.octa 0x1100
	/* C15 */
	.octa 0x2000
	/* C30 */
	.octa 0x400010
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x20b3
	/* C7 */
	.octa 0x1100
	/* C11 */
	.octa 0x0
	/* C13 */
	.octa 0x0
	/* C15 */
	.octa 0x0
	/* C25 */
	.octa 0x0
	/* C30 */
	.octa 0x20b3
initial_SP_EL3_value:
	.octa 0x2000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000700040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000700070000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001080
	.dword 0x0000000000001da0
	.dword final_cap_values + 48
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x380b543f // strb_imm:aarch64/instrs/memory/single/general/immediate/signed/post-idx Rt:31 Rn:1 01:01 imm9:010110101 0:0 opc:00 111000:111000 size:00
	.inst 0x7817a3e1 // sturh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:1 Rn:31 00:00 imm9:101111010 0:0 opc:00 111000:111000 size:01
	.inst 0x62ece5ff // LDP-C.RIBW-C Ct:31 Rn:15 Ct2:11001 imm7:1011001 L:1 011000101:011000101
	.inst 0xd65f03c0 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:30 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.inst 0x93508820 // sbfm:aarch64/instrs/integer/bitfield Rd:0 Rn:1 imms:100010 immr:010000 N:1 100110:100110 opc:00 sf:1
	.inst 0xc2c0b003 // GCSEAL-R.C-C Rd:3 Cn:0 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c5d00f // CVTDZ-C.R-C Cd:15 Rn:0 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xeb228483 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:3 Rn:4 imm3:001 option:100 Rm:2 01011001:01011001 S:1 op:1 sf:1
	.inst 0x9b2f047e // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:30 Rn:3 Ra:1 o0:0 Rm:15 01:01 U:0 10011011:10011011
	.inst 0x42fc34eb // LDP-C.RIB-C Ct:11 Rn:7 Ct2:01101 imm7:1111000 L:1 010000101:010000101
	.inst 0xc2c21200
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
	.inst 0xc2400221 // ldr c1, [x17, #0]
	.inst 0xc2400627 // ldr c7, [x17, #1]
	.inst 0xc2400a2f // ldr c15, [x17, #2]
	.inst 0xc2400e3e // ldr c30, [x17, #3]
	/* Set up flags and system registers */
	mov x17, #0x00000000
	msr nzcv, x17
	ldr x17, =initial_SP_EL3_value
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0xc2c1d23f // cpy c31, c17
	ldr x17, =0x200
	msr CPTR_EL3, x17
	ldr x17, =0x30850032
	msr SCTLR_EL3, x17
	ldr x17, =0x4
	msr S3_6_C1_C2_2, x17 // CCTLR_EL3
	isb
	/* Start test */
	ldr x16, =pcc_return_ddc_capabilities
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0x82603211 // ldr c17, [c16, #3]
	.inst 0xc28b4131 // msr DDC_EL3, c17
	isb
	.inst 0x82601211 // ldr c17, [c16, #1]
	.inst 0x82602210 // ldr c16, [c16, #2]
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
	.inst 0xc2400230 // ldr c16, [x17, #0]
	.inst 0xc2d0a401 // chkeq c0, c16
	b.ne comparison_fail
	.inst 0xc2400630 // ldr c16, [x17, #1]
	.inst 0xc2d0a421 // chkeq c1, c16
	b.ne comparison_fail
	.inst 0xc2400a30 // ldr c16, [x17, #2]
	.inst 0xc2d0a4e1 // chkeq c7, c16
	b.ne comparison_fail
	.inst 0xc2400e30 // ldr c16, [x17, #3]
	.inst 0xc2d0a561 // chkeq c11, c16
	b.ne comparison_fail
	.inst 0xc2401230 // ldr c16, [x17, #4]
	.inst 0xc2d0a5a1 // chkeq c13, c16
	b.ne comparison_fail
	.inst 0xc2401630 // ldr c16, [x17, #5]
	.inst 0xc2d0a5e1 // chkeq c15, c16
	b.ne comparison_fail
	.inst 0xc2401a30 // ldr c16, [x17, #6]
	.inst 0xc2d0a721 // chkeq c25, c16
	b.ne comparison_fail
	.inst 0xc2401e30 // ldr c16, [x17, #7]
	.inst 0xc2d0a7c1 // chkeq c30, c16
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001080
	ldr x1, =check_data0
	ldr x2, =0x000010a0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001d90
	ldr x1, =check_data1
	ldr x2, =0x00001db0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f7a
	ldr x1, =check_data2
	ldr x2, =0x00001f7c
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
