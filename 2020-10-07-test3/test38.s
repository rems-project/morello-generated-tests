.section data0, #alloc, #write
	.zero 176
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 3904
.data
check_data0:
	.byte 0x00, 0x00, 0x40, 0x00
.data
check_data1:
	.zero 16
.data
check_data2:
	.zero 2
.data
check_data3:
	.byte 0x20, 0x74, 0x3b, 0x02, 0xcc, 0x9b, 0x5c, 0xc2, 0xe2, 0x79, 0x66, 0x82, 0xe5, 0xc0, 0x4f, 0xe2
	.byte 0xee, 0x5b, 0x3b, 0x78, 0xf8, 0x67, 0xde, 0xc2, 0x03, 0x32, 0xc2, 0xc2
.data
check_data4:
	.zero 8
.data
check_data5:
	.byte 0x40, 0x78, 0x5c, 0x2d, 0x05, 0x14, 0xc0, 0xda, 0xc1, 0x53, 0x22, 0xeb, 0xa0, 0x12, 0xc2, 0xc2
.data
.balign 16
initial_cap_values:
	/* C1 */
	.octa 0x22007017ffffffffff800
	/* C5 */
	.octa 0x0
	/* C7 */
	.octa 0x40000000000100050000000000001f00
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000100050000000000000f1c
	/* C16 */
	.octa 0x200080008007a63f000000000040b610
	/* C27 */
	.octa 0xd3d00000
	/* C30 */
	.octa 0xffffffffffffa980
final_cap_values:
	/* C0 */
	.octa 0x2200701800000000006dd
	/* C1 */
	.octa 0xfffffffffc40001c
	/* C2 */
	.octa 0x400000
	/* C5 */
	.octa 0x6
	/* C7 */
	.octa 0x40000000000100050000000000001f00
	/* C12 */
	.octa 0x0
	/* C14 */
	.octa 0x0
	/* C15 */
	.octa 0x80000000000100050000000000000f1c
	/* C16 */
	.octa 0x200080008007a63f000000000040b610
	/* C24 */
	.octa 0xffffffffffffa980
	/* C27 */
	.octa 0xd3d00000
	/* C30 */
	.octa 0x200080002001c005000000000040001c
initial_SP_EL3_value:
	.octa 0xfffffffe58601ffc
pcc_return_ddc_capabilities:
	.dword pcc_return_ddc_capabilities
	.dword 0xFFFFC00000010005
	.octa 0x200080002001c0050000000000400000
	.dword finish
	.dword 0xFFFFC00000010005
	.octa 0xc01000000005000700ffffffe0000001
.balign 8
initial_tag_locations:
	.dword pcc_return_ddc_capabilities
	.dword pcc_return_ddc_capabilities + 16
	.dword pcc_return_ddc_capabilities + 32
	.dword 0x0000000000001be0
	.dword initial_cap_values + 32
	.dword initial_cap_values + 64
	.dword initial_cap_values + 80
	.dword final_cap_values + 64
	.dword final_cap_values + 112
	.dword final_cap_values + 128
	.dword final_cap_values + 176
	.dword pcc_return_ddc_capabilities + 48
	.dword 0
.section text0, #alloc, #execinstr
test_start:
	.inst 0x023b7420 // ADD-C.CIS-C Cd:0 Cn:1 imm12:111011011101 sh:0 A:0 00000010:00000010
	.inst 0xc25c9bcc // LDR-C.RIB-C Ct:12 Rn:30 imm12:011100100110 L:1 110000100:110000100
	.inst 0x826679e2 // ALDR-R.RI-32 Rt:2 Rn:15 op:10 imm9:001100111 L:1 1000001001:1000001001
	.inst 0xe24fc0e5 // ASTURH-R.RI-32 Rt:5 Rn:7 op2:00 imm9:011111100 V:0 op1:01 11100010:11100010
	.inst 0x783b5bee // strh_reg:aarch64/instrs/memory/single/general/register Rt:14 Rn:31 10:10 S:1 option:010 Rm:27 1:1 opc:00 111000:111000 size:01
	.inst 0xc2de67f8 // CPYVALUE-C.C-C Cd:24 Cn:31 001:001 opc:11 0:0 Cm:30 11000010110:11000010110
	.inst 0xc2c23203 // BLRR-C-C 00011:00011 Cn:16 100:100 opc:01 11000010110000100:11000010110000100
	.zero 46580
	.inst 0x2d5c7840 // ldp_fpsimd:aarch64/instrs/memory/pair/simdfp/offset Rt:0 Rn:2 Rt2:11110 imm7:0111000 L:1 1011010:1011010 opc:00
	.inst 0xdac01405 // cls_int:aarch64/instrs/integer/arithmetic/cnt Rd:5 Rn:0 op:1 10110101100000000010:10110101100000000010 sf:1
	.inst 0xeb2253c1 // subs_addsub_ext:aarch64/instrs/integer/arithmetic/add-sub/extendedreg Rd:1 Rn:30 imm3:100 option:010 Rm:2 01011001:01011001 S:1 op:1 sf:1
	.inst 0xc2c212a0
	.zero 1001952
.text
.global preamble
preamble:
	/* Write tags to memory */
	mrs x28, cptr_el3
	orr x28, x28, #0x200
	msr cptr_el3, x28
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
	ldr x28, =initial_cap_values
	.inst 0xc2400381 // ldr c1, [x28, #0]
	.inst 0xc2400785 // ldr c5, [x28, #1]
	.inst 0xc2400b87 // ldr c7, [x28, #2]
	.inst 0xc2400f8e // ldr c14, [x28, #3]
	.inst 0xc240138f // ldr c15, [x28, #4]
	.inst 0xc2401790 // ldr c16, [x28, #5]
	.inst 0xc2401b9b // ldr c27, [x28, #6]
	.inst 0xc2401f9e // ldr c30, [x28, #7]
	/* Set up flags and system registers */
	mov x28, #0x00000000
	msr nzcv, x28
	ldr x28, =initial_SP_EL3_value
	.inst 0xc240039c // ldr c28, [x28, #0]
	.inst 0xc2c1d39f // cpy c31, c28
	ldr x28, =0x200
	msr CPTR_EL3, x28
	ldr x28, =0x30850032
	msr SCTLR_EL3, x28
	ldr x28, =0x0
	msr S3_6_C1_C2_2, x28 // CCTLR_EL3
	isb
	/* Start test */
	ldr x21, =pcc_return_ddc_capabilities
	.inst 0xc24002b5 // ldr c21, [x21, #0]
	.inst 0x826032bc // ldr c28, [c21, #3]
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	.inst 0x826012bc // ldr c28, [c21, #1]
	.inst 0x826022b5 // ldr c21, [c21, #2]
	.inst 0xc2c21380 // br c28
finish:
	/* Reconstruct general DDC from PCC */
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
	isb
	/* Check processor flags */
	mrs x28, nzcv
	ubfx x28, x28, #28, #4
	mov x21, #0xf
	and x28, x28, x21
	cmp x28, #0x8
	b.ne comparison_fail
	/* Check registers */
	ldr x28, =final_cap_values
	.inst 0xc2400395 // ldr c21, [x28, #0]
	.inst 0xc2d5a401 // chkeq c0, c21
	b.ne comparison_fail
	.inst 0xc2400795 // ldr c21, [x28, #1]
	.inst 0xc2d5a421 // chkeq c1, c21
	b.ne comparison_fail
	.inst 0xc2400b95 // ldr c21, [x28, #2]
	.inst 0xc2d5a441 // chkeq c2, c21
	b.ne comparison_fail
	.inst 0xc2400f95 // ldr c21, [x28, #3]
	.inst 0xc2d5a4a1 // chkeq c5, c21
	b.ne comparison_fail
	.inst 0xc2401395 // ldr c21, [x28, #4]
	.inst 0xc2d5a4e1 // chkeq c7, c21
	b.ne comparison_fail
	.inst 0xc2401795 // ldr c21, [x28, #5]
	.inst 0xc2d5a581 // chkeq c12, c21
	b.ne comparison_fail
	.inst 0xc2401b95 // ldr c21, [x28, #6]
	.inst 0xc2d5a5c1 // chkeq c14, c21
	b.ne comparison_fail
	.inst 0xc2401f95 // ldr c21, [x28, #7]
	.inst 0xc2d5a5e1 // chkeq c15, c21
	b.ne comparison_fail
	.inst 0xc2402395 // ldr c21, [x28, #8]
	.inst 0xc2d5a601 // chkeq c16, c21
	b.ne comparison_fail
	.inst 0xc2402795 // ldr c21, [x28, #9]
	.inst 0xc2d5a701 // chkeq c24, c21
	b.ne comparison_fail
	.inst 0xc2402b95 // ldr c21, [x28, #10]
	.inst 0xc2d5a761 // chkeq c27, c21
	b.ne comparison_fail
	.inst 0xc2402f95 // ldr c21, [x28, #11]
	.inst 0xc2d5a7c1 // chkeq c30, c21
	b.ne comparison_fail
	/* Check vector registers */
	ldr x28, =0x0
	mov x21, v0.d[0]
	cmp x28, x21
	b.ne comparison_fail
	ldr x28, =0x0
	mov x21, v0.d[1]
	cmp x28, x21
	b.ne comparison_fail
	ldr x28, =0x0
	mov x21, v30.d[0]
	cmp x28, x21
	b.ne comparison_fail
	ldr x28, =0x0
	mov x21, v30.d[1]
	cmp x28, x21
	b.ne comparison_fail
	/* Check memory */
	ldr x0, =0x000010b8
	ldr x1, =check_data0
	ldr x2, =0x000010bc
check_data_loop0:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop0
	ldr x0, =0x00001be0
	ldr x1, =check_data1
	ldr x2, =0x00001bf0
check_data_loop1:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop1
	ldr x0, =0x00001ffc
	ldr x1, =check_data2
	ldr x2, =0x00001ffe
check_data_loop2:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop2
	ldr x0, =0x00400000
	ldr x1, =check_data3
	ldr x2, =0x0040001c
check_data_loop3:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop3
	ldr x0, =0x004000e0
	ldr x1, =check_data4
	ldr x2, =0x004000e8
check_data_loop4:
	ldrb w3, [x0], #1
	ldrb w4, [x1], #1
	cmp x3, x4
	b.ne comparison_fail
	cmp x0, x2
	b.ne check_data_loop4
	ldr x0, =0x0040b610
	ldr x1, =check_data5
	ldr x2, =0x0040b620
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
	.inst 0xc2c5b01c // cvtp c28, x0
	.inst 0xc2df439c // scvalue c28, c28, x31
	.inst 0xc28b413c // msr DDC_EL3, c28
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
