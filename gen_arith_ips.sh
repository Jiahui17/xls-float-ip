OUTDIR="./xls_output"
rm -f $OUTDIR/*.v
mkdir -p $OUTDIR

# Remember to "bash fetch_xls_release.sh" before

run_xls () {

  F_DSLX=$1
  MODULE_NAME=$2
  PIPELINE_STAGES=$3

  F_XLS_IR=/tmp/$MODULE_NAME.ir
  F_XLS_IR_OPT=/tmp/$MODULE_NAME.opt.ir
  F_XLS_V=/tmp/$MODULE_NAME.v

  ./xls-v*.*.*/ir_converter_main \
    --dslx_stdlib_path ./xls-v*/xls/dslx/stdlib \
    --top=$MODULE_NAME --package_name="" \
    $F_DSLX > $F_XLS_IR

  ./xls-v*.*.*/opt_main \
    $F_XLS_IR \
    > $F_XLS_IR_OPT

  ./xls-v*.*.*/codegen_main \
    --reset=rst \
    --pipeline_stages=$PIPELINE_STAGES \
    --delay_model=unit \
    --use_system_verilog=false \
    --flop_inputs=false \
    --multi_proc \
    --module_name="xls_float_ips__"$MODULE_NAME \
    --streaming_channel_valid_suffix="_vld" \
    --streaming_channel_ready_suffix="_rdy" \
    $F_XLS_IR_OPT \
    > $F_XLS_V

  cp $F_XLS_V $OUTDIR
}

run_xls ./xls_float_ips.x addf32 9
run_xls ./xls_float_ips.x subf32 9
run_xls ./xls_float_ips.x mulf32 4
run_xls ./xls_float_ips.x divsi32 36
run_xls ./xls_float_ips.x divui32 36
run_xls ./xls_float_ips.x divf32 30
run_xls ./xls_float_ips.x cmpf32_OEQ 1
run_xls ./xls_float_ips.x cmpf32_OGT 1
run_xls ./xls_float_ips.x cmpf32_OGE 1
run_xls ./xls_float_ips.x cmpf32_OLE 1
run_xls ./xls_float_ips.x cmpf32_OLT 1
run_xls ./xls_float_ips.x cmpf32_UEQ 1
run_xls ./xls_float_ips.x cmpf32_UGT 1
run_xls ./xls_float_ips.x cmpf32_UGE 1
run_xls ./xls_float_ips.x cmpf32_ULE 1
run_xls ./xls_float_ips.x cmpf32_ULT 1
run_xls ./xls_float_ips.x sitofp 5
run_xls ./xls_float_ips.x fptosi 5
run_xls ./xls_float_ips.x extf 1

cat $OUTDIR/*.v > $OUTDIR/xls_float_ip.v
