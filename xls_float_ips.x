import std;
import apfloat;
import float32;

type F32 = float32::F32;

proc xls_addf32 {

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
        let sum = float32::add(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}

proc xls_subf32 {

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
        let sum = float32::sub(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}

proc xls_mulf32 {

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
        let sum = float32::mul(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}

proc xls_divsi32 {

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

        let signed_div = if negated { (-std::to_signed(unsigned_div)) } else {std::to_signed(unsigned_div)};

        send(join(tok_a, tok_b), result, signed_div);
    }
}


proc xls_divui32 {

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

proc xls_divf32 {

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
        let result_significant = if flag_zero { (u23:1) } else {std::iterative_div(a.fraction, b.fraction)};

        let sum = float32::unflatten(result_sign ++ result_exp ++ result_significant);

        send(join(tok_a, tok_b), result, sum);
    }

}


proc xls_cmpf32_OEQ {

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
        let sum = apfloat::eq_2(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}

proc xls_cmpf32_OGT {

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
        let sum = apfloat::gt_2(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}

proc xls_cmpf32_OGE {

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
        let sum = apfloat::gte_2(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}


proc xls_cmpf32_OLE {

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
        let sum = apfloat::lte_2(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}

proc xls_cmpf32_OLT {

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
        let sum = apfloat::lt_2(a,b);
        send(join(tok_a, tok_b), result, sum);
    }
}

