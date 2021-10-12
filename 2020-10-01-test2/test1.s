.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 8
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x28, 0x70, 0x14, 0xf8, 0x5f, 0x3e, 0x03, 0xd5, 0x55, 0x06, 0x6e, 0xc2, 0x10, 0x68, 0xd7, 0xc2
	.byte 0x41, 0xa4, 0xd0, 0xc2, 0xe1, 0x03, 0x02, 0x9a, 0x56, 0x3d, 0x0a, 0xac, 0xb2, 0x37, 0xc2, 0x0a
	.byte 0x08, 0xc0, 0xde, 0xc2, 0xe8, 0xb3, 0xc0, 0xc2, 0x20, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x10f9
	/* C2 */
	.octa 0x800000000000000000000000
	/* C8 */
	.octa 0x0
	/* C10 */
	.octa 0xf10
	/* C18 */
	.octa 0xffffffffffff6010
	/* C23 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x800000000000000000000000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000000000000000000000
	/* C8 */
	.octa 0x1
	/* C10 */
	.octa 0xf10
	/* C16 */
	.octa 0x800000000000000000000000
	/* C18 */
	.octa 0x0
	/* C21 */
	.octa 0x0
	/* C23 */
	.octa 0x0
initial_csp_value:
	.octa 0x3fff800000000000000000000000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000100070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000000201c005000000000202c001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001820
	.dword initial_cap_values + 0
	.dword final_cap_values + 0
	.dword final_cap_values + 112
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xf8147028 // stur_gen:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:8 Rn:1 00:00 imm9:101000111 0:0 opc:00 111000:111000 size:11
	.inst 0xd5033e5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1110 11010101000000110011:11010101000000110011
	.inst 0xc26e0655 // LDR-C.RIB-C Ct:21 Rn:18 imm12:101110000001 L:1 110000100:110000100
	.inst 0xc2d76810 // ORRFLGS-C.CR-C Cd:16 Cn:0 1010:1010 opc:01 Rm:23 11000010110:11000010110
	.inst 0xc2d0a441 // CHKEQ-_.CC-C 00001:00001 Cn:2 001:001 opc:01 1:1 Cm:16 11000010110:11000010110
	.inst 0x9a0203e1 // adc:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:31 000000:000000 Rm:2 11010000:11010000 S:0 op:0 sf:1
	.inst 0xac0a3d56 // stnp_fpsimd:aarch64/instrs/memory/pair/simdfp/no-alloc Rt:22 Rn:10 Rt2:01111 imm7:0010100 L:0 1011000:1011000 opc:10
	.inst 0x0ac237b2 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:18 Rn:29 imm6:001101 Rm:2 N:0 shift:11 01010:01010 opc:00 sf:0
	.inst 0xc2dec008 // CVT-R.CC-C Rd:8 Cn:0 110000:110000 Cm:30 11000010110:11000010110
	.inst 0xc2c0b3e8 // GCSEAL-R.C-C Rd:8 Cn:31 100:100 opc:101 1100001011000000:1100001011000000
	.inst 0xc2c21220
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x22, cptr_el3
	orr x22, x22, #0x200
	msr cptr_el3, x22
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
	ldr x22, =initial_cap_values
	.inst 0xc24002c0 // ldr c0, [x22, #0]
	.inst 0xc24006c1 // ldr c1, [x22, #1]
	.inst 0xc2400ac2 // ldr c2, [x22, #2]
	.inst 0xc2400ec8 // ldr c8, [x22, #3]
	.inst 0xc24012ca // ldr c10, [x22, #4]
	.inst 0xc24016d2 // ldr c18, [x22, #5]
	.inst 0xc2401ad7 // ldr c23, [x22, #6]
	/* Vector registers */
	mrs x22, cptr_el3
	bfc x22, #10, #1
	msr cptr_el3, x22
	isb
	ldr q15, =0x0
	ldr q22, =0x0
	/* Set up flags and system registers */
	mov x22, #0x00000000
	msr nzcv, x22
	ldr x22, =initial_csp_value
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0xc2c1d2df // cpy c31, c22
	ldr x22, =0x200
	msr CPTR_EL3, x22
	ldr x22, =0x30850032
	msr SCTLR_EL3, x22
	ldr x22, =0x0
	msr S3_6_C1_C2_2, x22 // CCTLR_EL3
	isb
	/* Start test */
	ldr x17, =pcc_return_ddc_capabilities
	.inst 0xc2400231 // ldr c17, [x17, #0]
	.inst 0x82603236 // ldr c22, [c17, #3]
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	.inst 0x82601236 // ldr c22, [c17, #1]
	.inst 0x82602231 // ldr c17, [c17, #2]
	.inst 0xc2c212c0 // br c22
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
	isb
	/* Check processor flags */
	mrs x22, nzcv
	ubfx x22, x22, #28, #4
	mov x17, #0xf
	and x22, x22, x17
	cmp x22, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x22, =final_cap_values
	.inst 0xc24002d1 // ldr c17, [x22, #0]
	.inst 0xc2d1a401 // chkeq c0, c17
	b.ne comparison_fail
	.inst 0xc24006d1 // ldr c17, [x22, #1]
	.inst 0xc2d1a421 // chkeq c1, c17
	b.ne comparison_fail
	.inst 0xc2400ad1 // ldr c17, [x22, #2]
	.inst 0xc2d1a441 // chkeq c2, c17
	b.ne comparison_fail
	.inst 0xc2400ed1 // ldr c17, [x22, #3]
	.inst 0xc2d1a501 // chkeq c8, c17
	b.ne comparison_fail
	.inst 0xc24012d1 // ldr c17, [x22, #4]
	.inst 0xc2d1a541 // chkeq c10, c17
	b.ne comparison_fail
	.inst 0xc24016d1 // ldr c17, [x22, #5]
	.inst 0xc2d1a601 // chkeq c16, c17
	b.ne comparison_fail
	.inst 0xc2401ad1 // ldr c17, [x22, #6]
	.inst 0xc2d1a641 // chkeq c18, c17
	b.ne comparison_fail
	.inst 0xc2401ed1 // ldr c17, [x22, #7]
	.inst 0xc2d1a6a1 // chkeq c21, c17
	b.ne comparison_fail
	.inst 0xc24022d1 // ldr c17, [x22, #8]
	.inst 0xc2d1a6e1 // chkeq c23, c17
	b.ne comparison_fail
	/* Check vector registers */
	ldr x22, =0x0
	mov x17, v15.d[0]
	cmp x22, x17
	b.ne comparison_fail
	ldr x22, =0x0
	mov x17, v15.d[1]
	cmp x22, x17
	b.ne comparison_fail
	ldr x22, =0x0
	mov x17, v22.d[0]
	cmp x22, x17
	b.ne comparison_fail
	ldr x22, =0x0
	mov x17, v22.d[1]
	cmp x22, x17
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001040
	ldr x1, =check_data0
	ldr x2, =0x00001048
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001050
	ldr x1, =check_data1
	ldr x2, =0x00001070
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
	.inst 0xc2c5b016 // cvtp c22, x0
	.inst 0xc2df42d6 // scvalue c22, c22, x31
	.inst 0xc28b4136 // msr ddc_el3, c22
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
