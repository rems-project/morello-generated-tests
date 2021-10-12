.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 16
.data
check_data1:
	.byte 0x1f, 0xd3, 0x45, 0x82, 0x4e, 0x50, 0xc1, 0xc2, 0xe0, 0xc4, 0xd3, 0xc2
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 4
.data
check_data4:
	.byte 0x80, 0x11, 0xc2, 0xc2
.data
check_data5:
	.byte 0x3b, 0x18, 0x53, 0x8b, 0x0c, 0xaf, 0x56, 0xbd, 0xe3, 0x20, 0xeb, 0xc2, 0x36, 0x08, 0xd4, 0xc2
	.byte 0x02, 0x58, 0xe0, 0x78, 0x3d, 0x0a, 0xc0, 0xda, 0x3e, 0xcd, 0xc5, 0x34
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x2
	/* C1 */
	.octa 0x0
	/* C7 */
	.octa 0x20408002000300070000000000480000
	/* C19 */
	.octa 0x400002000000000000000000000000
	/* C20 */
	.octa 0x2000000300be0178000c00000000001
	/* C24 */
	.octa 0x40000000405401b80000000000001000
	/* C30 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x2
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x0
	/* C3 */
	.octa 0x20408002000300070000000000480000
	/* C7 */
	.octa 0x20408002000300070000000000480000
	/* C19 */
	.octa 0x400002000000000000000000000000
	/* C20 */
	.octa 0x2000000300be0178000c00000000001
	/* C22 */
	.octa 0x800000000000000000000000
	/* C24 */
	.octa 0x40000000405401b80000000000001000
	/* C27 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000001227060700000000003fe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x8245d31f // ASTR-C.RI-C Ct:31 Rn:24 op:00 imm9:001011101 L:0 1000001001:1000001001
	.inst 0xc2c1504e // CFHI-R.C-C Rd:14 Cn:2 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xc2d3c4e0 // RETS-C.C-C 00000:00000 Cn:7 001:001 opc:10 1:1 Cm:19 11000010110:11000010110
	.zero 47536
	.inst 0xc2c21180
	.zero 476736
	.inst 0x8b53183b // add_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:27 Rn:1 imm6:000110 Rm:19 0:0 shift:01 01011:01011 S:0 op:0 sf:1
	.inst 0xbd56af0c // ldr_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/unsigned Rt:12 Rn:24 imm12:010110101011 opc:01 111101:111101 size:10
	.inst 0xc2eb20e3 // BICFLGS-C.CI-C Cd:3 Cn:7 0:0 00:00 imm8:01011001 11000010111:11000010111
	.inst 0xc2d40836 // SEAL-C.CC-C Cd:22 Cn:1 0010:0010 opc:00 Cm:20 11000010110:11000010110
	.inst 0x78e05802 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:2 Rn:0 10:10 S:1 option:010 Rm:0 1:1 opc:11 111000:111000 size:01
	.inst 0xdac00a3d // rev32_int:aarch64/instrs/integer/arithmetic/rev Rd:29 Rn:17 opc:10 1011010110000000000:1011010110000000000 sf:1
	.inst 0x34c5cd3e // cbz:aarch64/instrs/branch/conditional/compare Rt:30 imm19:1100010111001101001 op:0 011010:011010 sf:0
	.zero 524260
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
	.inst 0xc2400200 // ldr c0, [x16, #0]
	.inst 0xc2400601 // ldr c1, [x16, #1]
	.inst 0xc2400a07 // ldr c7, [x16, #2]
	.inst 0xc2400e13 // ldr c19, [x16, #3]
	.inst 0xc2401214 // ldr c20, [x16, #4]
	.inst 0xc2401618 // ldr c24, [x16, #5]
	.inst 0xc2401a1e // ldr c30, [x16, #6]
	/* Set up flags and system registers */
	mov x16, #0x00000000
	msr nzcv, x16
	ldr x16, =0x200
	msr CPTR_EL3, x16
	ldr x16, =0x30850032
	msr SCTLR_EL3, x16
	ldr x16, =0x4
	msr S3_6_C1_C2_2, x16 // CCTLR_EL3
	isb
	/* Start test */
	ldr x12, =pcc_return_ddc_capabilities
	.inst 0xc240018c // ldr c12, [x12, #0]
	.inst 0x82603190 // ldr c16, [c12, #3]
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	.inst 0x82601190 // ldr c16, [c12, #1]
	.inst 0x8260218c // ldr c12, [c12, #2]
	.inst 0xc2c21200 // br c16
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b010 // cvtp c16, x0
	.inst 0xc2df4210 // scvalue c16, c16, x31
	.inst 0xc28b4130 // msr DDC_EL3, c16
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x16, =final_cap_values
	.inst 0xc240020c // ldr c12, [x16, #0]
	.inst 0xc2cca401 // chkeq c0, c12
	b.ne comparison_fail
	.inst 0xc240060c // ldr c12, [x16, #1]
	.inst 0xc2cca421 // chkeq c1, c12
	b.ne comparison_fail
	.inst 0xc2400a0c // ldr c12, [x16, #2]
	.inst 0xc2cca441 // chkeq c2, c12
	b.ne comparison_fail
	.inst 0xc2400e0c // ldr c12, [x16, #3]
	.inst 0xc2cca461 // chkeq c3, c12
	b.ne comparison_fail
	.inst 0xc240120c // ldr c12, [x16, #4]
	.inst 0xc2cca4e1 // chkeq c7, c12
	b.ne comparison_fail
	.inst 0xc240160c // ldr c12, [x16, #5]
	.inst 0xc2cca661 // chkeq c19, c12
	b.ne comparison_fail
	.inst 0xc2401a0c // ldr c12, [x16, #6]
	.inst 0xc2cca681 // chkeq c20, c12
	b.ne comparison_fail
	.inst 0xc2401e0c // ldr c12, [x16, #7]
	.inst 0xc2cca6c1 // chkeq c22, c12
	b.ne comparison_fail
	.inst 0xc240220c // ldr c12, [x16, #8]
	.inst 0xc2cca701 // chkeq c24, c12
	b.ne comparison_fail
	.inst 0xc240260c // ldr c12, [x16, #9]
	.inst 0xc2cca761 // chkeq c27, c12
	b.ne comparison_fail
	.inst 0xc2402a0c // ldr c12, [x16, #10]
	.inst 0xc2cca7c1 // chkeq c30, c12
	b.ne comparison_fail
	/* Check vector registers */
	ldr x16, =0x0
	mov x12, v12.d[0]
	cmp x16, x12
	b.ne comparison_fail
	ldr x16, =0x0
	mov x12, v12.d[1]
	cmp x16, x12
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000015d0
	ldr x1, =check_data0
	ldr x2, =0x000015e0
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x0040000c
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400606
	ldr x1, =check_data2
	ldr x2, =0x00400608
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00402cac
	ldr x1, =check_data3
	ldr x2, =0x00402cb0
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x0040b9bc
	ldr x1, =check_data4
	ldr x2, =0x0040b9c0
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00480000
	ldr x1, =check_data5
	ldr x2, =0x0048001c
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
