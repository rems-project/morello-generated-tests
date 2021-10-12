.section data0, #alloc, #write
	.zero 2064
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 144
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1856
.data
check_data0:
	.byte 0xb8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 1
.data
check_data1:
	.byte 0x20, 0x00, 0x00, 0x00
.data
check_data2:
	.byte 0x5d, 0x8d, 0xdd, 0xc2, 0x60, 0xc4, 0xd5, 0xc2
.data
check_data3:
	.byte 0xbe, 0x73, 0x7f, 0x38, 0xd0, 0x0b, 0xd0, 0xc2, 0x81, 0x66, 0xd3, 0x8a, 0xc0, 0x82, 0x21, 0xa2
	.byte 0xbd, 0x2b, 0xde, 0x1a, 0x1d, 0x41, 0x2c, 0x38, 0x9f, 0x62, 0x7d, 0xb8, 0xa6, 0x7e, 0xc0, 0x9b
	.byte 0xa0, 0x11, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C3 */
	.octa 0x204080805009000000000000004007ec
	/* C8 */
	.octa 0x8
	/* C12 */
	.octa 0x80
	/* C19 */
	.octa 0xfffe01fffe01ffff
	/* C20 */
	.octa 0xb8
	/* C21 */
	.octa 0x400080000000000000000000000010
	/* C22 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x0
	/* C1 */
	.octa 0xb8
	/* C3 */
	.octa 0x204080805009000000000000004007ec
	/* C6 */
	.octa 0x0
	/* C8 */
	.octa 0x8
	/* C12 */
	.octa 0x80
	/* C19 */
	.octa 0xfffe01fffe01ffff
	/* C20 */
	.octa 0xb8
	/* C21 */
	.octa 0x400080000000000000000000000010
	/* C22 */
	.octa 0x0
	/* C29 */
	.octa 0x0
	/* C30 */
	.octa 0x1
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080000007c8470000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd0100000000700c200fffffffffc1001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001800
	.dword initial_cap_values + 0
	.dword initial_cap_values + 80
	.dword final_cap_values + 0
	.dword final_cap_values + 32
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2dd8d5d // CSEL-C.CI-C Cd:29 Cn:10 11:11 cond:1000 Cm:29 11000010110:11000010110
	.inst 0xc2d5c460 // RETS-C.C-C 00000:00000 Cn:3 001:001 opc:10 1:1 Cm:21 11000010110:11000010110
	.zero 2020
	.inst 0x387f73be // lduminb:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:29 00:00 opc:111 0:0 Rs:31 1:1 R:1 A:0 111000:111000 size:00
	.inst 0xc2d00bd0 // SEAL-C.CC-C Cd:16 Cn:30 0010:0010 opc:00 Cm:16 11000010110:11000010110
	.inst 0x8ad36681 // and_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:1 Rn:20 imm6:011001 Rm:19 N:0 shift:11 01010:01010 opc:00 sf:1
	.inst 0xa22182c0 // SWP-CC.R-C Ct:0 Rn:22 100000:100000 Cs:1 1:1 R:0 A:0 10100010:10100010
	.inst 0x1ade2bbd // asrv:aarch64/instrs/integer/shift/variable Rd:29 Rn:29 op2:10 0010:0010 Rm:30 0011010110:0011010110 sf:0
	.inst 0x382c411d // ldsmaxb:aarch64/instrs/memory/atomicops/ld Rt:29 Rn:8 00:00 opc:100 0:0 Rs:12 1:1 R:0 A:0 111000:111000 size:00
	.inst 0xb87d629f // stumax:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:20 00:00 opc:110 o3:0 Rs:29 1:1 R:1 A:0 00:00 V:0 111:111 size:10
	.inst 0x9bc07ea6 // umulh:aarch64/instrs/integer/arithmetic/mul/widening/64-128hi Rd:6 Rn:21 Ra:11111 0:0 Rm:0 10:10 U:1 10011011:10011011
	.inst 0xc2c211a0
	.zero 1046512
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
	ldr x14, =initial_cap_values
	.inst 0xc24001c3 // ldr c3, [x14, #0]
	.inst 0xc24005c8 // ldr c8, [x14, #1]
	.inst 0xc24009cc // ldr c12, [x14, #2]
	.inst 0xc2400dd3 // ldr c19, [x14, #3]
	.inst 0xc24011d4 // ldr c20, [x14, #4]
	.inst 0xc24015d5 // ldr c21, [x14, #5]
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	/* Set up flags and system registers */
	mov x14, #0x60000000
	msr nzcv, x14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x13, =pcc_return_ddc_capabilities
	.inst 0xc24001ad // ldr c13, [x13, #0]
	.inst 0x826031ae // ldr c14, [c13, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826011ae // ldr c14, [c13, #1]
	.inst 0x826021ad // ldr c13, [c13, #2]
	.inst 0xc2c211c0 // br c14
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30851035
	msr SCTLR_EL3, x14
	isb
	/* Check processor flags */
	mrs x14, nzcv
	ubfx x14, x14, #28, #4
	mov x13, #0x6
	and x14, x14, x13
	cmp x14, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001cd // ldr c13, [x14, #0]
	.inst 0xc2cda401 // chkeq c0, c13
	b.ne comparison_fail
	.inst 0xc24005cd // ldr c13, [x14, #1]
	.inst 0xc2cda421 // chkeq c1, c13
	b.ne comparison_fail
	.inst 0xc24009cd // ldr c13, [x14, #2]
	.inst 0xc2cda461 // chkeq c3, c13
	b.ne comparison_fail
	.inst 0xc2400dcd // ldr c13, [x14, #3]
	.inst 0xc2cda4c1 // chkeq c6, c13
	b.ne comparison_fail
	.inst 0xc24011cd // ldr c13, [x14, #4]
	.inst 0xc2cda501 // chkeq c8, c13
	b.ne comparison_fail
	.inst 0xc24015cd // ldr c13, [x14, #5]
	.inst 0xc2cda581 // chkeq c12, c13
	b.ne comparison_fail
	.inst 0xc24019cd // ldr c13, [x14, #6]
	.inst 0xc2cda661 // chkeq c19, c13
	b.ne comparison_fail
	.inst 0xc2401dcd // ldr c13, [x14, #7]
	.inst 0xc2cda681 // chkeq c20, c13
	b.ne comparison_fail
	.inst 0xc24021cd // ldr c13, [x14, #8]
	.inst 0xc2cda6a1 // chkeq c21, c13
	b.ne comparison_fail
	.inst 0xc24025cd // ldr c13, [x14, #9]
	.inst 0xc2cda6c1 // chkeq c22, c13
	b.ne comparison_fail
	.inst 0xc24029cd // ldr c13, [x14, #10]
	.inst 0xc2cda7a1 // chkeq c29, c13
	b.ne comparison_fail
	.inst 0xc2402dcd // ldr c13, [x14, #11]
	.inst 0xc2cda7c1 // chkeq c30, c13
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001800
	ldr x1, =check_data0
	ldr x2, =0x00001811
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x000018b8
	ldr x1, =check_data1
	ldr x2, =0x000018bc
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400000
	ldr x1, =check_data2
	ldr x2, =0x00400008
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004007ec
	ldr x1, =check_data3
	ldr x2, =0x00400810
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b00e // cvtp c14, x0
	.inst 0xc2df41ce // scvalue c14, c14, x31
	.inst 0xc28b412e // msr DDC_EL3, c14
	ldr x14, =0x30850030
	msr SCTLR_EL3, x14
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
