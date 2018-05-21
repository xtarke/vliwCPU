#include "alu.h"

void alu::do_calc() {
    sc_int<WORD_SIZE> local_a;
    sc_int<WORD_SIZE> local_b;

    sc_uint<WORD_SIZE> local_a_unsig;
    sc_uint<WORD_SIZE> local_b_unsig;

    sc_uint<ALUOPS> local_aluop;
    sc_uint<SHAMT_SIZE> local_shamt;

    sc_int<WORD_SIZE> local_result = 0;
    sc_int<WORD_SIZE> local_result_usigned = 0;
    sc_uint<2 * WORD_SIZE> local_result_doublew = 0;

    sc_int<WORD_SIZE> local_lo;
    sc_int<WORD_SIZE> local_hi;

    local_a = a.read();
    local_b = b.read();
    local_aluop = aluop.read();
    local_shamt = shamt.read();

    local_result = result.read();
    local_lo = lo_result.read();
    local_hi = hi_result.read();
    

    local_a_unsig = a.read().to_uint();
    local_b_unsig = b.read().to_uint();

    switch (local_aluop) {
        case ALU_ADD:
            local_result = local_a + local_b;
            //cout << "@ " << sc_time_stamp() << " ALU_ADD: " << local_result << endl;
            break;

        case ALU_SUB:
            local_result = local_a - local_b;
            //	 		cout << "@ " << sc_time_stamp() << " a: " << local_a << endl;
            //	 		cout << "@ " << sc_time_stamp() << " b: " << local_b << endl;
            //         cout << "@ " << sc_time_stamp() << " ALU_SUB: " << local_result << endl;
            break;

        case ALU_MULT:
            local_result_doublew = local_a * local_b;

            local_hi = local_result_doublew.range(2 * WORD_SIZE - 1, WORD_SIZE);
            local_lo = local_result_doublew.range(WORD_SIZE - 1, 0);

            //	 		cout << "@ " << sc_time_stamp() << " a: " << local_a << endl;
            //	 		cout << "@ " << sc_time_stamp() << " b: " << local_b << endl;
            //	 		cout << "@ " << sc_time_stamp() << " ALU_MULT: " << local_result_doublew << endl;
            //	 		cout << "@ " << sc_time_stamp() << " ALU_MULT hi: " << local_hi << endl;
            //	 		cout << "@ " << sc_time_stamp() << " ALU_MULT lo: " << local_lo << endl;
            break;

        case ALU_MULTU:
            local_result_doublew = local_a_unsig * local_b_unsig;

            local_hi = local_result_doublew.range(2 * WORD_SIZE - 1, WORD_SIZE);
            local_lo = local_result_doublew.range(WORD_SIZE - 1, 0);

            break;

        case ALU_MUL:
            local_result_doublew = local_a * local_b;
            local_result = local_result_doublew.range(WORD_SIZE - 1, 0);

            break;
        case ALU_AND:
            local_result = local_a & local_b;
            //cout << "@ " << sc_time_stamp() << " ALU_AND" << endl;
            break;

        case ALU_XOR:
            local_result = local_a ^ local_b;
            break;

        case ALU_OR:
            local_result = local_a | local_b;
            //cout << "@ " << sc_time_stamp() << " ALU_OR" << endl;
            break;

        case ALU_NOR:
            local_result = ~(local_a | local_b);
            //cout << "@ " << sc_time_stamp() << " ALU_OR" << endl;
            break;

        case ALU_SHIFTL_B:
            local_result = local_b << local_shamt;
            //cout << "@ " << sc_time_stamp() << " ALU_SHIFTL_B" << endl;
            break;
        case ALU_DIV:
            //Div 0 exception
            if (local_b == 0) {
                SC_REPORT_WARNING(1, "DIV 0 exception disabled in ALU_WCET mode");
                local_b = 1;
            }
            
            

            local_lo = local_a / local_b;
            local_hi = local_a % local_b;
            break;

        case ALU_SLT:
            if (local_a < local_b)
                local_result = 1;
            else
                local_result = 0;
            break;

        case ALU_SLTU:
            if (local_a_unsig < local_b_unsig)
                local_result = 1;
            else
                local_result = 0;
            break;

        case ALU_SLL:
            local_result = local_b << local_shamt;
            //cout << "@ " << sc_time_stamp() << " ALU_SHIFTL_B" << endl;
            break;

        case ALU_SLLV:
            local_result = local_b << local_a;
            //cout << "@ " << sc_time_stamp() << " ALU_SHIFTL_B" << endl;
            break;

        case ALU_SRA:
            local_result = local_b >> local_shamt;
            //cout << "@ " << sc_time_stamp() << " ALU_SHIFTL_B" << endl;
            break;
        case ALU_SRAV:
            local_result = local_b >> local_a;
            //cout << "@ " << sc_time_stamp() << " ALU_SHIFTL_B" << endl;
            break;

        case ALU_SRL:
            local_result_usigned = local_b_unsig >> local_shamt;
            local_result = local_result_usigned.to_int();

            //	 		cout << "@ " << sc_time_stamp() << " ALU_SRL" << endl;
            //	 		cout << "b: " << hex << local_b_unsig << "  shamt: " << shamt << endl;
            //	 		cout << "local_result_usigned: " << local_result_usigned <<  endl;
            break;

        case ALU_SRLV:
            local_result_usigned = local_b_unsig >> local_a;
            local_result = local_result_usigned.to_int();

            //	 		cout << "@ " << sc_time_stamp() << " ALU_SRL" << endl;
            //	 		cout << "b: " << hex << local_b_unsig << "  shamt: " << shamt << endl;
            //	 		cout << "local_result_usigned: " << local_result_usigned <<  endl;
            break;
        case ALU_CMPEQ:
            if (local_a == local_b)
                local_result = 1;
            else
                local_result = 0;
            break;

        case ALU_CMPGE:
            if (local_a >= local_b)
                local_result = 1;
            else
                local_result = 0;
            break;

        case ALU_CMPGEU:
            if (local_a_unsig >= local_b_unsig)
                local_result = 1;
            else
                local_result = 0;
            break;

        case ALU_CMPGT:
            if (local_a > local_b)
                local_result = 1;
            else
                local_result = 0;
            break;
        case ALU_CMPGTU:
            if (local_a_unsig > local_b_unsig)
                local_result = 1;
            else
                local_result = 0;
            break;
        case ALU_CMPLE:
            if (local_a <= local_b)
                local_result = 1;
            else
                local_result = 0;
            break;
        case ALU_CMPLEU:
            if (local_a_unsig <= local_b_unsig)
                local_result = 1;
            else
                local_result = 0;
            break;
        case ALU_CMPLT:
            if (local_a < local_b)
                local_result = 1;
            else
                local_result = 0;
            break;
        case ALU_CMPLTU:
            if (local_a_unsig < local_b_unsig)
                local_result = 1;
            else
                local_result = 0;
            break;

        case ALU_CMPNE:
            if (local_a != local_b)
                local_result = 1;
            else
                local_result = 0;
            break;

        case ALU_NANDL:
            local_result = ~(local_a & local_b);
            //cout << "@ " << sc_time_stamp() << " ALU_AND" << endl;
            break;

        default:
            //local_result = 0;
            break;
    }

    result_doublew.write(local_result_doublew);

    result.write(local_result);
    hi_result.write(local_hi);
    lo_result.write(local_lo);
};

void alu::do_output() {
    result_out.write(result.read());
}

void alu::do_hilo_ouput() {
    lo_out.write(lo_result.read());
    hi_out.write(hi_result.read());
    
}

//begin
//	process (A,B,aluop)
//	begin
//		CASE aluop IS
//			WHEN "000" =>
//				result <= (x"0000" & A) + (x"0000" & B);
//			WHEN "001" =>
//				result <= A * B;
//			WHEN "010" =>
//				result <= (x"0000" & A) and (x"0000" & B);
//			WHEN "011" =>
//				result <= (x"0000" & A) or (x"0000" & B);
//			WHEN "100" =>
//				result <= (x"0000" & not A);
//			WHEN "101" =>
//				result <= (A & B);
//			WHEN "110" => 				-- A < B ? 1 : 0
//				if A < B then
//					result <= (result'range => '1');
//				else
//					result <= (result'range => '0');
//				end if;
//			WHEN "111" => 		-- A == B ? 1 : 0
//				if A = B then
//					result <= (result'range => '1');
//				else
//					result <= (result'range => '0');
//				end if;
//			when OTHERS =>
//				--result <=  (result'range => 'Z');
//		end case;
//	end process;
//
//	result_32 <= result;
//	result_lsb <= result(n-1 downto 0);
//	result_msb <= result(2*n-1 downto n);
//
//end logic;

