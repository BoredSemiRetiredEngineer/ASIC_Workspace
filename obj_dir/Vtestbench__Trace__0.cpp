// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtestbench__Syms.h"


void Vtestbench___024root__trace_chg_0_sub_0(Vtestbench___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtestbench___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtestbench___024root__trace_chg_0\n"); );
    // Init
    Vtestbench___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtestbench___024root*>(voidSelf);
    Vtestbench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtestbench___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtestbench___024root__trace_chg_0_sub_0(Vtestbench___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vtestbench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtestbench___024root__trace_chg_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        bufp->chgCData(oldp+0,(vlSelf->testbench__DOT__MatrixMath__DOT__State_out),8);
        bufp->chgCData(oldp+1,(vlSelf->testbench__DOT__MatrixMath__DOT__OP_REGS),8);
        bufp->chgCData(oldp+2,(vlSelf->testbench__DOT__MatrixMath__DOT__MATC_ERROR),8);
        bufp->chgCData(oldp+3,(vlSelf->testbench__DOT__MatrixMath__DOT__Ain),8);
        bufp->chgCData(oldp+4,(vlSelf->testbench__DOT__MatrixMath__DOT__Bin),8);
        bufp->chgCData(oldp+5,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__ERROR_OP_REG),8);
        bufp->chgCData(oldp+6,(vlSelf->testbench__DOT__MatrixMath__DOT__state_op),8);
        bufp->chgCData(oldp+7,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                               [0U][0U]),8);
        bufp->chgCData(oldp+8,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                               [0U][1U]),8);
        bufp->chgCData(oldp+9,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                               [0U][2U]),8);
        bufp->chgCData(oldp+10,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                                [1U][0U]),8);
        bufp->chgCData(oldp+11,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                                [1U][1U]),8);
        bufp->chgCData(oldp+12,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                                [1U][2U]),8);
        bufp->chgCData(oldp+13,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                                [2U][0U]),8);
        bufp->chgCData(oldp+14,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                                [2U][1U]),8);
        bufp->chgCData(oldp+15,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixA
                                [2U][2U]),8);
        bufp->chgCData(oldp+16,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [0U][0U]),8);
        bufp->chgCData(oldp+17,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [0U][1U]),8);
        bufp->chgCData(oldp+18,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [0U][2U]),8);
        bufp->chgCData(oldp+19,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [1U][0U]),8);
        bufp->chgCData(oldp+20,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [1U][1U]),8);
        bufp->chgCData(oldp+21,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [1U][2U]),8);
        bufp->chgCData(oldp+22,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [2U][0U]),8);
        bufp->chgCData(oldp+23,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [2U][1U]),8);
        bufp->chgCData(oldp+24,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixB
                                [2U][2U]),8);
        bufp->chgCData(oldp+25,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [0U][0U]),8);
        bufp->chgCData(oldp+26,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [0U][1U]),8);
        bufp->chgCData(oldp+27,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [0U][2U]),8);
        bufp->chgCData(oldp+28,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [1U][0U]),8);
        bufp->chgCData(oldp+29,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [1U][1U]),8);
        bufp->chgCData(oldp+30,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [1U][2U]),8);
        bufp->chgCData(oldp+31,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [2U][0U]),8);
        bufp->chgCData(oldp+32,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [2U][1U]),8);
        bufp->chgCData(oldp+33,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixC
                                [2U][2U]),8);
        bufp->chgCData(oldp+34,(vlSelf->testbench__DOT__MatrixMath__DOT__Mat_Ouput),8);
        bufp->chgCData(oldp+35,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__OP_REGS),8);
        bufp->chgCData(oldp+36,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [0U][0U]),8);
        bufp->chgCData(oldp+37,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [0U][1U]),8);
        bufp->chgCData(oldp+38,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [0U][2U]),8);
        bufp->chgCData(oldp+39,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [1U][0U]),8);
        bufp->chgCData(oldp+40,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [1U][1U]),8);
        bufp->chgCData(oldp+41,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [1U][2U]),8);
        bufp->chgCData(oldp+42,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [2U][0U]),8);
        bufp->chgCData(oldp+43,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [2U][1U]),8);
        bufp->chgCData(oldp+44,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatA
                                [2U][2U]),8);
        bufp->chgCData(oldp+45,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [0U][0U]),8);
        bufp->chgCData(oldp+46,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [0U][1U]),8);
        bufp->chgCData(oldp+47,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [0U][2U]),8);
        bufp->chgCData(oldp+48,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [1U][0U]),8);
        bufp->chgCData(oldp+49,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [1U][1U]),8);
        bufp->chgCData(oldp+50,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [1U][2U]),8);
        bufp->chgCData(oldp+51,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [2U][0U]),8);
        bufp->chgCData(oldp+52,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [2U][1U]),8);
        bufp->chgCData(oldp+53,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatB
                                [2U][2U]),8);
        bufp->chgCData(oldp+54,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [0U][0U]),8);
        bufp->chgCData(oldp+55,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [0U][1U]),8);
        bufp->chgCData(oldp+56,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [0U][2U]),8);
        bufp->chgCData(oldp+57,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [1U][0U]),8);
        bufp->chgCData(oldp+58,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [1U][1U]),8);
        bufp->chgCData(oldp+59,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [1U][2U]),8);
        bufp->chgCData(oldp+60,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [2U][0U]),8);
        bufp->chgCData(oldp+61,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [2U][1U]),8);
        bufp->chgCData(oldp+62,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__MatC
                                [2U][2U]),8);
        bufp->chgSData(oldp+63,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__Resulting_Mat),9);
        bufp->chgBit(oldp+64,(vlSelf->testbench__DOT__MatrixMath__DOT__MatrixOps__DOT__Overfull_Error));
    }
    bufp->chgBit(oldp+65,(vlSelf->testbench__DOT__clk));
    bufp->chgBit(oldp+66,(vlSelf->testbench__DOT__rst_n));
    bufp->chgCData(oldp+67,(vlSelf->testbench__DOT__ui_in),8);
    bufp->chgCData(oldp+68,(vlSelf->testbench__DOT__uio_in),8);
    bufp->chgBit(oldp+69,((1U & (~ (IData)(vlSelf->testbench__DOT__rst_n)))));
}

void Vtestbench___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtestbench___024root__trace_cleanup\n"); );
    // Init
    Vtestbench___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtestbench___024root*>(voidSelf);
    Vtestbench__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
}
