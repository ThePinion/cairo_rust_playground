use core::clone::Clone;
use alexandria_math::BitShift;
use alexandria_data_structures::array_ext::ArrayTraitExt;
use alexandria_encoding::base64::Base64Encoder;
use core::debug::PrintTrait;
use core::testing;
use core::gas;
const U6_MAX: u128 = 0x3F;

fn bytes_be(val: felt252) -> Array<u8> {
    let mut result = array![];

    let mut num: u256 = val.into();
    loop {
        if num == 0 {
            break;
        }
        let (quotient, remainder) = DivRem::div_rem(
            num, 256_u256.try_into().expect('Division by 0')
        );
        result.append(remainder.try_into().unwrap());
        num = quotient;
    };
    loop {
        if result.len() >= 32 {
            break;
        }
        result.append(0_u8);
    };
    result = result.reverse();
    result
}

#[test]
#[available_gas(200000000)]
fn bench2() {
    let data: felt252 = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5;
    let data_old = data.clone();
    let initial = testing::get_available_gas();
    gas::withdraw_gas().unwrap();
    let data_old= bytes_be(data_old);
    let result_old = Base64EncoderNew::encode(data_old); 
    let gas_old = (initial - testing::get_available_gas());
    gas_old.print();
}

#[test]
#[available_gas(200000000)]
fn bench1() {
    let data: felt252 = 0x0169af1f6f99d35e0b80e0140235ec4a2041048868071a8654576223934726f5;
    let data_new = data.clone();
    let initial = testing::get_available_gas();
    // gas::withdraw_gas().unwrap();
    let result_new = Base64FeltEncoderNew::encode(data_new); 
    let gas_new = (initial - testing::get_available_gas());
    gas_new.print();
}


trait EncoderNew<T> {
    fn encode(data: T) -> Array<u8>;
}

impl Base64EncoderNew of EncoderNew<Array<u8>> {
    fn encode(data: Array<u8>) -> Array<u8> {
        let mut char_set = get_base64_char_set();
        char_set.append('+');
        char_set.append('/');
        encode_u8_array(data, char_set)
    }
}

impl Base64FeltEncoderNew of EncoderNew<felt252> {
    fn encode(data: felt252) -> Array<u8> {
        let mut char_set = get_base64_char_set();
        char_set.append('+');
        char_set.append('/');
        encode_felt(data, char_set)
    }
}

fn encode_u8_array(mut bytes: Array<u8>, base64_chars: Array<u8>) -> Array<u8> {
    let mut result = array![];
    if bytes.len() == 0 {
        return result;
    }
    let mut p: u8 = 0;
    let c = bytes.len() % 3;
    if c == 1 {
        p = 2;
        bytes.append(0_u8);
        bytes.append(0_u8);
    } else if c == 2 {
        p = 1;
        bytes.append(0_u8);
    }

    let mut i = 0;
    let bytes_len = bytes.len();
    let last_iteration = bytes_len - 3;
    loop {
        if i == bytes_len {
            break;
        }
        let n: u32 = (*bytes[i]).into() * 65536_u32
            | (*bytes[i + 1]).into() * 256_u32
            | (*bytes[i + 2]).into();
        let e1: usize = ((n / 262144) & 63).try_into().unwrap();
        let e2: usize = ((n / 4096) & 63).try_into().unwrap();
        let e3: usize = ((n / 64) & 63).try_into().unwrap();
        let e4: usize = (n & 63).try_into().unwrap();
        result.append(*base64_chars[e1]);
        result.append(*base64_chars[(e2)]);
        if i == last_iteration {
            if p == 2 {
                result.append('=');
                result.append('=');
            } else if p == 1 {
                result.append(*base64_chars[e3]);
                result.append('=');
            } else {
                result.append(*base64_chars[e3]);
                result.append(*base64_chars[e4]);
            }
        } else {
            result.append(*base64_chars[e3]);
            result.append(*base64_chars[e4]);
        }
        i += 3;
    };
    result
}

fn encode_felt(self: felt252, base64_chars: Array<u8>) -> Array<u8>{
    let mut result = array![];

    let mut num: u256 = self.into();
    if num != 0 {
        let (quotient, remainder) = DivRem::div_rem(
            num, 65536_u256.try_into().expect('Division by 0')
        );
        let remainder: usize = remainder.try_into().unwrap();
        let r3: usize = (remainder / 1024) & 63;
        let r2: usize = (remainder / 16) & 63;
        let r1: usize = (remainder * 4) & 63;
        result.append(*base64_chars[r1]);
        result.append(*base64_chars[r2]);
        result.append(*base64_chars[r3]);
        num = quotient;
    }
    loop {
        if num == 0 {
            break;
        }
        let (quotient, remainder) = DivRem::div_rem(
            num, 16777216_u256.try_into().expect('Division by 0')
        );
        let remainder: usize = remainder.try_into().unwrap();
        let r4: usize = remainder / 262144;
        let r3: usize = (remainder / 4096) & 63;
        let r2: usize = (remainder / 64) & 63;
        let r1: usize = remainder & 63;
        result.append(*base64_chars[r1]);
        result.append(*base64_chars[r2]);
        result.append(*base64_chars[r3]);
        result.append(*base64_chars[r4]);
        num = quotient;
    };
    loop {
        if result.len() >= 43 {
            break;
        }
        result.append('A');
    };
    result = result.reverse();
    result.append('=');
    result
}

fn get_base64_char_set() -> Array<u8> {
    let mut result = array![
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9'
    ];
    result
}
