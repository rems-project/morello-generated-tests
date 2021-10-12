.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 32
.data
check_data1:
	.zero 2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 1
.data
check_data4:
	.byte 0xa0, 0x2f, 0x78, 0x62, 0xa2, 0xba, 0x46, 0xc2, 0xfa, 0x93, 0xb9, 0xb0, 0xe1, 0x33, 0xc2, 0xc2
	.byte 0xd8, 0x6b, 0x2f, 0x78, 0xa3, 0x68, 0xc2, 0xc2, 0x22, 0xba, 0xc9, 0xc2, 0x22, 0xfc, 0x9f, 0x08
	.byte 0x5f, 0x3c, 0x03, 0xd5, 0xe0, 0x73, 0xc2, 0xc2, 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x40000000000100050000000000001ffe
	/* C5 */
	.octa 0x0
	/* C15 */
	.octa 0xff00000000003040
	/* C17 */
	.octa 0x1000500020000000000000000
	/* C21 */
	.octa 0x8000000000010005fffffffffffff700
	/* C24 */
	.octa 0x0
	/* C29 */
	.octa 0x80100000400000010000000000001100
	/* C30 */
	.octa 0x400000001007000700ffffffffffe000
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x40000000000100050000000000001ffe
	/* C2 */
	.octa 0x1401300000000000000000000
	/* C3 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C15 */
	.octa 0xff00000000003040
	/* C17 */
	.octa 0x1000500020000000000000000
	/* C21 */
	.octa 0x8000000000010005fffffffffffff700
	/* C24 */
	.octa 0x0
	/* C26 */
	.octa 0x2000800000000000000000007367d000
	/* C29 */
	.octa 0x80100000400000010000000000001100
	/* C30 */
	.octa 0x400000001007000700ffffffffffe000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000000000000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 16
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword final_cap_values + 176
	.dword final_cap_values + 192
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x62782fa0 // LDNP-C.RIB-C Ct:0 Rn:29 Ct2:01011 imm7:1110000 L:1 011000100:011000100
	.inst 0xc246baa2 // LDR-C.RIB-C Ct:2 Rn:21 imm12:000110101110 L:1 110000100:110000100
	.inst 0xb0b993fa // ADRP-C.I-C Rd:26 immhi:011100110010011111 P:1 10000:10000 immlo:01 op:1
	.inst 0xc2c233e1 // CHKTGD-C-C 00001:00001 Cn:31 100:100 opc:01 11000010110000100:11000010110000100
	.inst 0x782f6bd8 // strh_reg:aarch64/instrs/memory/single/general/register Rt:24 Rn:30 10:10 S:0 option:011 Rm:15 1:1 opc:00 111000:111000 size:01
	.inst 0xc2c268a3 // ORRFLGS-C.CR-C Cd:3 Cn:5 1010:1010 opc:01 Rm:2 11000010110:11000010110
	.inst 0xc2c9ba22 // SCBNDS-C.CI-C Cd:2 Cn:17 1110:1110 S:0 imm6:010011 11000010110:11000010110
	.inst 0x089ffc22 // stlrb:aarch64/instrs/memory/ordered Rt:2 Rn:1 Rt2:11111 o0:1 Rs:11111 0:0 L:0 0010001:0010001 size:00
	.inst 0xd5033c5f // clrex:aarch64/instrs/system/monitors 01011111:01011111 CRm:1100 11010101000000110011:11010101000000110011
	.inst 0xc2c273e0 // BX-_-C 00000:00000 (1)(1)(1)(1)(1):11111 100:100 opc:11 11000010110000100:11000010110000100
	.inst 0xc2c21280
	.zero 1048532
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x16, cptr_el3
	orr x16, x16, #0x200
	msr cptr_el3, x16
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
	ldr x16, =initial_cap_values
	.inst 0xc2400201 // ldr c1, [x16, #0]
	.inst 0xc2400605 // ldr c5, [x16, #1]
	.inst 0xc2400a0f // ldr c15, [x16, #2]
	.inst 0xc2400e11 // ldr c17, [x16, #3]
	.inst 0xc2401215 // ldr c21, [x16, #4]
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2401a1d // ldr c29, [x16, #6]
	.inst 0xc2401e1e // ldr c30, [x16, #7]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =initial_SP_EL3_value
	.inst 0xc2400210 // ldr c16, [x16, #0]
	.inst 0xc2c1d21f // cpy c31, c16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850030
	msr SCTLR_EL3, x16
	isb
	/* Start test */
	ldr x20, =pcc_return_ddc_capabilities
	.inst 0xc2400294 // ldr c20, [x20, #0]
	.inst 0x82601290 // ldr c16, [c20, #1]
	.inst 0x82602294 // ldr c20, [c20, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* Check processor flags */
	mrs x16, nzcv
	ubfx x16, x16, #28, #4
	mov x20, #0xf
	and x16, x16, x20
	cmp x16, #0x0
	b.ne comparison_fail
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc2400214 // ldr c20, [x16, #0]
	.inst 0xc2d4a401 // chkeq c0, c20
	b.ne comparison_fail
	.inst 0xc2400614 // ldr c20, [x16, #1]
	.inst 0xc2d4a421 // chkeq c1, c20
	b.ne comparison_fail
	.inst 0xc2400a14 // ldr c20, [x16, #2]
	.inst 0xc2d4a441 // chkeq c2, c20
	b.ne comparison_fail
	.inst 0xc2400e14 // ldr c20, [x16, #3]
	.inst 0xc2d4a461 // chkeq c3, c20
	b.ne comparison_fail
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2d4a4a1 // chkeq c5, c20
	b.ne comparison_fail
	.inst 0xc2401614 // ldr c20, [x16, #5]
	.inst 0xc2d4a561 // chkeq c11, c20
	b.ne comparison_fail
	.inst 0xc2401a14 // ldr c20, [x16, #6]
	.inst 0xc2d4a5e1 // chkeq c15, c20
	b.ne comparison_fail
	.inst 0xc2401e14 // ldr c20, [x16, #7]
	.inst 0xc2d4a621 // chkeq c17, c20
	b.ne comparison_fail
	.inst 0xc2402214 // ldr c20, [x16, #8]
	.inst 0xc2d4a6a1 // chkeq c21, c20
	b.ne comparison_fail
	.inst 0xc2402614 // ldr c20, [x16, #9]
	.inst 0xc2d4a701 // chkeq c24, c20
	b.ne comparison_fail
	.inst 0xc2402a14 // ldr c20, [x16, #10]
	.inst 0xc2d4a741 // chkeq c26, c20
	b.ne comparison_fail
	.inst 0xc2402e14 // ldr c20, [x16, #11]
	.inst 0xc2d4a7a1 // chkeq c29, c20
	b.ne comparison_fail
	.inst 0xc2403214 // ldr c20, [x16, #12]
	.inst 0xc2d4a7c1 // chkeq c30, c20
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001020
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001040
	ldr x1, =check_data1
	ldr x2, =0x00001042
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x000011e0
	ldr x1, =check_data2
	ldr x2, =0x000011f0
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
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
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
