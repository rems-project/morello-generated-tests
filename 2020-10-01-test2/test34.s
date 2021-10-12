.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.zero 32
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0xf4, 0xf3, 0x57, 0xa2, 0xa6, 0x58, 0x21, 0xa2, 0xc2, 0x01, 0x13, 0x3a, 0x7f, 0xc0, 0xb0, 0x90
	.byte 0xfe, 0x28, 0x79, 0xad, 0xca, 0xd3, 0xc5, 0xc2, 0x45, 0x44, 0xd3, 0xc2, 0x21, 0x04, 0x01, 0xb9
	.byte 0xa5, 0x78, 0xa1, 0xf8, 0x28, 0x18, 0xf2, 0xc2, 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x341070000000000000f00
	/* C5 */
	.octa 0xffffffffffff2000
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1100
	/* C18 */
	.octa 0x10400000108000
	/* C19 */
	.octa 0xffffffffffffffff
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C1 */
	.octa 0x341070000000000000f00
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x1100
	/* C8 */
	.octa 0x341070010400000108000
	/* C10 */
	.octa 0x0
	/* C18 */
	.octa 0x10400000108000
	/* C19 */
	.octa 0xffffffffffffffff
	/* C20 */
	.octa 0x0
	/* C30 */
	.octa 0x0
initial_csp_value:
	.octa 0x2001
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000048700040000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xcc0000006000000400ffffffffffe000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword final_cap_values + 16
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xa257f3f4 // LDUR-C.RI-C Ct:20 Rn:31 00:00 imm9:101111111 0:0 opc:01 10100010:10100010
	.inst 0xa22158a6 // STR-C.RRB-C Ct:6 Rn:5 10:10 S:1 option:010 Rm:1 1:1 opc:00 10100010:10100010
	.inst 0x3a1301c2 // adcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:2 Rn:14 000000:000000 Rm:19 11010000:11010000 S:1 op:0 sf:0
	.inst 0x90b0c07f // ADRP-C.IP-C Rd:31 immhi:011000011000000011 P:1 10000:10000 immlo:00 op:1
	.inst 0xad7928fe // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:30 Rn:7 Rt2:01010 imm7:1110010 L:1 1011010:1011010 opc:10
	.inst 0xc2c5d3ca // CVTDZ-C.R-C Cd:10 Rn:30 100:100 opc:10 11000010110001011:11000010110001011
	.inst 0xc2d34445 // CSEAL-C.C-C Cd:5 Cn:2 001:001 opc:10 0:0 Cm:19 11000010110:11000010110
	.inst 0xb9010421 // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:1 Rn:1 imm12:000001000001 opc:00 111001:111001 size:10
	.inst 0xf8a178a5 // prfm_reg:aarch64/instrs/memory/single/general/register Rt:5 Rn:5 10:10 S:1 option:011 Rm:1 1:1 opc:10 111000:111000 size:11
	.inst 0xc2f21828 // CVT-C.CR-C Cd:8 Cn:1 0110:0110 0:0 0:0 Rm:18 11000010111:11000010111
	.inst 0xc2c211a0
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x4, cptr_el3
	orr x4, x4, #0x200
	msr cptr_el3, x4
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
	ldr x4, =initial_cap_values
	.inst 0xc2400081 // ldr c1, [x4, #0]
	.inst 0xc2400485 // ldr c5, [x4, #1]
	.inst 0xc2400886 // ldr c6, [x4, #2]
	.inst 0xc2400c87 // ldr c7, [x4, #3]
	.inst 0xc2401092 // ldr c18, [x4, #4]
	.inst 0xc2401493 // ldr c19, [x4, #5]
	.inst 0xc240189e // ldr c30, [x4, #6]
	/* Set up flags and system registers */
	mov x4, #0x00000000
	msr nzcv, x4
	ldr x4, =initial_csp_value
	.inst 0xc2400084 // ldr c4, [x4, #0]
	.inst 0xc2c1d09f // cpy c31, c4
	ldr x4, =0x200
	msr CPTR_EL3, x4
	ldr x4, =0x30850032
	msr SCTLR_EL3, x4
	ldr x4, =0x8
	msr S3_6_C1_C2_2, x4 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031a4 // ldr c4, [c13, #3]
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	.inst 0x826011a4 // ldr c4, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c21080 // br c4
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
	isb
	/* Check processor flags */
	mrs x4, nzcv
	ubfx x4, x4, #28, #4
	mov x13, #0xf
	and x4, x4, x13
	cmp x4, #0x1
	b.ne comparison_fail
	/* Check registers */
	ldr x4, =final_cap_values
	.inst 0xc240008d // ldr c13, [x4, #0]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc240048d // ldr c13, [x4, #1]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc240088d // ldr c13, [x4, #2]
	.inst 0xc2cda4e1 // chkeq c7, c13
	b.ne comparison_fail
	.inst 0xc2400c8d // ldr c13, [x4, #3]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc240108d // ldr c13, [x4, #4]
	.inst 0xc2cda541 // chkeq c10, c13
	b.ne comparison_fail
	.inst 0xc240148d // ldr c13, [x4, #5]
	.inst 0xc2cda641 // chkeq c18, c13
	b.ne comparison_fail
	.inst 0xc240188d // ldr c13, [x4, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401c8d // ldr c13, [x4, #7]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc240208d // ldr c13, [x4, #8]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check vector registers */
	ldr x4, =0x0
	mov x13, v10.d[0]
	cmp x4, x13
	b.ne comparison_fail
	ldr x4, =0x0
	mov x13, v10.d[1]
	cmp x4, x13
	b.ne comparison_fail
	ldr x4, =0x0
	mov x13, v30.d[0]
	cmp x4, x13
	b.ne comparison_fail
	ldr x4, =0x0
	mov x13, v30.d[1]
	cmp x4, x13
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
	ldr x0, =0x00001020
	ldr x1, =check_data1
	ldr x2, =0x00001040
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001f80
	ldr x1, =check_data2
	ldr x2, =0x00001f90
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
	.inst 0xc2c5b004 // cvtp c4, x0
	.inst 0xc2df4084 // scvalue c4, c4, x31
	.inst 0xc28b4124 // msr ddc_el3, c4
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
