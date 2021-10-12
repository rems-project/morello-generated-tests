.section data0, #alloc, #write
	.zero 4096
.data
check_data0:
	.zero 2
.data
check_data1:
	.zero 4
.data
check_data2:
	.zero 1
.data
check_data3:
	.byte 0xf9, 0x2a, 0xdf, 0x9a, 0xe2, 0xb3, 0x89, 0x5a, 0xdd, 0x43, 0xc2, 0xc2, 0x59, 0x00, 0xc1, 0xc2
	.byte 0x05, 0xd2, 0xeb, 0x82, 0xff, 0x10, 0x39, 0x78, 0x34, 0xf3, 0xc5, 0xc2, 0x1f, 0x68, 0x7a, 0x3c
	.byte 0x21, 0x44, 0x03, 0x3c, 0xff, 0x03, 0x6d, 0x78, 0xc0, 0x12, 0xc2, 0xc2
.data
check_data4:
	.zero 1
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000000001
	/* C1 */
	.octa 0x40000000000100050000000000001ffe
	/* C7 */
	.octa 0xc00000000401c0050000000000001000
	/* C11 */
	.octa 0xb100012c
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x13c001580
	/* C26 */
	.octa 0x4ffffd
	/* C30 */
	.octa 0x40000000000000000
final_cap_values:
	/* C0 */
	.octa 0x80000000000100050000000000000001
	/* C1 */
	.octa 0x40000000000100050000000000002032
	/* C2 */
	.octa 0x0
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0xc00000000401c0050000000000001000
	/* C11 */
	.octa 0xb100012c
	/* C13 */
	.octa 0x0
	/* C16 */
	.octa 0x13c001580
	/* C20 */
	.octa 0x0
	/* C25 */
	.octa 0x5ffe00000000000000000000
	/* C26 */
	.octa 0x4ffffd
	/* C29 */
	.octa 0x40000000000000000
	/* C30 */
	.octa 0x40000000000000000
initial_SP_EL3_value:
	.octa 0xc0000000400000020000000000001000
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000040600070000000000400001
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0x800000001007001700ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 0
	.dword initial_cap_values + 16
	.dword initial_cap_values + 32
	.dword final_cap_values + 0
	.dword final_cap_values + 16
	.dword final_cap_values + 64
	.dword initial_SP_EL3_value
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x9adf2af9 // asrv:aarch64/instrs/integer/shift/variable Rd:25 Rn:23 op2:10 0010:0010 Rm:31 0011010110:0011010110 sf:1
	.inst 0x5a89b3e2 // csinv:aarch64/instrs/integer/conditional/select Rd:2 Rn:31 o2:0 0:0 cond:1011 Rm:9 011010100:011010100 op:1 sf:0
	.inst 0xc2c243dd // SCVALUE-C.CR-C Cd:29 Cn:30 000:000 opc:10 0:0 Rm:2 11000010110:11000010110
	.inst 0xc2c10059 // SCBNDS-C.CR-C Cd:25 Cn:2 000:000 opc:00 0:0 Rm:1 11000010110:11000010110
	.inst 0x82ebd205 // ALDR-R.RRB-32 Rt:5 Rn:16 opc:00 S:1 option:110 Rm:11 1:1 L:1 100000101:100000101
	.inst 0x783910ff // stclrh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:7 00:00 opc:001 o3:0 Rs:25 1:1 R:0 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c5f334 // CVTPZ-C.R-C Cd:20 Rn:25 100:100 opc:11 11000010110001011:11000010110001011
	.inst 0x3c7a681f // ldr_reg_fpsimd:aarch64/instrs/memory/single/simdfp/register Rt:31 Rn:0 10:10 S:0 option:011 Rm:26 1:1 opc:01 111100:111100 size:00
	.inst 0x3c034421 // str_imm_fpsimd:aarch64/instrs/memory/single/simdfp/immediate/signed/post-idx Rt:1 Rn:1 01:01 imm9:000110100 0:0 opc:00 111100:111100 size:00
	.inst 0x786d03ff // staddh:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:31 00:00 opc:000 o3:0 Rs:13 1:1 R:1 A:0 00:00 V:0 111:111 size:01
	.inst 0xc2c212c0
	.zero 1048532
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
	.inst 0xc24001c0 // ldr c0, [x14, #0]
	.inst 0xc24005c1 // ldr c1, [x14, #1]
	.inst 0xc24009c7 // ldr c7, [x14, #2]
	.inst 0xc2400dcb // ldr c11, [x14, #3]
	.inst 0xc24011cd // ldr c13, [x14, #4]
	.inst 0xc24015d0 // ldr c16, [x14, #5]
	.inst 0xc24019da // ldr c26, [x14, #6]
	.inst 0xc2401dde // ldr c30, [x14, #7]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q1, =0x0
	/* Set up flags and system registers */
	mov x14, #0x80000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x30851037
	msr SCTLR_EL3, x14
	ldr x14, =0x4
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x22, =pcc_return_ddc_capabilities
	.inst 0xc24002d6 // ldr c22, [x22, #0]
	.inst 0x826032ce // ldr c14, [c22, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x826012ce // ldr c14, [c22, #1]
	.inst 0x826022d6 // ldr c22, [c22, #2]
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
	mov x22, #0x9
	and x14, x14, x22
	cmp x14, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d6 // ldr c22, [x14, #0]
	.inst 0xc2d6a401 // chkeq c0, c22
	b.ne comparison_fail
	.inst 0xc24005d6 // ldr c22, [x14, #1]
	.inst 0xc2d6a421 // chkeq c1, c22
	b.ne comparison_fail
	.inst 0xc24009d6 // ldr c22, [x14, #2]
	.inst 0xc2d6a441 // chkeq c2, c22
	b.ne comparison_fail
	.inst 0xc2400dd6 // ldr c22, [x14, #3]
	.inst 0xc2d6a4a1 // chkeq c5, c22
	b.ne comparison_fail
	.inst 0xc24011d6 // ldr c22, [x14, #4]
	.inst 0xc2d6a4e1 // chkeq c7, c22
	b.ne comparison_fail
	.inst 0xc24015d6 // ldr c22, [x14, #5]
	.inst 0xc2d6a561 // chkeq c11, c22
	b.ne comparison_fail
	.inst 0xc24019d6 // ldr c22, [x14, #6]
	.inst 0xc2d6a5a1 // chkeq c13, c22
	b.ne comparison_fail
	.inst 0xc2401dd6 // ldr c22, [x14, #7]
	.inst 0xc2d6a601 // chkeq c16, c22
	b.ne comparison_fail
	.inst 0xc24021d6 // ldr c22, [x14, #8]
	.inst 0xc2d6a681 // chkeq c20, c22
	b.ne comparison_fail
	.inst 0xc24025d6 // ldr c22, [x14, #9]
	.inst 0xc2d6a721 // chkeq c25, c22
	b.ne comparison_fail
	.inst 0xc24029d6 // ldr c22, [x14, #10]
	.inst 0xc2d6a741 // chkeq c26, c22
	b.ne comparison_fail
	.inst 0xc2402dd6 // ldr c22, [x14, #11]
	.inst 0xc2d6a7a1 // chkeq c29, c22
	b.ne comparison_fail
	.inst 0xc24031d6 // ldr c22, [x14, #12]
	.inst 0xc2d6a7c1 // chkeq c30, c22
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x22, v1.d[0]
	cmp x14, x22
	b.ne comparison_fail
	ldr x14, =0x0
	mov x22, v1.d[1]
	cmp x14, x22
	b.ne comparison_fail
	ldr x14, =0x0
	mov x22, v31.d[0]
	cmp x14, x22
	b.ne comparison_fail
	ldr x14, =0x0
	mov x22, v31.d[1]
	cmp x14, x22
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001002
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001a40
	ldr x1, =check_data1
	ldr x2, =0x00001a44
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
	ldr x0, =0x004ffffe
	ldr x1, =check_data4
	ldr x2, =0x004fffff
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
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
