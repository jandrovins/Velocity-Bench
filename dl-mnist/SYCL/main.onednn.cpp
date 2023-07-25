/* Copyright (C) 2023 Intel Corporation
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom
 * the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 * OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * SPDX-License-Identifier: MIT
 */


#include "oneapi/dnnl/dnnl.hpp"
#if DNNL_GPU_RUNTIME == DNNL_RUNTIME_SYCL
#include "dnnl_sycl.hpp"
#endif

#include "conv_layer.onednn.h"
#include "dl_network_mgr.onednn.h"
#include "../common/mnist.h"
#include "../common/utils.h"
#include "../common/timing.h"
#include "../common/exec_policies.h" 
#include "../common/workload_params.h"
#include "SYCL.h"
#include "Utilities.h"
#include "CommandLineParser.h"

using namespace dl_infra::common;
using namespace dl_infra::onednn;

int main(int argc, const char** argv) {
    Timer* timer = new Timer();
    Timer* dataFileReadTimer = new Timer();

    Time wallClockStart = get_time_now();
    Time start;

    try {

        cout << endl << "\t\tWelcome to DL-MNIST workload: SYCL version." << endl << endl;
        cout << "=======================================================================" << endl;

#if defined(RUN_ON_GPU)
        sycl::device* dht = new sycl::device(sycl::gpu_selector_v);
#elif defined(RUN_ON_CPU)
        sycl::device* dht = new sycl::device(sycl::cpu_selector_v);
#else
        #error No variable RUN_ON_GPU nor RUN_ON_CPU defined
#endif

#ifdef DEVICE_TIMER  
        start = get_time_now();
#endif    
        sycl::context context(*dht);
#ifdef DEVICE_TIMER  
        timer->recordOpTimeTaken(1000, calculate_op_time_taken(start), "CREATE_SYCL_CONTEXT");
#endif    
        //auto propList = sycl::property_list{sycl::property::queue::in_order()};    
#ifdef DEVICE_TIMER  
        start = get_time_now();  
#endif     
        sycl::queue deviceQueue1(context, *dht);
#ifdef DEVICE_TIMER  
        timer->recordOpTimeTaken(1000, calculate_op_time_taken(start), "CREATE_SYCL_QUEUE");
#endif    
#ifdef DEVICE_TIMER  
        start = get_time_now();
#endif    
        //engine eng(engine::kind::gpu, 0);
        engine eng = dnnl::sycl_interop::make_engine(*dht, context);
#ifdef DEVICE_TIMER  
        timer->recordOpTimeTaken(1000, calculate_op_time_taken(start), "CREATE_ONEDNN_ENGINE");
#endif    
#ifdef DEVICE_TIMER      
        start = get_time_now();
#endif    
        //stream s(eng);
        stream s = dnnl::sycl_interop::make_stream(eng, deviceQueue1);
#ifdef DEVICE_TIMER      
        timer->recordOpTimeTaken(1000, calculate_op_time_taken(start), "CREATE_ONEDNN STREAM");
#endif
        SYCL sycl(dnnl::sycl_interop::get_queue(s).get_device());
        sycl.DisplayProperties();
        cout << "=======================================================================" << endl;
        cout << endl;

        WorkloadParams workload_params(argc, argv);

        // Since this workload is for inference, we are keeping N=1 which is the usual case for inference. 
        // We would also exercise multiple inference iterations and calculate time taken across all

        
        //                                INPUT_DIMS           FILTER_DIMS            OUTPUT_DIMS
        //                                   ||                    ||                    ||
        //                                   \/                    \/                    \/                
        //                              N    C   H   W         N    C  H  W          N    C   H   W  
        int conv_dims1[10][3][4] = {{{1,   1, 28, 28},    { 32,   1, 3, 3},     {1,  32, 26, 26}},   //LAYER 0
                                    {{1,  32, 26, 26},    { 48,  32, 3, 3},     {1,  48, 24, 24}},   //LAYER 1
                                    {{1,  48, 24, 24},    { 64,  48, 3, 3},     {1,  64, 22, 22}},   //LAYER 2
                                    {{1,  64, 22, 22},    { 80,  64, 3, 3},     {1,  80, 20, 20}},   //LAYER 3
                                    {{1,  80, 20, 20},    { 1,  80, 3, 3},      {1,  1, 18, 18}},   //LAYER 4
                                    {{1,  1, 18, 18},     {112,  1, 3, 3},      {1, 112, 16, 16}},   //LAYER 5
                                    {{1, 112, 16, 16},    {128, 112, 3, 3},     {1, 128, 14, 14}},   //LAYER 6
                                    {{1, 128, 14, 14},    {144, 128, 3, 3},     {1, 144, 12, 12}},   //LAYER 7
                                    {{1, 144, 12, 12},    {160, 144, 3, 3},     {1, 160, 10, 10}},   //LAYER 8
                                    {{1, 160, 10, 10},    {176, 160, 3, 3},     {1, 176,  8,  8}}};  //LAYER 9


        //                                INPUT_DIMS           FILTER_DIMS           OUTPUT_DIMS
        //                                   ||                    ||                    ||
        //                                   \/                    \/                    \/                
        //                             N    C   H   W        N     C  H  W          N    C  H    W  
        int conv_dims2[5][3][4] =  {{{1,   1, 28, 28},    {32,    1, 5, 5},     {1,  32, 24, 24}},   //LAYER 0
                                    {{1,  32, 24, 24},    {64,   32, 5, 5},     {1,  64, 20, 20}},   //LAYER 1
                                    {{1,  64, 20, 20},    {1,   64, 5, 5},      {1,  1, 16, 16}},   //LAYER 2
                                    {{1,  1, 16, 16},     {128,  1, 5, 5},      {1, 128, 12, 12}},   //LAYER 3
                                    {{1, 128, 12, 12},    {160, 128, 5, 5},     {1, 160,  8,  8}}};  //LAYER 4


        //                               INPUT_DIMS            FILTER_DIMS           OUTPUT_DIMS
        //                                   ||                    ||                    ||
        //                                   \/                    \/                    \/                
        //                              N    C   H   W         N    C  H  W          N    C   H   W  
        int conv_dims3[4][3][4] =  {{{1,   1, 28, 28},    { 48,   1, 7, 7},     {1,  48, 22, 22}},   //LAYER 0
                                    {{1,  48, 22, 22},    { 1,  48, 7, 7},      {1,  1, 16, 16}},   //LAYER 1
                                    {{1,  1, 16, 16},     {144,  1, 7, 7},      {1, 144, 10, 10}},   //LAYER 2
                                    {{1, 144, 10, 10},    {192, 144, 7, 7},     {1, 192,  4,  4}}};  //LAYER 3


        //                                INPUT_DIMS             FILTER_DIMS           OUTPUT_DIMS
        //                                    ||                     ||                    ||
        //                                    \/                     \/                    \/                
        //                              N     C   H   W         N      C  H  W          N     C   H   W  
        int conv_dims4[6][3][4] =  {{{1,    1, 28, 28},    {  64,    1, 3, 3},     {1,   64, 26, 26}},   //LAYER 0
                                    {{1,   64, 26, 26},    { 128,   64, 3, 3},     {1,  128, 24, 24}},   //LAYER 1
                                    {{1,  128, 24, 24},    { 256,  128, 3, 3},     {1,  256, 22, 22}},   //LAYER 2
                                    {{1,  256, 22, 22},    { 512,  256, 3, 3},     {1,  512, 20, 20}},   //LAYER 3
                                    {{1,  512, 20, 20},    {1024,  512, 3, 3},     {1, 1024, 18, 18}},  //LAYER 4
                                    {{1, 1024, 18, 18},    {2000, 1024, 3, 3},     {1, 2000, 16, 16}}};  //LAYER 5

        cout.precision(3); 

        int noOfIterations = workload_params.getNoOfIterations();
        DlNetworkMgr* dlNetworkMgr = new DlNetworkMgr(&workload_params, eng, s, timer, dataFileReadTimer);

        string networkName1_1 = "nw_1.1";
        dlNetworkMgr->createDLNetwork(networkName1_1, 10, (int *)&conv_dims1);
        
        string networkName1_2 = "nw_1.2";
        dlNetworkMgr->createDLNetwork(networkName1_2, 5, (int *)&conv_dims2);
        
        string networkName1_3 = "nw_1.3";
        dlNetworkMgr->createDLNetwork(networkName1_3, 4, (int *)&conv_dims3);

        for (int i=0; i<noOfIterations; i++) 
            dlNetworkMgr->executeInferenceRun(networkName1_1);
        for (int i=0; i<noOfIterations; i++) 
            dlNetworkMgr->executeInferenceRun(networkName1_2);
        for (int i=0; i<noOfIterations; i++) 
            dlNetworkMgr->executeInferenceRun(networkName1_3);

        string networkName2 = "nw_2";
        dlNetworkMgr->createDLNetwork(networkName2, 6, (int *)&conv_dims4);
        
        for (int i=0; i<noOfIterations; i++) 
            dlNetworkMgr->executeInferenceRun(networkName2);
#ifdef DEVICE_TIMER  
        cout << "Final time across all networks: " << timer->getTotalOpTime() << " s" << std::endl;
#endif
        delete dlNetworkMgr;
        delete timer;

        std::cout << "dl-mnist - total time for whole calculation: " << calculate_op_time_taken(wallClockStart) - dataFileReadTimer->getTotalOpTime()<< " s" << std::endl;    
    } catch (dnnl::error& e) {
        std::cout << e.what() << "\n";
        std::cout << "Workload execution failed" << std::endl;
        return -1;
    } catch (std::runtime_error& e) {
        std::cout << e.what() << "\n";
        std::cout << "Workload execution failed" << std::endl;
        return -1;
    }
};
