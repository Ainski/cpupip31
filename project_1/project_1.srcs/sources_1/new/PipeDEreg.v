module PipeDEreg(
    input clk,rstn,wena,
    input [31:0] Dpc4,Da,Db,Dimm,Dcp0,Dhi,Dlo,
    input [4:0] Drn,
    input Dsign ,Ddiv,
    input [3:0] Daluc,
    input Dw_rf, Dw_hi, Dw_lo, Dw_dm,DisGoto,
    input Dasource,Dbsource,
    input [1:0] Dcuttersource,Dhisource,Dlosource,
    input [2:0] Drfsource,
    output reg[31:0] Epc4,Ea,Eb,Eimm,Ecp0,Ehi,Elo,
    output reg [4:0] Ern,
    output reg Esign, Ediv,
    output reg [3:0] Ealuc,
    output reg Ew_rf, Ew_hi, Ew_lo, Ew_dm,EisGoto,
    output reg Easource,Ebsource,
    output reg [1:0] Ecuttersource,Ehisource,Elosource,
    output reg [2:0] Erfsource
);

always @ (posedge clk or posedge rstn) begin
    if (!rstn) begin
        Epc4 <=0;
        Ea <= 0;
        Eb <= 0;
        Eimm <=0 ;
        Ecp0 <=0 ;
        Ehi <=0 ;
        Elo <=0 ;
        Ern <=0 ;
        Esign <=0 ;
        Ediv <=0 ;
        Ealuc <=0 ;
        Ew_rf <=0 ;
        Ew_hi <=0 ;
        Ew_lo <=0 ;
        Ew_dm <=0 ;
        EisGoto <=0 ;
        Easource <=0 ;
        Ebsource <=0 ;
        Ecuttersource <=0 ;
        Ehisource <=0 ;
        Elosource <=0 ;
        Erfsource <=0 ;
    end else begin
        Epc4 <= Dpc4 ;
        Ea <= Da ;
        Eb <= Db ;
        Eimm <= Dimm ;
        Ecp0 <= Dcp0 ;
        Ehi <= Dhi ;
        Elo <= Dlo ;
        Ern <= Drn ;
        Esign <= Dsign ;
        Ediv <= Ddiv ;
        Ealuc <= Daluc ;
        Ew_rf <= Dw_rf ;
        Ew_hi <= Dw_hi ;
        Ew_lo <= Dw_lo ;
        Ew_dm <= Dw_dm ;
        EisGoto <= DisGoto ;
        Easource <= Dasource ;
        Ebsource <= Dbsource ;
        Ecuttersource <= Dcuttersource ;
        Ehisource <= Dhisource ;
        Elosource <= Dlosource ;
        Erfsource <= Drfsource ;
    end
end

endmodule