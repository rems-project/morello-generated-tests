.section data0, #alloc, #write
	.byte 0x00, 0xd0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.zero 20
.data
check_data1:
	.zero 1
.data
check_data2:
	.byte 0xdf, 0x52, 0xc1, 0xc2, 0x80, 0x01, 0x5f, 0xd6
.data
check_data3:
	.byte 0xfe, 0x57, 0x50, 0xd1, 0xc1, 0x0f, 0xca, 0x1a, 0x1e, 0x64, 0x45, 0xa2, 0xe6, 0x1f, 0xb7, 0x6c
	.byte 0x1f, 0xf3, 0x21, 0xeb, 0xdc, 0x13, 0x30, 0xb9, 0x8c, 0x07, 0xc1, 0x54, 0x11, 0x78, 0xe1, 0x38
	.byte 0x60, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C0 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x3e4
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x560
	/* C1 */
	.octa 0x0
	/* C10 */
	.octa 0x0
	/* C12 */
	.octa 0x3e4
	/* C17 */
	.octa 0x0
	/* C24 */
	.octa 0x0
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0xffffffffffffd000
initial_SP_EL3_value:
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000500000000000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xd00000004204100000ffffffffffe001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0xc2c152df // CFHI-R.C-C Rd:31 Cn:22 100:100 opc:10 11000010110000010:11000010110000010
	.inst 0xd65f0180 // ret:aarch64/instrs/branch/unconditional/register Rm:00000 Rn:12 M:0 A:0 111110000:111110000 op:10 0:0 Z:0 1101011:1101011
	.zero 988
	.inst 0xd15057fe // sub_addsub_imm:aarch64/instrs/integer/arithmetic/add-sub/immediate Rd:30 Rn:31 imm12:010000010101 sh:1 0:0 10001:10001 S:0 op:1 sf:1
	.inst 0x1aca0fc1 // sdiv:aarch64/instrs/integer/arithmetic/div Rd:1 Rn:30 o1:1 00001:00001 Rm:10 0011010110:0011010110 sf:0
	.inst 0xa245641e // LDR-C.RIAW-C Ct:30 Rn:0 01:01 imm9:001010110 0:0 opc:01 10100010:10100010
	.inst 0x6cb71fe6 // stp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:6 Rn:31 Rt2:00111 imm7:1101110 L:0 1011001:1011001 opc:01
	.inst 0xeb21f31f // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:31 Rn:24 imm3:100 option:111 Rm:1 01011001:01011001 S:1 op:1 sf:1
	.inst 0xb93013dc // str_imm_gen:aarch64/instrs/memory/single/general/immediate/unsigned Rt:28 Rn:30 imm12:110000000100 opc:00 111001:111001 size:10
	.inst 0x54c1078c // b_cond:aarch64/instrs/branch/conditional/cond cond:1100 0:0 imm19:1100000100000111100 01010100:01010100
	.inst 0x38e17811 // ldrsb_reg:aarch64/instrs/memory/single/general/register Rt:17 Rn:0 10:10 S:1 option:011 Rm:1 1:1 opc:11 111000:111000 size:00
	.inst 0xc2c21260
	.zero 1047544
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
	.inst 0xc24005ca // ldr c10, [x14, #1]
	.inst 0xc24009cc // ldr c12, [x14, #2]
	.inst 0xc2400dd8 // ldr c24, [x14, #3]
	.inst 0xc24011dc // ldr c28, [x14, #4]
	/* Vector registers */
	mrs x14, cptr_el3
	bfc x14, #10, #1
	msr cptr_el3, x14
	isb
	ldr q6, =0x0
	ldr q7, =0x0
	/* Set up flags and system registers */
	mov x14, #0x00000000
	msr nzcv, x14
	ldr x14, =initial_SP_EL3_value
	.inst 0xc24001ce // ldr c14, [x14, #0]
	.inst 0xc2c1d1df // cpy c31, c14
	ldr x14, =0x200
	msr CPTR_EL3, x14
	ldr x14, =0x3085103d
	msr SCTLR_EL3, x14
	ldr x14, =0xc
	msr S3_6_C1_C2_2, x14 // CCTLR_EL3
	isb
	/* Start test */
	ldr x19, =pcc_return_ddc_capabilities
	.inst 0xc2400273 // ldr c19, [x19, #0]
	.inst 0x8260326e // ldr c14, [c19, #3]
	.inst 0xc28b412e // msr DDC_EL3, c14
	isb
	.inst 0x8260126e // ldr c14, [c19, #1]
	.inst 0x82602273 // ldr c19, [c19, #2]
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
	mov x19, #0xf
	and x14, x14, x19
	cmp x14, #0x6
	b.ne comparison_fail
	/* Check registers */
	ldr x14, =final_cap_values
	.inst 0xc24001d3 // ldr c19, [x14, #0]
	.inst 0xc2d3a401 // chkeq c0, c19
	b.ne comparison_fail
	.inst 0xc24005d3 // ldr c19, [x14, #1]
	.inst 0xc2d3a421 // chkeq c1, c19
	b.ne comparison_fail
	.inst 0xc24009d3 // ldr c19, [x14, #2]
	.inst 0xc2d3a541 // chkeq c10, c19
	b.ne comparison_fail
	.inst 0xc2400dd3 // ldr c19, [x14, #3]
	.inst 0xc2d3a581 // chkeq c12, c19
	b.ne comparison_fail
	.inst 0xc24011d3 // ldr c19, [x14, #4]
	.inst 0xc2d3a621 // chkeq c17, c19
	b.ne comparison_fail
	.inst 0xc24015d3 // ldr c19, [x14, #5]
	.inst 0xc2d3a701 // chkeq c24, c19
	b.ne comparison_fail
	.inst 0xc24019d3 // ldr c19, [x14, #6]
	.inst 0xc2d3a781 // chkeq c28, c19
	b.ne comparison_fail
	.inst 0xc2401dd3 // ldr c19, [x14, #7]
	.inst 0xc2d3a7c1 // chkeq c30, c19
	b.ne comparison_fail
	/* Check vector registers */
	ldr x14, =0x0
	mov x19, v6.d[0]
	cmp x14, x19
	b.ne comparison_fail
	ldr x14, =0x0
	mov x19, v6.d[1]
	cmp x14, x19
	b.ne comparison_fail
	ldr x14, =0x0
	mov x19, v7.d[0]
	cmp x14, x19
	b.ne comparison_fail
	ldr x14, =0x0
	mov x19, v7.d[1]
	cmp x14, x19
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x00001000
	ldr x1, =check_data0
	ldr x2, =0x00001014
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001560
	ldr x1, =check_data1
	ldr x2, =0x00001561
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
	ldr x0, =0x004003e4
	ldr x1, =check_data3
	ldr x2, =0x00400408
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
