OUTDIR="./xls_output"
rm -f $OUTDIR/*.v
mkdir -p $OUTDIR

RUN_COMMON="python3 run_xls.py --cg_reset rst"

$RUN_COMMON --cg_pipeline_stages 9 ./xls_float_ips.x xls_addf32
$RUN_COMMON --cg_pipeline_stages 9 ./xls_float_ips.x xls_subf32
$RUN_COMMON --cg_pipeline_stages 32 ./xls_float_ips.x xls_divsi32
$RUN_COMMON --cg_pipeline_stages 32 ./xls_float_ips.x xls_divui32
$RUN_COMMON --cg_pipeline_stages 32 ./xls_float_ips.x xls_divf32
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x xls_cmpf32_OEQ
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x xls_cmpf32_OGT
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x xls_cmpf32_OGE
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x xls_cmpf32_OLE
$RUN_COMMON --cg_pipeline_stages 1 ./xls_float_ips.x xls_cmpf32_OLT

cp /tmp/xls_addf32.v $OUTDIR
cp /tmp/xls_subf32.v $OUTDIR
cp /tmp/xls_divsi32.v $OUTDIR
cp /tmp/xls_divui32.v $OUTDIR
cp /tmp/xls_divf32.v $OUTDIR
cp /tmp/xls_cmpf32_OEQ.v $OUTDIR
cp /tmp/xls_cmpf32_OGT.v $OUTDIR
cp /tmp/xls_cmpf32_OGE.v $OUTDIR
cp /tmp/xls_cmpf32_OLE.v $OUTDIR
cp /tmp/xls_cmpf32_OLT.v $OUTDIR

SED='s/(__)?xls_float_ips__//g;s/vld/valid/g;s/rdy/ready/g;s/_0_next\(/\(/g'

sed -i -E $SED $OUTDIR/xls_addf32.v
sed -i -E $SED $OUTDIR/xls_subf32.v
sed -i -E $SED $OUTDIR/xls_divsi32.v
sed -i -E $SED $OUTDIR/xls_divui32.v
sed -i -E $SED $OUTDIR/xls_divf32.v
sed -i -E $SED $OUTDIR/xls_cmpf32_OEQ.v
sed -i -E $SED $OUTDIR/xls_cmpf32_OGT.v
sed -i -E $SED $OUTDIR/xls_cmpf32_OGE.v
sed -i -E $SED $OUTDIR/xls_cmpf32_OLE.v
sed -i -E $SED $OUTDIR/xls_cmpf32_OLT.v

cat $OUTDIR/xls_*.v > $OUTDIR/xls_float_ip.v
