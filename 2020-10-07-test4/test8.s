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
	.zero 1
.data
check_data3:
	.byte 0x40, 0x6a, 0xe6, 0x78, 0x22, 0x4c, 0xcd, 0xd0, 0xa8, 0xce, 0x4b, 0xa2, 0xc1, 0xeb, 0xbe, 0x38
	.byte 0x3f, 0xec, 0xa1, 0x9b, 0x0b, 0x14, 0x56, 0x82, 0x46, 0xb0, 0x01, 0xab, 0xe0, 0x17, 0x74, 0x82
	.byte 0xf0, 0x6b, 0xd6, 0xc2, 0x53, 0x10, 0xc1, 0xc2, 0xa0, 0x10, 0xc2, 0xc2
.data
check_data4:
	.byte 0x9d, 0x1e
.data
check_data5:
	.zero 16
.data
.balign 16
initial_cap_values:
	/* C6 */
	.octa 0x2020
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000602420040000000000400000
	/* C21 */
	.octa 0x80100000000720050000000000408000
	/* C30 */
	.octa 0x80000000000100050000000000000801
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x2000800000050007ffffffff9ad86000
	/* C6 */
	.octa 0xffffffff9ad86000
	/* C8 */
	.octa 0x0
	/* C11 */
	.octa 0x0
	/* C18 */
	.octa 0x80000000602420040000000000400000
	/* C19 */
	.octa 0xffffffff40000000
	/* C21 */
	.octa 0x80100000000720050000000000408bc0
	/* C30 */
	.octa 0x80000000000100050000000000000801
initial_SP_EL3_value:
	.octa 0x1eb0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000500070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 32
	.dword initial_cap_values + 48
	.dword initial_cap_values + 64
	.dword final_cap_values + 96
	.dword final_cap_values + 128
	.dword final_cap_values + 144
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78e66a40 // ldrsh_reg:aarch64/instrs/memory/single/general/register Rt:0 Rn:18 10:10 S:0 option:011 Rm:6 1:1 opc:11 111000:111000 size:01
	.inst 0xd0cd4c22 // ADRP-C.IP-C Rd:2 immhi:100110101001100001 P:1 10000:10000 immlo:10 op:1
	.inst 0xa24bcea8 // LDR-C.RIBW-C Ct:8 Rn:21 11:11 imm9:010111100 0:0 opc:01 10100010:10100010
	.inst 0x38beebc1 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:1 Rn:30 10:10 S:0 option:111 Rm:30 1:1 opc:10 111000:111000 size:00
	.inst 0x9ba1ec3f // umsubl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:31 Rn:1 Ra:27 o0:1 Rm:1 01:01 U:1 10011011:10011011
	.inst 0x8256140b // ASTRB-R.RI-B Rt:11 Rn:0 op:01 imm9:101100001 L:0 1000001001:1000001001
	.inst 0xab01b046 // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:6 Rn:2 imm6:101100 Rm:1 0:0 shift:00 01011:01011 S:1 op:0 sf:1
	.inst 0x827417e0 // ALDRB-R.RI-B Rt:0 Rn:31 op:01 imm9:101000001 L:1 1000001001:1000001001
	.inst 0xc2d66bf0 // ORRFLGS-C.CR-C Cd:16 Cn:31 1010:1010 opc:01 Rm:22 11000010110:11000010110
	.inst 0xc2c11053 // GCLIM-R.C-C Rd:19 Cn:2 100:100 opc:00 11000010110000010:11000010110000010
	.inst 0xc2c210a0
	.zero 8180
	.inst 0x00001e9d
	.zero 1040348
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x9, cptr_el3
	orr x9, x9, #0x200
	msr cptr_el3, x9
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
	ldr x9, =initial_cap_values
	.inst 0xc2400126 // ldr c6, [x9, #0]
	.inst 0xc240052b // ldr c11, [x9, #1]
	.inst 0xc2400932 // ldr c18, [x9, #2]
	.inst 0xc2400d35 // ldr c21, [x9, #3]
	.inst 0xc240113e // ldr c30, [x9, #4]
	/* Set up flags and system registers */
	mov x9, #0x00000000
	msr nzcv, x9
	ldr x9, =initial_SP_EL3_value
	.inst 0xc2400129 // ldr c9, [x9, #0]
	.inst 0xc2c1d13f // cpy c31, c9
	ldr x9, =0x200
	msr CPTR_EL3, x9
	ldr x9, =0x3085003a
	msr SCTLR_EL3, x9
	ldr x9, =0x0
	msr S3_6_C1_C2_2, x9 // CCTLR_EL3
	isb
	/* Start test */
	ldr x5, =pcc_return_ddc_capabilities
	.inst 0xc24000a5 // ldr c5, [x5, #0]
	.inst 0x826030a9 // ldr c9, [c5, #3]
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	.inst 0x826010a9 // ldr c9, [c5, #1]
	.inst 0x826020a5 // ldr c5, [c5, #2]
	.inst 0xc2c21120 // br c9
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
	isb
	/* Check processor flags */
	mrs x9, nzcv
	ubfx x9, x9, #28, #4
	mov x5, #0xf
	and x9, x9, x5
	cmp x9, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x9, =final_cap_values
	.inst 0xc2400125 // ldr c5, [x9, #0]
	.inst 0xc2c5a401 // chkeq c0, c5
	b.ne comparison_fail
	.inst 0xc2400525 // ldr c5, [x9, #1]
	.inst 0xc2c5a421 // chkeq c1, c5
	b.ne comparison_fail
	.inst 0xc2400925 // ldr c5, [x9, #2]
	.inst 0xc2c5a441 // chkeq c2, c5
	b.ne comparison_fail
	.inst 0xc2400d25 // ldr c5, [x9, #3]
	.inst 0xc2c5a4c1 // chkeq c6, c5
	b.ne comparison_fail
	.inst 0xc2401125 // ldr c5, [x9, #4]
	.inst 0xc2c5a501 // chkeq c8, c5
	b.ne comparison_fail
	.inst 0xc2401525 // ldr c5, [x9, #5]
	.inst 0xc2c5a561 // chkeq c11, c5
	b.ne comparison_fail
	.inst 0xc2401925 // ldr c5, [x9, #6]
	.inst 0xc2c5a641 // chkeq c18, c5
	b.ne comparison_fail
	.inst 0xc2401d25 // ldr c5, [x9, #7]
	.inst 0xc2c5a661 // chkeq c19, c5
	b.ne comparison_fail
	.inst 0xc2402125 // ldr c5, [x9, #8]
	.inst 0xc2c5a6a1 // chkeq c21, c5
	b.ne comparison_fail
	.inst 0xc2402525 // ldr c5, [x9, #9]
	.inst 0xc2c5a7c1 // chkeq c30, c5
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001002
	ldr x1, =check_data0
	ldr x2, =0x00001003
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001ff1
	ldr x1, =check_data1
	ldr x2, =0x00001ff2
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffe
	ldr x1, =check_data2
	ldr x2, =0x00001fff
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
	ldr x0, =0x00402020
	ldr x1, =check_data4
	ldr x2, =0x00402022
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00408bc0
	ldr x1, =check_data5
	ldr x2, =0x00408bd0
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
	.inst 0xc2c5b009 // cvtp c9, x0
	.inst 0xc2df4129 // scvalue c9, c9, x31
	.inst 0xc28b4129 // msr DDC_EL3, c9
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
