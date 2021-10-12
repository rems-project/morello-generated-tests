.section data0, #alloc, #write
	.zero 1280
	.byte 0x00, 0x00, 0x00, 0x00, 0xf8, 0xf7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 2800
.data
check_data0:
	.zero 2
.data
check_data1:
	.byte 0x1e, 0x02, 0xbd, 0x78, 0xa1, 0x03, 0x00, 0xfa, 0xa0, 0x01, 0x3f, 0xd6, 0xc5, 0x7f, 0x32, 0x9b
	.byte 0x41, 0xc1, 0xbf, 0xb8, 0xa0, 0x03, 0x1f, 0xd6
.data
check_data2:
	.byte 0x31, 0x08, 0xc0, 0x5a, 0xcc, 0xd3, 0xc1, 0xc2, 0xb1, 0xa7, 0xdd, 0xca, 0x1e, 0x32, 0xc7, 0xc2
	.byte 0x00, 0x13, 0xc2, 0xc2
.data
check_data3:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C10 */
	.octa 0x4fdfc8
	/* C13 */
	.octa 0x40000c
	/* C16 */
	.octa 0x1504
	/* C29 */
	.octa 0x400808
final_cap_values:
	/* C1 */
	.octa 0x0
	/* C10 */
	.octa 0x4fdfc8
	/* C12 */
	.octa 0x40000c
	/* C13 */
	.octa 0x40000c
	/* C16 */
	.octa 0x1504
	/* C17 */
	.octa 0x200404400808
	/* C29 */
	.octa 0x400808
	/* C30 */
	.octa 0xffffffffffffffff
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500100000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc0000000000100050000000000000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x78bd021e // ldaddh:aarch64/instrs/memory/atomicops/ld Rt:30 Rn:16 00:00 opc:000 0:0 Rs:29 1:1 R:0 A:1 111000:111000 size:01
	.inst 0xfa0003a1 // sbcs:aarch64/instrs/integer/arithmetic/add-sub/carry Rd:1 Rn:29 000000:000000 Rm:0 11010000:11010000 S:1 op:1 sf:1
	.inst 0xd63f01a0 // blr:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:13 M:0 A:0 111110000:111110000 op:01 0:0 Z:0 1101011:1101011
	.inst 0x9b327fc5 // smaddl:aarch64/instrs/integer/arithmetic/mul/widening/32-64 Rd:5 Rn:30 Ra:31 o0:0 Rm:18 01:01 U:0 10011011:10011011
	.inst 0xb8bfc141 // ldapr:aarch64/instrs/memory/ordered-rcpc Rt:1 Rn:10 110000:110000 Rs:11111 111000101:111000101 size:10
	.inst 0xd61f03a0 // br:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:29 M:0 A:0 111110000:111110000 op:00 0:0 Z:0 1101011:1101011
	.zero 2032
	.inst 0x5ac00831 // rev:aarch64/instrs/integer/arithmetic/rev Rd:17 Rn:1 opc:10 1011010110000000000:1011010110000000000 sf:0
	.inst 0xc2c1d3cc // CPY-C.C-C Cd:12 Cn:30 100:100 opc:10 11000010110000011:11000010110000011
	.inst 0xcadda7b1 // eor_log_shift:aarch64/instrs/integer/logical/shiftedreg Rd:17 Rn:29 imm6:101001 Rm:29 N:0 shift:11 01010:01010 opc:10 sf:1
	.inst 0xc2c7321e // RRMASK-R.R-C Rd:30 Rn:16 100:100 opc:01 11000010110001110:11000010110001110
	.inst 0xc2c21300
	.zero 1046500
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
	ldr x23, =initial_cap_values
	.inst 0xc24002ea // ldr c10, [x23, #0]
	.inst 0xc24006ed // ldr c13, [x23, #1]
	.inst 0xc2400af0 // ldr c16, [x23, #2]
	.inst 0xc2400efd // ldr c29, [x23, #3]
	/* Set up flags and system registers */
	mov x23, #0x00000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x24, =pcc_return_ddc_capabilities
	.inst 0xc2400318 // ldr c24, [x24, #0]
	.inst 0x82603317 // ldr c23, [c24, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x82601317 // ldr c23, [c24, #1]
	.inst 0x82602318 // ldr c24, [c24, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* No processor flags to check */
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002f8 // ldr c24, [x23, #0]
	.inst 0xc2d8a421 // chkeq c1, c24
	b.ne comparison_fail
	.inst 0xc24006f8 // ldr c24, [x23, #1]
	.inst 0xc2d8a541 // chkeq c10, c24
	b.ne comparison_fail
	.inst 0xc2400af8 // ldr c24, [x23, #2]
	.inst 0xc2d8a581 // chkeq c12, c24
	b.ne comparison_fail
	.inst 0xc2400ef8 // ldr c24, [x23, #3]
	.inst 0xc2d8a5a1 // chkeq c13, c24
	b.ne comparison_fail
	.inst 0xc24012f8 // ldr c24, [x23, #4]
	.inst 0xc2d8a601 // chkeq c16, c24
	b.ne comparison_fail
	.inst 0xc24016f8 // ldr c24, [x23, #5]
	.inst 0xc2d8a621 // chkeq c17, c24
	b.ne comparison_fail
	.inst 0xc2401af8 // ldr c24, [x23, #6]
	.inst 0xc2d8a7a1 // chkeq c29, c24
	b.ne comparison_fail
	.inst 0xc2401ef8 // ldr c24, [x23, #7]
	.inst 0xc2d8a7c1 // chkeq c30, c24
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001504
	ldr x1, =check_data0
	ldr x2, =0x00001506
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00400000
	ldr x1, =check_data1
	ldr x2, =0x00400018
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00400808
	ldr x1, =check_data2
	ldr x2, =0x0040081c
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x004fdfc8
	ldr x1, =check_data3
	ldr x2, =0x004fdfcc
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	/* Done print message */
	/* turn off MMU */
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
	isb
	ldr x0, =ok_message
	b write_tube
	.global comparison_fail
comparison_fail:
	/* Reconstruct general DDC from PCC, turn off MMU */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30850030
	msr SCTLR_EL3, x23
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
