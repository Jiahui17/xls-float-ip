OUTDIR="./xls_output"
rm -f $OUTDIR/*.v
mkdir -p $OUTDIR


RUN_COMMON="python3 run_xls.py --cg_reset rst --cg_flop_inputs false"

$RUN_COMMON --cg_pipeline_stages 9 ./xls_float_ips.x addf32
$RUN_COMMON --cg_pipeline_stages 9 ./xls_float_ips.x subf32
$RUN_COMMON --cg_pipeline_stages 4 ./xls_float_ips.x mulf32
$RUN_COMMON --cg_pipeline_stages 36 ./xls_float_ips.x divsi32
$RUN_COMMON --cg_pipeline_stages 36 ./xls_float_ips.x divui32
$RUN_COMMON --cg_pipeline_stages 30 ./xls_float_ips.x divf32
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_OEQ
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_OGT
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_OGE
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_OLE
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_OLT
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_UEQ
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_UGT
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_UGE
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_ULE
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x cmpf32_ULT
$RUN_COMMON --cg_pipeline_stages 5 ./xls_float_ips.x sitofp
$RUN_COMMON --cg_pipeline_stages 5 ./xls_float_ips.x fptosi
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x extf

cp /tmp/addf32.v $OUTDIR
cp /tmp/subf32.v $OUTDIR
cp /tmp/mulf32.v $OUTDIR
cp /tmp/divsi32.v $OUTDIR
cp /tmp/divui32.v $OUTDIR
cp /tmp/divf32.v $OUTDIR
cp /tmp/cmpf32_OEQ.v $OUTDIR
cp /tmp/cmpf32_OGT.v $OUTDIR
cp /tmp/cmpf32_OGE.v $OUTDIR
cp /tmp/cmpf32_OLE.v $OUTDIR
cp /tmp/cmpf32_OLT.v $OUTDIR
cp /tmp/cmpf32_UEQ.v $OUTDIR
cp /tmp/cmpf32_UGT.v $OUTDIR
cp /tmp/cmpf32_UGE.v $OUTDIR
cp /tmp/cmpf32_ULE.v $OUTDIR
cp /tmp/cmpf32_ULT.v $OUTDIR
cp /tmp/fptosi.v $OUTDIR
cp /tmp/sitofp.v $OUTDIR
cp /tmp/extf.v $OUTDIR

cat $OUTDIR/*.v > $OUTDIR/xls_float_ip.v
