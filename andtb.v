
module andtb;
reg a,b;
wire y;

andg u1(y,a,b);
initial
begin
a=1'b0;b=1'b0;
#20 a=1'b0;b=1'b1;
#30 a=1'b1;b=1'b0;
#100 a=1'b1;b=1'b1; #200 $finish;
end
endmodule
