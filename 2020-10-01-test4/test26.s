.section data0, #alloc, #write
	.zero 112
	.byte 0xe2, 0xe2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3856
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe2, 0xe2, 0xe2, 0xe2
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe2, 0xe2, 0x00, 0x00, 0x00, 0x00
	.zero 32
	.byte 0x00, 0x00, 0x00, 0x00, 0xe2, 0xe2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data0:
	.byte 0xe2, 0xe2
.data
check_data1:
	.byte 0xe2, 0xe2, 0xe2, 0xe2
.data
check_data2:
	.byte 0xe2, 0xe2
.data
check_data3:
	.byte 0xe2, 0xe2
.data
check_data4:
	.byte 0x3e, 0xf9, 0x55, 0xe2, 0x42, 0x26, 0xc1, 0x1a, 0x94, 0xf1, 0xc0, 0xc2, 0x0d, 0x34, 0x8d, 0xab
	.byte 0x20, 0x69, 0x80, 0x82, 0x02, 0xda, 0xcf, 0x69, 0xe2, 0x17, 0xc0, 0x5a, 0x2f, 0xc4, 0x99, 0xe2
	.byte 0x61, 0xb7, 0x7e, 0xe2, 0xfe, 0x59, 0x81, 0xf9, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.byte 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2, 0xe2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0xffffffffffffff89
	/* C1 */
	.octa 0x2000
	/* C9 */
	.octa 0x206b
	/* C16 */
	.octa 0x800000006001e00200000000004011c8
	/* C27 */
	.octa 0x1085
final_cap_values:
	/* C0 */
	.octa 0xffffffffffffe2e2
	/* C1 */
	.octa 0x2000
	/* C2 */
	.octa 0x1f
	/* C9 */
	.octa 0x206b
	/* C15 */
	.octa 0xe2e2e2e2
	/* C16 */
	.octa 0x800000006001e0020000000000401244
	/* C22 */
	.octa 0xffffffffe2e2e2e2
	/* C27 */
	.octa 0x1085
	/* C30 */
	.octa 0xffffffffffffe2e2
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000608070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x80000000040700050000000000006001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 48
	.dword final_cap_values + 80
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xe255f93e // ALDURSH-R.RI-64 Rt:30 Rn:9 op2:10 imm9:101011111 V:0 op1:01 11100010:11100010
	.inst 0x1ac12642 // lsrv:aarch64/instrs/integer/shift/variable Rd:2 Rn:18 op2:01 0010:0010 Rm:1 0011010110:0011010110 sf:0
	.inst 0xc2c0f194 // GCTYPE-R.C-C Rd:20 Cn:12 100:100 opc:111 1100001011000000:1100001011000000
	.inst 0xab8d340d // adds_addsub_shift:aarch64/instrs/integer/arithmetic/add-sub/shiftedreg Rd:13 Rn:0 imm6:001101 Rm:13 0:0 shift:10 01011:01011 S:1 op:0 sf:1
	.inst 0x82806920 // ALDRSH-R.RRB-64 Rt:0 Rn:9 opc:10 S:0 option:011 Rm:0 0:0 L:0 100000101:100000101
	.inst 0x69cfda02 // ldpsw:aarch64/instrs/memory/pair/general/pre-idx Rt:2 Rn:16 Rt2:10110 imm7:0011111 L:1 1010011:1010011 opc:01
	.inst 0x5ac017e2 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:2 Rn:31 op:1 10110101100000000010:10110101100000000010 sf:0
	.inst 0xe299c42f // ALDUR-R.RI-32 Rt:15 Rn:1 op2:01 imm9:110011100 V:0 op1:10 11100010:11100010
	.inst 0xe27eb761 // ALDUR-V.RI-H Rt:1 Rn:27 op2:01 imm9:111101011 V:1 op1:01 11100010:11100010
	.inst 0xf98159fe // prfm_imm:aarch64/instrs/memory/single/general/immediate/unsigned Rt:30 Rn:15 imm12:000001010110 opc:10 111001:111001 size:11
	.inst 0xc2c211c0
	.zero 4632
	.inst 0xe2e2e2e2
	.inst 0xe2e2e2e2
	.zero 1043892
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x6, cptr_el3
	orr x6, x6, #0x200
	msr cptr_el3, x6
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
	ldr x6, =initial_cap_values
	.inst 0xc24000c0 // ldr c0, [x6, #0]
	.inst 0xc24004c1 // ldr c1, [x6, #1]
	.inst 0xc24008c9 // ldr c9, [x6, #2]
	.inst 0xc2400cd0 // ldr c16, [x6, #3]
	.inst 0xc24010db // ldr c27, [x6, #4]
	/* Set up flags and system registers */
	mov x6, #0x00000000
	msr nzcv, x6
	ldr x6, =0x200
	msr CPTR_EL3, x6
	ldr x6, =0x30850030
	msr SCTLR_EL3, x6
	ldr x6, =0x4
	msr S3_6_C1_C2_2, x6 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c6 // ldr c6, [c14, #3]
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	.inst 0x826011c6 // ldr c6, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210c0 // br c6
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x6, =final_cap_values
	.inst 0xc24000ce // ldr c14, [x6, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ce // ldr c14, [x6, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24008ce // ldr c14, [x6, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400cce // ldr c14, [x6, #3]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24010ce // ldr c14, [x6, #4]
	.inst 0xc2cea5e1 // chkeq c15, c14
	b.ne comparison_fail
	.inst 0xc24014ce // ldr c14, [x6, #5]
	.inst 0xc2cea601 // chkeq c16, c14
	b.ne comparison_fail
	.inst 0xc24018ce // ldr c14, [x6, #6]
	.inst 0xc2cea6c1 // chkeq c22, c14
	b.ne comparison_fail
	.inst 0xc2401cce // ldr c14, [x6, #7]
	.inst 0xc2cea761 // chkeq c27, c14
	b.ne comparison_fail
	.inst 0xc24020ce // ldr c14, [x6, #8]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x6, =0xe2e2
	mov x14, v1.d[0]
	cmp x6, x14
	b.ne comparison_fail
	ldr x6, =0x0
	mov x14, v1.d[1]
	cmp x6, x14
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001070
	ldr x1, =check_data0
	ldr x2, =0x00001072
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001f9c
	ldr x1, =check_data1
	ldr x2, =0x00001fa0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001fca
	ldr x1, =check_data2
	ldr x2, =0x00001fcc
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001ff4
	ldr x1, =check_data3
	ldr x2, =0x00001ff6
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
	ldr x0, =0x00401244
	ldr x1, =check_data5
	ldr x2, =0x0040124c
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
	.inst 0xc2c5b006 // cvtp c6, x0
	.inst 0xc2df40c6 // scvalue c6, c6, x31
	.inst 0xc28b4126 // msr ddc_el3, c6
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
