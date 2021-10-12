.section data0, #alloc, #write
	.byte 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 4080
.data
check_data0:
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data1:
	.byte 0x7c, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.data
check_data2:
	.zero 2
.data
check_data3:
	.zero 8
.data
check_data4:
	.byte 0x3b, 0xcc, 0xc2, 0x6c, 0x27, 0x70, 0x02, 0xa8, 0x48, 0x6f, 0x79, 0x82, 0x5e, 0x08, 0x6e, 0x82
	.byte 0x09, 0xff, 0x00, 0x48, 0x5e, 0x35, 0x9e, 0xda, 0x5f, 0x2d, 0xc2, 0x1a, 0xdf, 0x50, 0x24, 0x38
	.byte 0xdf, 0x53, 0x20, 0xb8, 0xff, 0x84, 0x58, 0xe2, 0xe0, 0x11, 0xc2, 0xc2
.data
check_data5:
	.zero 4
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x0
	/* C2 */
	.octa 0x800000005ffc0162000000000040ff80
	/* C4 */
	.octa 0x10
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x8000000000010005000000000000107c
	/* C24 */
	.octa 0xa06
	/* C26 */
	.octa 0x80000000000300070000000000001180
	/* C28 */
	.octa 0x0
final_cap_values:
	/* C0 */
	.octa 0x1
	/* C1 */
	.octa 0x28
	/* C2 */
	.octa 0x800000005ffc0162000000000040ff80
	/* C4 */
	.octa 0x10
	/* C6 */
	.octa 0x0
	/* C7 */
	.octa 0x8000000000010005000000000000107c
	/* C8 */
	.octa 0x0
	/* C24 */
	.octa 0xa06
	/* C26 */
	.octa 0x80000000000300070000000000001180
	/* C28 */
	.octa 0x0
	/* C30 */
	.octa 0x0
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x20008000000080080000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc00000000c0708060000000000000007
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword initial_cap_values + 16
	.dword initial_cap_values + 64
	.dword initial_cap_values + 96
	.dword final_cap_values + 32
	.dword final_cap_values + 80
	.dword final_cap_values + 128
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x6cc2cc3b // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/post-idx Rt:27 Rn:1 Rt2:10011 imm7:0000101 L:1 1011001:1011001 opc:01
	.inst 0xa8027027 // stnp_gen:aarch64/instrs/memory/pair/general/no-alloc Rt:7 Rn:1 Rt2:11100 imm7:0000100 L:0 1010000:1010000 opc:10
	.inst 0x82796f48 // ALDR-R.RI-64 Rt:8 Rn:26 op:11 imm9:110010110 L:1 1000001001:1000001001
	.inst 0x826e085e // ALDR-R.RI-32 Rt:30 Rn:2 op:10 imm9:011100000 L:1 1000001001:1000001001
	.inst 0x4800ff09 // stlxrh:aarch64/instrs/memory/exclusive/single Rt:9 Rn:24 Rt2:11111 o0:1 Rs:0 0:0 L:0 0010000:0010000 size:01
	.inst 0xda9e355e // csneg:aarch64/instrs/integer/conditional/select Rd:30 Rn:10 o2:1 0:0 cond:0011 Rm:30 011010100:011010100 op:1 sf:1
	.inst 0x1ac22d5f // rorv:aarch64/instrs/integer/shift/variable Rd:31 Rn:10 op2:11 0010:0010 Rm:2 0011010110:0011010110 sf:0
	.inst 0x382450df // stsminb:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:6 00:00 opc:101 o3:0 Rs:4 1:1 R:0 A:0 00:00 V:0 111:111 size:00
	.inst 0xb82053df // stsmin:aarch64/instrs/memory/atomicops/st 11111:11111 Rn:30 00:00 opc:101 o3:0 Rs:0 1:1 R:0 A:0 00:00 V:0 111:111 size:10
	.inst 0xe25884ff // ALDURH-R.RI-32 Rt:31 Rn:7 op2:01 imm9:110001000 V:0 op1:01 11100010:11100010
	.inst 0xc2c211e0
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
	ldr x23, =initial_cap_values
	.inst 0xc24002e1 // ldr c1, [x23, #0]
	.inst 0xc24006e2 // ldr c2, [x23, #1]
	.inst 0xc2400ae4 // ldr c4, [x23, #2]
	.inst 0xc2400ee6 // ldr c6, [x23, #3]
	.inst 0xc24012e7 // ldr c7, [x23, #4]
	.inst 0xc24016f8 // ldr c24, [x23, #5]
	.inst 0xc2401afa // ldr c26, [x23, #6]
	.inst 0xc2401efc // ldr c28, [x23, #7]
	/* Set up flags and system registers */
	mov x23, #0x20000000
	msr nzcv, x23
	ldr x23, =0x200
	msr CPTR_EL3, x23
	ldr x23, =0x30851037
	msr SCTLR_EL3, x23
	ldr x23, =0x4
	msr S3_6_C1_C2_2, x23 // CCTLR_EL3
	isb
	/* Start test */
	ldr x15, =pcc_return_ddc_capabilities
	.inst 0xc24001ef // ldr c15, [x15, #0]
	.inst 0x826031f7 // ldr c23, [c15, #3]
	.inst 0xc28b4137 // msr DDC_EL3, c23
	isb
	.inst 0x826011f7 // ldr c23, [c15, #1]
	.inst 0x826021ef // ldr c15, [c15, #2]
	.inst 0xc2c212e0 // br c23
finish:
	/* Reconstruct general DDC from PCC, keep MMU and cache on for comparisons */
	.inst 0xc2c5b017 // cvtp c23, x0
	.inst 0xc2df42f7 // scvalue c23, c23, x31
	.inst 0xc28b4137 // msr DDC_EL3, c23
	ldr x23, =0x30851035
	msr SCTLR_EL3, x23
	isb
	/* Check processor flags */
	mrs x23, nzcv
	ubfx x23, x23, #28, #4
	mov x15, #0x2
	and x23, x23, x15
	cmp x23, #0x2
	b.ne comparison_fail
	/* Check registers */
	ldr x23, =final_cap_values
	.inst 0xc24002ef // ldr c15, [x23, #0]
	.inst 0xc2cfa401 // chkeq c0, c15
	b.ne comparison_fail
	.inst 0xc24006ef // ldr c15, [x23, #1]
	.inst 0xc2cfa421 // chkeq c1, c15
	b.ne comparison_fail
	.inst 0xc2400aef // ldr c15, [x23, #2]
	.inst 0xc2cfa441 // chkeq c2, c15
	b.ne comparison_fail
	.inst 0xc2400eef // ldr c15, [x23, #3]
	.inst 0xc2cfa481 // chkeq c4, c15
	b.ne comparison_fail
	.inst 0xc24012ef // ldr c15, [x23, #4]
	.inst 0xc2cfa4c1 // chkeq c6, c15
	b.ne comparison_fail
	.inst 0xc24016ef // ldr c15, [x23, #5]
	.inst 0xc2cfa4e1 // chkeq c7, c15
	b.ne comparison_fail
	.inst 0xc2401aef // ldr c15, [x23, #6]
	.inst 0xc2cfa501 // chkeq c8, c15
	b.ne comparison_fail
	.inst 0xc2401eef // ldr c15, [x23, #7]
	.inst 0xc2cfa701 // chkeq c24, c15
	b.ne comparison_fail
	.inst 0xc24022ef // ldr c15, [x23, #8]
	.inst 0xc2cfa741 // chkeq c26, c15
	b.ne comparison_fail
	.inst 0xc24026ef // ldr c15, [x23, #9]
	.inst 0xc2cfa781 // chkeq c28, c15
	b.ne comparison_fail
	.inst 0xc2402aef // ldr c15, [x23, #10]
	.inst 0xc2cfa7c1 // chkeq c30, c15
	b.ne comparison_fail
	/* Check vector registers */
	ldr x23, =0x0
	mov x15, v19.d[0]
	cmp x23, x15
	b.ne comparison_fail
	ldr x23, =0x0
	mov x15, v19.d[1]
	cmp x23, x15
	b.ne comparison_fail
	ldr x23, =0x20
	mov x15, v27.d[0]
	cmp x23, x15
	b.ne comparison_fail
	ldr x23, =0x0
	mov x15, v27.d[1]
	cmp x23, x15
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
	ldr x0, =0x00001048
	ldr x1, =check_data1
	ldr x2, =0x00001058
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001a06
	ldr x1, =check_data2
	ldr x2, =0x00001a08
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00001e30
	ldr x1, =check_data3
	ldr x2, =0x00001e38
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
	ldr x0, =0x00410300
	ldr x1, =check_data5
	ldr x2, =0x00410304
check_data_loop5:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop5
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
