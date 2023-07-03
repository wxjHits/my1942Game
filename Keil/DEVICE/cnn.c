#include "cnn.h"

uint32_t read_cnn_result(void){
    return CNN->CNN_Result;
}

void write_ov5640_config(uint32_t init_bus_bin_mode_ctrl,uint32_t init_bus_bin_rgb_threshold,uint32_t init_bus_bin_crbr_threshold){
    CNN->bus_bin_mode_ctrl=init_bus_bin_mode_ctrl;
    CNN->bus_bin_rgb_threshold=init_bus_bin_rgb_threshold;
    CNN->bus_bin_crbr_threshold=init_bus_bin_crbr_threshold;
}