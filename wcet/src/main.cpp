/*
 * main.cpp
 *
 *  Created on: May 23, 2013
 *      Author: andreu/renan
 */

#include "ELFobject.h"
#include "ELFlinker.h"
#include "boot.h"
#include "cfg.h"
#include "ipet.h"
#include "ipet_glpk.h"
#include "ipet_lpsolve.h"
#include "loopbounddetector.h"
#include "simplelbd.h"
#include "loopbound_reader.h"
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <getopt.h>
//#include "systemc.h"
#include "timing.h"
#include "cache_analisys.h"
#include "boundary_hazard_detector.h"
#include "memory_stalls_detector.h"
#include "stack_analyzer.h"
#include "MIF_converter.h"
#include "pipeline_analisys.h"
#include "automatic_lbd.h"
#include "code_specs.h"
#include "CFG_pruner.h"

//#define DEBUG_MAIN

using namespace std;

static uint32_t stack_pointer = 0;
static const char* program_name = NULL;
static char* output_file = NULL;
static char* input_file = NULL;
static char* cfg_file = NULL;
static char* loopbounds_file = NULL;
static bool print_input = false;
static bool print_output = false;
static bool single_fetch = false;
static bool no_cache = false;
static bool glpk = false;
static bool lpsolve = false;
static bool prune_retry = false;

string str_input_file;

static const char elf_ext[] = ".o";
static const char bin_ext[] = ".bin";
static const char loop_ext[] = ".lb";
static const char cfg_ext[] = ".ll.cfg";


static const struct option long_options[] = {
    { "all", required_argument, NULL, 'a'},
    { "elf", required_argument, NULL, 'e'},
    { "output", required_argument, NULL, 'o'},
    { "graph", required_argument, NULL, 'g'},
    { "stack", required_argument, NULL, 's'},
    { "solver", required_argument, NULL, 'l'},
    { "no-cache", no_argument, NULL, 'n'},
    { "s-fetch", no_argument, NULL, 'f'},
    { "help", no_argument, NULL, 'h'},
    { "dump-input", no_argument, NULL, 'd'},
    { "dump-output", no_argument, NULL, 'D'},
    { "prune-retry", no_argument, NULL, 'p'},
    { NULL, no_argument, NULL, 0}
};

static int htoi(char *p) {

    if ((p[1] == 'x') || (p[1] == 'X')) {
        return (strtol(&p[2], (char **) 0, 16));
    } else {
        return (strtol(p, (char **) 0, 16));
    }
}

/*usage params*/
static void usage(void) {
    cout << "Integrated Linker & Wcet Analyzer" << endl;
    cout << "Usage:" << endl << endl;
    cout << "\tLinker Params:" << endl;
    cout << "\t\t-e (--elf) <elffile>" << endl;
    cout << "\t\t-o (--output) <outputfile>" << endl;
    cout << "\t\t-s (--stack) <stackpointer> (optional)" << endl;
    cout << "\t\t-d (--dump-input) (dump input - optional)" << endl;
    cout << "\t\t-D (--dump-output) (dump output - optional)" << endl << endl;

    cout << "\tWcet Analyzer Params:" << endl;
    cout << "\t\t-g (--cfg) <cfgfile>" << endl;
    cout << "\t\t-n (--no-cache)" << endl;
    cout << "\t\t-l (--solver) <glpk | lpsolve>)" << endl;

    cout << "\tShortcut param (program name):" << endl;
    cout << "\t\t-a (--all) <program-name>" << endl;

    exit(EXIT_FAILURE);
}

static int parse_command_line(int argc, char** argv) {
    int c;
    const char* solver_name = NULL;

    while (1) {
        /* getopt_long stores the option index here. */
        int option_index = 0;

        c = getopt_long(argc, argv, "l:e:o:g:s:d:D:a:h:n:p",
                long_options, &option_index);

        /* Detect the end of the options. */
        if (c == -1) {
            break;
        }

        switch (c) {
            case 0:
                usage();
                break;
                //input_file = (char*) strdup(optarg);

            case 'l':
                solver_name = strdup(optarg);
                break;
            case 'a':
                program_name = strdup(optarg);
                break;
            case 'e':
                input_file = strdup(optarg);
                break;
            case 'o':
                output_file = strdup(optarg);
                break;
            case 'g':
                cfg_file = strdup(optarg);
                break;
            case 's':
                stack_pointer = htoi(optarg);
                break;
            case 'd':
                print_input = true;
                break;
            case 'D':
                print_output = true;
                break;
            case 'n':
                no_cache = true;
                break;
            case 'f':
                single_fetch = true;
                break;
            case 'p':
                prune_retry = true;
                break;
            case 'h':
                usage();
                exit(0);
        }
    }

    if (program_name) {
        str_input_file = program_name;
        input_file = new char[strlen(program_name) + strlen(elf_ext) + 1];
        output_file = new char[strlen(program_name) + strlen(bin_ext) + 1];
        cfg_file = new char[strlen(program_name) + strlen(cfg_ext) + 1];
        loopbounds_file = new char[strlen(program_name) + strlen(loop_ext) + 1];

        sprintf(input_file, "%s%s", program_name, elf_ext);
        sprintf(output_file, "%s%s", program_name, bin_ext);
        sprintf(cfg_file, "%s%s", program_name, cfg_ext);
        sprintf(loopbounds_file, "%s%s", program_name, loop_ext);
    }



    if (!input_file) {
        printf("ABORT: Undefined input file\n");
        exit(EXIT_FAILURE);
    } else {
#if defined(DEBUG_MAIN)
        printf("ELF input file at: %s\n", input_file);
#endif
    }

    if (!stack_pointer) {
        //TODO
#if defined(DEBUG_MAIN)
        printf("Undefined stack pointer, using default (0x%08X)\n", PREFERED_STACK);
#endif
        stack_pointer = linker::get_prefered_stack();
    } else {
#if defined(DEBUG_MAIN)
        printf("Stack at: 0x%08X\n", stack_pointer);
#endif
    }


    if (!output_file) {
        printf("Undefined output file (final image will not be generated)\n");
        exit(EXIT_FAILURE);
    } else {
#if defined(DEBUG_MAIN)
        printf("Output raw file at: %s\n", output_file);
#endif
    }

    if (!cfg_file) {
        printf("Undefined CFG file (wcet will not be calculated)\n");
        exit(EXIT_FAILURE);
    } else {
#if defined(DEBUG_MAIN)
        printf("CFG file at: %s\n", cfg_file);
#endif
    }

    if (loopbounds_file) {
        ifstream file(loopbounds_file);
        if (!file) {
            loopbounds_file = NULL;
            delete[] loopbounds_file;
        } else {
            file.close();
        }
    }

    if (!solver_name) {
        return 0;
    }

    if (strcmp(solver_name, "glpk") == 0) {
        glpk = true;
    } else if (strcmp(solver_name, "lpsolve") == 0) {
        lpsolve = true;
    } else {
        printf("Invalid solver backend: \n", solver_name);
        exit(EXIT_FAILURE);
    }

    delete solver_name;

    return 0;
}

static void write_to_file(const char* file_name, unsigned char *image, int size) {
    FILE* file = fopen(file_name, "w+");
    //cpu_info info;
    uint16_t cache_info[2];

    cache_info[0] = 8;
    cache_info[1] = 16;

    if (!file) {
        cerr << "output open\n";
        exit(EXIT_FAILURE);
    }

    if (!fwrite(cache_info, sizeof (uint16_t)*2, 1, file)) {
        cerr << "output writing\n";
        exit(EXIT_FAILURE);
    }

    if (!fwrite(image, size, 1, file)) {
        cerr << "output writing\n";
        exit(EXIT_FAILURE);
    }

    fclose(file);
}

int main(int argc, char *argv[]) {

    // linker actions
    int size;
    uint32_t entry;
    uint32_t initial_offset;

    parse_command_line(argc, argv);

    //initial_offset = linker::get_boot_code_size(stack_pointer);
    initial_offset = linker::get_program_alignment();

    linker::ELF_object* object = new linker::ELF_object(input_file);
    linker::ELF_linker* linker = new linker::ELF_linker(object, initial_offset);
    linker->link();

    linker->get_result()->dump_functions("functions.txt");
    //return 0;
    //linker->write_text_section_to_mif("out.mif");

    string mif_file_name = str_input_file;
    MIF_converter* mif_conv;

    mif_conv = new MIF_converter(linker->get_result());

    mif_file_name.append(".mif");
    mif_conv->dump_to_file(mif_file_name.c_str());

    mif_file_name.clear();
    mif_file_name = str_input_file;
    mif_file_name.append("-dp_sp.mif");

    mif_conv->dump_data_to_file(mif_file_name.c_str());

    //assert(false && "linker finished");

    //size = linker->get_image_size();
    //entry = linker->search_main_entry();

    //uint8_t* image = linker->convert_object_to_image();
    //linker::write_boot_code(image, entry, stack_pointer);

    //if(print_output){
    //dump_image((const char*) image, size, initial_offset);
    //}

    basic_block::set_elf_object(object);


    if (output_file) {
        //write_to_file(output_file, image, size);
        // basic_block::set_binary_image(image);
    }
#if defined(DEBUG_MAIN)
    printf("Raw image successful generated.\n");
#endif

    if (cfg_file) {

        cfg* cfg_test;

        pipeline_analisys* cfg_pipeline_analisys;
        cache_analysis *cfg_cache_analysis;

        timing *cfg_time;

        //linker::boot_instr_range* boot_range =
        //        linker::get_boot_instr_range(stack_pointer);


        // ---------- begin cfg mod ---------------

        cfg_specs *CFG_SPECS = new cfg_specs;
// 
//         bb_specs *bb_6 = new bb_specs;
//         bb_6->bb_id = 6;
//         bb_6->succ_to_remove.push_back(4);
//         bb_6->new_flow_type.insert(make_pair(7, 0));
//         bb_6->ini_addr = 64;
//         bb_6->end_addr = 75;
// 
//         bb_specs *bb_4 = new bb_specs;
//         bb_4->bb_id = 4;
//         bb_4->succ_to_remove.push_back(5);
//         bb_4->ini_addr = 56;
//         bb_4->end_addr = 59;
// 
//         bb_specs *bb_7 = new bb_specs;
//         bb_7->bb_id = 7;
//         bb_7->succ_to_remove.push_back(9);
//         bb_7->ini_addr = 76;
//         bb_7->end_addr = 79;

        //    	CFG_SPECS->bbs_to_modify.push_back(bb_6);
        //    	CFG_SPECS->bbs_to_modify.push_back(bb_4);
        //   	CFG_SPECS->bbs_to_modify.push_back(bb_7);

        // ---------- end cfg mod ---------------


        // ---------- begin code mod ------------------

//         code_specs *CODE_SPECS = new code_specs;
// 
//         CODE_SPECS->add_inst(121, 0x25004491); //nop
//         CODE_SPECS->add_inst(122, 0x08000280);
        // 	CODE_SPECS->add_inst(58, 0x08000000);
        // 	CODE_SPECS->add_inst(59, 0x88000000);

        /*	CODE_SPECS->add_inst(72, 0x86100490); // cmpeq	$br4, $r18, $r16
                CODE_SPECS->add_inst(73, 0x96000000); // paron
	
                CODE_SPECS->add_inst(74, 0x60004211); //(1) ldw	$r8 = 4[$r17]
                CODE_SPECS->add_inst(75, 0xC81FF289); //(1) add $r10 = $r9, -1
	
                CODE_SPECS->add_inst(76, 0xA0000451); // (0) ldw $r17 = 0[$r17]  
                CODE_SPECS->add_inst(77, 0x86D40411); // (0) cmple	$br5, $r17, $r16    
	
                CODE_SPECS->add_inst(78, 0x081FFC8B);	//(0)add $r50 = $r11, -1  78  
                CODE_SPECS->add_inst(79, 0x88001CCB);   //(0)add $r51 = $r11, 1   79  
	
                CODE_SPECS->add_inst(81, 0x10A0AC8A); //(0) slct  $r10 = $br5, $r50, $r10     
                CODE_SPECS->add_inst(82, 0x11A09CC9); //(0) slctf $r9  = $br5, $r51, $r9   */

        /*	
                CODE_SPECS->modify(linker->get_result());
                CODE_SPECS->modify(object);
                mif_conv->dump_to_file("code.mif");*/

        // ----------end  code mod ------------------

        // ----------NORMAL WCET ------------------

        cfg_test = new cfg(cfg_file, CFG_SPECS);
        cfg_test->dump_cfg("graph.dot", output_file);

        cfg_cache_analysis = new cache_analysis(*cfg_test);

        cfg_pipeline_analisys = new pipeline_analisys(cfg_test);
        cfg_pipeline_analisys->analize();

        cfg_test->identify_loops();
        cfg_test->print_loop_info();

        cfg_cache_analysis->analize();
        cfg_cache_analysis->log();

        cfg_time = new timing(*cfg_test);
        //cfg_time->get_basic_block_times();  //deprecated, timing comes from pipeline analysis
        cfg_time->add_cache_miss_penalty();

        cfg_test->dump_cfg_cache("cache.dot", output_file);

	
	
        loop_bound_detector* lbd;

        if (loopbounds_file) {
            lbd = new loopbound_reader(cfg_test, loopbounds_file, object);
        } else {
            //cfg_test->print_loop_info();
            //lbd = new simple_lbd(cfg_test);
            //cfg_test->print_loop_info();
            lbd = new automatic_lbd(cfg_test, object);
        }

        lbd->detect_bounds();


        /*	
                //cfg_test->print_must_cstate();
                cfg_test->print_input_rmb_cstate();
                cfg_test->print_bb_inst();
                cfg_test->dump_cfg("graph.dot", output_file);*/

        //         // hazard detection here, just for safety
        //         boundary_hazard_detector* hazard_detector = new boundary_hazard_detector(cfg_test);
        //         hazard_detector->detect();
        // 
        //         //counts loads and stores from slow memory
        //         memory_stalls_detector* stalls_detector = new memory_stalls_detector(cfg_test);
        //         stalls_detector->detect();
        // 
        //         //add the slow memory penalty
        //         cfg_time->add_slow_mem_penalty();
        // 
        //         if (no_cache || single_fetch) {
        //             cfg_time->no_cache_timing();
        //         } else {
        //             cfg_time->add_cache_miss_penalty();
        //             cfg_cache_analysis->log();
        //         }


        //stack_analyzer* s_analyzer =
        //        new stack_analyzer(image, info.get_scratchpad_size() * sizeof (uint32_t));
        // s_analyzer->analyze();

        ipet* wcet_solver;
        //ipet* wcet_solver = new ipet_glpk(cfg_test);
        if (glpk) {
            wcet_solver = new ipet_glpk(cfg_test);
        } else if (lpsolve) {
            wcet_solver = new ipet_lpsolve(cfg_test);
        } else {
            //default solver
            wcet_solver = new ipet_glpk(cfg_test);
        }

        wcet_solver->calculate_wcet();
        //wcet_solver->dump_wcet_cfg("wcet_cfg.dot");

        if (prune_retry) {

            delete cfg_pipeline_analisys;
            delete cfg_cache_analysis;
            delete cfg_time;

            CFG_pruner* pruner = new CFG_pruner(cfg_test, wcet_solver);
            pruner->prune();
            
            delete wcet_solver;

            cfg_test->clear();

            cfg_cache_analysis = new cache_analysis(*cfg_test);

            cfg_pipeline_analisys = new pipeline_analisys(cfg_test);
            cfg_pipeline_analisys->analize();

            cfg_test->identify_loops();
            cfg_test->print_loop_info();

            cfg_cache_analysis->analize();
            cfg_cache_analysis->log();

            cfg_time = new timing(*cfg_test);
            //cfg_time->get_basic_block_times();  //deprecated, timing comes from pipeline analysis
            cfg_time->add_cache_miss_penalty();
	    
	    
	    cfg_test->print_input_rmb_cstate();
//	    cfg_test->print_inst_cstate();
            
            cfg_test->dump_cfg_cache("cache.dot", output_file);

            wcet_solver = new ipet_glpk(cfg_test);
            wcet_solver->calculate_wcet();
            //wcet_solver->dump_wcet_cfg("wcet_cfg2.dot");

        }
        wcet_solver->dump_wcet_cfg("wcet_cfg.dot");

        std::ofstream wcet_file;
        wcet_file.open("wcet-value.txt");
        wcet_file << str_input_file << " : " << cfg_test->get_wcet() << endl;
        wcet_file.close();

	cfg_test->print_output_rmb_cstate();
	
	cfg_test->print_must_cstate();
	
//         cfg_test->print_inst_cstate();
	
	
        cout << str_input_file << " : " << cfg_test->get_wcet() << endl;

        cfg_test->dump_cfg_raw("result.cfg");

        //         delete hazard_detector;	

        //delete cfg_test;	--crash
        delete cfg_pipeline_analisys;
        delete cfg_cache_analysis;
        delete cfg_time;
        delete wcet_solver;
    }

    if (loopbounds_file) {
        delete[] loopbounds_file;
    }

    if (output_file) {
        //delete[] image;
    }

    delete linker;
    delete object;

    delete[] input_file;
    delete[] output_file;
    delete[] cfg_file;
}


