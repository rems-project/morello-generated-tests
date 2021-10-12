.section data0, #alloc, #write
	.byte 0x80, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x90, 0x00, 0x80, 0x00, 0x28
	.zero 3984
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xa2, 0x00, 0x00, 0x00, 0x00
	.zero 80
.data
check_data0:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 16
.data
check_data3:
	.byte 0x80, 0xa2
.data
check_data4:
	.zero 2
.data
check_data5:
	.byte 0x81, 0x9c, 0x99, 0x78, 0x3f, 0x10, 0x1e, 0xc2, 0xe9, 0x33, 0x71, 0x82, 0xec, 0x88, 0x73, 0x37
.data
check_data6:
	.byte 0xbd, 0x02, 0x56, 0x50, 0x41, 0xbc, 0x45, 0xe2, 0xbf, 0x41, 0x9d, 0x78, 0xda, 0xcb, 0xe1, 0x82
	.byte 0x05, 0xfc, 0xb4, 0xa2, 0xc0, 0x11, 0xc2, 0xc2
.data
check_data7:
	.zero 8
.data
check_data8:
	.byte 0x80, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x1000
	/* C2 */
	.octa 0x800000005ae100010000000000001a73
	/* C4 */
	.octa 0x2011
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C12 */
	.octa 0x4000
	/* C13 */
	.octa 0x2010
	/* C20 */
	.octa 0x28008000900200000000000000400080
	/* C30 */
	.octa 0x8000000018079a070000000000401728
final_cap_values:
	/* C0 */
	.octa 0x1000
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000005ae100010000000000001a73
	/* C4 */
	.octa 0x1faa
	/* C5 */
	.octa 0x4000000000000000000000000000
	/* C9 */
	.octa 0x0
	/* C12 */
	.octa 0x4000
	/* C13 */
	.octa 0x2010
	/* C20 */
	.octa 0x28008000900200000000000000400080
	/* C29 */
	.octa 0x4ac0d6
	/* C30 */
	.octa 0x8000000018079a070000000000401728
initial_SP_EL3_value:
	.octa 0x901000006804000200000000000006e0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000320700070000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd800000048020ff20000000000000000
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001000
	.dword 0x0000000000001810
	.dword initial_cap_values + 16
	.dword initial_cap_values + 48
	.dword initial_cap_values + 96
	.dword initial_cap_values + 112
	.dword final_cap_values + 32
	.dword final_cap_values + 64
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword final_cap_values + 160
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78999c81 // ldrsh_imm:aarch64/instrs/memory/single/general/immediate/signed/pre-idx Rt:1 Rn:4 11:11 imm9:110011001 0:0 opc:10 111000:111000 size:01
	.inst 0xc21e103f // STR-C.RIB-C Ct:31 Rn:1 imm12:011110000100 L:0 110000100:110000100
	.inst 0x827133e9 // ALDR-C.RI-C Ct:9 Rn:31 op:00 imm9:100010011 L:1 1000001001:1000001001
	.inst 0x377388ec // tbnz:aarch64/instrs/branch/conditional/test Rt:12 imm14:01110001000111 b40:01110 op:1 011011:011011 b5:0
	.zero 112
	.inst 0x505602bd // ADR-C.I-C Rd:29 immhi:101011000000010101 P:0 10000:10000 immlo:10 op:0
	.inst 0xe245bc41 // ALDURSH-R.RI-32 Rt:1 Rn:2 op2:11 imm9:001011011 V:0 op1:01 11100010:11100010
	.inst 0x789d41bf // ldursh:aarch64/instrs/memory/single/general/immediate/signed/offset/normal Rt:31 Rn:13 00:00 imm9:111010100 0:0 opc:10 111000:111000 size:01
	.inst 0x82e1cbda // ALDR-V.RRB-D Rt:26 Rn:30 opc:10 S:0 option:110 Rm:1 1:1 L:1 100000101:100000101
	.inst 0xa2b4fc05 // CASL-C.R-C Ct:5 Rn:0 11111:11111 R:1 Cs:20 1:1 L:0 1:1 10100010:10100010
	.inst 0xc2c211c0
	.zero 28816
	.inst 0xc2c21280 // BR-C-C 00000:00000 Cn:20 100:100 opc:00 11000010110000100:11000010110000100
	.zero 1019604
.text
.global preamble
preamble:
	/* Ensure Morello is on */
	mov x0, 0x200
	msr cptr_el3, x0
	isb
	/* Set exception handler */
	ldr x0, =vector_table
	.inst 0xc2c5b001 // cvtp c1, x0
	.inst 0xc2c04021 // scvalue c1, c1, x0
	.inst 0xc28ec001 // msr CVBAR_EL3, c1
	isb
	/* Set up translation */
	ldr x0, =tt_l1_base
	msr ttbr0_el3, x0
	mov x0, #0xff
	msr mair_el3, x0
	ldr x0, =0x0d001519
	msr tcr_el3, x0
	isb
	tlbi alle3
	dsb sy
	isb
	/* Write tags to memory */
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
	ldr x7, =initial_cap_values
	.inst 0xc24000e0 // ldr c0, [x7, #0]
	.inst 0xc24004e2 // ldr c2, [x7, #1]
	.inst 0xc24008e4 // ldr c4, [x7, #2]
	.inst 0xc2400ce5 // ldr c5, [x7, #3]
	.inst 0xc24010ec // ldr c12, [x7, #4]
	.inst 0xc24014ed // ldr c13, [x7, #5]
	.inst 0xc24018f4 // ldr c20, [x7, #6]
	.inst 0xc2401cfe // ldr c30, [x7, #7]
	/* Set up flags and system registers */
	mov x7, #0x00000000
	msr nzcv, x7
	ldr x7, =initial_SP_EL3_value
	.inst 0xc24000e7 // ldr c7, [x7, #0]
	.inst 0xc2c1d0ff // cpy c31, c7
	ldr x7, =0x200
	msr CPTR_EL3, x7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	ldr x7, =0x8
	msr S3_6_C1_C2_2, x7 // CCTLR_EL3
	isb
	/* Start test */
	ldr x14, =pcc_return_ddc_capabilities
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0x826031c7 // ldr c7, [c14, #3]
	.inst 0xc28b4127 // msr DDC_EL3, c7
	isb
	.inst 0x826011c7 // ldr c7, [c14, #1]
	.inst 0x826021ce // ldr c14, [c14, #2]
	.inst 0xc2c210e0 // br c7
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30851035
	msr SCTLR_EL3, x7
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x7, =final_cap_values
	.inst 0xc24000ee // ldr c14, [x7, #0]
	.inst 0xc2cea401 // chkeq c0, c14
	b.ne comparison_fail
	.inst 0xc24004ee // ldr c14, [x7, #1]
	.inst 0xc2cea421 // chkeq c1, c14
	b.ne comparison_fail
	.inst 0xc24008ee // ldr c14, [x7, #2]
	.inst 0xc2cea441 // chkeq c2, c14
	b.ne comparison_fail
	.inst 0xc2400cee // ldr c14, [x7, #3]
	.inst 0xc2cea481 // chkeq c4, c14
	b.ne comparison_fail
	.inst 0xc24010ee // ldr c14, [x7, #4]
	.inst 0xc2cea4a1 // chkeq c5, c14
	b.ne comparison_fail
	.inst 0xc24014ee // ldr c14, [x7, #5]
	.inst 0xc2cea521 // chkeq c9, c14
	b.ne comparison_fail
	.inst 0xc24018ee // ldr c14, [x7, #6]
	.inst 0xc2cea581 // chkeq c12, c14
	b.ne comparison_fail
	.inst 0xc2401cee // ldr c14, [x7, #7]
	.inst 0xc2cea5a1 // chkeq c13, c14
	b.ne comparison_fail
	.inst 0xc24020ee // ldr c14, [x7, #8]
	.inst 0xc2cea681 // chkeq c20, c14
	b.ne comparison_fail
	.inst 0xc24024ee // ldr c14, [x7, #9]
	.inst 0xc2cea7a1 // chkeq c29, c14
	b.ne comparison_fail
	.inst 0xc24028ee // ldr c14, [x7, #10]
	.inst 0xc2cea7c1 // chkeq c30, c14
	b.ne comparison_fail
	/* Check vector registers */
	ldr x7, =0x0
	mov x14, v26.d[0]
	cmp x7, x14
	b.ne comparison_fail
	ldr x7, =0x0
	mov x14, v26.d[1]
	cmp x7, x14
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
	ldr x0, =0x00001810
	ldr x1, =check_data1
	ldr x2, =0x00001820
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ac0
	ldr x1, =check_data2
	ldr x2, =0x00001ad0
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001faa
	ldr x1, =check_data3
	ldr x2, =0x00001fac
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x00001fe4
	ldr x1, =check_data4
	ldr x2, =0x00001fe6
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x00400000
	ldr x1, =check_data5
	ldr x2, =0x00400010
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
	ldr x0, =0x00400080
	ldr x1, =check_data6
	ldr x2, =0x00400098
check_data_loop6:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop6
	ldr x0, =0x00401728
	ldr x1, =check_data7
	ldr x2, =0x00401730
check_data_loop7:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop7
	ldr x0, =0x00407128
	ldr x1, =check_data8
	ldr x2, =0x0040712c
check_data_loop8:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop8
	/* Done print message */
	/* turn off MMU */
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b007 // cvtp c7, x0
	.inst 0xc2df40e7 // scvalue c7, c7, x31
	.inst 0xc28b4127 // msr DDC_EL3, c7
	ldr x7, =0x30850030
	msr SCTLR_EL3, x7
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

.section vector_table, #alloc, #execinstr
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

	/* Translation table, single entry, capabilities allowed */
.section text_tt, #alloc, #execinstr
	.align 12
	.global tt_l1_base
tt_l1_base:
	.dword 0x3000000000000701
	.fill 4088, 1, 0
