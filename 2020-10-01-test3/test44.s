.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x12, 0x6c, 0xcc, 0xe2, 0x21, 0x68, 0xc1, 0xc2, 0xc3, 0x0b, 0xc1, 0xc2, 0xbf, 0x6f, 0x93, 0x78
	.byte 0xc2, 0x87, 0x3f, 0x79, 0xff, 0x53, 0xc0, 0xc2, 0x60, 0x64, 0x74, 0x51, 0x20, 0x58, 0xd3, 0xc2
	.byte 0xff, 0x67, 0xdf, 0xc2, 0xf8, 0x53, 0xc1, 0xc2, 0xe0, 0x12, 0xc2, 0xc2
.data
check_data2:
	.zero 16
.data
check_data3:
	.zero 2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x3fffca
	/* C1 */
	.octa 0x200000040015ebaffc0000000008000
	/* C2 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000001000700000000005000b8
	/* C30 */
	.octa 0x4000000000010005000000000000001e
final_cap_values:
	/* C0 */
	.octa 0x200000040015ebaffc0004000000000
	/* C1 */
	.octa 0x200000040015ebaffc0000000008000
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x4000000000010005000000000000001e
	/* C18 */
	.octa 0x0
	/* C29 */
	.octa 0x800000000001000700000000004fffee
	/* C30 */
	.octa 0x4000000000010005000000000000001e
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000e40070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000000500070000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 16
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe2cc6c12 // ALDUR-C.RI-C Ct:18 Rn:0 op2:11 imm9:011000110 V:0 op1:11 11100010:11100010
	.inst 0xc2c16821 // ORRFLGS-C.CR-C Cd:1 Cn:1 1010:1010 opc:01 Rm:1 11000010110:11000010110
	.inst 0xc2c10bc3 // SEAL-C.CC-C Cd:3 Cn:30 0010:0010 opc:00 Cm:1 11000010110:11000010110
	.inst 0x78936fbf // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:31 Rn:29 11:11 imm9:100110110 0:0 opc:10 111000:111000 size:01
	.inst 0x793f87c2 // strh_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:2 Rn:30 imm12:111111100001 opc:00 111001:111001 size:01
	.inst 0xc2c053ff // GCVALUE-R.C-C Rd:31 Cn:31 100:100 opc:010 1100001011000000:1100001011000000
	.inst 0x51746460 // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:0 Rn:3 imm12:110100011001 sh:1 0:0 10001:10001 S:0 op:1 sf:0
	.inst 0xc2d35820 // ALIGNU-C.CI-C Cd:0 Cn:1 0110:0110 U:1 imm6:100110 11000010110:11000010110
	.inst 0xc2df67ff // CPYVALUE-C.C-C Cd:31 Cn:31 001:001 opc:11 0:0 Cm:31 11000010110:11000010110
	.inst 0xc2c153f8 // CFHI-R.C-C Rd:24 Cn:31 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2c212e0
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
	.inst 0xc2400561 // ldr c1, [x11, #1]
	.inst 0xc2400962 // ldr c2, [x11, #2]
	.inst 0xc2400d7d // ldr c29, [x11, #3]
	.inst 0xc240117e // ldr c30, [x11, #4]
	/* Set up flags and system registers */
	mov x11, #0x00000000
	msr nzcv, x11
	ldr x11, =0x200
	msr CPTR_EL3, x11
	ldr x11, =0x30850030
	msr SCTLR_EL3, x11
	ldr x11, =0x0
	msr S3_6_C1_C2_2, x11 // CCTLR_EL3
	isb
	/* Start test */
	ldr x23, =pcc_return_ddc_capabilities
	.inst 0xc24002f7 // ldr c23, [x23, #0]
	.inst 0x826032eb // ldr c11, [c23, #3]
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	.inst 0x826012eb // ldr c11, [c23, #1]
	.inst 0x826022f7 // ldr c23, [c23, #2]
	.inst 0xc2c21160 // br c11
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b00b // cvtp c11, x0
	.inst 0xc2df416b // scvalue c11, c11, x31
	.inst 0xc28b412b // msr ddc_el3, c11
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x11, =final_cap_values
	.inst 0xc2400177 // ldr c23, [x11, #0]
	.inst 0xc2d7a401 // chkeq c0, c23
	b.ne comparison_fail
	.inst 0xc2400577 // ldr c23, [x11, #1]
	.inst 0xc2d7a421 // chkeq c1, c23
	b.ne comparison_fail
	.inst 0xc2400977 // ldr c23, [x11, #2]
	.inst 0xc2d7a441 // chkeq c2, c23
	b.ne comparison_fail
	.inst 0xc2400d77 // ldr c23, [x11, #3]
	.inst 0xc2d7a461 // chkeq c3, c23
	b.ne comparison_fail
	.inst 0xc2401177 // ldr c23, [x11, #4]
	.inst 0xc2d7a641 // chkeq c18, c23
	b.ne comparison_fail
	.inst 0xc2401577 // ldr c23, [x11, #5]
	.inst 0xc2d7a7a1 // chkeq c29, c23
	b.ne comparison_fail
	.inst 0xc2401977 // ldr c23, [x11, #6]
	.inst 0xc2d7a7c1 // chkeq c30, c23
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001fe0
	ldr x1, =check_data0
	ldr x2, =0x00001fe2
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
	ldr x0, =0x00400090
	ldr x1, =check_data2
	ldr x2, =0x004000a0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fffee
	ldr x1, =check_data3
	ldr x2, =0x004ffff0
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
