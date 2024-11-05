module decoder (
    input wire btnr, btnl, btnc,
    output wire [3:0] alu_op
 );

not n1(btnr_not, btnr);
not n2(btnl_not, btnl);
not n3(btnc_not, btnc);


and a1(f11, btnr_not, btnl);
xor x1(f12, btnl, btnc);
and a2(f13, btnr, f12);
or  o1(alu_op[0], f11, f13);

and a4(f21, btnr, btnl);
and a5(f22, btnl_not, btnc_not);
or  o2(alu_op[1], f21, f22);


or  o4(f31, btnl, btnr);
and a8(alu_op[2], f31, btnc_not);


or  o5(f41, btnr_not, btnc);
and a6(alu_op[3], f41, btnl);

endmodule
