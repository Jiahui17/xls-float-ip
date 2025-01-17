import std;
import apfloat;
import float32;
import float64;

type F32 = float32::F32;
type F64 = float64::F64;

proc addf32 {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<F32> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<F32> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, float32::add(a,b));
    }
}

proc addf64 {

    lhs: chan<F64> in;
    rhs: chan<F64> in;
    result: chan<F64> out;

    init { () } 

    config(lhs: chan<F64> in, rhs: chan<F64> in, result: chan<F64> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, float64::add(a,b));
    }
}

proc subf32 {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<F32> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<F32> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, float32::sub(a,b));
    }
}

proc subf64 {

    lhs: chan<F64> in;
    rhs: chan<F64> in;
    result: chan<F64> out;

    init { () } 

    config(lhs: chan<F64> in, rhs: chan<F64> in, result: chan<F64> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, float64::sub(a,b));
    }
}

proc mulf32 {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<F32> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<F32> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, float32::mul(a,b));
    }
}

proc mulf64 {

    lhs: chan<F64> in;
    rhs: chan<F64> in;
    result: chan<F64> out;

    init { () } 

    config(lhs: chan<F64> in, rhs: chan<F64> in, result: chan<F64> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, float64::mul(a,b));
    }
}

proc divsi32 {

    lhs: chan<s32> in;
    rhs: chan<s32> in;
    result: chan<s32> out;

    init { () } 

    config(lhs: chan<s32> in, rhs: chan<s32> in, result: chan<s32> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);

        let sign_a = a < (s32:0);
        let sign_b = b < (s32:0);

        let unsigned_a = std::to_unsigned(a);
        let unsigned_b = std::to_unsigned(b);

        let unsigned_div = std::iterative_div(unsigned_a,unsigned_b);

        let negated = sign_a ^ sign_b;

        send(join(tok_a, tok_b), result, if negated { (-std::to_signed(unsigned_div)) } else {std::to_signed(unsigned_div)});
    }
}


proc divui32 {

    lhs: chan<u32> in;
    rhs: chan<u32> in;
    result: chan<u32> out;

    init { () } 

    config(lhs: chan<u32> in, rhs: chan<u32> in, result: chan<u32> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);

        let unsigned_div = std::iterative_div(a, b);

        send(join(tok_a, tok_b), result, unsigned_div);
    }
}

proc divf32 {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<F32> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<F32> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);

        // extract the fields from the two float numbers

        // compute the result:
        // -1 / -1 = + 1; +1 / +1 = + 1
        // -1 / +1 = - 1; +1 / -1 = - 1

        // if a_exp - b_exp <= -127: 0
        // if a_exp - b_exp > +127: inf
        // otherwise: result_exp = a_exp - b_exp + 127

        let signed_exp_s9 = ((a.bexp as s9) - (b.bexp as s9) + (s9:127));

        let flag_zero = signed_exp_s9 < (s9:0);
        let flag_inf = signed_exp_s9 > (s9:254);
        let result_sign = (a.sign != b.sign);
        let result_exp = if flag_zero { (u8:0) } else {  if flag_inf { (u8:255) } else { signed_exp_s9 as u8 } };
        let result_fraction = if flag_zero { (u23:1) } else {std::iterative_div(a.fraction, b.fraction)};

        send(join(tok_a, tok_b), result, float32::unflatten(result_sign ++ result_exp ++ result_fraction));
    }

}


proc cmpf32_OEQ {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, apfloat::eq_2(a,b));
    }
}

proc cmpf32_OGT {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, apfloat::gt_2(a,b));
    }
}

proc cmpf32_OGE {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, apfloat::gte_2(a,b));
    }
}


proc cmpf32_OLE {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, apfloat::lte_2(a,b));
    }
}

proc cmpf32_OLT {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        send(join(tok_a, tok_b), result, apfloat::lt_2(a,b));
    }
}

proc cmpf32_UEQ {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        // Returns 1 if any of the input is undefined.
        send(join(tok_a, tok_b), result, if (apfloat::is_nan(a) | apfloat::is_nan(b)) { u1:1 } else {apfloat::eq_2(a,b)});
    }
}

proc cmpf32_UGT {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        // Returns 1 if any of the input is undefined.
        send(join(tok_a, tok_b), result, if (apfloat::is_nan(a) | apfloat::is_nan(b)) {u1:1} else {apfloat::gt_2(a,b)});
    }
}

proc cmpf32_UGE {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        // Returns 1 if any of the input is undefined.
        send(join(tok_a, tok_b), result, if (apfloat::is_nan(a) | apfloat::is_nan(b)) {u1:1} else {apfloat::gte_2(a,b)});
    }
}

proc cmpf32_ULE {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        // Returns 1 if any of the input is undefined.
        send(join(tok_a, tok_b), result, if (apfloat::is_nan(a) | apfloat::is_nan(b)) {u1:1} else {apfloat::lte_2(a,b)});
    }
}

proc cmpf32_ULT {

    lhs: chan<F32> in;
    rhs: chan<F32> in;
    result: chan<u1> out;

    init { () } 

    config(lhs: chan<F32> in, rhs: chan<F32> in, result: chan<u1> out) {
        (lhs, rhs, result)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), lhs);
        let (tok_b, b) = recv(join(), rhs);
        // Returns 1 if any of the input is undefined.
        send(join(tok_a, tok_b), result, if (apfloat::is_nan(a) | apfloat::is_nan(b)) {u1:1} else { apfloat::lt_2(a,b) });
    }
}

proc sitofp {

    ins: chan<s32> in;
    outs: chan<F32> out;

    init { () } 

    config(ins: chan<s32> in, outs: chan<F32> out) {
        (ins, outs)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), ins);
        send(join(tok_a), outs, float32::from_int32(a));
    }
}

proc fptosi {

    ins: chan<F32> in;
    outs: chan<s32> out;

    init { () } 

    config(ins: chan<F32> in, outs: chan<s32> out) {
        (ins, outs)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), ins);
        send(join(tok_a), outs, float32::to_int32(a));
    }
}

proc extf {

    ins: chan<F32> in;
    outs: chan<F64> out;

    init { () } 

    config(ins: chan<F32> in, outs: chan<F64> out) {
        (ins, outs)
    }

    next(_ : ()) {
        let (tok_a, a) = recv(join(), ins);
        send(join(tok_a), outs, apfloat::upcast<float64::F64_EXP_SZ, float64::F64_FRACTION_SZ>(a));
    }
}
