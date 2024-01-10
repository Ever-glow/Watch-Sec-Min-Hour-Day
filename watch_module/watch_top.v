`timescale 1ns / 1ps

module watch_top(
    clk,
    reset,
	i_run_en,
	i_freq,
    o_sec,
    o_min,
    o_hour,
	o_day
    );
parameter P_COUNT_BIT = 30; // (default) 30b, under 1GHz. 2^30 = 1073741824
parameter P_SEC_BIT	 = 6; // 2^6 = 64
parameter P_MIN_BIT	 = 6; // 2^6 = 64 
parameter P_HOUR_BIT = 5; // 2^5 = 32
parameter P_DAY_BIT = 9; // 2^9 = 512 

input 							clk;
input 							reset;
input 							i_run_en;
input	[P_COUNT_BIT-1:0]		i_freq;
output 	[P_SEC_BIT-1:0]			o_sec;
output 	[P_MIN_BIT-1:0]			o_min;
output 	[P_HOUR_BIT-1:0]		o_hour;
output 	[P_DAY_BIT-1:0]			o_day;

wire w_one_sec_tick;
wire w_one_min_tick;
wire w_one_hour_tick;
wire w_one_day_tick;

// Gen one sec
one_sec_gen 
# (
	.P_COUNT_BIT	(P_COUNT_BIT) 
) u_one_sec_gen(
	.clk 				(clk			),
	.reset 				(reset			),
	.i_run_en			(i_run_en		),
	.i_freq				(i_freq			),
	.o_one_sec_tick 	(w_one_sec_tick	)
);

// count sec
tick_gen
# (
	.P_DELAY_OUT	(3),
	.P_COUNT_BIT	(P_SEC_BIT),
	.P_INPUT_CNT	(60) // 60 sec
) u_tick_gen_sec(
    .clk				(clk			),
    .reset				(reset			),
	.i_run_en			(i_run_en		),
	.i_tick				(w_one_sec_tick	),
    .o_tick_gen			(w_one_min_tick	),
    .o_cnt_val			(o_sec			)
);

// count min
tick_gen
# (
	.P_DELAY_OUT	(2),
	.P_COUNT_BIT	(P_MIN_BIT),
	.P_INPUT_CNT	(60) // 60 min
) u_tick_gen_min(
    .clk				(clk			),
    .reset				(reset			),
	.i_run_en			(i_run_en		),
	.i_tick				(w_one_min_tick	),
    .o_tick_gen			(w_one_hour_tick),
    .o_cnt_val			(o_min			)
);

// count hour
tick_gen
# (
	.P_DELAY_OUT	(1),
	.P_COUNT_BIT	(P_HOUR_BIT),
	.P_INPUT_CNT	(24) // 24 hour
) u_tick_gen_hour(
    .clk				(clk			),
    .reset				(reset			),
	.i_run_en			(i_run_en		),
	.i_tick				(w_one_hour_tick),
    .o_tick_gen			(w_one_day_tick), 
    .o_cnt_val			(o_hour			)
);

// count day
tick_gen
# (
	.P_DELAY_OUT	(0),
	.P_COUNT_BIT	(P_DAY_BIT),
	.P_INPUT_CNT	(365) // 365 day
) u_tick_gen_day(
    .clk				(clk			),
    .reset				(reset			),
	.i_run_en			(i_run_en		),
	.i_tick				(w_one_day_tick),
    .o_tick_gen			(				), // If you want to add year, you can use it.
    .o_cnt_val			(o_day			)
);

endmodule